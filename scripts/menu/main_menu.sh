#!/bin/sh

set -e

if [ ! -f /etc/init.d/S58factoryreset ]; then
  cp /usr/data/helper-script/files/services/S58factoryreset /etc/init.d/S58factoryreset
  chmod 755 /etc/init.d/S58factoryreset
fi

get_model=$( /usr/bin/get_sn_mac.sh model 2>&1 )
if echo "$get_model" | grep -iq "K1"; then
  model="K1"
else
  echo -e "\033[01;31m Error: this fork supports only the Creality K1C (detected model: ${get_model}).\033[m"
  exit 1
fi

function get_script_version() {
  local version
  cd "${HELPER_SCRIPT_FOLDER}"
  version="$(git describe HEAD --always --tags | sed 's/-.*//')"
  echo "${cyan}${version}${white}"
}

function version_line() {
  local content="$1"
  local content_length="${#content}"
  local width=$((75))
  local padding_length=$((width - content_length - 3))
  printf " │ %*s%s%s\n" $padding_length '' "$content" " │"
}

function script_title() {
  echo "K1C"
}

function main_menu_ui() {
  top_line
  title "• HELPER SCRIPT FOR CREALITY $(script_title) •" "${blue}"
  title "Copyright © Cyril Guislain (Guilouz)" "${white}"
  inner_line
  title "/!\\ ONLY USE THIS SCRIPT WITH LATEST FIRMWARE VERSION /!\\" "${darkred}"
  inner_line
  hr
  main_menu_option '1' '[Install]' 'Menu'
  main_menu_option '2' '[Remove]' 'Menu'
  main_menu_option '3' '[Customize]' 'Menu'
  main_menu_option '4' '[Backup & Restore]' 'Menu'
  main_menu_option '5' '[Tools]' 'Menu'
  main_menu_option '6' '[Information]' 'Menu'
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
         install_menu_k1
         break;;
      2) clear
         remove_menu_k1
         break;;
      3) clear
         customize_menu_k1
         break;;
      4) clear
         backup_restore_menu
         break;;
      5) clear
         tools_menu_k1
         main_ui;;
      6) clear
         info_menu_k1
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
