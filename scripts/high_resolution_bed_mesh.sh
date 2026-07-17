#!/bin/sh

set -e

function high_resolution_bed_mesh_message(){
  top_line
  title 'High Resolution Bed Mesh' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows Useful Macros to generate full bed meshes up to   ${white}│"
  echo -e " │ ${cyan}10x10 on K1 Max without changing the stock G29 workflow.    ${white}│"
  hr
  bottom_line
}

function install_high_resolution_bed_mesh(){
  high_resolution_bed_mesh_message
  local yn
  while true; do
    install_msg "High Resolution Bed Mesh" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Linking files..."
        ln -sf "$HIGH_RES_BED_MESH_URL" "$HIGH_RES_BED_MESH_FILE"
        ln -sf "$PRTOUCH_EXTENDED_POINTS_URL" "$PRTOUCH_EXTENDED_POINTS_FILE"
        if grep -q "include Helper-Script/high-resolution-bed-mesh" "$PRINTER_CFG" ; then
          echo -e "Info: High Resolution Bed Mesh is already enabled in printer.cfg file..."
        else
          echo -e "Info: Adding High Resolution Bed Mesh to printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include Helper-Script/high-resolution-bed-mesh\.cfg\]' "$PRINTER_CFG"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "High Resolution Bed Mesh has been installed successfully!"
        echo -e "   ${white}Run ${yellow}BED_LEVELING POINTS=9${white} for a 9x9 full bed mesh."
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_high_resolution_bed_mesh(){
  high_resolution_bed_mesh_message
  local yn
  while true; do
    remove_msg "High Resolution Bed Mesh" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing files..."
        rm -f "$HIGH_RES_BED_MESH_FILE"
        rm -f "$PRTOUCH_EXTENDED_POINTS_FILE"
        rm -f "${PRTOUCH_EXTENDED_POINTS_FILE}c"
        rm -f "$KLIPPER_EXTRAS_FOLDER"/__pycache__/prtouch_extended_points.*.pyc
        if grep -q "include Helper-Script/high-resolution-bed-mesh" "$PRINTER_CFG" ; then
          echo -e "Info: Removing High Resolution Bed Mesh from printer.cfg file..."
          sed -i '/include Helper-Script\/high-resolution-bed-mesh\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: High Resolution Bed Mesh is already removed from printer.cfg file..."
        fi
        if [ -d "$HS_CONFIG_FOLDER" ] && [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "High Resolution Bed Mesh has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
