#!/bin/sh

#
# Installation script for mobileraker companion.
#
# Based on OctoEverywhere for Klipper, courtesy of Quinn Damerell
# OctoEverywhere: https://octoeverywhere.com
#

set -e

#
# First things first, we need to detect what kind of OS we are running on. The script works by default with all
# Debian OSs, but some printers with embedded computers run strange embedded OSs, that have a lot of restrictions.
# These must stay in sync with update.sh and uninstall.sh!
#

# The K1 and K1 Max run an OS called Buildroot. We detect that by looking at the os-release file.
# Quick note about bash vars, to support all OSs, we use the most compilable var version. This means we use ints
# where 1 is true and 0 is false, and we use comparisons like this [ "$IS_K1_OS" -eq 1 ]
IS_K1_OS=0
if grep -Fqs "ID=buildroot" /etc/os-release; then
    IS_K1_OS=1
    # On the K1, we always want the path to be /usr/data
    # /usr/share has very limited space, so we don't want to use it.
    # This is also where the github script installs moonraker and everything.
    HOME="/usr/data"
fi

# Next, we try to detect if this OS is the Sonic Pad OS.
# The Sonic Pad runs openwrt. We detect that by looking at the os-release file.
IS_SONIC_PAD_OS=0
if grep -Fqs "sonic" /etc/openwrt_release; then
    IS_SONIC_PAD_OS=1
    # On the K1, we always want the path to be /usr/share, this is where the rest of the klipper stuff is.
    HOME="/usr/share"
fi

# Get the path where this script is executing
SCRIPT_DIR=$(readlink -f "$(dirname "$0")")
REPO_DIR=$(readlink -f "$SCRIPT_DIR/..")

# This is the root of where our py virtual env will be. Note that all instances share this same
# virtual environment. This how the rest of the system is, where all other services, even with multiple instances, share the same
# virtual environment. I probably wouldn't have done it like this, but we have to create this before we know what instance we are targeting, so it's fine.
ENV_DIR="${HOME}/mobileraker-env"

# Note that this is parsed by the update process (Of Moonraker) to find and update required system packages on update!
# On update THIS SCRIPT ISN'T RAN, only this line is parsed out and used to install / update system packages.
# For python packages, the `requirements.txt` package is used on update.
# This var name MUST BE `PKGLIST`!!
#
# The python requirements are for the installer and plugin
# The virtualenv is for our virtual package env we create
# The curl requirement is for some things in this bootstrap script.
PKGLIST="python3 python3-pip virtualenv curl"
# For the Creality OS, we only need to install these.
# We don't override the default name, since that's used by the Moonraker installer
# Note that we DON'T want to use the same name as above (not even in this comment) because some parsers might find it.
SONIC_PAD_DEP_LIST="python3 python3-pip"
CREALITY_DEP_LIST="python3 python3-pillow python3-pip"


#
# Console Write Helpers
#
c_default=$(printf "\033[39m")
c_green=$(printf "\033[92m")
c_yellow=$(printf "\033[93m")
c_magenta=$(printf "\033[35m")
c_red=$(printf "\033[91m")
c_cyan=$(printf "\033[96m")

log_header()
{
    printf "%s\n" "${c_magenta}$1${c_default}"
}

log_important()
{
    printf "%s\n" "${c_yellow}$1${c_default}"
}

log_error()
{
    log_blank
    printf "%s\n" "${c_red}$1${c_default}"
    log_blank
}

log_info()
{
    printf "%s\n" "${c_green}$1${c_default}"
}

log_blue()
{
    printf "%s\n" "${c_cyan}$1${c_default}"
}

log_blank()
{
    printf "\n"
}

