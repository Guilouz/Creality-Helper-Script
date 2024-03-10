#!/bin/sh

set -e

function backup_klipper(){
  if [ -f /usr/data/printer_data/config/backup_config.tar.gz ]; then
    rm -f /usr/data/printer_data/config/backup_config.tar.gz
  fi
  cd /usr/data/printer_data
  echo -e "Info: Compressing files..."
  tar -czvf /usr/data/printer_data/config/backup_config.tar.gz config
  echo -e "Info: Klipper configuration files have been saved successfully!"
  exit 0
}

function restore_klipper(){
  if [ ! -f /usr/data/printer_data/config/backup_config.tar.gz ]; then
    echo -e "Info: Please backup Klipper configuration files before restore!"
    exit 1
  fi
  cd /usr/data/printer_data
  mv config/backup_config.tar.gz backup_config.tar.gz
  if [ -d config ]; then
    rm -rf config
  fi
  echo -e "Info: Restoring files..."
  tar -xvf backup_config.tar.gz
  mv backup_config.tar.gz config/backup_config.tar.gz
  echo -e "Info: Klipper configuration files have been restored successfully!"
  exit 0
}

function backup_moonraker(){
  if [ -f /usr/data/printer_data/config/backup_database.tar.gz ]; then
    rm -f /usr/data/printer_data/config/backup_database.tar.gz
  fi
  cd /usr/data/printer_data
  echo -e "Info: Compressing files..."
  tar -czvf /usr/data/printer_data/config/backup_database.tar.gz database
  echo -e "Info: Moonraker database has been saved successfully!"
  exit 0
}

function restore_moonraker(){
  if [ ! -f /usr/data/printer_data/config/backup_database.tar.gz ]; then
    echo -e "Info: Please backup Moonraker database before restore!"
    exit 1
  fi
  cd /usr/data/printer_data
  mv config/backup_database.tar.gz backup_database.tar.gz
  if [ -d database ]; then
    rm -rf database
  fi
  echo -e "Info: Restoring files..."
  tar -xvf backup_database.tar.gz
  mv backup_database.tar.gz config/backup_database.tar.gz
  echo -e "Info: Moonraker database has been restored successfully!"
  exit 0
}

if [ "$1" == "-backup_klipper" ]; then
  backup_klipper
elif [ "$1" == "-restore_klipper" ]; then
  restore_klipper
elif [ "$1" == "-backup_moonraker" ]; then
  backup_moonraker
elif [ "$1" == "-restore_moonraker" ]; then
  restore_moonraker
else
  echo -e "Invalid argument. Usage: $0 [-backup_klipper | -restore_klipper | -backup_moonraker | -restore_moonraker]"
  exit 1
fi