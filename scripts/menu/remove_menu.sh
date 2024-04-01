#!/bin/sh

set -e

function remove_menu_ui() {
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
  menu_option ' 6' 'Remove' 'Klipper Adaptive Meshing & Purging'
  menu_option ' 7' 'Remove' 'Buzzer Support'
  menu_option ' 8' 'Remove' 'Nozzle Cleaning Fan Control'
  menu_option ' 9' 'Remove' 'Fans Control Macros'
  menu_option '10' 'Remove' 'Improved Shapers Calibrations'
  menu_option '11' 'Remove' 'Useful Macros'
  menu_option '12' 'Remove' 'Save Z-Offset Macros'
  menu_option '13' 'Remove' 'Screws Tilt Adjust Support'
  menu_option '14' 'Remove' 'Virtual Pins Support'
  menu_option '15' 'Remove' 'M600 Support'
  menu_option '16' 'Remove' 'Git Backup'
  hr
  subtitle '•CAMERA:'
  menu_option '17' 'Remove' 'Moonraker Timelapse'
  menu_option '18' 'Remove' 'Camera Settings Control'
  hr
  subtitle '•REMOTE ACCESS:'
  menu_option '19' 'Remove' 'OctoEverywhere'
  menu_option '20' 'Remove' 'Moonraker Obico'
  menu_option '21' 'Remove' 'GuppyFLO'
  menu_option '22' 'Remove' 'Mobileraker Companion'
  menu_option '23' 'Remove' 'OctoApp Companion'
  menu_option '24' 'Remove' 'SimplyPrint'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function remove_menu() {
  clear
  remove_menu_ui
  local remove_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" remove_menu_opt
    case "${remove_menu_opt}" in
      1)
        if [ ! -d "$MOONRAKER_FOLDER" ] && [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Moonraker and Nginx are not installed!"
        else
         run "remove_moonraker_nginx" "remove_menu_ui"
        fi;;
      2)
        if [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Fluidd is not installed!"
        elif [ ! -f "$CREALITY_WEB_FILE" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Creality Web Interface is removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to remove Fluidd.${white}"
          echo
        else
          run "remove_fluidd" "remove_menu_ui"
        fi;;
      3)
        if [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Mainsail is not installed!"
        elif [ ! -f "$CREALITY_WEB_FILE" ] && [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Creality Web Interface is removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to remove Mainsail.${white}"
          echo
        else
          run "remove_mainsail" "remove_menu_ui"
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
        else
          run "remove_entware" "remove_menu_ui"
        fi;;
      5)
        if [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is not installed!"
        elif [ -f "$BUZZER_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Buzzer Support, please uninstall it first!"
        elif [ -f "$CAMERA_SETTINGS_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Camera Settings Control, please uninstall it first!"
        elif [ -d "$GUPPY_SCREEN_FOLDER" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Guppy Screen, please uninstall it first!"
        elif [ -d "$IMP_SHAPERS_FOLDER" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Improved Shapers Calibrations, please uninstall it first!"
        elif [ -d "$GIT_BACKUP_FOLDER" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Git Backup, please uninstall it first!"
        elif [ -f "$USEFUL_MACROS_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed to use Useful Macros, please uninstall it first!"
        else
          run "remove_gcode_shell_command" "remove_menu_ui"
        fi;;
      6)
        if [ ! -d "$KAMP_FOLDER" ]; then
          error_msg "Klipper Adaptive Meshing & Purging is not installed!"
        else
          run "remove_kamp" "remove_menu_ui"
        fi;;
      7)
        if [ ! -f "$BUZZER_FILE" ]; then
          error_msg "Buzzer Support is not installed!"
        else
          run "remove_buzzer_support" "remove_menu_ui"
        fi;;
      8)
        if [ ! -d "$NOZZLE_CLEANING_FOLDER" ]; then
          error_msg "Nozzle Cleaning Fan Control is not installed!"
        else
          run "remove_nozzle_cleaning_fan_control" "remove_menu_ui"
        fi;;
      9)
        if [ ! -f "$FAN_CONTROLS_FILE" ]; then
          error_msg "Fans Control Macros are not installed!"
        else
          run "remove_fans_control_macros" "remove_menu_ui"
        fi;;
      10)
        if [ ! -d "$IMP_SHAPERS_FOLDER" ]; then
          error_msg "Improved Shapers Calibrations are not installed!"
        else
          run "remove_improved_shapers" "remove_menu_ui"
        fi;;
      11)
        if [ ! -f "$USEFUL_MACROS_FILE" ]; then
          error_msg "Useful Macros are not installed!"
        else
          run "remove_useful_macros" "remove_menu_ui"
        fi;;
      12)
        if [ ! -f "$SAVE_ZOFFSET_FILE" ]; then
          error_msg "Save Z-Offset Macros are not installed!"
        else
          run "remove_save_zoffset_macros" "remove_menu_ui"
        fi;;
      13)
        if [ ! -f "$SCREWS_ADJUST_FILE" ]; then
          error_msg "Screws Tilt Adjust Support is not installed!"
        else
          run "remove_screws_tilt_adjust" "remove_menu_ui"
        fi;;
      14)
        if [ ! -f "$VIRTUAL_PINS_FILE" ]; then
          error_msg "Virtual Pins Support is not installed!"
        else
          run "remove_virtual_pins" "remove_menu_ui"
        fi;;
      15)
        if [ ! -f "$M600_SUPPORT_FILE" ]; then
          error_msg "M600 Support is not installed!"
        else
          run "remove_m600_support" "remove_menu_ui"
        fi;;
      16)
        if [ ! -f "$GIT_BACKUP_FILE" ]; then
          error_msg "Git Backup is not installed!"
        else
          run "remove_git_backup" "remove_menu_ui"
        fi;;
      17)
        if [ ! -f "$TIMELAPSE_FILE" ]; then
          error_msg "Moonraker Timelapse is not installed!"
        else
          run "remove_moonraker_timelapse" "remove_menu_ui"
        fi;;
      18)
        if [ ! -f "$CAMERA_SETTINGS_FILE" ]; then
          error_msg "Camera Settings Control is not installed!"
        else
          run "remove_camera_settings_control" "remove_menu_ui"
        fi;;
      19)
        if [ ! -d "$OCTOEVERYWHERE_FOLDER" ]; then
          error_msg "OctoEverywhere is not installed!"
        else
          run "remove_octoeverywhere" "remove_menu_ui"
        fi;;
      20)
        if [ ! -d "$MOONRAKER_OBICO_FOLDER" ]; then
          error_msg "Moonraker Obico is not installed!"
        else
          run "remove_moonraker_obico" "remove_menu_ui"
        fi;;
      21)
        if [ ! -d "$GUPPYFLO_FOLDER" ]; then
          error_msg "GuppyFLO is not installed!"
        else
          run "remove_guppyflo" "remove_menu_ui"
        fi;;
      22)
        if [ ! -d "$MOBILERAKER_COMPANION_FOLDER" ]; then
          error_msg "Mobileraker Companion is not installed!"
        else
          run "remove_mobileraker_companion" "remove_menu_ui"
        fi;;
      23)
        if [ ! -d "$OCTOAPP_COMPANION_FOLDER" ]; then
          error_msg "OctoApp Companion is not installed!"
        else
          run "remove_octoapp_companion" "remove_menu_ui"
        fi;;
      24)
        if ! grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
          error_msg "SimplyPrint is not installed!"
        else
          run "remove_simplyprint" "remove_menu_ui"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  remove_menu
}
