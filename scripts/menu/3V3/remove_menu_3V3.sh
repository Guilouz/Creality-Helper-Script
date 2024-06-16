#!/bin/sh

set -e

function remove_menu_ui_3v3() {
  top_line
  title '[ REMOVE MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  menu_option ' 1' 'Remove' 'Updated Moonraker'
  menu_option ' 2' 'Remove' 'Updated Fluidd (port 4408)'
  menu_option ' 3' 'Remove' 'Mainsail (port 4409)'
  hr
  subtitle '•UTILITIES:'
  menu_option ' 4' 'Remove' 'Entware'
  menu_option ' 5' 'Remove' 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  menu_option ' 6' 'Remove' 'Klipper Adaptive Meshing & Purging'
  menu_option ' 7' 'Remove' 'Buzzer Support'
  menu_option ' 8' 'Remove' 'Improved Shapers Calibrations'
  menu_option ' 9' 'Remove' 'Useful Macros'
  menu_option '10' 'Remove' 'Save Z-Offset Macros'
  menu_option '11' 'Remove' 'M600 Support'
  menu_option '12' 'Remove' 'Git Backup'
  hr
  subtitle '•CAMERA:'
  menu_option '13' 'Remove' 'Moonraker Timelapse'
  menu_option '14' 'Remove' 'Nebula Camera Settings Control'
  menu_option '15' 'Remove' 'USB Camera Support'
  hr
  subtitle '•REMOTE ACCESS:'
  menu_option '16' 'Remove' 'OctoEverywhere'
  menu_option '17' 'Remove' 'Moonraker Obico'
  menu_option '18' 'Remove' 'GuppyFLO'
  menu_option '19' 'Remove' 'Mobileraker Companion'
  menu_option '20' 'Remove' 'OctoApp Companion'
  menu_option '21' 'Remove' 'SimplyPrint'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function remove_menu_3v3() {
  clear
  remove_menu_ui_3v3
  local remove_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" remove_menu_opt
    case "${remove_menu_opt}" in
      1)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is not installed!"
        else
         run "remove_moonraker_3v3" "remove_menu_ui_3v3"
        fi;;
      2)
        if [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Updated Fluidd is not installed!"
        elif [ ! -f "$CREALITY_WEB_FILE" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Creality Web Interface is removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to remove Updated Fluidd.${white}"
          echo
        else
          run "remove_fluidd_3v3" "remove_menu_ui_3v3"
        fi;;
      3)
        if [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Mainsail is not installed!"
        elif [ ! -f "$CREALITY_WEB_FILE" ] && [ ! -d "$FLUIDD_FOLDER" ]; then
          error_msg "Creality Web Interface is removed!"
          echo -e " ${darkred}Please restore Creality Web Interface first if you want to remove Mainsail.${white}"
          echo
        else
          run "remove_mainsail" "remove_menu_ui_3v3"
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
          run "remove_entware" "remove_menu_ui_3v3"
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
          run "remove_gcode_shell_command" "remove_menu_ui_3v3"
        fi;;
      6)
        if [ ! -d "$KAMP_FOLDER" ]; then
          error_msg "Klipper Adaptive Meshing & Purging is not installed!"
        else
          run "remove_kamp" "remove_menu_ui_3v3"
        fi;;
      7)
        if [ ! -f "$BUZZER_FILE" ]; then
          error_msg "Buzzer Support is not installed!"
        else
          run "remove_buzzer_support" "remove_menu_ui_3v3"
        fi;;
      8)
        if [ ! -d "$IMP_SHAPERS_FOLDER" ]; then
          error_msg "Improved Shapers Calibrations are not installed!"
        else
          run "remove_improved_shapers" "remove_menu_ui_3v3"
        fi;;
      9)
        if [ ! -f "$USEFUL_MACROS_FILE" ]; then
          error_msg "Useful Macros are not installed!"
        else
          run "remove_useful_macros" "remove_menu_ui_3v3"
        fi;;
      10)
        if [ ! -f "$SAVE_ZOFFSET_FILE" ]; then
          error_msg "Save Z-Offset Macros are not installed!"
        else
          run "remove_save_zoffset_macros" "remove_menu_ui_3v3"
        fi;;
      11)
        if [ ! -f "$M600_SUPPORT_FILE" ]; then
          error_msg "M600 Support is not installed!"
        else
          run "remove_m600_support" "remove_menu_ui_3v3"
        fi;;
      12)
        if [ ! -f "$GIT_BACKUP_FILE" ]; then
          error_msg "Git Backup is not installed!"
        else
          run "remove_git_backup" "remove_menu_ui_3v3"
        fi;;
      13)
        if [ ! -f "$TIMELAPSE_FILE" ]; then
          error_msg "Moonraker Timelapse is not installed!"
        else
          run "remove_moonraker_timelapse" "remove_menu_ui_3v3"
        fi;;
      14)
        if [ ! -f "$CAMERA_SETTINGS_FILE" ]; then
          error_msg "Nebula Camera Settings Control is not installed!"
        else
          run "remove_camera_settings_control" "remove_menu_ui_3v3"
        fi;;
      15)
        if [ ! -f "$USB_CAMERA_FILE" ]; then
          error_msg "USB Camera Support is not installed!"
        else
          run "remove_usb_camera" "remove_menu_ui_3v3"
        fi;;
      16)
        if [ ! -d "$OCTOEVERYWHERE_FOLDER" ]; then
          error_msg "OctoEverywhere is not installed!"
        else
          run "remove_octoeverywhere" "remove_menu_ui_3v3"
        fi;;
      17)
        if [ ! -d "$MOONRAKER_OBICO_FOLDER" ]; then
          error_msg "Moonraker Obico is not installed!"
        else
          run "remove_moonraker_obico" "remove_menu_ui_3v3"
        fi;;
      18)
        if [ ! -d "$GUPPYFLO_FOLDER" ]; then
          error_msg "GuppyFLO is not installed!"
        else
          run "remove_guppyflo" "remove_menu_ui_3v3"
        fi;;
      19)
        if [ ! -d "$MOBILERAKER_COMPANION_FOLDER" ]; then
          error_msg "Mobileraker Companion is not installed!"
        else
          run "remove_mobileraker_companion" "remove_menu_ui_3v3"
        fi;;
      20)
        if [ ! -d "$OCTOAPP_COMPANION_FOLDER" ]; then
          error_msg "OctoApp Companion is not installed!"
        else
          run "remove_octoapp_companion" "remove_menu_ui_3v3"
        fi;;
      21)
        if ! grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
          error_msg "SimplyPrint is not installed!"
        else
          run "remove_simplyprint" "remove_menu_ui_3v3"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  remove_menu_3v3
}
