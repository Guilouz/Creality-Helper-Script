#!/bin/sh

set -e

function customize_menu_ui_k1() {
  top_line
  title '[ CUSTOMIZE MENU ]' "${yellow}"
  inner_line
  hr
  menu_option '1' 'Install' 'Custom Boot Display'
  menu_option '2' 'Remove' 'Custom Boot Display'
  hr
  menu_option '3' 'Remove' 'Creality Web Interface'
  menu_option '4' 'Restore' 'Creality Web Interface'
  hr
  menu_option '5' 'Install' 'Guppy Screen'
  menu_option '6' 'Remove' 'Guppy Screen'
  hr
  menu_option '7' 'Install' 'Creality Dynamic Logos for Fluidd'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function customize_menu_k1() {
  clear
  customize_menu_ui_k1
  local customize_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" customize_menu_opt
    case "${customize_menu_opt}" in
      1)
        if [ -f "$BOOT_DISPLAY_FILE" ]; then
          error_msg "Custom Boot Display is already installed!"
        elif [ ! -d "$BOOT_DISPLAY_FOLDER" ]; then
          error_msg "Please use latest firmware to install Custom Boot Display!"  
        else
          run "install_custom_boot_display" "customize_menu_ui_k1"
        fi;;
      2)
        if [ ! -f "$BOOT_DISPLAY_FILE" ]; then
          error_msg "Custom Boot Display is not installed!"
        elif [ ! -d "$BOOT_DISPLAY_FOLDER" ]; then
          error_msg "Please use latest firmware to restore Stock Boot Display!"  
        else
          run "remove_custom_boot_display" "customize_menu_ui_k1"
        fi;;
      3)
        if [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$CREALITY_WEB_FILE" ]; then
          error_msg "Creality Web Interface is already removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to change the default Web Interface.${white}"
          echo
        else
          run "remove_creality_web_interface" "customize_menu_ui_k1"
        fi;;
      4)
        if [ -f "$CREALITY_WEB_FILE" ]; then
          error_msg "Creality Web Interface is already present!"
        elif [ ! -f "$INITD_FOLDER"/S99start_app ]; then
          error_msg "Guppy Screen need to be removed first to restore Creality Web Interface!"
        else
          run "restore_creality_web_interface" "customize_menu_ui_k1"
        fi;;
      5)
        if [ -d "$GUPPY_SCREEN_FOLDER" ]; then
          error_msg "Guppy Screen is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ] && [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        elif [ "$(curl -s localhost:7125/server/info | jq .result.klippy_connected)" != "true" ]; then
          error_msg "Moonraker and Klipper do not seem to be functional. Please check this!"
        elif [ ! -f /lib/ld-2.29.so ]; then
          error_msg "Make sure you're running latest firmware version!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        elif [ -d "$IMP_SHAPERS_FOLDER" ]; then
          error_msg "Please remove Improved Shapers Calibrations first, Guppy Screen already use it!"
        else
          run "install_guppy_screen" "customize_menu_ui_k1"
        fi;;
      6)
        if [ ! -d "$GUPPY_SCREEN_FOLDER" ]; then
          error_msg "Guppy Screen is not installed!"
        else
          run "remove_guppy_screen" "customize_menu_ui_k1"
        fi;;
      7)
        if [ -f "$FLUIDD_LOGO_FILE" ]; then
          error_msg "Creality Dynamic Logos for Fluidd are already installed!"
        elif [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Fluidd is needed, please install it first!"
        else
          run "install_creality_dynamic_logos" "customize_menu_ui_k1"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  customize_menu_k1
}
