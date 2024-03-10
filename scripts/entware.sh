#!/bin/sh

set -e

function entware_message(){
  top_line
  title 'Entware' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Entware is a software repository for devices which use Linux ${white}│"
  echo -e " │ ${cyan}kernel. It allows packages to be added to your printer.      ${white}│"
  hr
  bottom_line
}

function install_entware(){
  entware_message
  local yn
  while true; do
    install_msg "Entware" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Running Entware installer..."
        set +e
        chmod 755 "$ENTWARE_URL"
        sh "$ENTWARE_URL"
        set -e
        ok_msg "Entware has been installed successfully!"
        echo -e "   Disconnect and reconnect SSH session, and you can now install packages with: ${yellow}opkg install <packagename>${white}"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_entware(){
  entware_message
  local yn
  while true; do
    remove_msg "Entware" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Removing startup script..."
        rm -f /etc/init.d/S50unslung
        echo -e "Info: Removing directories..."
        rm -rf /usr/data/opt
        if [ -L /opt ]; then
          rm /opt
          mkdir -p /opt
          chmod 755 /opt
        fi
        echo -e "Info: Removing SFTP server symlink..."
        [ -L /usr/libexec/sftp-server ] && rm /usr/libexec/sftp-server
        echo -e "Info: Removing changes in system profile..."
        rm -f /etc/profile.d/entware.sh
        sed -i 's/\/opt\/bin:\/opt\/sbin:\/bin:/\/bin:/' /etc/profile
        ok_msg "Entware has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}