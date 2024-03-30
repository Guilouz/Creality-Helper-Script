#!/bin/sh

set -e

function octoapp_message(){
  top_line
  title 'OctoApp Companion' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Control your Creality printer from your phone and ${white}│"
  echo -e " │ ${cyan}get notifications for your print!                 ${white}│"
  hr
  bottom_line
}

function install_octoapp(){
  octoapp_message
  local yn
  while true; do
    install_msg "OctoApp Companion" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -d "$OCTOAPP_FOLDER" ]; then
		  echo -e "Info: OctoApp Companion is already installed. Download skipped."
		else
          echo -e "Info: Downloading OctoApp Companion..."
          git config --global http.sslVerify false
          git clone "$OCTOAPP_URL" "$OCTOAPP_FOLDER"
		fi
		echo -e "Info: Running OctoApp Companion installer..."
		cd "$OCTOAPP_FOLDER"
		sh ./install.sh
        ok_msg "OctoApp Companion has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_octoapp(){
  octoapp_message
  local yn
  while true; do
    remove_msg "OctoApp Companion" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Running OctoApp Companion installer..."
        cd "$OCTOAPP_FOLDER"
		    sh ./uninstall.sh
        ok_msg "OctoApp Companion has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}