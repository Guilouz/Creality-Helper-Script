#!/bin/sh

set -e

function guppyflo_message(){
  top_line
  title 'GuppyFLO' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}GuppyFLO is a self-hosted service that enables local/remote  ${white}│"
  echo -e " │ ${cyan}management of multiple Klipper printers using Moonraker.     ${white}│"
  hr
  bottom_line
}

function install_guppyflo(){
  guppyflo_message
  local yn
  while true; do
    install_msg "GuppyFLO" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$INITD_FOLDER"/S99guppyflo ]; then
          echo -e "Info: Stopping GuppyFLO service..."
          /etc/init.d/S99guppyflo stop &> /dev/null
        fi
        if [ -d "$GUPPYFLO_FOLDER" ]; then
          rm -rf "$GUPPYFLO_FOLDER"
        fi
        if [ -f "$INITD_FOLDER"/S99guppyflo ]; then
          rm -f "$INITD_FOLDER"/S99guppyflo
        fi
        if [ -f /lib/libeinfo.so.1 ]; then
          rm -f /lib/libeinfo.so.1
        fi
        if [ -f /lib/librc.so.1 ]; then
          rm -f /lib/librc.so.1
        fi
        echo -e "Info: Downloading GuppyFLO file..."
        "$CURL" -L "$GUPPYFLO_URL" -o "$USR_DATA"/guppyflo.zip
        echo -e "Info: Creating directory..."
        mkdir -p "$GUPPYFLO_FOLDER"
        echo -e "Info: Extracting files..."
        unzip "$USR_DATA"/guppyflo.zip -d "$GUPPYFLO_FOLDER"
        rm -f "$USR_DATA"/guppyflo.zip
        echo -e "Info: Linking files..."
        ln -sf "$GUPPYFLO_FOLDER"/services/S99guppyflo "$INITD_FOLDER"/S99guppyflo
        ln -sf "$GUPPYFLO_FOLDER"/services/respawn/libeinfo.so.1 /lib/libeinfo.so.1
        ln -sf "$GUPPYFLO_FOLDER"/services/respawn/librc.so.1 /lib/librc.so.1
        echo -e "Info: Starting GuppyFLO service..."
        /etc/init.d/S99guppyflo start &> /dev/null
        ok_msg "GuppyFLO has been installed successfully!"
        echo -e "   You can now connect to GuppyFLO Web Interface with ${yellow}http://$(check_ipaddress):9873${white}"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_guppyflo(){
  guppyflo_message
  local yn
  while true; do
    remove_msg "GuppyFLO" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$INITD_FOLDER"/S99guppyflo ]; then
          echo -e "Info: Stopping GuppyFLO service..."
          /etc/init.d/S99guppyflo stop &> /dev/null
        fi
        echo -e "Info: Removing files..."
        rm -rf "$GUPPYFLO_FOLDER"
        rm -f "$INITD_FOLDER"/S99guppyflo
        rm -f /lib/libeinfo.so.1
        rm -f /lib/librc.so.1
        ok_msg "GuppyFLO has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}