#!/bin/sh

set -e

function backup_moonraker_database_message(){
  top_line
  title 'Backup Moonraker database' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to backup Moonraker database in a                ${white}│"
  echo -e " │ ${cyan}backup_database.tar.gz compressed file.                      ${white}│"
  hr
  bottom_line
}

function restore_moonraker_database_message(){
  top_line
  title 'Restore Moonraker database' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to restore Moonraker database from a             ${white}│"
  echo -e " │ ${cyan}backup_database.tar.gz compressed file.                      ${white}│"
  hr
  bottom_line
}

function backup_moonraker_database(){
  backup_moonraker_database_message
  local yn
  while true; do
    backup_msg "Moonraker database" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$KLIPPER_CONFIG_FOLDER"/backup_database.tar.gz ]; then
          rm -f "$KLIPPER_CONFIG_FOLDER"/backup_database.tar.gz
        fi
        cd "$PRINTER_DATA_FOLDER"
        echo -e "Info: Compressing files..."
        tar -czvf "$KLIPPER_CONFIG_FOLDER"/backup_database.tar.gz database
        ok_msg "Moonraker database has been saved successfully in ${yellow}/usr/data/printer_data/config ${green}folder!"
        return;;
      N|n)
        error_msg "Backup canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function restore_moonraker_database(){
  restore_moonraker_database_message
  local yn
  while true; do
    restore_msg "Moonraker database" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        cd "$PRINTER_DATA_FOLDER"
        if [ -f config/backup_database.tar.gz ]; then
          mv config/backup_database.tar.gz backup_database.tar.gz
        fi
        if [ -d database ]; then
          rm -rf database
        fi
        echo -e "Info: Restoring files..."
        tar -xvf backup_database.tar.gz
        mv backup_database.tar.gz config/backup_database.tar.gz
        ok_msg "Moonraker database has been restored successfully!"
        return;;
      N|n)
        error_msg "Restoration canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}