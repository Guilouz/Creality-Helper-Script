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
        if [ "$model" = "E5M" ]; then
          # E5M Specific Logic
          echo -e "Info: Applying E5M specific fan control macros..."
          if [ ! -d "$HS_BACKUP_FOLDER" ]; then
            mkdir -p "$HS_BACKUP_FOLDER"
          fi
          echo -e "Info: Backing up gcode_macro.cfg..."
          cp "$MACROS_CFG" "$HS_BACKUP_FOLDER/gcode_macro.cfg.e5m_fans_backup_$(date +%Y%m%d%H%M%S)"

          echo -e "Info: Removing existing M106 and M107 macros from gcode_macro.cfg..."
          # Delete M106 section - from [gcode_macro M106] to the line before the next [ or end of file
          sed -i.bak '/^\[gcode_macro M106\]/{:a;N;/\n\[/!s/\n.*//;Ta;P;D;}' "$MACROS_CFG"
          # Delete M107 section - similarly
          sed -i.bak '/^\[gcode_macro M107\]/{:a;N;/\n\[/!s/\n.*//;Ta;P;D;}' "$MACROS_CFG"
          # A simpler approach if sections are known to be contiguous or last:
          # sed -i '/^\[gcode_macro M106\]/,/^\[gcode_macro M107\]/{/^\[gcode_macro M107\]/!d;}' # if M107 is right after M106
          # Or more generally, delete from start of section to next section or EOF:
          sed -i -e '/^\[gcode_macro M106\]/{:loop1 N; /\n\[/!b loop1; /\n\[gcode_macro M106\]/P; D}' -e 's/\n$//' "$MACROS_CFG"
          sed -i -e '/^\[gcode_macro M107\]/{:loop2 N; /\n\[/!b loop2; /\n\[gcode_macro M107\]/P; D}' -e 's/\n$//' "$MACROS_CFG"
          # Fallback: Remove the lines if the previous sed commands were not fully effective or the sections are at the end.
          sed -i '/^\[gcode_macro M106\]/,/^\s*$/d' "$MACROS_CFG" # Delete M106 block ending with empty line
          sed -i '/^\[gcode_macro M107\]/,/^\s*$/d' "$MACROS_CFG" # Delete M107 block ending with empty line
          # Clean up extra blank lines that might result from deletions
          sed -i '/^$/N;/^\n$/D' "$MACROS_CFG"

          echo -e "Info: Appending E5M fan definitions to gcode_macro.cfg..."
          cat "$FAN_DEFINITIONS_E5M_URL" >> "$MACROS_CFG"

          if [ ! -d "$HS_CONFIG_FOLDER" ]; then
            mkdir -p "$HS_CONFIG_FOLDER"
          fi
          touch "$HS_CONFIG_FOLDER/e5m_custom_fan_definitions_applied.flag"
        else
          # Original logic for other printers
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
          # For non-E5M, we still need to disable M106 if it exists, as fans-control.cfg provides its own.
          # This part should ideally only affect non-E5M models after this modification.
          if grep -q "^\[gcode_macro M106\]" "$MACROS_CFG" ; then
            echo -e "Info: Disabling [gcode_macro M106] in gcode_macro.cfg file for non-E5M model (standard fans-control takes over)..."
            sed -i '/^\[gcode_macro M106\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MACROS_CFG"
          fi
          if grep -q "^\[gcode_macro M107\]" "$MACROS_CFG" ; then # M107 is usually not in default gcode_macro.cfg but check anyway
             echo -e "Info: Disabling [gcode_macro M107] in gcode_macro.cfg file for non-E5M model..."
             sed -i '/^\[gcode_macro M107\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MACROS_CFG"
          fi
          if grep -q "\[gcode_macro M141\]" "$MACROS_CFG" ; then
            echo -e "Info: Disabling [gcode_macro M141] in gcode_macro.cfg file..."
            sed -i '/^\[gcode_macro M141\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MACROS_CFG"
          else
            echo -e "Info: [gcode_macro M141] macro is already disabled in gcode_macro.cfg file..."
          fi
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
        if [ "$model" = "E5M" ]; then
          # E5M Specific Removal Logic
          echo -e "Info: Removing E5M specific fan control macros..."
          latest_backup=$(ls -t "$HS_BACKUP_FOLDER"/gcode_macro.cfg.e5m_fans_backup_* 2>/dev/null | head -n 1)
          if [ -f "$latest_backup" ]; then
            echo -e "Info: Restoring gcode_macro.cfg from $latest_backup..."
            cp "$latest_backup" "$MACROS_CFG"
            rm "$latest_backup"
          else
            echo -e "Warning: No backup found for gcode_macro.cfg. Attempting to remove E5M fan macros directly."
            # Fallback: Remove the E5M macros by their definition headers
            sed -i -e '/^\[gcode_macro M106\]/{:loop1 N; /\n\[/!b loop1; /\n\[gcode_macro M106\]/P; D}' -e 's/\n$//' "$MACROS_CFG"
            sed -i -e '/^\[gcode_macro M107\]/{:loop2 N; /\n\[/!b loop2; /\n\[gcode_macro M107\]/P; D}' -e 's/\n$//' "$MACROS_CFG"
            sed -i -e '/^\[gcode_macro TURN_OFF_FANS\]/{:loop3 N; /\n\[/!b loop3; /\n\[gcode_macro TURN_OFF_FANS\]/P; D}' -e 's/\n$//' "$MACROS_CFG"
            sed -i -e '/^\[gcode_macro TURN_ON_FANS\]/{:loop4 N; /\n\[/!b loop4; /\n\[gcode_macro TURN_ON_FANS\]/P; D}' -e 's/\n$//' "$MACROS_CFG"
            sed -i '/^$/N;/^\n$/D' "$MACROS_CFG"
          fi
          rm -f "$HS_CONFIG_FOLDER/e5m_custom_fan_definitions_applied.flag"
        else
          # Original logic for other printers
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
          # For non-E5M, re-enable M106 and M107 if they were commented out.
          # This assumes they were originally present and commented by this script.
          if grep -q "#\[gcode_macro M106\]" "$MACROS_CFG" ; then
            echo -e "Info: Enabling [gcode_macro M106] in gcode_macro.cfg file for non-E5M model..."
            sed -i -e 's/^\s*#[[:space:]]*\[gcode_macro M106\]/[gcode_macro M106]/' -e '/^\[gcode_macro M106\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MACROS_CFG"
          fi
          if grep -q "#\[gcode_macro M107\]" "$MACROS_CFG" ; then
             echo -e "Info: Enabling [gcode_macro M107] in gcode_macro.cfg file for non-E5M model..."
             sed -i -e 's/^\s*#[[:space:]]*\[gcode_macro M107\]/[gcode_macro M107]/' -e '/^\[gcode_macro M107\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MACROS_CFG"
          fi
          if grep -q "#\[gcode_macro M141\]" "$MACROS_CFG" ; then
            echo -e "Info: Enabling [gcode_macro M141] in gcode_macro.cfg file..."
            sed -i -e 's/^\s*#[[:space:]]*\[gcode_macro M141\]/[gcode_macro M141]/' -e '/^\[gcode_macro M141\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MACROS_CFG"
          else
            echo -e "Info: [gcode_macro M141] is already enabled in gcode_macro.cfg file..."
          fi
        fi
        # Check if HS_CONFIG_FOLDER is empty only if not E5M or if flag is also gone for E5M
        if [ "$model" != "E5M" ] && [ ! -n "$(ls -A "$HS_CONFIG_FOLDER" 2>/dev/null)" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        elif [ "$model" = "E5M" ] && [ ! -f "$HS_CONFIG_FOLDER/e5m_custom_fan_definitions_applied.flag" ] && [ ! -n "$(ls -A "$HS_CONFIG_FOLDER" 2>/dev/null | grep -v 'e5m_custom_fan_definitions_applied.flag')" ]; then
           # If E5M, and flag is gone, and dir is empty OR only contains other E5M flags for other features, then consider removing.
           # This logic might need to be more robust if other E5M flags exist.
           # Simplified: if flag is gone and dir is otherwise empty, rm it.
           if [ ! "$(ls -A "$HS_CONFIG_FOLDER" 2>/dev/null | grep -v '^e5m_custom_fan_definitions_applied.flag$' | tr -d '\n')" ]; then
             rm -rf "$HS_CONFIG_FOLDER"
           fi 
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