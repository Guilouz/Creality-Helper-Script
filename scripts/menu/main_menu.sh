#!/bin/sh

set -e

if /usr/bin/get_sn_mac.sh model 2>&1 | grep -iq "K1"; then K1=1; else K1=0; fi

function get_script_version() {
  local version
  cd "${HELPER_SCRIPT_FOLDER}"
  version="$(git describe HEAD --always --tags | sed 's/-.*//')"
  echo "${cyan}${version}${white}"
}

function version_line() {
  local content="$1"
  local content_length="${#content}"
  local width=$((73))
  local padding_length=$((width - content_length - 3))
  printf " │ %*s%s%s\n" $padding_length '' "$content" " │"
}

function script_title() {
  local title
  if [ $K1 -eq 0 ]; then
    title="KE"
  else
    title="K1"
  fi
  echo "${title}"
}

function fw_version() {
  local firmware
  if [ $K1 -eq 0 ]; then
    firmware="1.1.0.12"
  else
    firmware="1.3.3.5"
  fi
  echo "${firmware}"
}

function main_menu_ui() {
  top_line
  title "• HELPER SCRIPT FOR CREALITY $(script_title) SERIES •" "${blue}"
  title "Copyright © Cyril Guislain (Guilouz)" "${white}"
  inner_line
  title "/!\\ ONLY USE IT WITH FIRMWARE $(fw_version) AND ABOVE /!\\" "${darkred}"
  inner_line
  hr
  main_menu_option '1' '[Install]' 'Menu'
  main_menu_option '2' '[Remove]' 'Menu'
  main_menu_option '3' '[Customize]' 'Menu'
  main_menu_option '4' '[Backup & Restore]' 'Menu'
  main_menu_option '5' '[Tools]' 'Menu'
  main_menu_option '6' '[Informations]' 'Menu'
  main_menu_option '7' '[System]' 'Menu'
  hr
  inner_line
  hr
  bottom_menu_option 'q' 'Exit' "${darkred}"
  hr
  version_line "$(get_script_version)"
  bottom_line
}

function main_menu() {
  clear
  main_menu_ui
  local main_menu_opt
  while true; do
    read -p "${white} Type your choice and validate with Enter: ${yellow}" main_menu_opt
    case "${main_menu_opt}" in
      1) clear
         if [ $K1 -eq 0 ]; then
           install_menu_ke
         else
           install_menu
         fi
         break;;
      2) clear
         if [ $K1 -eq 0 ]; then
           remove_menu_ke
         else
           remove_menu
         fi
         break;;
      3) clear
         if [ $K1 -eq 0 ]; then
           customize_menu_ke
         else
           customize_menu
         fi
         break;;
      4) clear
         backup_restore_menu
         break;;
      5) clear
         if [ $K1 -eq 0 ]; then
           tools_menu_ke
         else
           tools_menu
         fi
         main_ui;;
      6) clear
         if [ $K1 -eq 0 ]; then
           info_menu_ke
         else
           info_menu
         fi
         break;;
      7) clear
         system_menu
         break;;
      Q|q)
         clear; exit 0;;
      *)
         error_msg "Please select a correct choice!";;
    esac
  done
  main_menu
}
