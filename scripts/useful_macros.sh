#!/bin/sh

set -e

function useful_macros_message(){
  top_line
  title 'Useful Macros' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows to use some usefull macros like Bed Leveling, PID, ${white}│"
  echo -e " │ ${cyan}stress test or backup and restore Klipper configurations     ${white}│"
  echo -e " │ ${cyan}files and Moonraker database.                                ${white}│"
  hr
  bottom_line
}

function install_useful_macros(){
  useful_macros_message
  local yn
  while true; do
    install_msg "Useful Macros" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/useful-macros.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/useful-macros.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Linking file..."
        ln -sf "$USEFUL_MACROS_URL" "$HS_CONFIG_FOLDER"/useful-macros.cfg
        if grep -q "include Helper-Script/useful-macros" "$PRINTER_CFG" ; then
          echo -e "Info: Useful Macros configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Useful Macros configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/useful-macros\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Useful Macros have been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_useful_macros(){
  useful_macros_message
  local yn
  while true; do
    remove_msg "Useful Macros" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing file..."
        rm -f "$HS_CONFIG_FOLDER"/useful-macros.cfg
        if grep -q "include Helper-Script/useful-macros" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Useful Macros configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/useful-macros\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Useful Macros configurations are already removed in printer.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Useful Macros have been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}