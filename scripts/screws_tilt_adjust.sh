#!/bin/sh

set -e

function screws_tilt_adjust_message(){
  top_line
  title 'Screws Tilt Adjust Support' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows to add support for Screws Tilt Adjust              ${white}│"
  echo -e " │ ${cyan}functionality.                                               ${white}│"
  hr
  bottom_line
}

function install_screws_tilt_adjust(){
  screws_tilt_adjust_message
  local yn
  while true; do
    install_msg "Screws Tilt Adjust Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Backing up original file..."
        if [ ! -d "$HS_BACKUP_FOLDER"/screws-tilt-adjust ]; then
          mkdir -p "$HS_BACKUP_FOLDER"/screws-tilt-adjust
        fi
        if [ -f "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.py ]; then
          mv "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.py "$HS_BACKUP_FOLDER"/screws-tilt-adjust
          mv "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.pyc "$HS_BACKUP_FOLDER"/screws-tilt-adjust
        fi
        echo
        local printer_choice
        while true; do
          read -p " ${white}Do you want install it for ${yellow}K1${white} or ${yellow}K1 Max${white}? (${yellow}k1${white}/${yellow}k1max${white}): ${yellow}" printer_choice
          case "${printer_choice}" in
            K1|k1)
              echo -e "${white}"
              echo -e "Info: Linking files..."
              ln -sf "$SCREWS_ADJUST_K1_URL" "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
              break;;
            K1MAX|k1max)
              echo -e "${white}"
              echo -e "Info: Linking files..."
              ln -sf "$SCREWS_ADJUST_K1M_URL" "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
              break;;
            *)
              error_msg "Please select a correct choice!";;
          esac
        done
        ln -sf "$SCREWS_ADJUST_URL" "$KLIPPER_EXTRAS_FOLDER"/screws_tilt_adjust.py
        if grep -q "include Helper-Script/screws-tilt-adjust" "$PRINTER_CFG" ; then
          echo -e "Info: Screws Tilt Adjust Support configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Screws Tilt Adjust Support configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/screws-tilt-adjust\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Screws Tilt Adjust Support has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_screws_tilt_adjust(){
  screws_tilt_adjust_message
  local yn
  while true; do
    remove_msg "Screws Tilt Adjust Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Restoring files..."
        if [ -f "$HS_BACKUP_FOLDER"/screws-tilt-adjust/screws_tilt_adjust.py ]; then
          mv "$HS_BACKUP_FOLDER"/screws-tilt-adjust/screws_tilt_adjust.py "$KLIPPER_EXTRAS_FOLDER"
          mv "$HS_BACKUP_FOLDER"/screws-tilt-adjust/screws_tilt_adjust.pyc "$KLIPPER_EXTRAS_FOLDER"
          rm -rf "$HS_BACKUP_FOLDER"/screws-tilt-adjust
        fi
        if [ ! -n "$(ls -A "$HS_BACKUP_FOLDER")" ]; then
          rm -rf "$HS_BACKUP_FOLDER"
        fi
        echo -e "Info: Removing file..."
        rm -f "$HS_CONFIG_FOLDER"/screws-tilt-adjust.cfg
        if grep -q "include Helper-Script/screws-tilt-adjust" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Screws Tilt Adjust Support configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/screws-tilt-adjust\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Screws Tilt Adjust Support configurations are already removed in printer.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Screws Tilt Adjust Support has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}