#
# It's important for consistency that the repo root is in set $HOME for the K1 and Sonic Pad
# To enforce that, we will move the repo where it should be.
ensure_creality_os_right_repo_path()
{
    # TODO - re-enable this for the  || [ "$IS_K1_OS" -eq 1 ] after the github script updates.
    if [ "$IS_SONIC_PAD_OS" -eq 1 ] || [ "$IS_K1_OS" -eq 1 ]; then
        # Due to the K1 shell, we have to use grep rather than any bash string contains syntax.
        if echo "$REPO_DIR" | grep "$HOME" - > /dev/null; then
            return
        else
            log_info "Current path $REPO_DIR"
            log_error "For the Creality devices the mobileraker_companion repo must be cloned into $HOME/mobileraker_companion"
            log_important "Moving the repo and running the install again..."
            cd "$HOME" || exit 1
            # Send errors to null, if the folder already exists this will fail.
            git clone https://github.com/Clon1998/mobileraker_companion.git mobileraker_companion 2>/dev/null || true
            cd "$HOME/mobileraker_companion" || exit 1
            # Ensure state
            git reset --hard
            # TODO: I dont want to checkout main. Just keep the current branch.
            #git checkout main
            git pull
            # Log the current path after git pull        
            log_info "Current path $(pwd)"
            # Run the install, if it fails, still do the clean-up of this repo.
            if [ "$IS_K1_OS" -eq 1 ]; then
                sh "$HOME/mobileraker_companion/scripts/install.sh" "$@" || true
            else
                "$HOME/mobileraker_companion/scripts/install.sh" "$@" || true
            fi
            installExit=$?
            # Delete this folder.
            log_info "Cleaning up the old repo folder. The new repo is in $HOME/mobileraker_companion"
            rm -fr "$REPO_DIR"
            # Take the user back to the new install folder.
            cd "$HOME" || exit 1
            # Exit.
            exit "$installExit"
        fi
    fi
}

#
# Logic to create / update our virtual py env
#
ensure_py_venv()
{
    log_header "Checking Python Virtual Environment For Mobileraker Companion..."
    # If the service is already running, we can't recreate the virtual env so if it exists, don't try to create it.
    # Note that we check the bin folder exists in the path, since we mkdir the folder below but virtualenv might fail and leave it empty.
    ENV_BIN_PATH="$ENV_DIR/bin"
    if [ -d "$ENV_BIN_PATH" ]; then
        # This virtual env refresh fails on some devices when the service is already running, so skip it for now.
        # This only refreshes the virtual environment package anyways, so it's not super needed.
        #log_info "Virtual environment found, updating to the latest version of python."
        #python3 -m venv --upgrade "${ENV_DIR}"
        return 0
    fi

    log_info "No virtual environment found, creating one now."
    mkdir -p "${ENV_DIR}"
    if [ "$IS_K1_OS" -eq 1 ]; then
        # The K1 requires we setup the virtualenv like this.
        if [[ -f /opt/bin/python3 ]]; then
            virtualenv -p /opt/bin/python3 --system-site-packages "${ENV_DIR}"
        else
            python3 /usr/lib/python3.8/site-packages/virtualenv.py -p /usr/bin/python3 --system-site-packages "${ENV_DIR}"
        fi
    else
        # Everything else can use this more modern style command.
        virtualenv -p /usr/bin/python3 --system-site-packages "${ENV_DIR}"
    fi
}

#
# Logic to make sure all of our required system packages are installed.
#
install_or_update_system_dependencies()
{
    log_header "Checking required system packages are installed..."

    if [ "$IS_K1_OS" -eq 1 ]; then
        # The K1 by default doesn't have any package manager. In some cases
        # the user might install opkg via the 3rd party moonraker installer script.
        # But in general, PY will already be installed, so there's no need to try.
        # On the K1, the only we thing we ensure is that virtualenv is installed via pip.
        if [[ -f /opt/bin/opkg ]]; then
            opkg update || true
            opkg install ${CREALITY_DEP_LIST}
        fi
        pip3 install --trusted-host pypi.python.org --trusted-host pypi.org --trusted-host=files.pythonhosted.org --no-cache-dir virtualenv
    elif [ "$IS_SONIC_PAD_OS" -eq 1 ]; then
        # The sonic pad always has opkg installed, so we can make sure these packages are installed.
        opkg update || true
        opkg install ${SONIC_PAD_DEP_LIST}
        pip3 install virtualenv
    else
        # It seems a lot of printer control systems don't have the date and time set correctly, and then the fail
        # getting packages and other downstream things. We will will use our HTTP API to set the current UTC time.
        # Note that since cloudflare will auto force http -> https, we use https, but ignore cert errors, that could be
        # caused by an incorrect date.
        # Note some companion systems don't have curl installed, so this will fail.
        log_info "Ensuring the system date and time is correct..."
        
        log_important "You might be asked for your system password - this is required to install the required system packages."
        # Thanks to Quinn Damerell for allowing us to use the OctoEverywhere API for this.
        sudo date -s "$(curl --insecure 'https://octoeverywhere.com/api/util/date' 2>/dev/null)" || true

        # These we require to be installed in the OS.
        # Note we need to do this before we create our virtual environment
    
        log_info "Installing required system packages. This can take a few minutes..."
        sudo apt update 1>/dev/null 2>/dev/null || true
        sudo apt install --yes ${PKGLIST}

        # The PY lib Pillow depends on some system packages that change names depending on the OS.
        # The easiest way to do this was just to try to install them and ignore errors.
        # Most systems already have the packages installed, so this only fixes edge cases.
        # Notes on Pillow deps: https://pillow.readthedocs.io/en/latest/installation.html
        log_info "Ensuring zlib is install for Pillow, it's ok if this package install fails."
        sudo apt install --yes zlib1g-dev 2> /dev/null || true
        sudo apt install --yes zlib-devel 2> /dev/null || true
        sudo apt install --yes libjpeg62-turbo-dev 2> /dev/null || true
        sudo apt install --yes libjpeg8-dev 2> /dev/null || true
    fi
    log_blank
    log_info "System package install complete."
}

