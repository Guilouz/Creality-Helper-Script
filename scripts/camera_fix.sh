#!/bin/sh

set -e

function camera_fix_message(){
  top_line
  title 'Fix internal camera for Fluidd and Mainsail' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Since firmware 1.3.5.22, the internal camera no longer works ${white}│"
  echo -e " │ ${cyan}in Fluidd and Mainsail. This fix starts a MJPG Streamer      ${white}│"
  echo -e " │ ${cyan}service which reads the camera stream from shared memory.    ${white}│"
  echo -e " │ ${cyan}Creality Print, WebRTC and AI detection keep working.        ${white}│"
  hr
  bottom_line
}

function install_camera_fix(){
  camera_fix_message
  local yn
  while true; do
    install_msg "Internal Camera Fix" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ ! -f /usr/lib/mjpg-streamer/input_memfd.so ]; then
          error_msg "Your firmware is not compatible with this fix (input_memfd.so not found)!"
          return
        fi
        if [ -f "$USB_CAMERA_FILE" ]; then
          error_msg "Please remove USB Camera Support first!"
          return
        fi
        echo -e "Info: Copying file..."
        cp "$CAMERA_FIX_URL" "$CAMERA_FIX_FILE"
        chmod 755 "$CAMERA_FIX_FILE"
        echo -e "Info: Starting service..."
        "$CAMERA_FIX_FILE" start
        if [ -f "$CAMERA_SETTINGS_FILE" ] && [ "$(camera_settings_url)" = "$CAMERA_SETTINGS_MEMFD_URL" ] && ! cmp -s "$CAMERA_SETTINGS_MEMFD_URL" "$CAMERA_SETTINGS_FILE"; then
          echo -e "Info: Replacing Camera Settings Control file with compatible values..."
          cp "$CAMERA_SETTINGS_FILE" "$CAMERA_SETTINGS_FILE".bak
          cp "$CAMERA_SETTINGS_MEMFD_URL" "$CAMERA_SETTINGS_FILE"
          echo -e "Info: Restarting Klipper service..."
          restart_klipper
        fi
        ok_msg "Internal Camera Fix has been installed successfully!"
        echo -e "   Note: This fix must be applied again after each firmware update."
        echo
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_camera_fix(){
  camera_fix_message
  local yn
  while true; do
    remove_msg "Internal Camera Fix" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Stopping service..."
        "$CAMERA_FIX_FILE" stop
        echo -e "Info: Removing file..."
        rm -f "$CAMERA_FIX_FILE"
        if [ -f "$CAMERA_SETTINGS_FILE".bak ]; then
          echo -e "Info: Restoring previous Camera Settings Control file..."
          mv -f "$CAMERA_SETTINGS_FILE".bak "$CAMERA_SETTINGS_FILE"
          echo -e "Info: Restarting Klipper service..."
          restart_klipper
        fi
        ok_msg "Internal Camera Fix has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
