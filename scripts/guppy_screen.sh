#!/bin/sh

set -e

function guppy_screen_message(){
  top_line
  title 'Guppy Screen' "${yellow}"
  inner_line
  hr
  echo -e " │ ${cyan}Guppy Screen is a touch UI for Klipper using APIs exposed by ${white}│"
  echo -e " │ ${cyan}Moonraker. It replace Creality touch UI.                     ${white}│"
  hr
  bottom_line
}

function install_guppy_screen(){
  guppy_screen_message
  local yn
  while true; do
    install_msg "Guppy Screen" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        if [ -f "$USR_DATA"/guppyscreen.tar.gz ]; then
          rm -f "$USR_DATA"/guppyscreen.tar.gz
        fi
        if [ $K1 -eq 1 ]; then
          local theme_choice
          while true; do
            read -p " Do you want to install it with ${green}Material Design ${white}or ${green}Z-Bolt ${white}theme? (${yellow}material${white}/${yellow}zbolt${white}): ${yellow}" theme_choice
            case "${theme_choice}" in
              MATERIAL|material)
                echo -e "${white}"
                echo -e "Info: Downloading Guppy Screen..."
                "$CURL" -L https://github.com/ballaswag/guppyscreen/releases/latest/download/guppyscreen.tar.gz -o "$USR_DATA"/guppyscreen.tar.gz
                break;;
              ZBOLT|zbolt)
                echo -e "${white}"
                echo -e "Info: Downloading Guppy Screen..."
                "$CURL" -L https://github.com/ballaswag/guppyscreen/releases/latest/download/guppyscreen-zbolt.tar.gz -o "$USR_DATA"/guppyscreen.tar.gz
                break;;
              *)
                error_msg "Please select a correct choice!";;
            esac
          done
        else
          echo -e "Info: Downloading Guppy Screen..."
          "$CURL" -L https://github.com/ballaswag/guppyscreen/releases/latest/download/guppyscreen-smallscreen.tar.gz -o "$USR_DATA"/guppyscreen.tar.gz
        fi
        echo -e "Info: Installing files..."
        tar -xvf "$USR_DATA"/guppyscreen.tar.gz -C "$USR_DATA"
        rm -f "$USR_DATA"/guppyscreen.tar.gz
        if [ ! -d "$HS_BACKUP_FOLDER"/guppyscreen ]; then
          echo -e "Info: Backing up original file..."
          mkdir -p "$HS_BACKUP_FOLDER"/guppyscreen
          if [ -f "$INITD_FOLDER"/S12boot_display ]; then
            mv "$INITD_FOLDER"/S12boot_display "$HS_BACKUP_FOLDER"/guppyscreen
          fi
          if [ -f "$INITD_FOLDER"/S50dropbear ]; then
            cp "$INITD_FOLDER"/S50dropbear "$HS_BACKUP_FOLDER"/guppyscreen
          fi
          if [ -f "$INITD_FOLDER"/S99start_app ]; then
            cp "$INITD_FOLDER"/S99start_app "$HS_BACKUP_FOLDER"/guppyscreen
          fi
        fi
        if [ ! -f "$HS_BACKUP_FOLDER"/guppyscreen/ft2font.cpython-38-mipsel-linux-gnu.so ]; then
          mv /usr/lib/python3.8/site-packages/matplotlib/ft2font.cpython-38-mipsel-linux-gnu.so "$HS_BACKUP_FOLDER"/guppyscreen
        fi
        local yn
          while true; do
            echo
            echo -e " ${white}Do you want to disable all Creality services ?"
            echo -e " ${yellow}Benefits: ${white}\e[97mFrees up system resources on your K1 for critical services such as Klipper (recommended)${white}"
            echo -e " ${yellow}Disadvantages: ${white}\e[97mDisabling all Creality services breaks Creality Cloud and Creality Print${white}"
            echo
            read -p " Do you want to disable all Creality Services? (${yellow}y${white}/${yellow}n${white}): ${yellow}" yn
            case "${yn}" in
              Y|y)
                echo -e "${white}"
                echo -e "Info: Disabling Creality services..."
                if [ -f "$INITD_FOLDER"/S99start_app ]; then
                  rm -f "$INITD_FOLDER"/S99start_app
                fi
                set +e
                killall -q master-server
                killall -q audio-server
                killall -q wifi-server
                killall -q app-server
                killall -q upgrade-server
                killall -q web-server
                set -e
                break;;
              N|n)
                break;;
              *)
                error_msg "Please select a correct choice!";;
            esac
          done
        if [ ! -d "/usr/lib/python3.8/site-packages/matplotlib-2.2.3-py3.8.egg-info" ]; then
          echo -e "Info: mathplotlib ft2font module is not replaced. PSD graphs might not work..."
        else
          echo -e "Info: Replacing mathplotlib ft2font module to generate PSD graphs..."
          cp "$GUPPY_SCREEN_FOLDER"/k1_mods/ft2font.cpython-38-mipsel-linux-gnu.so /usr/lib/python3.8/site-packages/matplotlib/ft2font.cpython-38-mipsel-linux-gnu.so
        fi
        echo -e "Info: Setting up Guppy Screen..."
        cp "$GUPPY_SCREEN_FOLDER"/k1_mods/S50dropbear "$INITD_FOLDER"/S50dropbear
        cp "$GUPPY_SCREEN_FOLDER"/k1_mods/S99guppyscreen "$INITD_FOLDER"/S99guppyscreen
        ln -sf "$GUPPY_SCREEN_FOLDER"/k1_mods/calibrate_shaper_config.py "$KLIPPER_EXTRAS_FOLDER"/calibrate_shaper_config.py
        ln -sf "$GUPPY_SCREEN_FOLDER"/k1_mods/guppy_module_loader.py "$KLIPPER_EXTRAS_FOLDER"/guppy_module_loader.py
        ln -sf "$GUPPY_SCREEN_FOLDER"/k1_mods/guppy_config_helper.py "$KLIPPER_EXTRAS_FOLDER"/guppy_config_helper.py
        ln -sf "$GUPPY_SCREEN_FOLDER"/k1_mods/tmcstatus.py "$KLIPPER_EXTRAS_FOLDER"/tmcstatus.py
        ln -sf "$GUPPY_SCREEN_FOLDER"/k1_mods/respawn/libeinfo.so.1 /lib/libeinfo.so.1
        ln -sf "$GUPPY_SCREEN_FOLDER"/k1_mods/respawn/librc.so.1 /lib/librc.so.1
        mkdir -p "$KLIPPER_CONFIG_FOLDER"/GuppyScreen/scripts
        cp "$GUPPY_SCREEN_FOLDER"/scripts/*.cfg "$KLIPPER_CONFIG_FOLDER"/GuppyScreen
        cp "$GUPPY_SCREEN_FOLDER"/scripts/*.py "$KLIPPER_CONFIG_FOLDER"/GuppyScreen/scripts
        ln -sf "$GUPPY_SCREEN_URL1" "$KLIPPER_CONFIG_FOLDER"/GuppyScreen/guppy_update.cfg
        chmod 775 "$GUPPY_SCREEN_URL2"
        if grep -q "include GuppyScreen" "$PRINTER_CFG" ; then
          echo -e "Info: Guppy Screen configurations are already enabled in printer.cfg file."
        else
          echo -e "Info: Adding Guppy Screen configurations in printer.cfg file..."
          sed -i '/\[include printer_params\.cfg\]/a \[include GuppyScreen/*\.cfg\]' "$PRINTER_CFG"
        fi
        if grep -q 'variable_autotune_shapers:' "$MACROS_CFG" ; then
          echo -e "Info: Disabling stock configuration in gcode_macro.cfg file..."
          sed -i 's/variable_autotune_shapers:/#&/' "$MACROS_CFG"
        else
          echo -e "Info: Stock configuration is already disabled in gcode_macro.cfg file..."
        fi
        if grep -q '\[gcode_macro INPUTSHAPER\]' "$MACROS_CFG" ; then
          echo -e "Info: Replacing stock configuration in gcode_macro.cfg file..."
          sed -i 's/SHAPER_CALIBRATE AXIS=y/SHAPER_CALIBRATE/' "$MACROS_CFG"
        else
          echo -e "Info: Stock configuration is already replaced in gcode_macro.cfg file..."
        fi
        sync
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        echo -e "Info: Disabling services..."
        if [ -f /usr/bin/Monitor ]; then
          mv /usr/bin/Monitor /usr/bin/Monitor.disabled
        fi
        if [ -f /usr/bin/display-server ]; then
          mv /usr/bin/display-server /usr/bin/display-server.disabled
        fi
        set +e
        killall -q Monitor
        killall -q display-server
        set -e
        echo -e "Info: Starting Guppy Screen service..."
        /etc/init.d/S99guppyscreen restart &> /dev/null
        sleep 1
        ps auxw | grep guppyscreen | grep -v sh | grep -v grep
        ok_msg "Guppy Screen has been installed successfully!"
        return;;
      N|n)
        error_msg "Installation canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}

function remove_guppy_screen(){
  guppy_screen_message
  local yn
  while true; do
    remove_msg "Guppy Screen" yn
    case "${yn}" in
      Y|y)
        echo -e "${white}"
        echo -e "Info: Restoring backup files..."
        if [ -d "$HS_BACKUP_FOLDER"/guppyscreen ]; then
          if [ -f "$HS_BACKUP_FOLDER"/guppyscreen/S12boot_display ]; then
            cp "$HS_BACKUP_FOLDER"/guppyscreen/S12boot_display "$INITD_FOLDER"/S12boot_display
          fi
          if [ -f "$HS_BACKUP_FOLDER"/guppyscreen/S50dropbear ]; then
            cp "$HS_BACKUP_FOLDER"/guppyscreen/S50dropbear "$INITD_FOLDER"/S50dropbear
          fi
          if [ -f "$HS_BACKUP_FOLDER"/guppyscreen/S99start_app ]; then
            cp "$HS_BACKUP_FOLDER"/guppyscreen/S99start_app "$INITD_FOLDER"/S99start_app
          fi
          rm -rf "$HS_BACKUP_FOLDER"/guppyscreen
        fi
        if [ ! -n "$(ls -A "$HS_BACKUP_FOLDER")" ]; then
          rm -rf "$HS_BACKUP_FOLDER"
        fi
        echo -e "Info: Stopping Guppy Screen Service..."
        [ -f "$INITD_FOLDER"/S99guppyscreen ] && "$INITD_FOLDER"/S99guppyscreen stop &> /dev/null
        set +e
        killall -q guppyscreen
        set -e
        echo -e "Info: Removing files..."
        rm -f "$KLIPPER_EXTRAS_FOLDER"/calibrate_shaper_config.py
        rm -f "$KLIPPER_EXTRAS_FOLDER"/calibrate_shaper_config.pyc
        rm -f "$KLIPPER_EXTRAS_FOLDER"/guppy_module_loader.py
        rm -f "$KLIPPER_EXTRAS_FOLDER"/guppy_module_loader.pyc
        rm -f "$KLIPPER_EXTRAS_FOLDER"/guppy_config_helper.py
        rm -f "$KLIPPER_EXTRAS_FOLDER"/guppy_config_helper.pyc
        rm -f "$KLIPPER_EXTRAS_FOLDER"/tmcstatus.py
        rm -f "$KLIPPER_EXTRAS_FOLDER"/tmcstatus.pyc
        rm -f "$INITD_FOLDER"/S99guppyscreen
        rm -f /lib/libeinfo.so.1
        rm -f /lib/librc.so.1
        rm -rf "$GUPPY_SCREEN_FOLDER"
        rm -rf "$KLIPPER_CONFIG_FOLDER"/GuppyScreen
        if grep -q "include GuppyScreen/*" "$PRINTER_CFG" ; then
          echo -e "Info: Removing Guppy Screen configurations in printer.cfg file..."
          sed -i '/\[include GuppyScreen\/\*\.cfg\]/d' "$PRINTER_CFG"
        else
          echo -e "Info: Guppy Screen configurations are already removed in printer.cfg file..."
        fi
        if grep -q "#variable_autotune_shapers:" "$MACROS_CFG"; then
          echo -e "Info: Enabling stock configuration in gcode_macro.cfg file..."
          sed -i 's/#variable_autotune_shapers:/variable_autotune_shapers:/' "$MACROS_CFG"
        else
          echo -e "Info: Stock configuration is already enabled in gcode_macro.cfg file..."
        fi
        if grep -q '\[gcode_macro INPUTSHAPER\]' "$MACROS_CFG" ; then
          echo -e "Info: Restoring stock configuration in gcode_macro.cfg file..."
          sed -i 's/SHAPER_CALIBRATE/SHAPER_CALIBRATE AXIS=y/' "$MACROS_CFG"
        else
          echo -e "Info: Stock configuration is already restored in gcode_macro.cfg file..."
        fi
        echo -e "Info: Restarting Moonraker service..."
        stop_moonraker
        start_moonraker
        echo -e "Info: Restarting Klipper service..."
        restart_klipper
        echo -e "Info: Restoring services..."
        if [ -f /usr/bin/Monitor.disabled ]; then
          mv /usr/bin/Monitor.disabled /usr/bin/Monitor
        fi
        if [ -f /usr/bin/display-server.disabled ]; then
          mv /usr/bin/display-server.disabled /usr/bin/display-server
        fi
        echo -e "Info: Restarting Creality services..."
        set +e
        /usr/bin/Monitor > /dev/null 2>&1 &
        /usr/bin/display-server > /dev/null 2>&1 &
        /usr/bin/master-server > /dev/null 2>&1 &
        /usr/bin/audio-server > /dev/null 2>&1 &
        /usr/bin/wifi-server > /dev/null 2>&1 &
        /usr/bin/app-server > /dev/null 2>&1 &
        /usr/bin/upgrade-server > /dev/null 2>&1 &
        if [ -f /usr/bin/web-server ]; then
          /usr/bin/web-server > /dev/null 2>&1 &
        fi
        set -e
        ok_msg "Guppy Screen has been removed successfully!"
        return;;
      N|n)
        error_msg "Deletion canceled!"
        return;;
      *)
        error_msg "Please select a correct choice!";;
    esac
  done
}