#
# Logic to install or update the virtual env and all of our required packages.
#
install_or_update_python_env()
{
    # Now, ensure the virtual environment is created.
    ensure_py_venv

    # Update pip if needed - we added a note because this takes a while on the sonic pad.
    log_info "Updating PIP if needed... (this can take a few seconds or so)"
    if [ "$IS_K1_OS" -eq 1 ]; then
        "${ENV_DIR}"/bin/python -m pip install --trusted-host pypi.python.org --trusted-host pypi.org --trusted-host=files.pythonhosted.org --no-cache-dir --upgrade pip
    else
        "${ENV_DIR}"/bin/python -m pip install --upgrade pip
    fi

    # Set the cache directory based on the OS
    CACHE_DIR="${ENV_DIR}/cache"

    # Finally, ensure our plugin requirements are installed and updated.
    log_info "Installing or updating required python libs..."
    if [ "$IS_K1_OS" -eq 1 ]; then
        TMPDIR="${CACHE_DIR}" "${ENV_DIR}"/bin/pip3 install --trusted-host pypi.python.org --trusted-host pypi.org --trusted-host=files.pythonhosted.org -q -r "${SCRIPT_DIR}"/mobileraker-requirements.txt
    else
        TMPDIR="${CACHE_DIR}" "${ENV_DIR}"/bin/pip3 install -q -r "${SCRIPT_DIR}"/mobileraker-requirements.txt
    fi
    log_info "Python libs installed."
}

