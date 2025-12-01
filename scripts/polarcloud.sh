#!/bin/sh

set -e

function polarcloud_message(){
  top_line
  title 'Polar Cloud' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Polar Cloud provides remote access and monitoring for your   ${white}│"
  echo -e " │ ${cyan}3D printer. Connect to your printer from anywhere, manage    ${white}│"
  echo -e " │ ${cyan}print jobs, and access cloud-based slicing features.         ${white}│"
  hr
  bottom_line
}

function install_polarcloud(){
  polarcloud_message
  local yn
  while true; do
    install_msg "Polar Cloud" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -d "$POLARCLOUD_FOLDER" ]; then
          echo -e "Info: Polar Cloud is already installed. Download skipped."
        else
          echo -e "Info: Downloading Polar Cloud..."
          git config --global http.sslVerify false
          git clone "$POLARCLOUD_URL" "$POLARCLOUD_FOLDER"
        fi
        echo -e "Info: Running Polar Cloud installer..."
        cd "$POLARCLOUD_FOLDER"
        sh ./install.sh
        echo
        ok_msg "Polar Cloud has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_polarcloud(){
  polarcloud_message
  local yn
  while true; do
    remove_msg "Polar Cloud" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Running Polar Cloud uninstaller..."
        cd "$POLARCLOUD_FOLDER"
        sh ./uninstall.sh
        echo
        ok_msg "Polar Cloud has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
