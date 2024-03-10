#!/bin/sh

set -e

function octoeverywhere_message(){
  top_line
  title 'OctoEverywhere' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Cloud empower your Klipper printers with free, private, and  ${white}│"
  echo -e " │ ${cyan}unlimited remote access to your full web control portal from ${white}│"
  echo -e " │ ${cyan}anywhere!                                                    ${white}│"
  hr
  bottom_line
}

function install_octoeverywhere(){
  octoeverywhere_message
  local yn
  while true; do
    install_msg "OctoEverywhere" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -d "$OCTOEVERYWHERE_FOLDER" ]; then
		  echo -e "Info: OctoEverywhere is already installed. Download skipped."
		else
          echo -e "Info: Downloading OctoEverywhere..."
          git config --global http.sslVerify false
          git clone "$OCTOEVERYWHERE_URL" "$OCTOEVERYWHERE_FOLDER"
		fi
		echo -e "Info: Running OctoEverywhere installer..."
		cd "$OCTOEVERYWHERE_FOLDER"
		sh ./install.sh
        ok_msg "OctoEverywhere has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_octoeverywhere(){
  octoeverywhere_message
  local yn
  while true; do
    remove_msg "OctoEverywhere" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Running OctoEverywhere installer..."
        cd "$OCTOEVERYWHERE_FOLDER"
		sh ./uninstall.sh
        ok_msg "OctoEverywhere has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}