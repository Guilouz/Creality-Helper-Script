#!/bin/sh

set -e

function moonraker_obico_message(){
  top_line
  title 'Moonraker Obico' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Obico is a Moonraker plugin that allows you to monitor and   ${white}│"
  echo -e " │ ${cyan}control your 3D printer from anywhere.                       ${white}│"
  hr
  bottom_line
}

function install_moonraker_obico(){
  moonraker_obico_message
  local yn
  while true; do
    install_msg "Moonraker Obico" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -d "$MOONRAKER_OBICO_FOLDER" ]; then
		  echo -e "Info: Moonraker Obico is already installed. Download skipped."
		else
          echo -e "Info: Downloading Moonraker Obico..."
          git config --global http.sslVerify false
          git clone "$MOONRAKER_OBICO_URL" "$MOONRAKER_OBICO_FOLDER"
		fi
		echo -e "Info: Running Moonraker Obico installer..."
		cd "$MOONRAKER_OBICO_FOLDER"
		sh ./scripts/install_creality.sh -k
        ok_msg "Moonraker Obico has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_moonraker_obico(){
  moonraker_obico_message
  local yn
  while true; do
    remove_msg "Moonraker Obico" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if grep -q "include moonraker_obico_macros" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Moonraker Obico configurations in printer.cfg file..."
          sed -i '/include moonraker_obico_macros\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Moonraker Obico configurations are already removed in printer.cfg file..."
        fi
        if grep -q "\[include moonraker-obico-update.cfg\]" "$MOONRAKER_CFG" ; then
          echo -e "Info: Removing Moonraker Obico configurations in moonraker.conf file..."
          sed -i '/include moonraker-obico-update\.cfg/d' "$MOONRAKER_CFG"
        else
          echo -e "Info: Moonraker Obico configurations are already removed in moonraker.conf file..."
        fi
        echo -e "Info: Removing files..."
        rm -rf "$MOONRAKER_OBICO_FOLDER"
        rm -rf /usr/data/moonraker-obico-env
        rm -f "$KLIPPER_CONFIG_FOLDER"/moonraker-obico-update.cfg 
        rm -f "$KLIPPER_CONFIG_FOLDER"/config/moonraker-obico.cfg
        rm -f /etc/init.d/S99moonraker_obico
        if [ -f "$ENTWARE_FILE" ]; then
          echo -e "Info: Removing packages..."
          "$ENTWARE_FILE" --autoremove remove python3
          "$ENTWARE_FILE" --autoremove remove python3-pip
        fi
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Moonraker Obico has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}