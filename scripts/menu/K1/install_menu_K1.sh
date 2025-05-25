#!/bin/sh

set -e

function install_menu_ui_k1() {
  top_line
  title '[ INSTALL MENU ]' "${yellow}"
  inner_line
  hr
  subtitle '•ESSENTIALS:'
  menu_option ' 1' 'Install' 'Moonraker and Nginx'
  menu_option ' 2' 'Install' 'Fluidd (port 4408)'
  menu_option ' 3' 'Install' 'Mainsail (port 4409)'
  hr
  subtitle '•UTILITIES:'
  menu_option ' 4' 'Install' 'Entware'
  menu_option ' 5' 'Install' 'Klipper Gcode Shell Command'
  hr
  subtitle '•IMPROVEMENTS:'
  menu_option ' 6' 'Install' 'Klipper Adaptive Meshing & Purging'
  menu_option ' 7' 'Install' 'Buzzer Support'
  menu_option ' 8' 'Install' 'Nozzle Cleaning Fan Control'
  menu_option ' 9' 'Install' 'Fans Control Macros'
  menu_option '10' 'Install' 'Improved Shapers Calibrations'
  menu_option '11' 'Install' 'Useful Macros'
  menu_option '12' 'Install' 'Save Z-Offset Macros'
  menu_option '13' 'Install' 'Screws Tilt Adjust Support'
  menu_option '14' 'Install' 'M600 Support'
  menu_option '15' 'Install' 'Git Backup'
  hr
  subtitle '•CAMERA:'
  menu_option '16' 'Install' 'Moonraker Timelapse'
  menu_option '17' 'Install' 'Camera Settings Control'
  menu_option '18' 'Install' 'USB Camera Support'
  hr
  subtitle '•REMOTE ACCESS:'
  menu_option '19' 'Install' 'OctoEverywhere'
  menu_option '20' 'Install' 'Moonraker Obico'
  menu_option '21' 'Install' 'GuppyFLO'
  menu_option '22' 'Install' 'Mobileraker Companion'
  menu_option '23' 'Install' 'OctoApp Companion'
  menu_option '24' 'Install' 'SimplyPrint'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function install_menu_k1() {
  clear
  install_menu_ui_k1
  local install_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" install_menu_opt
    case "${install_menu_opt}" in
      1)
        if [ -d "$MOONRAKER_FOLDER" ]; then  
          error_msg "Moonraker and Nginx are already installed!"
        else
          run "install_moonraker_nginx" "install_menu_ui_k1"
        fi;;
      2)
        if [ -d "$FLUIDD_FOLDER" ]; then  
          error_msg "Fluidd is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ] && [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        else
          run "install_fluidd" "install_menu_ui_k1"
        fi;;
      3)
        if [ -d "$MAINSAIL_FOLDER" ]; then  
          error_msg "Mainsail is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ] && [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        else
          run "install_mainsail" "install_menu_ui_k1"
        fi;;
      4)
        if [ -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is already installed!"
        else
          run "install_entware" "install_menu_ui_k1"
        fi;;
      5)
        if [ -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is already installed!"
        else
          run "install_gcode_shell_command" "install_menu_ui_k1"
        fi;;
      6)
        if [ -d "$KAMP_FOLDER" ]; then
          error_msg "Klipper Adaptive Meshing & Purging is already installed!"
        else
          run "install_kamp" "install_menu_ui_k1"
        fi;;
      7)
        if [ -f "$BUZZER_FILE" ]; then
          error_msg "Buzzer Support is already installed!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_buzzer_support" "install_menu_ui_k1"
        fi;;
      8)
        if [ -d "$NOZZLE_CLEANING_FOLDER" ]; then
          error_msg "Nozzle Cleaning Fan Control is already installed!"
        else
          run "install_nozzle_cleaning_fan_control" "install_menu_ui_k1"
        fi;;
      9)
        if [ -f "$FAN_CONTROLS_FILE" ]; then
          error_msg "Fans Control Macros are already installed!"
        else
          run "install_fans_control_macros" "install_menu_ui_k1"
        fi;;
      10)
        if [ -d "$IMP_SHAPERS_FOLDER" ]; then
          error_msg "Improved Shapers Calibrations are already installed!"
        elif [ -d "$GUPPY_SCREEN_FOLDER" ]; then
          error_msg "Guppy Screen already has these features!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_improved_shapers" "install_menu_ui_k1"
        fi;;
      11)
        if [ -f "$USEFUL_MACROS_FILE" ]; then
          error_msg "Useful Macros are already installed!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_useful_macros" "install_menu_ui_k1"
        fi;;
      12)
        if [ -f "$SAVE_ZOFFSET_FILE" ]; then
          error_msg "Save Z-Offset Macros are already installed!"
        else
          run "install_save_zoffset_macros" "install_menu_ui_k1"
        fi;;
      13)
        if [ -f "$SCREWS_ADJUST_FILE" ]; then
          error_msg "Screws Tilt Adjust Support is already installed!"
        else
          run "install_screws_tilt_adjust" "install_menu_ui_k1"
        fi;;
      14)
        if [ -f "$M600_SUPPORT_FILE" ]; then
          error_msg "M600 Support is already installed!"
        else
          run "install_m600_support" "install_menu_ui_k1"
        fi;;
      15)
        if [ -f "$GIT_BACKUP_FILE" ]; then
          error_msg "Git Backup is already installed!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        elif [ ! -f "$KLIPPER_SHELL_FILE" ]; then
          error_msg "Klipper Gcode Shell Command is needed, please install it first!"
        else
          run "install_git_backup" "install_menu_ui_k1"
        fi;;
      16)
        if [ -f "$TIMELAPSE_FILE" ]; then
          error_msg "Moonraker Timelapse is already installed!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_moonraker_timelapse" "install_menu_ui_k1"
        fi;;
      17)
        if [ -f "$CAMERA_SETTINGS_FILE" ]; then
          error_msg "Camera Settings Control is already installed!"
          continue
        elif v4l2-ctl --list-devices | grep -q 'CCX2F3299' && [ -f "$INITD_FOLDER"/S50usb_camera ]; then
          error_msg "You have the new hardware version of the Creality AI camera and it's not compatible!"
          if [ "lsusb | grep -E \"(Integrated Camera|Webcam|CVD|Video|uvcvideo)\" | wx -l | grep -q '^ [1-9]" ]; then
            echo -e "\e[1A\e[K ${yellow}An additional USB webcam was detected. It may work with the camera settings, but that's not guaranteed."
            echo -e "${yellow} Would you like too install anyway?"
            read -p " ${white}Continue (y/n): ${yellow}" response
            case "$response" in
              [nN][oO]|[nN])
              run "install_menu_ui_k1" 
            ;;
            *)
              if [ ! -f "$KLIPPER_SHELL_FILE" ]; then
                error_msg "Klipper Gcode Shell Command is needed, please install it first!"
              else
                run "install_camera_settings_control" "install_menu_ui_k1"
              fi
            esac
          fi
        fi;;
      18)
        if [ -f "$USB_CAMERA_FILE" ]; then
          error_msg "Camera USB Support is already installed!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_usb_camera" "install_menu_ui_k1"
        fi;;
      19)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_octoeverywhere" "install_menu_ui_k1"
        fi;;
      20)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_moonraker_obico" "install_menu_ui_k1"
        fi;;
      21)
        if [ ! -d "$MOONRAKER_FOLDER" ] && [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        else
          run "install_guppyflo" "install_menu_ui_k1"
        fi;;
      22)
        if [ -d "$MOBILERAKER_COMPANION_FOLDER" ]; then
          error_msg "Mobileraker Companion is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_mobileraker_companion" "install_menu_ui_k1"
        fi;;
      23)
        if [ -d "$OCTOAPP_COMPANION_FOLDER" ]; then
          error_msg "OctoApp Companion is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Fluidd or Mainsail is needed, please install one of them first!"
        elif [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is needed, please install it first!"
        else
          run "install_octoapp_companion" "install_menu_ui_k1"
        fi;;
      24)
        if grep -q "\[simplyprint\]" "$MOONRAKER_CFG"; then
          error_msg "SimplyPrint is already installed!"
        elif [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Moonraker and Nginx are needed, please install them first!"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          error_msg "Fluidd or Mainsail is needed, please install one of them first!"
        else
          run "install_simplyprint" "install_menu_ui_k1"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  install_menu_k1
}
