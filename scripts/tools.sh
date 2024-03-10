#!/bin/sh

set -e

function prevent_updating_klipper_files_message(){
  top_line
  title 'Prevent updating Klipper configuration files' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This prevents updating Klipper configuration files when      ${white}│"
  echo -e " │ ${cyan}Klipper restarts.                                            ${white}│"
  hr
  bottom_line
}

function allow_updating_klipper_files_message(){
  top_line
  title 'Allow updating Klipper configuration files' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows updating Klipper configuration files when        ${white}│"
  echo -e " │ ${cyan}Klipper restarts.                                            ${white}│"
  hr
  bottom_line
}

function printing_gcode_from_folder_message(){
  top_line
  title 'Fix printing Gcode files from folder' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}From Fluidd or Mainsail it's possible to classify your Gcode ${white}│"
  echo -e " │ ${cyan}files in folders but by default it's not possible to start   ${white}│"
  echo -e " │ ${cyan}a print from a folder. This fix allows that.                 ${white}│"
  hr
  bottom_line
}

function restore_previous_firmware_message(){
  top_line
  title 'Restore a previous firmware' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}To restore a previous firmware, follow these steps and       ${white}│"
  echo -e " │ ${cyan}validate your choice:                                        ${white}│"
  echo -e " │                                                              │"
  echo -e " │ ${cyan}1. ${white}Copy the firmware (.img) you want to update to the root   ${white}│"
  echo -e " │    of a USB drive.                                           ${white}│"
  echo -e " │ ${cyan}2. ${white}Make sure there is only this file on the USB drive.       ${white}│"
  echo -e " │ ${cyan}3. ${white}Insert the USB drive into the printer.                    ${white}│"
  hr
  bottom_line
}

function reset_factory_settings_message(){
  top_line
  title 'Reset factory settings' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This the best way to reset the printer to its factory        ${white}│"
  echo -e " │ ${cyan}settings.                                                    ${white}│"
  echo -e " │ ${cyan}Note that the Factory Reset function in the screen menu      ${white}│"
  echo -e " │ ${cyan}settings only performs a partial reset.                      ${white}│"
  hr
  echo -e " │ ${cyan}Note: After factory reset all features already been          ${white}│"
  echo -e " │ ${cyan}installed with Creality Helper Script must be reinstalled    ${white}│"
  echo -e " │ ${cyan}and it's necessary to reconnect your printer to your network ${white}│"
  echo -e " │ ${cyan} from screen settings in `Settings` → `Network` tab.         ${white}│"
  hr
  bottom_line
}

function prevent_updating_klipper_files(){
  prevent_updating_klipper_files_message
  local yn
  while true; do
    read -p "${white} Do you want to prevent updating ${green}Klipper configuration files ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Backup file..."
        mv "$INITD_FOLDER"/S55klipper_service "$INITD_FOLDER"/disabled.S55klipper_service
        echo -e "Info: Copying file..."
        cp "$KLIPPER_SERVICE_URL" "$INITD_FOLDER"/S55klipper_service
        echo -e "Info: Applying permissions..."
        chmod 755 "$INITD_FOLDER"/S55klipper_service
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Klipper configuration files will no longer be updated when Klipper restarts!"
        return;;
      N|n)
        error_msg "Preventing canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function allow_updating_klipper_files(){
  allow_updating_klipper_files_message
  local yn
  while true; do
    read -p "${white} Do you want to allow updating ${green}Klipper configuration files ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Restoring file..."
        rm -f /etc/init.d/S55klipper_service
        mv "$INITD_FOLDER"/disabled.S55klipper_service "$INITD_FOLDER"/S55klipper_service
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Klipper configuration files will be updated when Klipper restarts!"
        return;;
      N|n)
        error_msg "Authorization canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function printing_gcode_from_folder(){
  printing_gcode_from_folder_message
  local yn
  while true; do
    read -p "${white} Do you want to apply fix for ${green}printing Gcode files from folder ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Deleting files..."
        if [ -f "$KLIPPER_KLIPPY_FOLDER"/gcode.py ]; then
          rm -f "$KLIPPER_KLIPPY_FOLDER"/gcode.py
          rm -f "$KLIPPER_KLIPPY_FOLDER"/gcode.pyc
        fi
        echo -e "Info: Linking files..."
        ln -sf "$KLIPPER_GCODE_URL" "$KLIPPER_KLIPPY_FOLDER"/gcode.py
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Fix has been applied successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function restart_nginx_action(){
  echo
  local yn
  while true; do
    restart_msg "Nginx service" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        stop_nginx
        start_nginx
        ok_msg "Nginx service has been restarted successfully!"
        return;;
      N|n)
        error_msg "Restart canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function restart_moonraker_action(){
  echo
  local yn
  while true; do
    restart_msg "Moonraker service" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        stop_moonraker
        start_moonraker
        ok_msg "Moonraker service has been restarted successfully!"
        return;;
      N|n)
        error_msg "Restart canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function restart_klipper_action(){
  echo
  local yn
  while true; do
    restart_msg "Klipper service" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        restart_klipper
        ok_msg "Klipper service has been restarted successfully!"
        return;;
      N|n)
        error_msg "Restart canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function update_entware_packages(){
  echo
  local yn
  while true; do
    read -p "${white} Are you sure you want to update ${green}Entware packages ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Updating packages list..."
        "$ENTWARE_FILE" update
        echo -e "Info: Updating packages..."
        "$ENTWARE_FILE" upgrade
        ok_msg "Entware packages have been updated!"
        return;;
      N|n)
        error_msg "Updating canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function clear_cache(){
  echo
  local yn
  while true; do
    read -p "${white} Are you sure you want to ${green}clear cache ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Clearing root partition cache..."
        rm -rf /root/.cache
        echo -e "Info: Clearing git cache..."
        cd "${HELPER_SCRIPT_FOLDER}"
        git gc --aggressive --prune=all
        ok_msg "Cache has been cleared!"
        return;;
      N|n)
        error_msg "Clearing cache canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function clear_logs(){
  echo
  local yn
  while true; do
    read -p "${white} Are you sure you want to clear ${green}logs files ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Clearing logs files..."
        rm -f "$USR_DATA"/creality/userdata/log/*.log
        rm -f "$USR_DATA"/creality/userdata/log/*.gz
        rm -f "$USR_DATA"/creality/userdata/fault_code/*
        rm -f "$PRINTER_DATA_FOLDER"/logs/*
        ok_msg "Logs files have been cleared!"
        return;;
      N|n)
        error_msg "Clearing logs files canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function restore_previous_firmware(){
  restore_previous_firmware_message
  local yn
  while true; do
    read -p "${white} Do you want to restore a previous firmware ? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        if ls /tmp/udisk/sda1/*.img 1> /dev/null 2>&1; then
          echo -e "${white}"
          echo "Info: Restoring firmware..."
          rm -rf /overlay/upper/*
          /etc/ota_bin/local_ota_update.sh /tmp/udisk/sda1/*.img
          ok_msg "Firmware has been restored! Please reboot your printer."
          exit 0
        else
          error_msg "No .img file found on the USB drive. Restoration canceled!"
        fi
        return;;
      N|n)
        error_msg "Restoration canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function reset_factory_settings(){
  reset_factory_settings_message
  local yn
  while true; do
    read -p "${white} Are you sure you want to ${green}reset factory settings ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Restoration..."
        echo "all" | nc -U /var/run/wipe.sock
        ;;
      N|n)
        error_msg "Reset canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}