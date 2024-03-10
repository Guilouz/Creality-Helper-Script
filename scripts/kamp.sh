#!/bin/sh

set -e

function kamp_message(){
  top_line
  title 'Klipper Adaptive Meshing & Purging' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}KAMP is an extension that allows to generate a mesh and      ${white}│"
  echo -e " │ ${cyan}purge line only in the area you really need it.              ${white}│"
  hr
  bottom_line
}

function install_kamp(){
  kamp_message
  local yn
  while true; do
    install_msg "Klipper Adaptive Meshing & Purging" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -d "$HS_CONFIG_FOLDER"/KAMP ]; then
          rm -rf "$HS_CONFIG_FOLDER"/KAMP
        fi
        if [ -f "$HS_CONFIG_FOLDER"/KAMP_Settings.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/KAMP_Settings.cfg
        fi
        echo -e "Info: Creating directories..."
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        mkdir -p "$HS_CONFIG_FOLDER"/KAMP
        echo -e "Info: Linking files..."
        ln -sf "$KAMP_URL"/Adaptive_Meshing.cfg "$KAMP_FOLDER"/Adaptive_Meshing.cfg
        ln -sf "$KAMP_URL"/Line_Purge.cfg "$KAMP_FOLDER"/Line_Purge.cfg
        ln -sf "$KAMP_URL"/Prusa_Slicer.cfg "$KAMP_FOLDER"/Prusa_Slicer.cfg
        ln -sf "$KAMP_URL"/Smart_Park.cfg "$KAMP_FOLDER"/Smart_Park.cfg
        ln -sf "$KAMP_URL"/Start_Print.cfg "$KAMP_FOLDER"/Start_Print.cfg
        cp "$KAMP_URL"/KAMP_Settings.cfg "$KAMP_FOLDER"/KAMP_Settings.cfg
        if grep -q "include Helper-Script/KAMP/KAMP_Settings" "$PRINTER_CFG" ; then
          echo -e "Info: KAMP configurations are already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding KAMP configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a [include Helper-Script/KAMP/KAMP_Settings.cfg]' "$PRINTER_CFG"
        fi
        if grep -q "\[gcode_macro START_PRINT\]" "$MACROS_CFG" ; then
          echo -e "Info: Disabling [gcode_macro START_PRINT] in gcode_macro.cfg file..."
          sed -i '/\[gcode_macro START_PRINT\]/,/^\s*CX_PRINT_DRAW_ONE_LINE/ { /^\s*$/d }' "$MACROS_CFG"
          sed -i '/^\[gcode_macro START_PRINT\]/,/^\s*$/ s/^\(\s*\)\([^#]\)/#\1\2/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro START_PRINT] is already disabled in gcode_macro.cfg file..."
        fi
        echo
        local yn_prusa
        while true; do
          read -p " Do you want to enable needed macros for PrusaSlicer? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn_prusa
          case "${yn_prusa}" in
            Y|y)
              echo -e "${white}"
              if grep -q "#\[include Prusa_Slicer.cfg\]" "$KAMP_FOLDER"/KAMP_Settings.cfg ; then
                echo -e "Info: Enabling [include Prusa_Slicer.cfg] in KAMP_Settings.cfg file..."
                sed -i 's/^#\[include Prusa_Slicer\.cfg\]/[include Prusa_Slicer.cfg]/' "$KAMP_FOLDER"/KAMP_Settings.cfg
              else
                echo -e "Info: [include Prusa_Slicer.cfg] is already enabled in KAMP_Settings.cfg file..."
              fi
              break;;
            N|n)
              echo -e "${white}"
              break;;
            *)
              error_msg "Please select a correct choice!";;
          esac
        done
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Klipper Adaptive Meshing & Purging has been installed successfully!"
        echo -e "   Make sure Label Objects setting is enabled in your slicer."
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_kamp(){
  kamp_message
  local yn
  while true; do
    remove_msg "Klipper Adaptive Meshing & Purging" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing files..." 
        rm -rf "$HS_CONFIG_FOLDER"/KAMP
        if grep -q "include Helper-Script/KAMP/KAMP_Settings" "$PRINTER_CFG" ; then
          echo -e "Info: Removing KAMP configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/KAMP\/KAMP_Settings\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: KAMP configurations are already removed in printer.cfg file..."
        fi
        if grep -q "#\[gcode_macro START_PRINT\]" "$MACROS_CFG" ; then
          echo -e "Info: Enabling [gcode_macro START_PRINT] in gcode_macro.cfg file..."
          sed -i -e 's/^\s*#[[:space:]]*\[gcode_macro START_PRINT\]/[gcode_macro START_PRINT]/' -e '/^\[gcode_macro START_PRINT\]/,/^\s*$/ s/^\(\s*\)#/\1/' "$MACROS_CFG"
        else
          echo -e "Info: [gcode_macro START_PRINT] is already enabled in gcode_macro.cfg file..."
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Klipper Adaptive Meshing & Purging has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}