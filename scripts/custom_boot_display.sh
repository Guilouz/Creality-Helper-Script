#!/bin/sh

set -e

function install_custom_boot_display_message(){
  top_line
  title 'Install Custom Boot Display' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to install a custom Creality-themed boot         ${white}│"
  echo -e " │ ${cyan}display.                                                     ${white}│"
  hr
  bottom_line
}

function remove_custom_boot_display_message(){
  top_line
  title 'Remove Custom Boot Display' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to restore stock boot display.                   ${white}│"
  hr
  bottom_line
}

function install_custom_boot_display(){
  install_custom_boot_display_message
  local yn
  while true; do
    install_msg "Custom Boot Display" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing stock files..."
        rm -rf "$BOOT_DISPLAY_FOLDER"/part0
        rm -f "$BOOT_DISPLAY_FOLDER"/boot-display.conf
        echo -e "Info: Extracting custom files..."
        tar -xvf "$BOOT_DISPLAY_K1_URL" -C "$BOOT_DISPLAY_FOLDER"
        ok_msg "Custom Boot Display has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_custom_boot_display(){
  remove_custom_boot_display_message
  local yn
  while true; do
    remove_msg "Custom Boot Display" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing custom files..."
        rm -rf "$BOOT_DISPLAY_FOLDER"/part0
        rm -f "$BOOT_DISPLAY_FOLDER"/boot-display.conf
        echo -e "Info: Extracting stock files..."
        tar -xvf "$BOOT_DISPLAY_STOCK_URL" -C "$BOOT_DISPLAY_FOLDER"
        ok_msg "Custom Boot Display has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}