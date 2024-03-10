#!/bin/sh

set -e

function nozzle_cleaning_fan_control_message(){
  top_line
  title 'Nozzle Cleaning Fan Control' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This is an Klipper extension to control fans during nozzle   ${white}│"
  echo -e " │ ${cyan}cleaning.                                                    ${white}│"
  hr
  bottom_line
}

function install_nozzle_cleaning_fan_control(){
  nozzle_cleaning_fan_control_message
  local yn
  while true; do
    install_msg "Nozzle Cleaning Fan Control" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -d "NOZZLE_CLEANING_FOLDER" ]; then
          rm -rf "NOZZLE_CLEANING_FOLDER"
        fi
        mkdir -p "$NOZZLE_CLEANING_FOLDER"
        echo -e "Info: Linking files..."
        ln -sf "$NOZZLE_CLEANING_URL1" "$NOZZLE_CLEANING_FOLDER"/__init__.py
        ln -sf "$NOZZLE_CLEANING_URL2" "$NOZZLE_CLEANING_FOLDER"/prtouch_v2_fan.pyc
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        ln -sf "$NOZZLE_CLEANING_URL3" "$HS_CONFIG_FOLDER"/nozzle-cleaning-fan-control.cfg
        if grep -q "include Helper-Script/nozzle-cleaning-fan-control" "$PRINTER_CFG" ; then
          echo -e "Info: Nozzle Cleaning Fan Control configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Nozzle Cleaning Fan Control configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/nozzle-cleaning-fan-control\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Nozzle Cleaning Fan Control has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_nozzle_cleaning_fan_control(){
  nozzle_cleaning_fan_control_message
  local yn
  while true; do
    remove_msg "Nozzle Cleaning Fan Control" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing files..."
        rm -rf "$NOZZLE_CLEANING_FOLDER" 
        rm -f "$HS_CONFIG_FOLDER"/nozzle-cleaning-fan-control.cfg
        if grep -q "include Helper-Script/nozzle-cleaning-fan-control" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Nozzle Cleaning Fan Control configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/nozzle-cleaning-fan-control\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Nozzle Cleaning Fan Control configurations are already removed in printer.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Nozzle Cleaning Fan Control has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}