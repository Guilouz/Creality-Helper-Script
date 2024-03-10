#!/bin/sh

set -e

function mainsail_message(){
  top_line
  title 'Mainsail' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Mainsail makes Klipper more accessible by adding a           ${white}│"
  echo -e " │ ${cyan}lightweight, responsive web user interface, centred around   ${white}│"
  echo -e " │ ${cyan}an intuitive and consistent design philosophy.               ${white}│"
  echo -e " │ ${cyan}It will be accessible on port 4409.                          ${white}│"
  hr
  bottom_line
}

function install_mainsail(){
  mainsail_message
  local yn
  while true; do
    install_msg "Mainsail" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Downloading Mainsail file..."
        "$CURL" -L "$MAINSAIL_URL" -o "$USR_DATA"/mainsail.zip
        echo -e "Info: Creating directory..."
        if [ -d "$MAINSAIL_FOLDER" ]; then
          rm -rf "$MAINSAIL_FOLDER"
        fi
        mkdir -p "$MAINSAIL_FOLDER"
        mv "$USR_DATA"/mainsail.zip "$MAINSAIL_FOLDER"
        echo -e "Info: Extracting files..."
        unzip "$MAINSAIL_FOLDER"/mainsail.zip -d "$MAINSAIL_FOLDER"
        echo -e "Info: Removing file..."
        rm -f "$MAINSAIL_FOLDER"/mainsail.zip
        if grep -q "#\[update_manager mainsail\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Enabling Mainsail configurations for Update Manager..."
          sed -i -e 's/^\s*#[[:space:]]*\[update_manager mainsail\]/[update_manager mainsail]/' -e '/^\[update_manager mainsail\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MOONRAKER_CFG"
        else
          echo -e "Info: Mainsail configurations are already enabled for Update Manager..."        
        fi
        echo -e "Info: Retarting Nginx service..."
        restart_nginx
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        ok_msg "Mainsail has been installed successfully!"
        echo -e "   You can now connect to Mainsail Web Interface with ${yellow}http://$(check_ipaddress):4409${white}"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_mainsail(){
  mainsail_message
  local yn
  while true; do
    remove_msg "Mainsail" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing files..."
        rm -rf "$MAINSAIL_FOLDER"
        if grep -q "\[update_manager mainsail\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Disabling Mainsail configurations for Update Manager..."
          sed -i '/^\[update_manager mainsail\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MOONRAKER_CFG"
          echo -e "Info: Retarting Nginx service..."
          restart_nginx
          echo -e "Info: Restarting Moonraker service..."
          stop_moonraker
          start_moonraker
        else
          echo -e "Info: Mainsail configurations are already disabled for Update Manager..."
        fi
        ok_msg "Mainsail has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}