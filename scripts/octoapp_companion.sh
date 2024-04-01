#!/bin/sh

set -e

function octoapp_companion_message(){
  top_line
  title 'OctoApp Companion' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}OctoApp Companion allows you to control your printer from    ${white}│"
  echo -e " │ ${cyan}OctoApp and get notifications for your prints.               ${white}│"
  hr
  bottom_line
}

function install_octoapp_companion(){
  octoapp_companion_message
  local yn
  while true; do
    install_msg "OctoApp Companion" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -d "$OCTOAPP_COMPANION_FOLDER" ]; then
		  echo -e "Info: OctoApp Companion is already installed. Download skipped."
		else
          echo -e "Info: Downloading OctoApp Companion..."
          git config --global http.sslVerify false
          git clone "$OCTOAPP_COMPANION_URL" "$OCTOAPP_COMPANION_FOLDER"
		fi
		echo -e "Info: Running OctoApp Companion installer..."
		cd "$OCTOAPP_COMPANION_FOLDER"
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

function remove_octoapp_companion(){
  octoapp_companion_message
  local yn
  while true; do
    remove_msg "OctoApp Companion" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Running OctoApp Companion uninstaller..."
        cd "$OCTOAPP_COMPANION_FOLDER"
		sh ./uninstall.sh
		rm -f /root/update-OctoApp.sh
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