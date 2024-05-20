#!/bin/sh

set -e

function mobileraker_companion_message(){
  top_line
  title 'Mobileraker Companion' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Mobileraker Companion allows to push notification for        ${white}│"
  echo -e " │ ${cyan}Klipper using Moonraker for Mobileraker phone App.           ${white}│"
  hr
  bottom_line
}

function install_mobileraker_companion(){
  mobileraker_companion_message
  local yn
  while true; do
    install_msg "Mobileraker Companion" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Downloading Mobileraker Companion..."
        git config --global http.sslVerify false
        git clone "$MOBILERAKER_COMPANION_URL" "$MOBILERAKER_COMPANION_FOLDER"
        echo -e "Info: Running Mobileraker Companion installer..."
        sh "$MOBILERAKER_COMPANION_FOLDER"/scripts/install.sh
        echo
        if grep -q "#\[update_manager mobileraker\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Enabling Mobileraker Companion configurations for Update Manager..."
          sed -i -e 's/^\s*#[[:space:]]*\[update_manager mobileraker\]/[update_manager mobileraker]/' -e '/^\[update_manager mobileraker\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MOONRAKER_CFG"
        else
          echo -e "Info: Mobileraker Companion configurations are already enabled for Update Manager..."        
        fi
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Mobileraker Companion has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_mobileraker_companion(){
  mobileraker_companion_message
  local yn
  while true; do
    remove_msg "Mobileraker Companion" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Running Mobileraker Companion uninstaller..."
        sh "$MOBILERAKER_COMPANION_FOLDER"/scripts/install.sh -uninstall
        echo
        if grep -q "\[update_manager mobileraker\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Disabling Mobileraker Companion configurations for Update Manager..."
          sed -i '/^\[update_manager mobileraker\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MOONRAKER_CFG"
        else
          echo -e "Info: Mobileraker Companion configurations are already disabled for Update Manager..."
        fi
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Mobileraker Companion has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}