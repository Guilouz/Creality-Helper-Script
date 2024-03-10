#!/bin/sh

set -e

function moonraker_timelapse_message(){
  top_line
  title 'Moonraker Timelapse' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Moonraker Timelapse is a 3rd party Moonraker component to    ${white}│"
  echo -e " │ ${cyan}create timelapse of 3D prints.                               ${white}│"
  hr
  bottom_line
}

function install_moonraker_timelapse(){
  moonraker_timelapse_message
  local yn
  while true; do
    install_msg "Moonraker Timelapse" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/timelapse.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/timelapse.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Linking file..."
        ln -sf "$TIMELAPSE_URL1" "$TIMELAPSE_FILE"
        ln -sf "$TIMELAPSE_URL2" "$HS_CONFIG_FOLDER"/timelapse.cfg
        if grep -q "include Helper-Script/timelapse" "$PRINTER_CFG" ; then
          echo -e "Info: Moonraker Timelapse configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Moonraker Timelapse configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/timelapse\.cfg\]' "$PRINTER_CFG"
        fi
        if grep -q "#\[timelapse\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Enabling Moonraker Timelapse configurations in moonraker.conf file..."
          sed -i -e 's/^\s*#[[:space:]]*\[timelapse\]/[timelapse]/' -e '/^\[timelapse\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MOONRAKER_CFG"
        else
          echo -e "Info: Moonraker Timelapse configurations are already enabled in moonraker.conf file..."
        fi
        echo -e "Info: Updating ffmpeg..."
        "$ENTWARE_FILE" update && "$ENTWARE_FILE" upgrade ffmpeg
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Moonraker Timelapse has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_moonraker_timelapse(){
  moonraker_timelapse_message
  local yn
  while true; do
    remove_msg "Moonraker Timelapse" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing files..."
        rm -f "$HS_CONFIG_FOLDER"/timelapse.cfg
        rm -f /usr/data/moonraker/moonraker/moonraker/components/timelapse.py
        rm -f /usr/data/moonraker/moonraker/moonraker/components/timelapse.pyc
        if [ -f /opt/bin/ffmpeg ]; then
          "$ENTWARE_FILE" --autoremove remove ffmpeg
        fi
        if grep -q "include Helper-Script/timelapse" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Moonraker Timelapse configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/timelapse\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Moonraker Timelapse configurations are already removed in printer.cfg file..."
        fi
        if grep -q "\[timelapse\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Disabling Moonraker Timelapse configurations in moonraker.conf file..."
          sed -i '/^\[timelapse\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MOONRAKER_CFG"
        else
          echo -e "Info: Moonraker Timelapse configurations are already disabled in moonraker.conf file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Moonraker Timelapse has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}