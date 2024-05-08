#!/bin/sh

set -e

function git_backup_message(){
  top_line
  title 'Git Backup' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}It allows to watch Klipper configuration folder and          ${white}│"
  echo -e " │ ${cyan}automatically backup to GitHub whenever a change is made in  ${white}│"
  echo -e " │ ${cyan}that directory.                                              ${white}│"
  hr
  bottom_line
}

function install_git_backup(){
  git_backup_message
  local yn
  while true; do
    install_msg "Git Backup" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$HS_CONFIG_FOLDER"/git-backup.cfg ]; then
          rm -f "$HS_CONFIG_FOLDER"/git-backup.cfg
        fi
        if [ -d "$KLIPPER_CONFIG_FOLDER"/.git ]; then
          rm -rf "$KLIPPER_CONFIG_FOLDER"/.git
        fi
        if [ -d "$HS_BACKUP_FOLDER"/git-backup ]; then
          rm -rf "$HS_BACKUP_FOLDER"/git-backup
        fi
        if [ ! -d "$HS_CONFIG_FOLDER" ]; then
          mkdir -p "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Running Git Backup installer..."
        chmod 755 "$GIT_BACKUP_INSTALLER"
        sh "$GIT_BACKUP_INSTALLER" -i
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_git_backup(){
  git_backup_message
  local yn
  while true; do
    remove_msg "Git Backup" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Stopping services..."
        set +e
        /etc/init.d/S52Git-Backup stop >/dev/null 2>&1
        killall -q git-backup.sh
        killall -q inotifywait
        set -e
        echo -e "Info: Removing files..."
        rm -f "$HS_CONFIG_FOLDER"/git-backup.cfg
        if [ -f "$INITD_FOLDER"/S52Git-Backup ];then
          rm -f "$INITD_FOLDER"/S52Git-Backup
        fi
        if [ -f "$INITD_FOLDER"/disabled.S52Git-Backup ];then
          rm -f "$INITD_FOLDER"/disabled.S52Git-Backup
        fi
        rm -rf "$KLIPPER_CONFIG_FOLDER"/.git
        rm -rf "$HS_BACKUP_FOLDER"/git-backup
        if [ ! -n "$(ls -A "$HS_BACKUP_FOLDER")" ]; then
          rm -rf "$HS_BACKUP_FOLDER"
        fi
        if grep -q "include Helper-Script/git-backup" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Git Backup configurations in printer.cfg file..."
          sed -i '/include Helper-Script\/git-backup\.cfg/d' "$PRINTER_CFG"
        else
          echo -e "Info: Git Backup configurations are already removed in printer.cfg file..."
        fi
        if [ -f "$ENTWARE_FILE" ]; then
          echo -e "Info: Removing packages..."
          set +e
          "$ENTWARE_FILE" --autoremove remove inotifywait
          set -e
        fi
        if [ ! -n "$(ls -A "$HS_CONFIG_FOLDER")" ]; then
          rm -rf "$HS_CONFIG_FOLDER"
        fi
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        ok_msg "Git Backup has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}
