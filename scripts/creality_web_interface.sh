#!/bin/sh

set -e

function remove_creality_web_interface_message(){
  top_line
  title 'Remove Creality Web Interface' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to remove Creality Web Interface and replace     ${white}│"
  echo -e " │ ${cyan}it with Fluidd or Mainsail on port 80.                       ${white}│"
  hr
  bottom_line
}

function restore_creality_web_interface_message(){
  top_line
  title 'Restore Creality Web Interface' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}This allows to restore Creality Web Interface on port 80.    ${white}│"
  hr
  bottom_line
}

function remove_creality_web_interface(){
  remove_creality_web_interface_message
  local yn
  while true; do
    remove_msg "Creality Web Interface" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Disabling files..."
        if [ -f /usr/bin/web-server ]; then
          mv /usr/bin/web-server /usr/bin/web-server.disabled
        fi
        if [ -f /usr/bin/Monitor ]; then
          mv /usr/bin/Monitor /usr/bin/Monitor.disabled
        fi
        echo -e "Info: Stopping services..."
        set +e
        killall -q Monitor
        killall -q web-server
        set -e
        if [ -d "$FLUIDD_FOLDER" ] && [ ! -d "$MAINSAIL_FOLDER" ]; then
          echo -e "Info: Applying changes..."
          sed -i '/listen 4408 default_server;/a \        listen 80;' /usr/data/nginx/nginx/nginx.conf
          echo -e "Info: Restarting Nginx service..."
          restart_nginx
          ok_msg "Creality Web Interface has been removed successfully!"
          echo -e " ${white}You can now connect to Fluidd Web Interface with ${yellow}http://$(check_ipaddress)${white}"
        elif [ ! -d "$FLUIDD_FOLDER" ] && [ -d "$MAINSAIL_FOLDER" ]; then
          echo -e "Info: Applying changes..."
          sed -i '/listen 4409 default_server;/a \        listen 80;' /usr/data/nginx/nginx/nginx.conf
          echo -e "Info: Restarting Nginx service..."
          restart_nginx
          ok_msg "Creality Web Interface has been removed successfully!"
          echo -e " ${white}You can now connect to Mainsail Web Interface with ${yellow}http://$(check_ipaddress)${white}"
        elif [ -d "$FLUIDD_FOLDER" ] && [ -d "$MAINSAIL_FOLDER" ]; then
          local interface_choice
          while true; do
            echo
            read -p " ${white}Which Web Interface do you want to set as default (on port 80)? (${yellow}fluidd${white}/${yellow}mainsail${white}): ${yellow}" interface_choice
            case "${interface_choice}" in
              FLUIDD|fluidd)
                echo -e "${white}"
                echo -e "Info: Applying changes..."
                sed -i '/listen 4408 default_server;/a \        listen 80;' /usr/data/nginx/nginx/nginx.conf
                echo -e "Info: Restarting Nginx service..."
                restart_nginx
                ok_msg "Creality Web Interface has been removed successfully!"
                echo -e "   You can now connect to Fluidd Web Interface with ${yellow}http://$(check_ipaddress) ${white}or ${yellow}http://$(check_ipaddress):4408${white}"
                break;;
              MAINSAIL|mainsail)
                echo -e "${white}"
                echo -e "Info: Applying changes..."
                sed -i '/listen 4409 default_server;/a \        listen 80;' /usr/data/nginx/nginx/nginx.conf
                echo -e "Info: Restarting Nginx service..."
                restart_nginx
                ok_msg "Creality Web Interface has been removed successfully!"
                echo -e "   You can now connect to Mainsail Web Interface with ${yellow}http://$(check_ipaddress) ${white}or ${yellow}http://$(check_ipaddress):4409${white}"
                break;;
              *)
                error_msg "Please select a correct choice!";;
            esac
          done
        fi
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function restore_creality_web_interface(){
  restore_creality_web_interface_message
  local yn
  while true; do
    restore_msg "Creality Web Interface" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Restoring files..."
        if [ -f /usr/bin/web-server.disabled ] && [ -f "$INITD_FOLDER"/S99start_app ]; then
          mv /usr/bin/web-server.disabled /usr/bin/web-server
        fi
        if [ -f /usr/bin/Monitor.disabled ] && [ ! -d "$GUPPY_SCREEN_FOLDER" ]; then
          mv /usr/bin/Monitor.disabled /usr/bin/Monitor
        fi
        echo -e "Info: Restoring changes..."
        sed -i '/listen 80;/d' /usr/data/nginx/nginx/nginx.conf
        echo -e "Info: Restarting services..."
        restart_nginx
        set +e
        killall -q Monitor
        killall -q web-server
        set -e
        if [ -f /usr/bin/web-server ] && [ -f "$INITD_FOLDER"/S99start_app ]; then
          /usr/bin/web-server > /dev/null 2>&1 &
        fi
        if [ -f /usr/bin/Monitor ] && [ ! -d "$GUPPY_SCREEN_FOLDER" ]; then
          /usr/bin/Monitor > /dev/null 2>&1 &
        fi
        ok_msg "Creality Web Interface has been restored successfully!"
        echo -e "   You can now connect to Creality Web Interface with ${yellow}http://$(check_ipaddress) ${white}and with ${yellow}Creality Print${white}."
        return;;
      N|n)
        error_msg "Restoration canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}