log_blank
log_blank
log_blank
cat << EOF
MMMMMMMMMMMMMMMMMMMMMMWNX0xolldk0XWWMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMWNKkdl:;;:;,,',:ldk0XWMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMWNX0xoc;,;:ldxxxxdoc:,'',:lxOKNWWMMMMMMMMMM
MMMMMMMMMWNKOxl:;,;codxkkdooddxxkkdol:;''';coxOXWMMMMMMM
MMMMMMWXOdl:,,:loxkkkdoloodxkOOkxxxxkkxdlc;''',:lkXWMMMM
MMMMMWk:,,,,,:x0OdoloddxxxddxkkOOOOkxddxkOOl''''',cOWMMM
MMMMMWOc,,,,,,:lddxkkxdollllodddxxkO000kkxo:'''''':OWMMM
MMMMWXOkxo:;,,,,,;loddooodxO0KK0Okkkkkdl;,'''',:odkOXWMM
MMMWXo;:ldxxdl:,,',,,:clx0NWWWWNKkoc;,''''';ldxxoc;,lKMM
MMMMNx:,,,;coxkxoc;,,,,,;cokkkdl;,''''',:odxdl:,''':kNMM
MMMWXK0xl:,,,,:lxkkdl:,,,,,,'''''''';ldxxoc,'''';lx0KXWM
MMNkc:ok00koc,,,,;cdkkxoc;,''''',codxdl:,'''';lxOkdc;l0W
MMXo,',,;lxO0kdc;,,,;:oxOkxlccldxxoc,'''',:lxkko:,''',xW
MMWKo:,,,,,;ldO0Odl;,,,,;ldkkxdl;,'''',:oxkxo:,''''';dKW
MMMMNKxl;,,,,,;cdO00xo:,,,,,,,''''',coxkdl;'''''';lkKWMM
MMMMMMWNKxl:,,,,,,:ok00koc;,'''';ldkkdc,'''''';lxKWMMMMM
MMMMMMMMMMNKxo:,,,,,,:ok00Odlcoxkxo:,'''''';lkKNMMMMMMMM
MMMMMMMMMMMMWNKkl:,,,,,,;lxOOkxl:,'''''';lkKWMMMMMMMMMMM
MMMMMMMMMMMMMMMWNKkl:,,,,,,;;,''''''';lkKWMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMWNKko:,,,,'''''';lkKWMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMWNKko:,'',;lkKWMMMMMMMMMMMMMMMMMMMM
MMMMMMMMMMMMMMMMMMMMMMMMMWKkddkKWMMMMMMMMMMMMMMMMMMMMMMM
EOF
log_blank
log_important "                  Mobileraker Companion"
log_blue      " Companion for Mobileraker, enabling push notification for Klipper using Moonraker."
log_info      " - Installer Script based on OctoEverywhere for Klipper, courtesy of Quinn Damerell"
log_blank
log_blank
log_important "Mobileraker works as a simple UI for Klipper on the phone."
log_important "The companion is required to enable reliable push notifications."
log_info      "  - Print State Notifications"
log_info      "  - Progress Notifications"
log_info      "  - Custom Notifications via M117 or custom Macro enabling layer based notifications or heat up notifications."
log_blank
log_blank

# These are helpful for debugging.
if [ "$IS_SONIC_PAD_OS" -eq 1 ]; then
    echo "Running in Sonic Pad OS mode"
fi
if [ "$IS_K1_OS" -eq 1 ]; then
    echo "Running in K1 and K1 Max OS mode"
fi

# Before anything, make sure this repo is cloned into the correct path on Creality OS devices.
# If this is Creality OS and the path is wrong, it will re-clone the repo, run the install again, and exit.
ensure_creality_os_right_repo_path


# Check if cmd line arg "-uninstall" is passed, if so, do not run the system package install.
if (echo "$@" | grep -q -- '-uninstall'); then
    log_important "Uninstalling Mobileraker Companion..."
else
    # Next, make sure our required system packages are installed.
    # These are required for other actions in this script, so it must be done first.
    install_or_update_system_dependencies
    # Now make sure the virtual env exists, is updated, and all of our currently required PY packages are updated.
    install_or_update_python_env
fi
# Before launching our PY script, set any vars it needs to know
# Pass all of the command line args, so they can be handled by the PY script.
# Note that USER can be empty string on some systems when running as root. This is fixed in the PY installer.
USERNAME=${USER}
USER_HOME=${HOME}
CMD_LINE_ARGS="$@"

# ToDo Adjust passed args to match the needs of mobileraker
PY_LAUNCH_JSON="{\"REPO_DIR\":\"${REPO_DIR}\",\"ENV_DIR\":\"${ENV_DIR}\",\"USERNAME\":\"${USERNAME}\",\"USER_HOME\":\"${USER_HOME}\",\"CMD_LINE_ARGS\":\"${CMD_LINE_ARGS}\"}"
log_info "Bootstrap done. Starting python installer..."

# Now launch into our py setup script, that does everything else required.
# Since we use a module for file includes, we need to set the path to the root of the module
# so python will find it.
export PYTHONPATH="${REPO_DIR}"

# We can't use pushd on Creality OS, so do this.
CURRENT_DIR=$(pwd)
cd "${REPO_DIR}" > /dev/null || exit 1

# Disable the timestamp on the next line, since this is part of a larger function.
# shellcheck disable=SC2154
if [ "$IS_SONIC_PAD_OS" -eq 1 ] || [ "$IS_K1_OS" -eq 1 ]; then
    # Creality OS only has a root user and we can't use sudo.
    "${ENV_DIR}/bin/python3" -B -m installer "$PY_LAUNCH_JSON"
else
    sudo "${ENV_DIR}/bin/python3" -B -m installer "$PY_LAUNCH_JSON"
fi
PY_EXIT_CODE=$?

cd "${CURRENT_DIR}" > /dev/null || exit 1

log_info "Python installer done."

# All done, let the user know what to do next.
log_blank
if [ $PY_EXIT_CODE -eq 0 ]; then
    log_important "Installation of Mobileraker Companion was successful."
else
    log_error "Installation of Mobileraker Companion failed!"
fi