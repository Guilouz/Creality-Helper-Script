#!/bin/sh

set -e

function internal_camera_message(){
  top_line
  title 'Internal Camera Support' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This restores the internal camera stream in Mainsail and     ${white}│"
  echo -e " │ ${cyan}Fluidd on firmware 1.3.5.x and newer, where the camera is    ${white}│"
  echo -e " │ ${cyan}only reachable through cam_app.                              ${white}│"
  hr
  bottom_line
}

function install_internal_camera(){
  internal_camera_message
  local yn
  while true; do
    install_msg "Internal Camera Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Copying file..."
        cp "$INTERNAL_CAMERA_URL" "$INITD_FOLDER"/S59mjpg_streamer
        chmod 755 "$INITD_FOLDER"/S59mjpg_streamer
        echo -e "Info: Starting service..."
        "$INITD_FOLDER"/S59mjpg_streamer start
        ok_msg "Internal Camera Support has been installed successfully!"
        echo -e "   If the stream stays empty, add a webcam in your interface's settings"
        echo -e "   using ${cyan}/webcam/?action=stream${white} as stream URL."
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_internal_camera(){
  internal_camera_message
  local yn
  while true; do
    remove_msg "Internal Camera Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Stopping service..."
        "$INITD_FOLDER"/S59mjpg_streamer stop
        echo -e "Info: Removing file..."
        rm -f "$INITD_FOLDER"/S59mjpg_streamer
        ok_msg "Internal Camera Support has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
