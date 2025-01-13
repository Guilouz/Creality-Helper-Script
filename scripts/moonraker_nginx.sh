#!/bin/sh

set -e

function moonraker_nginx_message(){
  top_line
  title 'Moonraker and Nginx' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Moonraker is a Python 3 based web server that exposes APIs   ${white}│"
  echo -e " │ ${cyan}with which client applications may use to interact with      ${white}│"
  echo -e " │ ${cyan}Klipper firmware.                                            ${white}│"
  echo -e " │ ${cyan}Nginx is a web server that can also be used as a reverse     ${white}│" 
  echo -e " │ ${cyan}proxy, load balancer, mail proxy and HTTP cache.             ${white}│"
  hr
  bottom_line
}

function moonraker_3v3_message(){
  top_line
  title 'Updated Moonraker' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Moonraker is a Python 3 based web server that exposes APIs   ${white}│"
  echo -e " │ ${cyan}with which client applications may use to interact with      ${white}│"
  echo -e " │ ${cyan}Klipper firmware.                                            ${white}│"
  echo -e " │ ${cyan}This allows to have an updated version of Moonraker.         ${white}│"
  hr
  bottom_line
}

function install_moonraker_nginx(){
  moonraker_nginx_message
  local yn
  while true; do
    install_msg "Moonraker and Nginx" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Extracting Moonraker files..."
        tar -xvf "$MOONRAKER_URL1" -C "$USR_DATA"
        echo -e "Info: Extracting Nginx files..."
        tar -xvf "$NGINX_URL" -C "$USR_DATA"
        echo -e "Info: Copying services files..."
        if [ ! -f "$INITD_FOLDER"/S50nginx ]; then
          cp "$NGINX_SERVICE_URL" "$INITD_FOLDER"/S50nginx
          chmod +x "$INITD_FOLDER"/S50nginx
        fi
        if [ ! -f "$INITD_FOLDER"/S56moonraker_service ]; then
          cp "$MOONRAKER_SERVICE_URL" "$INITD_FOLDER"/S56moonraker_service
          chmod +x "$INITD_FOLDER"/S56moonraker_service
        fi
        echo -e "Info: Copying Moonraker configuration file..."
        if [ -f "$KLIPPER_CONFIG_FOLDER"/moonraker.conf ]; then
          rm -f "$KLIPPER_CONFIG_FOLDER"/moonraker.conf
        fi
        cp "$MOONRAKER_URL2" "$KLIPPER_CONFIG_FOLDER"/moonraker.conf
        if [ -f "$PRINTER_DATA_FOLDER"/moonraker.asvc ]; then
          rm -f "$PRINTER_DATA_FOLDER"/moonraker.asvc
        fi
        cp "$MOONRAKER_URL3" "$PRINTER_DATA_FOLDER"/moonraker.asvc
        echo -e "Info: Applying changes from official repo..."
        cd "$MOONRAKER_FOLDER"/moonraker
        git stash; git checkout master; git pull
        echo -e "Info: Installing Supervisor Lite..."
        chmod 755 "$SUPERVISOR_URL"
        ln -sf "$SUPERVISOR_URL" "$SUPERVISOR_FILE"
        echo -e "Info: Installing Host Controls Support..."
        chmod 755 "$SUDO_URL"
        chmod 755 "$SYSTEMCTL_URL"
        ln -sf "$SUDO_URL" "$SUDO_FILE"
        ln -sf "$SYSTEMCTL_URL" "$SYSTEMCTL_FILE"
        echo -e "Info: Starting Nginx service..."
        start_nginx
        echo -e "Info: Starting Moonraker service..."
        start_moonraker
        ok_msg "Moonraker and Nginx have been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_moonraker_nginx(){
  moonraker_nginx_message
  local yn
  while true; do
    remove_msg "Moonraker and Nginx" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Stopping Moonraker and Nginx services..."
        stop_moonraker
        stop_nginx
        echo -e "Info: Removing files..."
        rm -f "$INITD_FOLDER"/S50nginx
        rm -f "$INITD_FOLDER"/S56moonraker_service
        rm -f "$KLIPPER_CONFIG_FOLDER"/moonraker.conf
        rm -f "$KLIPPER_CONFIG_FOLDER"/.moonraker.conf.bkp
        rm -f "$PRINTER_DATA_FOLDER"/.moonraker.uuid
        rm -f "$PRINTER_DATA_FOLDER"/moonraker.asvc
        rm -rf "$PRINTER_DATA_FOLDER"/comms
        rm -rf "$NGINX_FOLDER"
        rm -rf "$MOONRAKER_FOLDER"
        rm -f "$SUPERVISOR_FILE"
        rm -f "$SUDO_FILE"
        rm -f "$SYSTEMCTL_FILE"
        ok_msg "Moonraker and Nginx have been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function install_moonraker_3v3(){
  moonraker_3v3_message
  local yn
  while true; do
    install_msg "Updated Moonraker" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Stopping Moonraker and Nginx services..."
        stop_moonraker
        stop_nginx
        echo -e "Info: Extracting files..."
        tar -xvf "$MOONRAKER_URL1" -C "$USR_DATA"
        echo -e "Info: Deleting existing folders..."
        rm -rf "$USR_SHARE"/moonraker
        rm -rf "$USR_SHARE"/moonraker-env
        echo -e "Info: Linking files..."
        ln -sf "$MOONRAKER_FOLDER"/moonraker "$USR_SHARE"/moonraker
        ln -sf "$MOONRAKER_FOLDER"/moonraker-env "$USR_SHARE"/moonraker-env
        if [ -f /etc/nginx/nginx.conf ]; then
          echo -e "Info: Copying Nginx configuration file..."
          mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
          cp "$NGINX_CONF_URL" /etc/nginx/nginx.conf
        fi
        if [ -f "$INITD_FOLDER"/S56moonraker_service ]; then
          echo -e "Info: Copying Moonraker service file..."
          mv "$INITD_FOLDER"/S56moonraker_service "$INITD_FOLDER"/disabled.S56moonraker_service
          cp "$MOONRAKER_SERVICE_URL" "$INITD_FOLDER"/S56moonraker_service
          chmod +x "$INITD_FOLDER"/S56moonraker_service
        fi
        echo -e "Info: Copying Moonraker configuration file..."
        if [ -f "$KLIPPER_CONFIG_FOLDER"/moonraker.conf ]; then
          rm -f "$KLIPPER_CONFIG_FOLDER"/moonraker.conf
        fi
        cp "$MOONRAKER_URL2" "$KLIPPER_CONFIG_FOLDER"/moonraker.conf
        if [ -f "$PRINTER_DATA_FOLDER"/moonraker.asvc ]; then
          rm -f "$PRINTER_DATA_FOLDER"/moonraker.asvc
        fi
        cp "$MOONRAKER_URL3" "$PRINTER_DATA_FOLDER"/moonraker.asvc
        echo -e "Info: Applying changes from official repo..."
        cd "$MOONRAKER_FOLDER"/moonraker
        git stash; git checkout master; git pull
        echo -e "Info: Installing Supervisor Lite..."
        chmod 755 "$SUPERVISOR_URL"
        ln -sf "$SUPERVISOR_URL" "$SUPERVISOR_FILE"
        echo -e "Info: Installing Host Controls Support..."
        chmod 755 "$SUDO_URL"
        chmod 755 "$SYSTEMCTL_URL"
        ln -sf "$SUDO_URL" "$SUDO_FILE"
        ln -sf "$SYSTEMCTL_URL" "$SYSTEMCTL_FILE"
        echo -e "Info: Starting Nginx service..."
        start_nginx
        echo -e "Info: Starting Moonraker service..."
        start_moonraker
        ok_msg "Updated Moonraker has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_moonraker_3v3(){
  moonraker_3v3_message
  local yn
  while true; do
    remove_msg "Updated Moonraker" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Stopping Moonraker and Nginx services..."
        stop_moonraker
        stop_nginx
        echo -e "Info: Removing files..."
        rm -rf "$PRINTER_DATA_FOLDER"/comms
        rm -rf "$MOONRAKER_FOLDER"
        rm -f "$KLIPPER_CONFIG_FOLDER"/moonraker.conf
        rm -f "$KLIPPER_CONFIG_FOLDER"/.moonraker.conf.bkp
        rm -f "$PRINTER_DATA_FOLDER"/.moonraker.uuid
        rm -f "$PRINTER_DATA_FOLDER"/moonraker.asvc
        rm -f "$SUPERVISOR_FILE"
        rm -f "$SUDO_FILE"
        rm -f "$SYSTEMCTL_FILE"
        if [ -f /etc/nginx/nginx.conf.backup ]; then
          echo -e "Info: Restoring stock Nginx configuration..."
          rm -f /etc/nginx/nginx.conf
          mv /etc/nginx/nginx.conf.backup /etc/nginx/nginx.conf
        fi
        if [ -f "$INITD_FOLDER"/disabled.S56moonraker_service ]; then
          echo -e "Info: Restoring Moonraker service file..."
          rm -f "$INITD_FOLDER"/S56moonraker_service
          mv "$INITD_FOLDER"/disabled.S56moonraker_service "$INITD_FOLDER"/S56moonraker_service
        fi
        echo -e "Info: Restoring stock Moonraker version..."
        rm -rf /overlay/upper/usr/share/moonraker
        rm -rf /overlay/upper/usr/share/moonraker-env
        mount -o remount /
        echo -e "Info: Starting Nginx service..."
        start_nginx
        echo -e "Info: Starting Moonraker service..."
        start_moonraker
        ok_msg "Updated Moonraker has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}