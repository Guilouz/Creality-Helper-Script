#!/bin/sh
#
# This program is based off of gitwatch @ https://github.com/gitwatch/gitwatch.git
# Copyright (C) 2013-2018  Patrick Lehner
#   with modifications and contributions by:
#   - Matthew McGowan
#   - Dominik D. Geyer
#   - Phil Thompson
#   - Dave Musicant
#   - Guislain Cyril

white=`echo -en "\033[m"`
yellow=`echo -en "\033[1;33m"`
green=`echo -en "\033[01;32m"`
darkred=`echo -en "\033[31m"`

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
COMMITMSG="Auto-commit by Git Backup"
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
    if [ -f mv /etc/init.d/S52Git-Backup ];then
        mv /etc/init.d/S52Git-Backup /etc/init.d/disabled.S52Git-Backup
    fi
    /etc/init.d/S52Git-Backup stop
    exit 0
elif [ "$RESUME" = 1 ]; then
    echo "Info: Resuming automatic backups..."
    if [ -f /etc/init.d/disabled.S52Git-Backup ];then
        mv /etc/init.d/disabled.S52Git-Backup /etc/init.d/S52Git-Backup
    fi
    /etc/init.d/S52Git-Backup start
    exit 0
elif [ "$INSTALL" = 1 ]; then
    # Install required packages using opkg
    if [ -f /opt/bin/opkg ]; then
        /opt/bin/opkg update
        /opt/bin/opkg install inotifywait
    else
        echo
        echo "${white}${darkred} ✗ opkg package manager not found. Please install Entware.${white}"
        echo
        exit 1
    fi
    
    # Prompt user for configuration
    echo "${white}"
    read -p " Please enter your ${green}GitHub username${white} and press Enter: ${yellow}" USER_NAME
    while [ -z "$USER_NAME" ]; do
        echo "${white}"
        echo "${darkred} ✗ Invalid GitHub username!${white}"
        echo
        read -p " Please enter your ${green}GitHub username${white} and press Enter: ${yellow}" USER_NAME
    done
    valid_email=false
    while [ "$valid_email" != true ]; do
        echo "${white}"
        read -p " Please enter your ${green}GitHub email address${white} and press Enter: ${yellow}" USER_MAIL
        echo "$USER_MAIL" | grep -E -q "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        if [ $? -ne 0 ]; then
            echo "${white}"
            echo "${darkred} ✗ Invalid email address!${white}"
        else
            valid_email=true
        fi
    done
    echo "${white}"
    read -p " Please enter your ${green}GitHub repository name${white} and press Enter: ${yellow}" REPO_NAME
    while [ -z "$REPO_NAME" ]; do
        echo "${white}"
        echo "${darkred} ✗ Invalid GitHub repository name!${white}"
        echo
        read -p " Please enter your ${green}GitHub repository name${white} and press Enter: ${yellow}" REPO_NAME
    done
    echo "${white}"
    read -p " Please enter your ${green}GitHub branch name${white} and press Enter: ${yellow}" REPO_BRANCH
    while [ -z "$REPO_BRANCH" ]; do
        echo "${white}"
        echo "${darkred} ✗ Invalid GitHub branch name!${white}"
        echo
        read -p " Please enter your ${green}GitHub branch name${white} and press Enter: ${yellow}" REPO_BRANCH
    done
    echo "${white}"
    read -p " Please enter your ${green}GitHub personal access token${white} and press Enter: ${yellow}" GITHUB_TOKEN
    while [ -z "$GITHUB_TOKEN" ]; do
        echo "${white}"
        echo "${darkred} ✗ Invalid GitHub personal access token!${white}"
        echo
        read -p " Please enter your ${green}GitHub personal access token${white} and press Enter: ${yellow}" GITHUB_TOKEN
    done
    echo "${white}"
    
    # Folder to be watched
    IFS=/usr/data/printer_data/config
    
    # Connect config directory to github
    cd "$IFS" || exit
    git config --global user.name "$USER_NAME"
    git config --global user.email "$USER_MAIL"
    git init
    git remote add origin "https://$USER_NAME:$GITHUB_TOKEN@github.com/$USER_NAME/$REPO_NAME.git"
    git checkout -b "$REPO_BRANCH"
    git add .
    git commit -m "Initial Backup"
    push_repo=$(git push -u origin "$REPO_BRANCH" 2>&1)
    if echo "$push_repo" | grep -q "fatal: remote origin already exists"; then
        echo
        rm -rf /usr/data/printer_data/config/.git
        killall -q inotifywait >/dev/null 2>&1
        /opt/bin/opkg --autoremove remove inotifywait >/dev/null 2>&1
        echo "${white}${darkred} ✗ A branch named $REPO_BRANCH already exists!"
        echo "   Use another branch name or clean your repo and restart Git Backup installation.${white}"
        echo
        exit 0
    elif echo "$push_repo" | grep -q "remote: error: GH007"; then
        echo
        rm -rf /usr/data/printer_data/config/.git
        killall -q inotifywait >/dev/null 2>&1
        /opt/bin/opkg --autoremove remove inotifywait >/dev/null 2>&1
        echo "${white}${darkred} ✗ Your push would publish a private email address!"
        echo "   You can use another email address or make this one public"
        echo "   or disable this protection by visiting: http://github.com/settings/emails${white}"
        echo
        exit 0
    elif echo "$push_repo" | grep -q "error: failed to push some refs to"; then
        echo
        rm -rf /usr/data/printer_data/config/.git
        killall -q inotifywait >/dev/null 2>&1
        /opt/bin/opkg --autoremove remove inotifywait >/dev/null 2>&1
        echo "${white}${darkred} ✗ Your repository already contains commits and files cannot be merged!"
        echo "   Please clean your repo and restart Git Backup installation.${white}"
        echo
        exit 0
    elif echo "$push_repo" | grep -q "remote: Repository not found"; then
        echo
        rm -rf /usr/data/printer_data/config/.git
        killall -q inotifywait >/dev/null 2>&1
        /opt/bin/opkg --autoremove remove inotifywait >/dev/null 2>&1
        echo "${white}${darkred} ✗ Your repository was not found!"
        echo "   Check your provided information and restart Git Backup installation.${white}"
        echo
        exit 0
    elif echo "$push_repo" | grep -q "fatal: Authentication failed"; then
        echo
        rm -rf /usr/data/printer_data/config/.git
        killall -q inotifywait >/dev/null 2>&1
        /opt/bin/opkg --autoremove remove inotifywait >/dev/null 2>&1
        echo "${white}${darkred} ✗ Authentication failed!"
        echo "   Check your GitHub personal access token and restart Git Backup installation.${white}"
        echo
        exit 0
    else
        git push -u origin "$REPO_BRANCH" 
    fi
    
    # Write configuration to .env file
    if [ ! -d /usr/data/helper-script-backup/git-backup ]; then
        mkdir -p /usr/data/helper-script-backup/git-backup
    fi
    ENV=/usr/data/helper-script-backup/git-backup/.env
    echo "IFS=$IFS" > "$ENV"
    echo "GITHUB_TOKEN=$GITHUB_TOKEN" >> "$ENV"
    echo "REMOTE=$REPO_NAME" >> "$ENV"
    echo "BRANCH=$REPO_BRANCH" >> "$ENV"
    echo "USER=$USER_NAME" >> "$ENV"
    
    # Insert .env to init.d
    echo "Info: Copying file..."
    cp -f /usr/data/helper-script/files/git-backup/S52Git-Backup /etc/init.d/S52Git-Backup
    sed -i "2i source $ENV" /etc/init.d/S52Git-Backup
    echo "Info: Linking file..."
    ln -sf /usr/data/helper-script/files/git-backup/git-backup.cfg /usr/data/printer_data/config/Helper-Script/git-backup.cfg
    if grep -q "include Helper-Script/git-backup" /usr/data/printer_data/config/printer.cfg ; then
        echo "Info: Git Backup configurations are already enabled in printer.cfg file..."
    else
        echo "Info: Adding Git Backup configurations in printer.cfg file..."
        sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/git-backup\.cfg\]' /usr/data/printer_data/config/printer.cfg
    fi
    echo "Info: Starting Git Backup service..."
    chmod +x /etc/init.d/S52Git-Backup
    /etc/init.d/S52Git-Backup start >/dev/null 2>&1
    echo "Info: Restarting Klipper service..."
    /etc/init.d/S55klipper_service start
    echo
    echo "${white}${green} ✓ Git Backup has been installed and configured successfully!${white}"
    echo
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
        COMMITMSG=$(echo "$COMMITMSG") # splice the formatted date-time into the commit message
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
          killall -q inotifywait
          timeout
        fi
      fi
    fi
  done
done
