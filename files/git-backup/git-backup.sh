#!/bin/sh
#
# This program is based off of gitwatch @ https://github.com/gitwatch/gitwatch.git
# Copyright (C) 2013-2018  Patrick Lehner
#   with modifications and contributions by:
#   - Matthew McGowan
#   - Dominik D. Geyer
#   - Phil Thompson
#   - Dave Musicant
#
# Edited to work on busybox ash shell, specifically the Creality K1 & K1Max
#############################################################################
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
#
#   Idea and original code taken from http://stackoverflow.com/a/965274
#       original work by Lester Buck
#       (but heavily modified by now)
#
#   Requires the command 'inotifywait' to be available, which is part of
#   the inotify-tools (See https://github.com/rvoicilas/inotify-tools ),
#   and (obviously) git.
#   Will check the availability of both commands using the `which` command
#   and will abort if either command (or `which`) is not found.
#

white=`echo -en "\033[m"`
yellow=`echo -en "\033[1;33m"`
green=`echo -en "\033[01;32m"`

INSTALL=0
PAUSE=0
RESUME=0
STOP=0
REMOTE=""
BRANCH=""
TARGET=""
EVENTS="${EVENTS:-close_write,move,move_self,delete,create,modify}"
SLEEP_TIME=5
DATE_FMT="+%d-%m-%Y (%H:%M:%S)"
COMMITMSG="Auto-commit on %d by Git Backup"
SKIP_IF_MERGING=0

# Function to print script help
shelp() {
    echo "Usage: $(basename "$0") [-i] [-p] [-r] [-s] -b branch -t target -g remote"
    echo "Options:"
    echo "  -i              Install"
    echo "  -p              Pause"
    echo "  -r              Resume"
    echo "  -s              Stop"
    echo "  -b branch       Specify branch for git push"
    echo "  -t target       Specify target directory or file to watch"
    echo "  -g remote       Specify remote for git push"
}

# Parse command-line arguments
while getopts "iprsb:t:g:hn" option; do
    case "${option}" in
        i) INSTALL=1 ;;
        p) PAUSE=1 ;;
        r) RESUME=1 ;;
        s) STOP=1 ;;
        b) BRANCH="${OPTARG}" ;;
        t) TARGET="${OPTARG}" ;;
        g) REMOTE="${OPTARG}" ;;
        h) 
            shelp
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            shelp
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            shelp
            exit 1
            ;;
        *)
            shelp
            exit 0
            ;;
    esac
done

# Check if more than one flag is used
if [ "$((INSTALL + PAUSE + RESUME + STOP))" -gt 1 ]; then
    echo "Error: Only one flag is allowed at a time."
    shelp
    exit 1
fi

# Pause, Resume, Stop flags
if [ "$PAUSE" = 1 ]; then
    echo "Info: Pausing automatic backups until the next reboot or manually restarted..."
    /etc/init.d/S52Git-Backup stop
    exit 0
elif [ "$STOP" = 1 ]; then
    echo "Info: Stopping automatic backups until manually restarted..."
    mv /etc/init.d/S52Git-Backup /etc/init.d/disabled.S52Git-Backup
    exit 0
elif [ "$RESUME" = 1 ]; then
    echo "Info: Resuming automatic backups..."
    mv /etc/init.d/disabled.S52Git-Backup /etc/init.d/S52Git-Backup
    exit 0
elif [ "$INSTALL" = 1 ]; then
    # Install required packages using opkg
    if [ -f /opt/bin/opkg ]; then
        /opt/bin/opkg update
        /opt/bin/opkg install inotifywait procps-ng-pkill
    else
        echo "Error: opkg package manager not found. Please install Entware."
        exit 1
    fi
    
    # Prompt user for configuration
    echo "${white}"
    read -p " Please enter your ${green}GitHub username${white} and press Enter: ${yellow}" USER_NAME
    echo "${white}"
    read -p " Please enter your ${green}GitHub repository name${white} and press Enter: ${yellow}" REPO_NAME
    echo "${white}"
    read -p " Please enter your ${green}GitHub personal access token${white} and press Enter: ${yellow}" GITHUB_TOKEN
    echo "${white}"
    
    # Prompt user to select folders to be watched
    IFS=/usr/data/printer_data/config
    
    # Connect config directory to github
    cd "$IFS" || exit
    git init
    git remote add origin "https://$USER_NAME:$GITHUB_TOKEN@github.com/$USER_NAME/$REPO_NAME.git"
    git checkout -b "$BRANCH"
    git add .
    git commit -m "Initial Backup"
    git push -u origin "$BRANCH"
    
    # Write configuration to .env file
    echo "IFS=$IFS" > "$IFS/.env"
    echo "GITHUB_TOKEN=$GITHUB_TOKEN" >> "$IFS/.env"
    echo "REMOTE=$REPO_NAME" >> "$IFS/.env"
    echo "BRANCH=$BRANCH" >> "$IFS/.env"
    echo "USER=$USER_NAME" >> "$IFS/.env"

    # Create .gitignore file to protect .env variables
    echo ".env" > "$IFS/.gitignore"
    
    # Insert .env to S52gitwatch.sh and move to init.d
    cp -f /usr/data/helper-script/files/git-backup/S52Git-Backup /etc/init.d/S52Git-Backup
    sed -i "2i source $IFS/.env" /etc/init.d/S52Git-Backup
    chmod +x /etc/init.d/S52Git-Backup
    /etc/init.d/S52Git-Backup start
    
    exit 0
