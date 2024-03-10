#!/bin/sh

set -e

function virtual_pins_message(){
  top_line
  title 'Virtual Pins Support' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows usage of virtual (simulated) pins in Klipper       ${white}│"
  echo -e " │ ${cyan}configurations files.                                        ${white}│"
  hr
  bottom_line
}

function install_virtual_pins(){
  virtual_pins_message
  local yn
  while true; do
    install_msg "Virtual Pins Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Linking file..."
        ln -sf "$VIRTUAL_PINS_URL" "$VIRTUAL_PINS_FILE"
        if grep -q "[virtual_pins]" "$PRINTER_CFG" ; then
          echo -e "Info: Adding [virtual_pins] configuration in printer.cfg file..."
          sed -i '/\[include sensorless.cfg\]/i [virtual_pins]' "$PRINTER_CFG"
        else
          echo -e "Info: [virtual_pins] configuration is already enabled in printer.cfg file..."
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Virtual Pins Support has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_virtual_pins(){
  virtual_pins_message
  local yn
  while true; do
    remove_msg "Virtual Pins Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing file..."
        rm -f "$KLIPPER_EXTRAS_FOLDER"/virtual_pins.py 
        rm -f "$KLIPPER_EXTRAS_FOLDER"/virtual_pins.pyc
        if grep -q "[virtual_pins]" "$PRINTER_CFG" ; then
          echo -e "Info: Removing [virtual_pins] configuration in printer.cfg file..."
          sed -i '/\[virtual_pins\]/d' "$PRINTER_CFG"
        else
          echo -e "Info: [virtual_pins] configuration is already removed in printer.cfg file..."
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Virtual Pins Support has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}