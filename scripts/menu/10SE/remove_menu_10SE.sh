#!/bin/sh

set -e

function remove_menu_ui_10se() {
  top_line
  title '[ REMOVE MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  menu_option ' 1' 'Remove' 'Moonraker and Nginx'
  menu_option ' 2' 'Remove' 'Fluidd (port 4408)'
  menu_option ' 3' 'Remove' 'Mainsail (port 4409)'
  hr
  subtitle '•UTILITIES:'
  menu_option ' 4' 'Remove' 'Entware'
  menu_option ' 5' 'Remove' 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  menu_option ' 6' 'Remove' 'Improved Shapers Calibrations'
  menu_option ' 7' 'Remove' 'Save Z-Offset Macros'
  menu_option ' 8' 'Remove' 'Git Backup'
  hr
  subtitle '•CAMERA:'
  menu_option ' 9' 'Remove' 'Moonraker Timelapse'
  menu_option '10' 'Remove' 'Nebula Camera Settings Control'
  menu_option '11' 'Remove' 'USB Camera Support'
  hr
  subtitle '•REMOTE ACCESS:'
  menu_option '12' 'Remove' 'OctoEverywhere'
  menu_option '13' 'Remove' 'Moonraker Obico'
  menu_option '14' 'Remove' 'GuppyFLO'
  menu_option '15' 'Remove' 'Mobileraker Companion'
  menu_option '16' 'Remove' 'OctoApp Companion'
  menu_option '17' 'Remove' 'SimplyPrint'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function remove_menu_10se() {
  clear
  remove_menu_ui_10se
  local remove_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" remove_menu_opt
    case "${remove_menu_opt}" in
      1)
        if [ ! -d "$MOONRAKER_FOLDER" ] && [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Moonraker and Nginx are not installed!"
        elif [ -d "$GUPPY_SCREEN_FOLDER" ]; then
          error_msg "Moonraker is needed to use Guppy Screen, please uninstall it first!"
        else
         run "remove_moonraker_nginx" "remove_menu_ui_10se"
        fi;;
      2)
        if [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Fluidd is not installed!"
        elif [ ! -f "$CREALITY_WEB_FILE" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Creality Web Interface is removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to remove Fluidd.${white}"
          echo
        else
          run "remove_fluidd" "remove_menu_ui_10se"
        fi;;
      3)
        if [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Mainsail is not installed!"
        elif [ ! -f "$CREALITY_WEB_FILE" ] && [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Creality Web Interface is removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to remove Mainsail.${white}"
          echo
        else
          run "remove_mainsail" "remove_menu_ui_10se"
        fi;;
      4)
        if [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is not installed!"
        elif [ -f "$TIMELAPSE_FILE" ]; then
          error_msg "Entware is needed to use Moonraker Timelapse, please uninstall it first!"
        elif [ -f "$GIT_BACKUP_FILE" ]; then
          error_msg "Entware is needed to use Git Backup, please uninstall it first!"
        elif [ -d "$OCTOEVERYWHERE_FOLDER" ]; then
          error_msg "Entware is needed to use OctoEverywhere, please uninstall it first!"
        elif [ -d "$MOONRAKER_OBICO_FOLDER" ]; then
          error_msg "Entware is needed to use Moonraker Obico, please uninstall it first!"
        elif [ -f "$USB_CAMERA_FILE" ]; then
          error_msg "Entware is needed to use USB Camera Support, please uninstall it first!"
        else
          run "remove_entware" "remove_menu_ui_10se"
        fi;;
      5)
        if [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is not installed!"
        elif [ -d "$GUPPY_SCREEN_FOLDER" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Guppy Screen, please uninstall it first!"
        elif [ -d "$IMP_SHAPERS_FOLDER" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Improved Shapers Calibrations, please uninstall it first!"
        elif [ -f "$GIT_BACKUP_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Git Backup, please uninstall it first!"
        else
          run "remove_gcode_shell_command" "remove_menu_ui_10se"
        fi;;
      6)
        if [ ! -d "$IMP_SHAPERS_FOLDER" ]; then
          error_msg "Improved Shapers Calibrations are not installed!"
        else
          run "remove_improved_shapers" "remove_menu_ui_10se"
        fi;;
      7)
        if [ ! -f "$SAVE_ZOFFSET_FILE" ]; then
          error_msg "Save Z-Offset Macros are not installed!"
        else
          run "remove_save_zoffset_macros" "remove_menu_ui_10se"
        fi;;
      8)
        if [ ! -f "$GIT_BACKUP_FILE" ]; then
          error_msg "Git Backup is not installed!"
        else
          run "remove_git_backup" "remove_menu_ui_10se"
        fi;;
      9)
        if [ ! -f "$TIMELAPSE_FILE" ]; then
          error_msg "Moonraker Timelapse is not installed!"
        else
          run "remove_moonraker_timelapse" "remove_menu_ui_10se"
        fi;;
      10)
        if [ ! -f "$CAMERA_SETTINGS_FILE" ]; then
          error_msg "Nebula Camera Settings Control is not installed!"
        else
          run "remove_camera_settings_control" "remove_menu_ui_10se"
        fi;;
      11)
        if [ ! -f "$USB_CAMERA_FILE" ]; then
          error_msg "USB Camera Support is not installed!"
        else
          run "remove_usb_camera" "remove_menu_ui_10se"
        fi;;
      12)
        if [ ! -d "$OCTOEVERYWHERE_FOLDER" ]; then
          error_msg "OctoEverywhere is not installed!"
        else
          run "remove_octoeverywhere" "remove_menu_ui_10se"
        fi;;
      13)
        if [ ! -d "$MOONRAKER_OBICO_FOLDER" ]; then
          error_msg "Moonraker Obico is not installed!"
        else
          run "remove_moonraker_obico" "remove_menu_ui_10se"
        fi;;
      14)
        if [ ! -d "$GUPPYFLO_FOLDER" ]; then
          error_msg "GuppyFLO is not installed!"
        else
          run "remove_guppyflo" "remove_menu_ui_10se"
        fi;;
      15)
        if [ ! -d "$MOBILERAKER_COMPANION_FOLDER" ]; then
          error_msg "Mobileraker Companion is not installed!"
        else
          run "remove_mobileraker_companion" "remove_menu_ui_10se"
        fi;;
      16)
        if [ ! -d "$OCTOAPP_COMPANION_FOLDER" ]; then
          error_msg "OctoApp Companion is not installed!"
        else
          run "remove_octoapp_companion" "remove_menu_ui_10se"
        fi;;
      17)
        if ! grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
          error_msg "SimplyPrint is not installed!"
        else
          run "remove_simplyprint" "remove_menu_ui_10se"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  remove_menu_10se
}