#!/bin/sh

set -e

function fans_control_macros_message(){
  top_line
  title 'Fans Control Macros' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to control Motherboard fan from Web interfaces   ${white}│"
  echo -e " │ ${cyan}or with slicers.                                             ${white}│"
  hr
  bottom_line
}

function install_fans_control_macros(){
  fans_control_macros_message
  local yn
  while true; do
    install_msg "Fans Control Macros" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/fans-control.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/fans-control.cfg
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Linking file..."
        ln -sf "$FAN_CONTROLS_URL" "$HS_CONFIG_FOLDER"/fans-control.cfg
        if grep -q "include Helper-Script/fans-control" "$PRINTER_CFG" ; then
          echo -e "Info: Fans Control Macros configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding Fans Control Macros configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/fans-control\.cfg\]' "$PRINTER_CFG"
        fi
        if grep -q "\[duplicate_pin_override\]" "$PRINTER_CFG" ; then
          echo -e "Info: Disabling [duplicate_pin_override] configuration in printer.cfg file..."
          sed -i '/^\[duplicate_pin_override\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$PRINTER_CFG"
        else
          echo -e "Info: [duplicate_pin_override] configuration is already disabled in printer.cfg file..."
        fi
        if grep -q "\[temperature_fan chamber_fan\]" "$PRINTER_CFG" ; then
          echo -e "Info: Disabling [temperature_fan chamber_fan] configuration in printer.cfg file..."
          sed -i '/^\[temperature_fan chamber_fan\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$PRINTER_CFG"
        else
          echo -e "Info: [temperature_fan chamber_fan] configuration is already disabled in printer.cfg file..."
        fi
        if grep -q "\[gcode_macro M106\]" "$MACROS_CFG" ; then
          echo -e "Info: Disabling [gcode_macro M106] in gcode_macro.cfg file..."
          sed -i '/^\[gcode_macro M106\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro M106] macro is already disabled in gcode_macro.cfg file..."
        fi
        if grep -q "\[gcode_macro M141\]" "$MACROS_CFG" ; then
          echo -e "Info: Disabling [gcode_macro M141] in gcode_macro.cfg file..."
          sed -i '/^\[gcode_macro M141\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro M141] macro is already disabled in gcode_macro.cfg file..."
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Fans Control Macros have been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_fans_control_macros(){
  fans_control_macros_message
  local yn
  while true; do
    remove_msg "Fans Control Macros" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing file..."
        rm -f "$HS_CONFIG_FOLDER"/fans-control.cfg
        if grep -q "include Helper-Script/fans-control" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Fans Control Macros configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/fans-control\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Fans Control Macros configurations are already removed in printer.cfg file..."
        fi
        if grep -q "#\[duplicate_pin_override\]" "$PRINTER_CFG" ; then
          echo -e "Info: Enabling [duplicate_pin_override] in printer.cfg file..."
          sed -i -e 's/^\s*#[[:space:]]*\[duplicate_pin_override\]/[duplicate_pin_override]/' -e '/^\[duplicate_pin_override\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$PRINTER_CFG"
        else
          echo -e "Info: [duplicate_pin_override] is already enabled in printer.cfg file..."
        fi
        if grep -q "#\[temperature_fan chamber_fan\]" "$PRINTER_CFG" ; then
          echo -e "Info: Enabling [temperature_fan chamber_fan] in printer.cfg file..."
          sed -i -e 's/^\s*#[[:space:]]*\[temperature_fan chamber_fan\]/[temperature_fan chamber_fan]/' -e '/^\[temperature_fan chamber_fan\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$PRINTER_CFG"
        else
          echo -e "Info: [temperature_fan chamber_fan] is already enabled in printer.cfg file..."
        fi
        if grep -q "#\[gcode_macro M106\]" "$MACROS_CFG" ; then
          echo -e "Info: Enabling [gcode_macro M106] in gcode_macro.cfg file..."
          sed -i -e 's/^\s*#[[:space:]]*\[gcode_macro M106\]/[gcode_macro M106]/' -e '/^\[gcode_macro M106\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro M106] is already enabled in gcode_macro.cfg file..."
        fi
        if grep -q "#\[gcode_macro M141\]" "$MACROS_CFG" ; then
          echo -e "Info: Enabling [gcode_macro M141] in gcode_macro.cfg file..."
          sed -i -e 's/^\s*#[[:space:]]*\[gcode_macro M141\]/[gcode_macro M141]/' -e '/^\[gcode_macro M141\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro M141] is already enabled in gcode_macro.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Fans Control Macros have been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}