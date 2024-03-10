#!/bin/sh

set -e

function top_line() {
  echo -e "${white}"
  echo -e " ┌──────────────────────────────────────────────────────────────┐"
}

function hr() {
  echo -e " │                                                              │"
}

function inner_line() {
  echo -e " ├──────────────────────────────────────────────────────────────┤"
}

function bottom_line() {
  echo -e " └──────────────────────────────────────────────────────────────┘"
  echo -e "${white}"
}

function blank_line() {
  echo -e " "
}

function title() {
  local text=$1
  local color=$2
  local max_length=62
  local text_length=${#text}
  local padding_left=$(((max_length - text_length) / 2))
  local padding_right=$((max_length - text_length - padding_left))
  printf " │%*s${color}%s${white}%*s│\n" $padding_left '' "$text" $padding_right ''
}

function subtitle() {
  local menu_text1=$1
  local max_length=61
  local padding=$((max_length - ${#menu_text1}))
  printf " │ ${blue}${menu_text1}%-${padding}s${white}│\n" ''
}

function main_menu_option() {
  local menu_number=$1
  local menu_text1=$2
  local menu_text2=$3
  local max_length=56
  local total_text_length=$(( ${#menu_text1} + ${#menu_text2} ))
  local padding=$((max_length - total_text_length))
  printf " │  ${yellow}${menu_number}${white}) ${green}${menu_text1} ${white}${menu_text2}%-${padding}s${white}│\n" ''
}

function menu_option() {
  local menu_number=$1
  local menu_text1=$2
  local menu_text2=$3
  local max_length=60
  local total_text_length=$(( ${#menu_text1} + ${#menu_text2} + ${#menu_number} + 4 ))
  local padding=$((max_length - total_text_length))
  printf " │   ${yellow}${menu_number}${white}) ${white}${menu_text1} ${green}${menu_text2}%-${padding}s${white}│\n" ''
}

function bottom_menu_option() {
  local menu_number=$1
  local menu_text=$2
  local color=$3
  local max_length=57
  local padding=$((max_length - ${#menu_text}))
  printf " │  $color${menu_number}${white}) ${white}${menu_text}%-${padding}s${white}│\n" ''
}

function info_line() {
  local status=$1
  local text=$2
  local color=$3
  local max_length=66
  local total_text_length=$(( ${#status} + ${#text} ))
  local padding=$((max_length - total_text_length))
  printf " │   $color${status} ${white}${text}%-${padding}s${white}│\n" ''
}

function system_line() {
  local title="$1"
  local value="$2"
  local max_length=61
  local title_length=${#title}
  local separator=": "
  local value_length=${#value}
  local value_padding=$((max_length - title_length - ${#separator} - value_length))
  printf " │ ${green}%s${white}%s${white}\e[97m%s%-*s%s${white}│\n" "$title" "$separator" "$value" $value_padding ''
}

function install_msg() {
  read -p "${white} Are you sure you want to install ${green}${1} ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" $2
}

function remove_msg() {
  read -p "${white} Are you sure you want to remove ${green}${1} ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" $2
}

function restore_msg() {
  read -p "${white} Are you sure you want to restore ${green}${1} ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" $2
}

function backup_msg() {
  read -p "${white} Are you sure you want to backup ${green}${1} ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" $2
}

function restart_msg() {
  read -p "${white} Are you sure you want to restart ${green}${1} ${white}? (${yellow}y${white}/${yellow}n${white}): ${yellow}" $2
}

function ok_msg() {
  echo
  echo -e "${white}${green} ✓ ${1}${white}"
  echo
}

function error_msg() {
  echo
  echo -e "${white}${darkred} ✗ ${1}${white}"
  echo
}

function run() {
  clear
  # $1 - Action performed
  $1
  # $2 - Menu launched after action is completed
  $2
}

function check_ipaddress() {
  eth0_ip=$(ip -4 addr show eth0 2>/dev/null | grep -o -E '(inet\s)([0-9]+\.){3}[0-9]+' | cut -d ' ' -f 2 | head -n 1)
  wlan0_ip=$(ip -4 addr show wlan0 | grep -o -E '(inet\s)([0-9]+\.){3}[0-9]+' | cut -d ' ' -f 2 | head -n 1)
  if [ -n "$eth0_ip" ]; then
    echo -e "$eth0_ip"
  elif [ -n "$wlan0_ip" ]; then
    echo -e "$wlan0_ip"
  else
    echo -e "xxx.xxx.xxx.xxx"
  fi
}

function start_moonraker() {
  set +e
  /etc/init.d/S56moonraker_service start
  sleep 1
  set -e
}

function stop_moonraker() {
  set +e
  /etc/init.d/S56moonraker_service stop
  sleep 1
  set -e
}

function start_nginx() {
  set +e
  /etc/init.d/S50nginx start
  sleep 1
  set -e
}

function stop_nginx() {
  set +e
  /etc/init.d/S50nginx stop
  sleep 1
  set -e
}

function restart_nginx() {
  set +e
  /etc/init.d/S50nginx restart
  sleep 1
  set -e
}

function start_klipper() {
  set +e
  /etc/init.d/S55klipper_service start
  set -e
}

function stop_klipper() {
  set +e
  /etc/init.d/S55klipper_service stop
  set -e
}

function restart_klipper() {
  set +e
  /etc/init.d/S55klipper_service restart
  set -e
}