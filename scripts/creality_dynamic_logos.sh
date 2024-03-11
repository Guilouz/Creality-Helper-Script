#!/bin/sh

set -e

function creality_dynamic_logos_message(){
  top_line
  title 'Creality Dynamic Logos for Fluidd' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to have the dynamic Creality logos on the Fluidd ${white}│"
  echo -e " │ ${cyan}Web interface.                                               ${white}│"
  hr
  bottom_line
}

function install_creality_dynamic_logos(){
  creality_dynamic_logos_message
  local yn
  while true; do
    install_msg "Creality Dynamic Logos for Fluidd" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Copying files..."
        cp "$FLUIDD_LOGO_URL1" "$FLUIDD_FOLDER"/logo_creality_v1.svg
        cp "$FLUIDD_LOGO_URL2" "$FLUIDD_FOLDER"/logo_creality_v2.svg
        rm -f "$FLUIDD_FOLDER"/config.json
        cp "$FLUIDD_LOGO_URL3" "$FLUIDD_FOLDER"/config.json
        ok_msg "Creality Dynamic Logos for Fluidd have been installed successfully!"
        echo -e "   You can now select ${yellow}Creality V1 ${white}or ${yellow}Creality V2 ${white}theme in Fluidd settings."
        echo -e "   Note: In some cases, it's necessary to clear your web browser's cache to see themes appear."
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}