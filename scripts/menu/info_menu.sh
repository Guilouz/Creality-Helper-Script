#!/bin/sh

set -e

function check_folder() {
  local folder_path="$1"
  if [ -d "$folder_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function check_file() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function info_menu_ui() {
  top_line
  title '[ INFORMATIONS MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  info_line "$(check_folder "$MOONRAKER_FOLDER")" 'Moonraker & Nginx'
  info_line "$(check_folder "$FLUIDD_FOLDER")" 'Fluidd'
  info_line "$(check_folder "$MAINSAIL_FOLDER")" 'Mainsail'
  hr
  subtitle '•UTILITIES:'
  info_line "$(check_file "$ENTWARE_FILE")" 'Entware'
  info_line "$(check_file "$KLIPPER_SHELL_FILE")" 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  info_line "$(check_folder "$KAMP_FOLDER")" 'Klipper Adaptive Meshing & Purging'
  info_line "$(check_file "$BUZZER_FILE")" 'Buzzer Support'
  info_line "$(check_folder "$NOZZLE_CLEANING_FOLDER")" 'Nozzle Cleaning Fan Control'
  info_line "$(check_file "$FAN_CONTROLS_FILE")" 'Fans Control Macros' 
  info_line "$(check_folder "$IMP_SHAPERS_FOLDER")" 'Improved Shapers Calibrations'
  info_line "$(check_file "$USEFUL_MACROS_FILE")" 'Useful Macros'
  info_line "$(check_file "$SAVE_ZOFFSET_FILE")" 'Save Z-Offset Macros'
  info_line "$(check_file "$SCREWS_ADJUST_FILE")" 'Screws Tilt Adjust Support'
  info_line "$(check_file "$VIRTUAL_PINS_FILE")" 'Virtual Pins Support'
  info_line "$(check_file "$M600_SUPPORT_FILE")" 'M600 Support'
  info_line "$(check_file "$GIT_BACKUP_FILE")" 'Git Backup'
  hr
  subtitle '•CAMERA:'
  info_line "$(check_file "$TIMELAPSE_FILE")" 'Moonraker Timelapse'
  info_line "$(check_file "$CAMERA_SETTINGS_FILE")" 'Camera Settings Control'
  hr
  subtitle '•REMOTE ACCESS AND AI DETECTION:'
  info_line "$(check_folder "$OCTOEVERYWHERE_FOLDER")" 'OctoEverywhere'
  info_line "$(check_folder "$MOONRAKER_OBICO_FOLDER")" 'Obico'
  info_line "$(check_folder "$MOBILERAKER_COMPANION_FOLDER")" 'Mobileraker Companion'
  info_line "$(check_folder "$GUPPYFLO_FOLDER")" 'GuppyFLO'
  hr
  subtitle '•CUSTOMIZATION:'
  info_line "$(check_file "$BOOT_DISPLAY_FILE")" 'Custom Boot Display'
  info_line "$(check_file "$CREALITY_WEB_FILE")" 'Creality Web Interface'
  info_line "$(check_folder "$GUPPY_SCREEN_FOLDER")" 'Guppy Screen'
  info_line "$(check_file "$FLUIDD_LOGO_FILE")" 'Creality Dynamic Logos for Fluidd'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function info_menu() {
  clear
  info_menu_ui
  local info_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" info_menu_opt
    case "${info_menu_opt}" in
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  info_menu
}
