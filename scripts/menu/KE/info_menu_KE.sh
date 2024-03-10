#!/bin/sh

set -e

function check_folder_ke() {
  local folder_path="$1"
  if [ -d "$folder_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function check_file_ke() {
  local file_path="$1"
  if [ -f "$file_path" ]; then
    echo -e "${green}✓"
  else
    echo -e "${red}✗"
  fi
}

function info_menu_ui_ke() {
  top_line
  title '[ INFORMATIONS MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  info_line "$(check_folder_ke "$MOONRAKER_FOLDER")" 'Moonraker & Nginx'
  info_line "$(check_folder_ke "$FLUIDD_FOLDER")" 'Fluidd'
  info_line "$(check_folder_ke "$MAINSAIL_FOLDER")" 'Mainsail'
  hr
  subtitle '•UTILITIES:'
  info_line "$(check_file_ke "$ENTWARE_FILE")" 'Entware'
  info_line "$(check_file_ke "$KLIPPER_SHELL_FILE")" 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  info_line "$(check_folder_ke "$IMP_SHAPERS_FOLDER")" 'Improved Shapers Calibrations'
  info_line "$(check_file_ke "$SAVE_ZOFFSET_FILE")" 'Save Z-Offset Macros'
  info_line "$(check_file_ke "$VIRTUAL_PINS_FILE")" 'Virtual Pins Support'
  info_line "$(check_file_ke "$GIT_BACKUP_FILE")" 'Git Backup'
  hr
  subtitle '•CAMERA:'
  info_line "$(check_file_ke "$TIMELAPSE_FILE")" 'Moonraker Timelapse'
  hr
  subtitle '•REMOTE ACCESS AND AI DETECTION:'
  info_line "$(check_folder_ke "$OCTOEVERYWHERE_FOLDER")" 'OctoEverywhere'
  info_line "$(check_folder_ke "$MOONRAKER_OBICO_FOLDER")" 'Obico'
  info_line "$(check_folder_ke "$MOBILERAKER_COMPANION_FOLDER")" 'Mobileraker Companion'
  hr
  subtitle '•CUSTOMIZATION:'
  info_line "$(check_file_ke "$CREALITY_WEB_FILE")" 'Creality Web Interface'
  info_line "$(check_folder_ke "$GUPPY_SCREEN_FOLDER")" 'Guppy Screen'
  info_line "$(check_file_ke "$FLUIDD_LOGO_FILE")" 'Creality Dynamic Logos for Fluidd'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function info_menu_ke() {
  clear
  info_menu_ui_ke
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
  info_menu_ke
}
