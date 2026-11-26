#!/bin/sh

function enable_slicer_discovery() {
  if [ ! -x /usr/bin/mdns ]; then
    error_msg "This firmware does not provide /usr/bin/mdns."
    return
  fi
  if [ ! -d "$MOONRAKER_FOLDER" ] || [ ! -d "$NGINX_FOLDER" ]; then
    error_msg "Install Moonraker and Nginx before enabling slicer discovery."
    return
  fi
  if "$SLICER_DISCOVERY_SERVICE" enable "$SLICER_DISCOVERY_INIT" "$MOONRAKER_CFG" "$MOONRAKER_FOLDER"; then
    ok_msg "Slicer discovery is enabled. Select Octo/Klipper and Browse in OrcaSlicer."
  else
    error_msg "Could not enable slicer discovery."
  fi
}

function disable_slicer_discovery() {
  if "$SLICER_DISCOVERY_SERVICE" disable "$SLICER_DISCOVERY_INIT" "$MOONRAKER_CFG" "$MOONRAKER_FOLDER" "$@"; then
    ok_msg "Helper-managed slicer discovery is disabled."
  else
    error_msg "Could not disable slicer discovery."
  fi
}
