#!/bin/sh

set -e

function tools_menu_ui() {
  top_line
  title '[ TOOLS MENU ]' "${yellow}"
  inner_line
  hr
  menu_option ' 1' 'Prevent updating' 'Klipper configuration files'
  menu_option ' 2' 'Allow updating' 'Klipper configuration files'
  menu_option ' 3' 'Fix' 'printing Gcode files from folder'
  hr
  menu_option ' 4' 'Enable' 'camera settings in Moonraker'
  menu_option ' 5' 'Disable' 'camera settings in Moonraker'
  hr
  menu_option ' 6' 'Restart' 'Nginx service'
  menu_option ' 7' 'Restart' 'Moonraker service'
  menu_option ' 8' 'Restart' 'Klipper service'
  hr
  menu_option ' 9' 'Update' 'Entware packages'
  hr
  menu_option '10' 'Clear' 'cache'
  menu_option '11' 'Clear' 'logs files'
  hr
  menu_option '12' 'Restore' 'a previous firmware'
  hr
  menu_option '13' 'Reset' 'factory settings'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function tools_menu() {
  clear
  tools_menu_ui
  local tools_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" tools_menu_opt
    case "${tools_menu_opt}" in
      1)
        if [ -f "$INITD_FOLDER"/disabled.S55klipper_service ]; then
          error_msg "Updating Klipper configuration files is already prevented!"
        else
          run "prevent_updating_klipper_files" "tools_menu_ui"
        fi;;
      2)
        if [ ! -f "$INITD_FOLDER"/disabled.S55klipper_service ]; then
          error_msg "Updating Klipper configuration files is already allowed!"
        else
          run "allow_updating_klipper_files" "tools_menu_ui"
        fi;;
      3)
        if [ -f "$KLIPPER_KLIPPY_FOLDER"/gcode.py ]; then
          run "printing_gcode_from_folder" "tools_menu_ui"
        fi;;
      4)
        if grep -q "^\[webcam Camera\]$" "$MOONRAKER_CFG"; then
          error_msg "Camera settings are alredy enabled in Moonraker!"
        else
          run "enable_camera_settings" "tools_menu_ui"
        fi;;
      5)
        if grep -q "^#\[webcam Camera\]" "$MOONRAKER_CFG"; then
          error_msg "Camera settings are alredy disabled in Moonraker!"
        else
          run "disable_camera_settings" "tools_menu_ui"
        fi;;
      6)
        if [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Nginx is not installed!"
        else
          run "restart_nginx_action" "tools_menu_ui"
        fi;;
      7)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Moonraker is not installed!"
        else
          run "restart_moonraker_action" "tools_menu_ui"
        fi;;
      8)
        if [ ! -f "$INITD_FOLDER"/S55klipper_service ]; then
          error_msg "Klipper service is not present!"
        else
          run "restart_klipper_action" "tools_menu_ui"
        fi;;
      9)
        if [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is not installed!"
        else
          run "update_entware_packages" "tools_menu_ui"
        fi;;
      10)
        run "clear_cache" "tools_menu_ui";;
      11)
        run "clear_logs" "tools_menu_ui";;
      12)
        run "restore_previous_firmware" "tools_menu_ui";;
      13)
        run "reset_factory_settings" "tools_menu_ui";;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
         error_msg "Please select a correct choice!";;
    esac
  done
  tools_menu
}
