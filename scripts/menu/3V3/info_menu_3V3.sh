#!/bin/sh

set -e

function check_folder_3v3() {
  local folder_path="$1"
  if [ -d "$folder_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function check_file_3v3() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function check_simplyprint_3v3() {
  if [ ! -f "$MOONRAKER_CFG" ]; then
    echo -e "${red}✗"
  elif grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function info_menu_ui_3v3() {
  top_line
  title '[ INFORMATION MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  info_line "$(check_folder_3v3 "$MOONRAKER_FOLDER")" 'Updated Moonraker'
  info_line "$(check_folder_3v3 "$FLUIDD_FOLDER")" 'Updated Fluidd'
  info_line "$(check_folder_3v3 "$MAINSAIL_FOLDER")" 'Mainsail'
  hr
  subtitle '•UTILITIES:'
  info_line "$(check_file_3v3 "$ENTWARE_FILE")" 'Entware'
  info_line "$(check_file_3v3 "$KLIPPER_SHELL_FILE")" 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  info_line "$(check_folder_3v3 "$KAMP_FOLDER")" 'Klipper Adaptive Meshing & Purging'
  info_line "$(check_file_3v3 "$BUZZER_FILE")" 'Buzzer Support'
  info_line "$(check_folder_3v3 "$IMP_SHAPERS_FOLDER")" 'Improved Shapers Calibrations'
  info_line "$(check_file_3v3 "$USEFUL_MACROS_FILE")" 'Useful Macros'
  info_line "$(check_file_3v3 "$SAVE_ZOFFSET_FILE")" 'Save Z-Offset Macros'
  info_line "$(check_file_3v3 "$M600_SUPPORT_FILE")" 'M600 Support'
  info_line "$(check_file_3v3 "$GIT_BACKUP_FILE")" 'Git Backup'
  hr
  subtitle '•CAMERA:'
  info_line "$(check_file_3v3 "$TIMELAPSE_FILE")" 'Moonraker Timelapse'
  info_line "$(check_file_3v3 "$CAMERA_SETTINGS_FILE")" 'Nebula Camera Settings Control'
  info_line "$(check_file_3v3 "$USB_CAMERA_FILE")" 'USB Camera Support'
  hr
  subtitle '•REMOTE ACCESS:'
  info_line "$(check_folder_3v3 "$OCTOEVERYWHERE_FOLDER")" 'OctoEverywhere'
  info_line "$(check_folder_3v3 "$MOONRAKER_OBICO_FOLDER")" 'Obico'
  info_line "$(check_folder_3v3 "$GUPPYFLO_FOLDER")" 'GuppyFLO'
  info_line "$(check_folder_3v3 "$MOBILERAKER_COMPANION_FOLDER")" 'Mobileraker Companion'
  info_line "$(check_folder_3v3 "$OCTOAPP_COMPANION_FOLDER")" 'OctoApp Companion'
  info_line "$(check_simplyprint_3v3)" 'SimplyPrint'
  hr
  subtitle '•CUSTOMIZATION:'
  info_line "$(check_file_3v3 "$CREALITY_WEB_FILE")" 'Creality Web Interface'
  info_line "$(check_folder_3v3 "$GUPPY_SCREEN_FOLDER")" 'Guppy Screen'
  info_line "$(check_file_3v3 "$FLUIDD_LOGO_FILE")" 'Creality Dynamic Logos for Fluidd'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function info_menu_3v3() {
  clear
  info_menu_ui_3v3
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
  info_menu_3v3
}
