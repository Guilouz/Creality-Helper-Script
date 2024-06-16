#!/bin/sh

set -e

function check_folder_10se() {
  local folder_path="$1"
  if [ -d "$folder_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function check_file_10se() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function check_simplyprint_10se() {
  if [ ! -f "$MOONRAKER_CFG" ]; then
    echo -e "${red}✗"
  elif grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function info_menu_ui_10se() {
  top_line
  title '[ INFORMATION MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  info_line "$(check_folder_10se "$MOONRAKER_FOLDER")" 'Moonraker & Nginx'
  info_line "$(check_folder_10se "$FLUIDD_FOLDER")" 'Fluidd'
  info_line "$(check_folder_10se "$MAINSAIL_FOLDER")" 'Mainsail'
  hr
  subtitle '•UTILITIES:'
  info_line "$(check_file_10se "$ENTWARE_FILE")" 'Entware'
  info_line "$(check_file_10se "$KLIPPER_SHELL_FILE")" 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  info_line "$(check_folder_10se "$IMP_SHAPERS_FOLDER")" 'Improved Shapers Calibrations'
  info_line "$(check_file_10se "$SAVE_ZOFFSET_FILE")" 'Save Z-Offset Macros'
  info_line "$(check_file_10se "$GIT_BACKUP_FILE")" 'Git Backup'
  hr
  subtitle '•CAMERA:'
  info_line "$(check_file_10se "$TIMELAPSE_FILE")" 'Moonraker Timelapse'
  info_line "$(check_file_10se "$CAMERA_SETTINGS_FILE")" 'Nebula Camera Settings Control'
  info_line "$(check_file_10se "$USB_CAMERA_FILE")" 'USB Camera Support'
  hr
  subtitle '•REMOTE ACCESS:'
  info_line "$(check_folder_10se "$OCTOEVERYWHERE_FOLDER")" 'OctoEverywhere'
  info_line "$(check_folder_10se "$MOONRAKER_OBICO_FOLDER")" 'Obico'
  info_line "$(check_folder_10se "$GUPPYFLO_FOLDER")" 'GuppyFLO'
  info_line "$(check_folder_10se "$MOBILERAKER_COMPANION_FOLDER")" 'Mobileraker Companion'
  info_line "$(check_folder_10se "$OCTOAPP_COMPANION_FOLDER")" 'OctoApp Companion'
  info_line "$(check_simplyprint_10se)" 'SimplyPrint'
  hr
  subtitle '•CUSTOMIZATION:'
  info_line "$(check_file_10se "$CREALITY_WEB_FILE")" 'Creality Web Interface'
  info_line "$(check_folder_10se "$GUPPY_SCREEN_FOLDER")" 'Guppy Screen'
  info_line "$(check_file_10se "$FLUIDD_LOGO_FILE")" 'Creality Dynamic Logos for Fluidd'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function info_menu_10se() {
  clear
  info_menu_ui_10se
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
  info_menu_10se
}
