#!/bin/sh

set -e

function install_menu_ui_3v3() {
  top_line
  title '[ INSTALL MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  menu_option ' 1' 'Install' 'Updated Moonraker'
  menu_option ' 2' 'Install' 'Updated Fluidd (port 4408)'
  menu_option ' 3' 'Install' 'Mainsail (port 4409)'
  hr
  subtitle '•UTILITIES:'
  menu_option ' 4' 'Install' 'Entware'
  menu_option ' 5' 'Install' 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  menu_option ' 6' 'Install' 'Klipper Adaptive Meshing & Purging'
  menu_option ' 7' 'Install' 'Buzzer Support'
  menu_option ' 8' 'Install' 'Improved Shapers Calibrations'
  menu_option ' 9' 'Install' 'Useful Macros'
  menu_option '10' 'Install' 'Save Z-Offset Macros'
  menu_option '11' 'Install' 'M600 Support'
  menu_option '12' 'Install' 'Git Backup'
  hr
  subtitle '•CAMERA:'
  menu_option '13' 'Install' 'Moonraker Timelapse'
  menu_option '14' 'Install' 'Nebula Camera Settings Control'
  menu_option '15' 'Install' 'USB Camera Support'
  hr
  subtitle '•REMOTE ACCESS:'
  menu_option '16' 'Install' 'OctoEverywhere'
  menu_option '17' 'Install' 'Moonraker Obico'
  menu_option '18' 'Install' 'GuppyFLO'
  menu_option '19' 'Install' 'Mobileraker Companion'
  menu_option '20' 'Install' 'OctoApp Companion'
  menu_option '21' 'Install' 'SimplyPrint'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function install_menu_3v3() {
  clear
  install_menu_ui_3v3
  local install_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" install_menu_opt
    case "${install_menu_opt}" in
      1)
        if [ -d "$MOONRAKER_FOLDER" ]; then  
          error_msg "Updated Moonraker is already installed!"
        else
          run "install_moonraker_3v3" "install_menu_ui_3v3"
        fi;;
      2)
        if [ -d "$FLUIDD_FOLDER" ]; then  
          error_msg "Updated Fluidd is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is needed, please install it first!"
        else
          run "install_fluidd_3v3" "install_menu_ui_3v3"
        fi;;
      3)
        if [ -d "$MAINSAIL_FOLDER" ]; then  
          error_msg "Mainsail is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is needed, please install it first!"
        else
          run "install_mainsail" "install_menu_ui_3v3"
        fi;;
      4)
        if [ -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is already installed!"
        else
          run "install_entware" "install_menu_ui_3v3"
        fi;;
      5)
        if [ -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is already installed!"
        else
          run "install_gcode_shell_command" "install_menu_ui_3v3"
        fi;;
      6)
        if [ -d "$KAMP_FOLDER" ]; then
          error_msg "Klipper Adaptive Meshing & Purging is already installed!"
        else
          run "install_kamp" "install_menu_ui_3v3"
        fi;;
      7)
        if [ -f "$BUZZER_FILE" ]; then
          error_msg "Buzzer Support is already installed!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_buzzer_support" "install_menu_ui_3v3"
        fi;;
      8)
        if [ -d "$IMP_SHAPERS_FOLDER" ]; then
          error_msg "Improved Shapers Calibrations are already installed!"
        elif [ -d "$GUPPY_SCREEN_FOLDER" ]; then
          error_msg "Guppy Screen already has these features!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_improved_shapers" "install_menu_ui_3v3"
        fi;;
      9)
        if [ -f "$USEFUL_MACROS_FILE" ]; then
          error_msg "Useful Macros are already installed!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_useful_macros" "install_menu_ui_3v3"
        fi;;
      10)
        if [ -f "$SAVE_ZOFFSET_FILE" ]; then
          error_msg "Save Z-Offset Macros are already installed!"
        else
          run "install_save_zoffset_macros" "install_menu_ui_3v3"
        fi;;
      11)
        if [ -f "$M600_SUPPORT_FILE" ]; then
          error_msg "M600 Support is already installed!"
        else
          run "install_m600_support" "install_menu_ui_3v3"
        fi;;
      12)
        if [ -f "$GIT_BACKUP_FILE" ]; then
          error_msg "Git Backup is already installed!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_git_backup" "install_menu_ui_3v3"
        fi;;
      13)
        if [ -f "$TIMELAPSE_FILE" ]; then
          error_msg "Moonraker Timelapse is already installed!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_moonraker_timelapse" "install_menu_ui_3v3"
        fi;;
      14)
        if [ -f "$CAMERA_SETTINGS_FILE" ]; then
          error_msg "Nebula Camera Settings Control is already installed!"
        elif ! v4l2-ctl --list-devices | grep -q 'CCX2F3298'; then
          error_msg "Nebula camera not detected, please plug it in!"  
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_camera_settings_control" "install_menu_ui_3v3"
        fi;;
      15)
        if [ -f "$USB_CAMERA_FILE" ]; then
          error_msg "Camera USB Support is already installed!"
        elif v4l2-ctl --list-devices | grep -qE 'CREALITY|CCX2F3298'; then
          error_msg "It looks like you are using a Creality camera and it's not compatible!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_usb_camera" "install_menu_ui_3v3"
        fi;;
      16)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is needed, please install it first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Updated Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_octoeverywhere" "install_menu_ui_3v3"
        fi;;
      17)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is needed, please install it first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Updated Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_moonraker_obico" "install_menu_ui_3v3"
        fi;;
      18)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is needed, please install it first!"
        else
          run "install_guppyflo" "install_menu_ui_3v3"
        fi;;
      19)
        if [ -d "$MOBILERAKER_COMPANION_FOLDER" ]; then
          error_msg "Mobileraker Companion is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is needed, please install it first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_mobileraker_companion" "install_menu_ui_3v3"
        fi;;
      20)
        if [ -d "$OCTOAPP_COMPANION_FOLDER" ]; then
          error_msg "OctoApp Companion is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is needed, please install it first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Updated Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_octoapp_companion" "install_menu_ui_3v3"
        fi;;
      21)
        if grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
          error_msg "SimplyPrint is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Updated Moonraker is needed, please install it first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Updated Fluidd or Mainsail is needed, please install one of them first!"
        else
          run "install_simplyprint" "install_menu_ui_3v3"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  install_menu_3v3
}
