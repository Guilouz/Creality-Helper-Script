#!/bin/sh

set -e

function backup_restore_menu_ui() {
  top_line
  title '[ BACKUP & RESTORE MENU ]' "${yellow}"
  inner_line
  hr
  menu_option '1' 'Backup' 'Klipper configuration files'
  menu_option '2' 'Restore' 'Klipper configuration files'
  hr
  menu_option '3' 'Backup' 'Moonraker database'
  menu_option '4' 'Restore' 'Moonraker database'
  hr
  inner_line
  hr
  bottom_menu_option 'b' 'Back to [Main Menu]' "${yellow}"
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function backup_restore_menu() {
  clear
  backup_restore_menu_ui
  local backup_restore_menu_opt
  while true; do
    read -p " ${white}Type your choice and validate with Enter: ${yellow}" backup_restore_menu_opt
    case "${backup_restore_menu_opt}" in
      1)
        run "backup_klipper_config_files" "backup_restore_menu_ui";;
      2)
        if [ ! -f "$KLIPPER_CONFIG_FOLDER"/backup_config.tar.gz ]; then
          error_msg "Please backup Klipper configuration files before restore!"
        else
          run "restore_klipper_config_files" "backup_restore_menu_ui"
        fi;;
      3)
        run "backup_moonraker_database" "backup_restore_menu_ui";;
      4)
        if [ ! -f "$KLIPPER_CONFIG_FOLDER"/backup_database.tar.gz ]; then
          error_msg "Please backup Moonraker database before restore!"
        else
          run "restore_moonraker_database" "backup_restore_menu_ui"
        fi;;
      B|b)
        clear; main_menu; break;;
      Q|q)
         clear; exit 0;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
  backup_restore_menu
}
