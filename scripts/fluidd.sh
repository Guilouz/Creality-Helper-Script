#!/bin/sh

set -e

function fluidd_message(){
  top_line
  title 'Fluidd' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Fluidd is a free and open-source Klipper Web interface for   ${white}│"
  echo -e " │ ${cyan}managing your 3d printer.                                    ${white}│"
  echo -e " │ ${cyan}It will be accessible on port 4408.                          ${white}│"
  hr
  bottom_line
}

function install_fluidd(){
  fluidd_message
  local yn
  while true; do
    install_msg "Fluidd" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Downloading Fluidd file..."
        "$CURL" -L "$FLUIDD_URL" -o "$USR_DATA"/fluidd.zip
        echo -e "Info: Creating directory..."
        if [ -d "$FLUIDD_FOLDER" ]; then
          rm -rf "$FLUIDD_FOLDER"
        fi
        mkdir -p "$FLUIDD_FOLDER"
        mv "$USR_DATA"/fluidd.zip "$FLUIDD_FOLDER"
        echo -e "Info: Extracting files..."
        unzip "$FLUIDD_FOLDER"/fluidd.zip -d "$FLUIDD_FOLDER"
        echo -e "Info: Removing file..."
        rm -f "$FLUIDD_FOLDER"/fluidd.zip
        if grep -q "#\[update_manager fluidd\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Enabling Fluidd configurations for Update Manager..."
          sed -i -e 's/^\s*#[[:space:]]*\[update_manager fluidd\]/[update_manager fluidd]/' -e '/^\[update_manager fluidd\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MOONRAKER_CFG"
        else
          echo -e "Info: Fluidd configurations are already enabled for Update Manager..."        
        fi
        echo -e "Info: Retarting Nginx service..."
        restart_nginx
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        ok_msg "Fluidd has been installed successfully!"
        echo -e "   You can now connect to Fluidd Web Interface with ${yellow}http://$(check_ipaddress):4408${white}"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_fluidd(){
  fluidd_message
  local yn
  while true; do
    remove_msg "Fluidd" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing files..."
        rm -rf "$FLUIDD_FOLDER"
        if grep -q "\[update_manager fluidd\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Disabling Fluidd configurations for Update Manager..."
          sed -i '/^\[update_manager fluidd\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MOONRAKER_CFG"
          echo -e "Info: Retarting Nginx service..."
          restart_nginx
          echo -e "Info: Restarting Moonraker service..."
          stop_moonraker
          start_moonraker
        else
          echo -e "Info: Fluidd configurations are already disabled for Update Manager..."
        fi
        ok_msg "Fluidd has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}