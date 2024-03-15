#!/bin/sh

set -e

function camera_settings_control_message(){
  top_line
  title 'Camera Settings Control' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows to install needed macros to adjust camera          ${white}│"
  echo -e " │ ${cyan}settings like brightness, saturation, contrast, etc...       ${white}│"
  hr
  bottom_line
}

function install_camera_settings_control(){
  camera_settings_control_message
  local yn
  while true; do
    install_msg "Camera Settings Control" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/camera-settings.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/camera-settings.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Linking file..."
        cp "$CAMERA_SETTINGS_URL" "$HS_CONFIG_FOLDER"/camera-settings.cfg
        if grep -q "include Helper-Script/camera-settings" "$PRINTER_CFG" ; then
          echo -e "Info: Camera Settings configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Camera Settings configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/camera-settings\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Camera Settings Control has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_camera_settings_control(){
  camera_settings_control_message
  local yn
  while true; do
    remove_msg "Camera Settings Control" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing file..."
        rm -f "$HS_CONFIG_FOLDER"/camera-settings.cfg
        if grep -q "include Helper-Script/camera-settings" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Camera Settings configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/camera-settings\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Camera Settings configurations are already removed in printer.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Camera Settings Control has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}