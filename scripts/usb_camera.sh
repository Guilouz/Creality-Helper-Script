#!/bin/sh

set -e

function usb_camera_message(){
  top_line
  title 'USB Camera Support' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to use third-party camera from your printer's    ${white}│"
  echo -e " │ ${cyan}USB port.                                                    ${white}│"
  hr
  bottom_line
}

function install_usb_camera(){
  usb_camera_message
  local yn
  while true; do
    install_msg "USB Camera Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Copying file..."
        if [ "$model" = "K1" ]; then
          cp "$USB_CAMERA_DUAL_URL" "$INITD_FOLDER"/S50usb_camera
        else
          cp "$USB_CAMERA_SINGLE_URL" "$INITD_FOLDER"/S50usb_camera
          echo
          echo -e " ${darkred}Be careful with the 1080p resolution!"
          echo -e " It takes more resources and timelapses are larger and take longer to convert.${white}"
          echo -e " 720p is a good compromise between quality and performance."
          echo -e " Make sure your camera is compatible with the chosen resolution."
          echo
          local resolution
          while true; do
            read -p " What camera resolution do you want to apply? (${yellow}480p${white}/${yellow}720p${white}/${yellow}1080p${white}): ${yellow}" resolution
            case "${resolution}" in
              480p|480P)
                echo -e "${white}"
                echo -e "Info: Applying change..."
                sed -i 's/1280x720/640x480/g' "$INITD_FOLDER"/S50usb_camera
              break;;
              720p|720P)
                echo -e "${white}"
                echo -e "Info: Applying change..."
              break;;
              1080p|1080p)
                echo -e "${white}"
                echo -e "Info: Applying change..."
                sed -i 's/1280x720/1920x1080/g' "$INITD_FOLDER"/S50usb_camera
              break;;
              *)
                error_msg "Please select a correct choice!";;
            esac
          done
        fi
        chmod 755 "$INITD_FOLDER"/S50usb_camera
        echo -e "Info: Installing necessary packages..."
        "$ENTWARE_FILE" update && "$ENTWARE_FILE" install mjpg-streamer mjpg-streamer-input-http mjpg-streamer-input-uvc mjpg-streamer-output-http mjpg-streamer-www
        echo -e "Info: Starting service..."
        "$INITD_FOLDER"/S50usb_camera start
        ok_msg "USB Camera Support has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_usb_camera(){
  usb_camera_message
  local yn
  while true; do
    remove_msg "USB Camera Support" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Stopping service..."
        "$INITD_FOLDER"/S50usb_camera stop
        echo -e "Info: Removing file..."
        rm -f "$INITD_FOLDER"/S50usb_camera
        echo -e "Info: Removing packages..."
        set +e
        "$ENTWARE_FILE" --autoremove remove mjpg-streamer-www
        "$ENTWARE_FILE" --autoremove remove mjpg-streamer-output-http
        "$ENTWARE_FILE" --autoremove remove mjpg-streamer-input-uvc
        "$ENTWARE_FILE" --autoremove remove mjpg-streamer-input-http
        "$ENTWARE_FILE" --autoremove remove mjpg-streamer
        set -e
        ok_msg "USB Camera Support has been removed successfully!"
        echo -e "   Please reboot your printer by using power switch on back!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
