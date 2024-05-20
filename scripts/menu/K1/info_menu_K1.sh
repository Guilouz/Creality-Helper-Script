#!/bin/sh

set -e

function check_folder_k1() {
  local folder_path="$1"
  if [ -d "$folder_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function check_file_k1() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function check_simplyprint_k1() {
  if [ ! -f "$MOONRAKER_CFG" ]; then
    echo -e "${red}✗"
  elif grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function info_menu_ui_k1() {
  top_line
  title '[ INFORMATION MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  info_line "$(check_folder_k1 "$MOONRAKER_FOLDER")" 'Moonraker & Nginx'
  info_line "$(check_folder_k1 "$FLUIDD_FOLDER")" 'Fluidd'
  info_line "$(check_folder_k1 "$MAINSAIL_FOLDER")" 'Mainsail'
  hr
  subtitle '•UTILITIES:'
  info_line "$(check_file_k1 "$ENTWARE_FILE")" 'Entware'
  info_line "$(check_file_k1 "$KLIPPER_SHELL_FILE")" 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  info_line "$(check_folder_k1 "$KAMP_FOLDER")" 'Klipper Adaptive Meshing & Purging'
  info_line "$(check_file_k1 "$BUZZER_FILE")" 'Buzzer Support'
  info_line "$(check_folder_k1 "$NOZZLE_CLEANING_FOLDER")" 'Nozzle Cleaning Fan Control'
  info_line "$(check_file_k1 "$FAN_CONTROLS_FILE")" 'Fans Control Macros' 
  info_line "$(check_folder_k1 "$IMP_SHAPERS_FOLDER")" 'Improved Shapers Calibrations'
  info_line "$(check_file_k1 "$USEFUL_MACROS_FILE")" 'Useful Macros'
  info_line "$(check_file_k1 "$SAVE_ZOFFSET_FILE")" 'Save Z-Offset Macros'
  info_line "$(check_file_k1 "$SCREWS_ADJUST_FILE")" 'Screws Tilt Adjust Support'
  info_line "$(check_file_k1 "$M600_SUPPORT_FILE")" 'M600 Support'
  info_line "$(check_file_k1 "$GIT_BACKUP_FILE")" 'Git Backup'
  hr
  subtitle '•CAMERA:'
  info_line "$(check_file_k1 "$TIMELAPSE_FILE")" 'Moonraker Timelapse'
  info_line "$(check_file_k1 "$CAMERA_SETTINGS_FILE")" 'Camera Settings Control'
  info_line "$(check_file_k1 "$USB_CAMERA_FILE")" 'USB Camera Support'
  hr
  subtitle '•REMOTE ACCESS:'
  info_line "$(check_folder_k1 "$OCTOEVERYWHERE_FOLDER")" 'OctoEverywhere'
  info_line "$(check_folder_k1 "$MOONRAKER_OBICO_FOLDER")" 'Obico'
  info_line "$(check_folder_k1 "$GUPPYFLO_FOLDER")" 'GuppyFLO'
  info_line "$(check_folder_k1 "$MOBILERAKER_COMPANION_FOLDER")" 'Mobileraker Companion'
  info_line "$(check_folder_k1 "$OCTOAPP_COMPANION_FOLDER")" 'OctoApp Companion'
  info_line "$(check_simplyprint_k1)" 'SimplyPrint'
  hr
  subtitle '•CUSTOMIZATION:'
  info_line "$(check_file_k1 "$BOOT_DISPLAY_FILE")" 'Custom Boot Display'
  info_line "$(check_file_k1 "$CREALITY_WEB_FILE")" 'Creality Web Interface'
  info_line "$(check_folder_k1 "$GUPPY_SCREEN_FOLDER")" 'Guppy Screen'
  info_line "$(check_file_k1 "$FLUIDD_LOGO_FILE")" 'Creality Dynamic Logos for Fluidd'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function info_menu_k1() {
  clear
  info_menu_ui_k1
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
  info_menu_k1
}
