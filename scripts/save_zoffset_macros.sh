#!/bin/sh

set -e

function save_zoffset_macros_message(){
  top_line
  title 'Save Z-Offset Macros' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows to save and load the the Z-Offset automatically.   ${white}│"
  hr
  bottom_line
}

function install_save_zoffset_macros(){
  save_zoffset_macros_message
  local yn
  while true; do
    install_msg "Save Z-Offset Macros" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/save-zoffset.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/save-zoffset.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Linking file..."
        ln -sf "$SAVE_ZOFFSET_URL" "$HS_CONFIG_FOLDER"/save-zoffset.cfg
        if grep -q "include Helper-Script/save-zoffset" "$PRINTER_CFG" ; then
          echo -e "Info: Save Z-Offset Macros configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Save Z-Offset Macros configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/save-zoffset\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Save Z-Offset Macros have been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_save_zoffset_macros(){
  save_zoffset_macros_message
  local yn
  while true; do
    remove_msg "Save Z-Offset Macros" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing file..."
        rm -f "$HS_CONFIG_FOLDER"/save-zoffset.cfg
        rm -f "$HS_CONFIG_FOLDER"/variables.cfg
        if grep -q "include Helper-Script/save-zoffset" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Save Z-Offset Macros configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/save-zoffset\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Save Z-Offset Macros configurations are already removed in printer.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Save Z-Offset Macros have been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}