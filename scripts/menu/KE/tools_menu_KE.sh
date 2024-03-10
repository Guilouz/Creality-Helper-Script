#!/bin/sh

set -e

function tools_menu_ui_ke() {
  top_line
  title '[ TOOLS MENU ]' "${yellow}"
  inner_line
  hr
  menu_option ' 1' 'Prevent updating' 'Klipper configuration files'
  menu_option ' 2' 'Allow updating' 'Klipper configuration files'
  hr
  menu_option ' 3' 'Restart' 'Nginx service'
  menu_option ' 4' 'Restart' 'Moonraker service'
  menu_option ' 5' 'Restart' 'Klipper service'
  hr
  menu_option ' 6' 'Update' 'Entware packages'
  hr
  menu_option ' 7' 'Clear' 'cache'
  menu_option ' 8' 'Clear' 'logs files'
  hr
  menu_option ' 9' 'Restore' 'a previous firmware'
  hr
  menu_option '10' 'Reset' 'factory settings'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function tools_menu_ke() {
  clear
  tools_menu_ui_ke
  local tools_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" tools_menu_opt
    case "${tools_menu_opt}" in
      1)
        if [ -f "$INITD_FOLDER"/disabled.S55klipper_service ]; then
          error_msg "Updating Klipper configuration files is already prevented!"
        else
          run "prevent_updating_klipper_files" "tools_menu_ui_ke"
        fi;;
      2)
        if [ ! -f "$INITD_FOLDER"/disabled.S55klipper_service ]; then
          error_msg "Updating Klipper configuration files is already allowed!"
        else
          run "allow_updating_klipper_files" "tools_menu_ui_ke"
        fi;;
      3)
        if [ ! -d "$NGINX_FOLDER" ]; then
          error_msg "Nginx is not installed!"
        else
          run "restart_nginx_action" "tools_menu_ui_ke"
        fi;;
      4)
        if [ ! -d "$MOONRAKER_FOLDER" ]; then
          error_msg "Moonraker is not installed!"
        else
          run "restart_moonraker_action" "tools_menu_ui_ke"
        fi;;
      5)
        if [ ! -f "$INITD_FOLDER"/S55klipper_service ]; then
          error_msg "Klipper service is not present!"
        else
          run "restart_klipper_action" "tools_menu_ui_ke"
        fi;;
      6)
        if [ ! -f "$ENTWARE_FILE" ]; then
          error_msg "Entware is not installed!"
        else
          run "update_entware_packages" "tools_menu_ui_ke"
        fi;;
      7)
        run "clear_cache" "tools_menu_ui_ke";;
      8)
        run "clear_logs" "tools_menu_ui_ke";;
      9)
        run "restore_previous_firmware" "tools_menu_ui_ke";;
      10)
        run "reset_factory_settings" "tools_menu_ui_ke";;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
         error_msg "Please select a correct choice!";;
    esac
  done
  tools_menu_ke
}
