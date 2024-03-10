#!/bin/sh

set -e

function m600_support_message(){
  top_line
  title 'M600 Support' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows to use M600 command in your slicer to change       ${white}│"
  echo -e " │ ${cyan}filament.                                                    ${white}│"
  hr
  bottom_line
}

function install_m600_support(){
  m600_support_message
  local yn
  while true; do
    install_msg "M600 Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/M600-support.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/M600-support.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Linking file..."
        ln -sf "$M600_SUPPORT_URL" "$HS_CONFIG_FOLDER"/M600-support.cfg
        if grep -q "include Helper-Script/M600-support" "$PRINTER_CFG" ; then
          echo -e "Info: M600 Support configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding M600 Support configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/M600-support\.cfg\]' "$PRINTER_CFG"
        fi
        if grep -q "\[idle_timeout\]" "$PRINTER_CFG" ; then
          echo -e "Info: Disabling [idle_timeout] configurations in printer.cfg file..."
          sed -i '/^\[idle_timeout\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$PRINTER_CFG"
        else
          echo -e "Info: [idle_timeout] configurations are already disabled in printer.cfg file..."
        fi
        if grep -q "\[filament_switch_sensor filament_sensor\]" "$PRINTER_CFG" ; then
          echo -e "Info: Disabling [filament_switch_sensor] configurations in printer.cfg file..."
          sed -i '/^\[filament_switch_sensor filament_sensor\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$PRINTER_CFG"
        else
          echo -e "Info: [filament_switch_sensor] configurations are already disabled in printer.cfg file..."
        fi
        if grep -q "\[gcode_macro RESUME\]" "$MACROS_CFG" ; then
          echo -e "Info: Disabling [gcode_macro RESUME] in gcode_macro.cfg file..."
          sed -i '/^\[gcode_macro RESUME\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro RESUME] is already disabled in gcode_macro.cfg file..."
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "M600 Support has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_m600_support(){
  m600_support_message
  local yn
  while true; do
    remove_msg "M600 Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing file..."
        rm -f "$HS_CONFIG_FOLDER"/M600-support.cfg
        if grep -q "include Helper-Script/M600-support" "$PRINTER_CFG" ; then
          echo -e "Info: Removing M600 Support configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/M600-support\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: M600 Support configurations are already removed in printer.cfg file..."
        fi
        if grep -q "#\[idle_timeout\]" "$PRINTER_CFG" ; then
          echo -e "Info: Enabling [idle_timeout] configurations in printer.cfg file..."
          sed -i -e 's/^\s*#[[:space:]]*\[idle_timeout\]/[idle_timeout]/' -e '/^\[idle_timeout\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$PRINTER_CFG"
        else
          echo -e "Info: [idle_timeout] configurations are already enabled in printer.cfg file..."        
        fi
        if grep -q "#\[filament_switch_sensor filament_sensor\]" "$PRINTER_CFG" ; then
          echo -e "Info: Enabling [filament_switch_sensor] configurations in printer.cfg file..."
          sed -i -e 's/^\s*#[[:space:]]*\[filament_switch_sensor filament_sensor\]/[filament_switch_sensor filament_sensor]/' -e '/^\[filament_switch_sensor filament_sensor\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$PRINTER_CFG"
        else
          echo -e "Info: [filament_switch_sensor] configurations are already enabled in printer.cfg file..."        
        fi
        if grep -q "#\[gcode_macro RESUME\]" "$MACROS_CFG" ; then
          echo -e "Info: Enabling [gcode_macro RESUME] in gcode_macro.cfg file..."
          sed -i -e 's/^\s*#[[:space:]]*\[gcode_macro RESUME\]/[gcode_macro RESUME]/' -e '/^\[gcode_macro RESUME\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro RESUME] is already enabled in gcode_macro.cfg file..."        
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "M600 Support has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}