fi

# print all arguments to stderr
stderr() {
  echo "$@" >&2
}

# clean up at end of program, killing the remaining sleep process if it still exists
cleanup() {
  if [ -n "$SLEEP_PID" ] && kill -0 "$SLEEP_PID" 2>/dev/null; then
    kill "$SLEEP_PID" 2>/dev/null
  fi
  exit 0
}

# Tests for the availability of a command
is_command() {
  command -v "$1" >/dev/null 2>&1
}

# Test whether or not current git directory has ongoing merge
is_merging () {
  [ -f "$(git rev-parse --git-dir)"/MERGE_HEAD ]
}

shift $((OPTIND - 1)) # Shift the input arguments, so that the input file (last arg) is $1 in the code below

GIT="git"
RL="readlink"
INW="inotifywait"

# Check availability of selected binaries and die if not met
for cmd in "$GIT" "$INW"; do
  is_command "$cmd" || {
    stderr "Error: Required command '$cmd' not found."
    exit 2
  }
done

SLEEP_PID="" # pid of timeout subprocess

trap "cleanup" EXIT # make sure the timeout is killed when exiting script

# Expand the path to the target to absolute path
if [ "$(uname)" != "Darwin" ]; then
  IN=$($RL -f "$TARGET")
else
  if is_command "greadlink"; then
    IN=$(greadlink -f "$TARGET")
  else
    IN=$($RL -f "$TARGET")
    if [ $? -eq 1 ]; then
      echo "Info: Seems like your readlink doesn't support '-f'. Running without. Please 'brew install coreutils'."
      IN=$($RL "$TARGET")
    fi
  fi
fi

if [ -d "$TARGET" ]; then # if the target is a directory

  TARGETDIR=$(echo "$IN" | sed -e "s/\/*$//") # dir to CD into before using git commands: trim trailing slash, if any

  # construct inotifywait-commandline
  if [ "$(uname)" != "Darwin" ]; then
    INW_ARGS="-qmr -e $EVENTS $TARGETDIR"
  fi
  GIT_ADD="git add -A ." # add "." (CWD) recursively to index
  GIT_COMMIT_ARGS="-a"     # add -a switch to "commit" call just to be sure

else
  stderr "Error: The target is neither a regular file nor a directory."
  exit 3
fi

# CD into the right dir
cd "$TARGETDIR" || {
  stderr "Error: Can't change directory to '${TARGETDIR}'."
  exit 5
}

if [ -n "$REMOTE" ]; then        # are we pushing to a remote?
  if [ -z "$BRANCH" ]; then      # Do we have a branch set to push to ?
    PUSH_CMD="$GIT push $REMOTE" # Branch not set, push to remote without a branch
  else
    # check if we are on a detached HEAD
    if HEADREF=$($GIT symbolic-ref HEAD 2> /dev/null); then # HEAD is not detached
      PUSH_CMD="$GIT push $REMOTE ${HEADREF#refs/heads/}:$BRANCH"
    else # HEAD is detached
      PUSH_CMD="$GIT push $REMOTE $BRANCH"
    fi
  fi
else
  PUSH_CMD="" # if no remote is selected, make sure the push command is empty
fi

# main program loop: wait for changes and commit them
#   whenever inotifywait reports a change, we spawn a timer (sleep process) that gives the writing
#   process some time (in case there are a lot of changes or w/e); if there is already a timer
#   running when we receive an event, we kill it and start a new one; thus we only commit if there
#   have been no changes reported during a whole timeout period
# Custom timeout function
# main program loop: wait for changes and commit them
# Custom timeout function
timeout() {
  sleep "5" &
  timeout_pid=$!
  trap "kill $timeout_pid 2>/dev/null" EXIT
  wait $timeout_pid 2>/dev/null
}

while true; do
  # Start inotifywait to monitor changes
  eval "$INW $INW_ARGS" | while read -r line; do
    # Check if there were any changes reported during the timeout period
    if [ -n "$line" ]; then
      # Process changes
      if [ -n "$DATE_FMT" ]; then
        COMMITMSG=$(echo "$COMMITMSG" | awk -v date="$(date "$DATE_FMT")" '{gsub(/%d/, date)}1') # splice the formatted date-time into the commit message
      fi

      cd "$TARGETDIR" || {
        stderr "Error: Can't change directory to '${TARGETDIR}'."
        exit 6
      }
      STATUS=$($GIT status -s)
      if [ -n "$STATUS" ]; then # only commit if status shows tracked changes.
        if [ "$SKIP_IF_MERGING" -eq 1 ] && is_merging; then
          echo "Skipping commit - repo is merging"
          continue
        fi

        $GIT_ADD # add file(s) to index
        $GIT commit $GIT_COMMIT_ARGS -m "$COMMITMSG" # construct commit message and commit

        if [ -n "$PUSH_CMD" ]; then
          echo "Push command is $PUSH_CMD"
          eval "$PUSH_CMD"
          pkill 'inotifywait'
          timeout
        fi
      fi
    fi
  done
done
