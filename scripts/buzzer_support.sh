#!/bin/sh

set -e

function buzzer_support_message(){
  top_line
  title 'Buzzer Support' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows to play sounds using the motherboard buzzer.       ${white}│"
  hr
  bottom_line
}

function install_buzzer_support(){
  buzzer_support_message
  local yn
  while true; do
    install_msg "Buzzer Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/buzzer-support.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/buzzer-support.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Linking file..."
        ln -sf "$BUZZER_URL" "$HS_CONFIG_FOLDER"/buzzer-support.cfg
        if grep -q "include Helper-Script/buzzer-support" "$PRINTER_CFG" ; then
          echo -e "Info: Buzzer Support configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Buzzer Support configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/buzzer-support\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Buzzer Support has been installed successfully!"
        echo -e "   You can now use ${yellow}BEEP ${white}command in your macros to play sound."
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_buzzer_support(){
  buzzer_support_message
  local yn
  while true; do
    remove_msg "Buzzer Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing file..."
        rm -f "$HS_CONFIG_FOLDER"/buzzer-support.cfg
        if grep -q "include Helper-Script/buzzer-support" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Buzzer Support configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/buzzer-support\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Buzzer Support configurations are already removed in printer.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Buzzer Support has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}