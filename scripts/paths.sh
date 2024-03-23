#!/bin/sh

set -e

function set_paths() {

  # Colors #
  white=`echo -en "\033[m"`
  blue=`echo -en "\033[36m"`
  cyan=`echo -en "\033[1;36m"`
  yellow=`echo -en "\033[1;33m"`
  green=`echo -en "\033[01;32m"`
  darkred=`echo -en "\033[31m"`
  red=`echo -en "\033[01;31m"`

  # System #
  CURL="${HELPER_SCRIPT_FOLDER}/files/fixes/curl"
  INITD_FOLDER="/etc/init.d"
  USR_DATA="/usr/data"
  PRINTER_DATA_FOLDER="$USR_DATA/printer_data"

  # Helper Script #
  HS_FILES="${HELPER_SCRIPT_FOLDER}/files"
  HS_CONFIG_FOLDER="$PRINTER_DATA_FOLDER/config/Helper-Script"
  HS_BACKUP_FOLDER="$USR_DATA/helper-script-backup"
  
  # Configuration Files #
  MOONRAKER_CFG="${PRINTER_DATA_FOLDER}/config/moonraker.conf"
  PRINTER_CFG="${PRINTER_DATA_FOLDER}/config/printer.cfg"
  MACROS_CFG="${PRINTER_DATA_FOLDER}/config/gcode_macro.cfg"
  
  # Moonraker #
  MOONRAKER_FOLDER="${USR_DATA}/moonraker"
  MOONRAKER_URL1="${HS_FILES}/moonraker/moonraker.tar.gz"
  MOONRAKER_URL2="${HS_FILES}/moonraker/moonraker.conf"
  MOONRAKER_URL3="${HS_FILES}/moonraker/moonraker.asvc"
  MOONRAKER_SERVICE_URL="${HS_FILES}/services/S56moonraker_service"
  
  # Nginx #
  NGINX_FOLDER="${USR_DATA}/nginx"
  NGINX_SERVICE_URL="${HS_FILES}/services/S50nginx"
  
  # Supervisor Lite #
  SUPERVISOR_FILE="/usr/bin/supervisorctl"
  SUPERVISOR_URL="${HS_FILES}/fixes/supervisorctl"

  # Host Controls Support #
  SYSTEMCTL_FILE="/usr/bin/systemctl"
  SYSTEMCTL_URL="${HS_FILES}/fixes/systemctl"
  SUDO_FILE="/usr/bin/sudo"
  SUDO_URL="${HS_FILES}/fixes/sudo"
  
  # Klipper #
  KLIPPER_EXTRAS_FOLDER="/usr/share/klipper/klippy/extras"
  KLIPPER_CONFIG_FOLDER="${PRINTER_DATA_FOLDER}/config"
  KLIPPER_KLIPPY_FOLDER="/usr/share/klipper/klippy"
  KLIPPER_SERVICE_URL="${HS_FILES}/services/S55klipper_service"
  KLIPPER_GCODE_URL="${HS_FILES}/fixes/gcode.py"
  
  # Fluidd #
  FLUIDD_FOLDER="${USR_DATA}/fluidd"
  FLUIDD_URL="https://github.com/fluidd-core/fluidd/releases/latest/download/fluidd.zip"

  # Mainsail #
  MAINSAIL_FOLDER="${USR_DATA}/mainsail"
  MAINSAIL_URL="https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip"
  
  # Entware #
  ENTWARE_FILE="/opt/bin/opkg"
  ENTWARE_URL="${HS_FILES}/entware/generic.sh"

  # Klipper Gcode Shell Command #
  KLIPPER_SHELL_FILE="${KLIPPER_EXTRAS_FOLDER}/gcode_shell_command.py"
  KLIPPER_SHELL_URL="${HS_FILES}/gcode-shell-command/gcode_shell_command.py"
  
  # Klipper Adaptive Meshing & Purging #
  KAMP_FOLDER="${HS_CONFIG_FOLDER}/KAMP"
  KAMP_URL="${HS_FILES}/kamp"
  
  # Buzzer Support #
  BUZZER_FILE="${HS_CONFIG_FOLDER}/buzzer-support.cfg"
  BUZZER_URL="${HS_FILES}/buzzer-support/buzzer-support.cfg"
  
  # Nozzle Cleaning Fan Control #
  NOZZLE_CLEANING_FOLDER="${KLIPPER_EXTRAS_FOLDER}/prtouch_v2_fan"
  NOZZLE_CLEANING_URL1="${HS_FILES}/nozzle-cleaning-fan-control/__init__.py"
  NOZZLE_CLEANING_URL2="${HS_FILES}/nozzle-cleaning-fan-control/prtouch_v2_fan.pyc"
  NOZZLE_CLEANING_URL3="${HS_FILES}/nozzle-cleaning-fan-control/nozzle-cleaning-fan-control.cfg"
  
  # Fans Control Macros #
  FAN_CONTROLS_FILE="${HS_CONFIG_FOLDER}/fans-control.cfg"
  FAN_CONTROLS_URL="${HS_FILES}/macros/fans-control.cfg"
  
  # Improved Shapers Calibrations #
  IMP_SHAPERS_FOLDER="${HS_CONFIG_FOLDER}/improved-shapers"
  IMP_SHAPERS_URL="${HS_FILES}/improved-shapers/"
  
  # Useful Macros #
  USEFUL_MACROS_FILE="${HS_CONFIG_FOLDER}/useful-macros.cfg"
  USEFUL_MACROS_URL="${HS_FILES}/macros/useful-macros.cfg"
  
  # Save Z-Offset Macros #
  SAVE_ZOFFSET_FILE="${HS_CONFIG_FOLDER}/save-zoffset.cfg"
  SAVE_ZOFFSET_URL="${HS_FILES}/macros/save-zoffset.cfg"
  
  # Screws Tilt Adjust Support #
  SCREWS_ADJUST_FILE="${HS_CONFIG_FOLDER}/screws-tilt-adjust.cfg"
  SCREWS_ADJUST_URL="${HS_FILES}/screws-tilt-adjust/screws_tilt_adjust.py"
  SCREWS_ADJUST_K1_URL="${HS_FILES}/screws-tilt-adjust/screws-tilt-adjust-k1.cfg"
  SCREWS_ADJUST_K1M_URL="${HS_FILES}/screws-tilt-adjust/screws-tilt-adjust-k1max.cfg"
  
  # Virtual Pins Support #
  VIRTUAL_PINS_FILE="${KLIPPER_EXTRAS_FOLDER}/virtual_pins.py"
  VIRTUAL_PINS_URL="${HS_FILES}/klipper-virtual-pins/virtual_pins.py"
  
  # M600 Support #
  M600_SUPPORT_FILE="${HS_CONFIG_FOLDER}/M600-support.cfg"
  M600_SUPPORT_URL="${HS_FILES}/macros/M600-support.cfg"
  
  # Git Backup #
  GIT_BACKUP_INSTALLER="${HS_FILES}/git-backup/git-backup.sh"
  GIT_BACKUP_FILE="${HS_CONFIG_FOLDER}/git-backup.cfg"
  GIT_BACKUP_URL="${HS_FILES}/git-backup/git-backup.cfg"
  
  # Moonraker Timelapse #
  TIMELAPSE_FILE="${USR_DATA}/moonraker/moonraker/moonraker/components/timelapse.py"
  TIMELAPSE_URL1="${HS_FILES}/moonraker-timelapse/timelapse.py"
  TIMELAPSE_URL2="${HS_FILES}/moonraker-timelapse/timelapse.cfg"
  
  # Camera Settings Control #
  CAMERA_SETTINGS_FILE="${HS_CONFIG_FOLDER}/camera-settings.cfg"
  CAMERA_SETTINGS_URL="${HS_FILES}/camera-settings/camera-settings.cfg"
  
  # OctoEverywhere #
  OCTOEVERYWHERE_FOLDER="${USR_DATA}/octoeverywhere"
  OCTOEVERYWHERE_URL="https://github.com/QuinnDamerell/OctoPrint-OctoEverywhere.git"
  
  # Moonraker Obico #
  MOONRAKER_OBICO_FOLDER="${USR_DATA}/moonraker-obico"
  MOONRAKER_OBICO_URL="https://github.com/TheSpaghettiDetective/moonraker-obico.git"
  
  # Mobileraker Companion #
  MOBILERAKER_COMPANION_FOLDER="${USR_DATA}/mobileraker_companion"
  MOBILERAKER_COMPANION_URL="https://github.com/Clon1998/mobileraker_companion.git"

  # GuppyFLO #
  GUPPYFLO_FOLDER="${USR_DATA}/guppyflo"
  GUPPYFLO_URL="https://github.com/ballaswag/guppyflo/releases/latest/download/guppyflo_mipsle.zip"

  # Custom Boot Display #
  BOOT_DISPLAY_FOLDER="/etc/boot-display"
  BOOT_DISPLAY_FILE="${BOOT_DISPLAY_FOLDER}/part0/pic_100.jpg"
  BOOT_DISPLAY_K1_URL="${HS_FILES}/boot-display/k1_boot_display.tar.gz"
  BOOT_DISPLAY_K1M_URL="${HS_FILES}/boot-display/k1max_boot_display.tar.gz"
  BOOT_DISPLAY_STOCK_URL="${HS_FILES}/boot-display/stock_boot_display.tar.gz"
  
  # Creality Web Interface #
  CREALITY_WEB_FILE="/usr/bin/web-server"
  
  # Guppy Screen #
  GUPPY_SCREEN_FOLDER="${USR_DATA}/guppyscreen"
  GUPPY_SCREEN_URL1="${HS_FILES}/guppy-screen/guppy_update.cfg"
  GUPPY_SCREEN_URL2="${HS_FILES}/guppy-screen/guppy-update.sh"
  
  # Creality Dynamic Logos for Fluidd #
  FLUIDD_LOGO_FILE="${USR_DATA}/fluidd/logo_creality_v2.svg"
  FLUIDD_LOGO_URL1="${HS_FILES}/fluidd-logos/logo_creality_v1.svg"
  FLUIDD_LOGO_URL2="${HS_FILES}/fluidd-logos/logo_creality_v2.svg"
  FLUIDD_LOGO_URL3="${HS_FILES}/fluidd-logos/config.json"

}

function set_permissions() {

  chmod +x "$CURL" >/dev/null 2>&1 &

}