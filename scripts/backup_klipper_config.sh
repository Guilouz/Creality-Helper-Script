#!/bin/sh

set -e

function backup_klipper_config_files_message(){
  top_line
  title 'Backup Klipper configuration files' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to backup Klipper configuration files in a       ${white}│"
  echo -e " │ ${cyan}backup_config.tar.gz compressed file.                        ${white}│"
  hr
  bottom_line
}

function restore_klipper_config_files_message(){
  top_line
  title 'Restore Klipper configuration files' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to restore Klipper configuration files from a    ${white}│"
  echo -e " │ ${cyan}backup_config.tar.gz compressed file.                        ${white}│"
  hr
  bottom_line
}

function backup_klipper_config_files(){
  backup_klipper_config_files_message
  local yn
  while true; do
    backup_msg "Klipper configuration files" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$KLIPPER_CONFIG_FOLDER"/backup_config.tar.gz ]; then
          rm -f "$KLIPPER_CONFIG_FOLDER"/backup_config.tar.gz
        fi
        cd "$PRINTER_DATA_FOLDER"
        echo -e "Info: Compressing files..."
        tar -czvf "$KLIPPER_CONFIG_FOLDER"/backup_config.tar.gz config
        ok_msg "Klipper configuration files have been saved successfully in ${yellow}/usr/data/printer_data/config ${green}folder!"
        return;;
      N|n)
        error_msg "Backup canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function restore_klipper_config_files(){
  restore_klipper_config_files_message
  local yn
  while true; do
    restore_msg "Klipper configuration files" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        cd "$PRINTER_DATA_FOLDER"
        if [ -f config/backup_config.tar.gz ]; then
          mv config/backup_config.tar.gz backup_config.tar.gz
        fi
        if [ -d config ]; then
          rm -rf config
        fi
        echo -e "Info: Restoring files..."
        tar -xvf backup_config.tar.gz
        mv backup_config.tar.gz config/backup_config.tar.gz
        ok_msg "Klipper configuration files have been restored successfully!"
        return;;
      N|n)
        error_msg "Restoration canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}