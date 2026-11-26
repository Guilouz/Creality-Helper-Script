#!/bin/sh

function enable_slicer_discovery() {
  local linked=0
  if [ ! -x /usr/bin/mdns ]; then
    error_msg "This firmware does not provide /usr/bin/mdns."
    return
  fi
  if [ ! -d "$MOONRAKER_FOLDER" ] || [ ! -d "$NGINX_FOLDER" ]; then
    error_msg "Install Moonraker and Nginx before enabling slicer discovery."
    return
  fi
  if [ "$(readlink "$SLICER_DISCOVERY_INIT")" != "$SLICER_DISCOVERY_SERVICE" ]; then
    if [ -e "$SLICER_DISCOVERY_INIT" ] || [ -L "$SLICER_DISCOVERY_INIT" ]; then
      error_msg "Another startup entry already exists at $SLICER_DISCOVERY_INIT."
      return
    fi
    if ! ln -s "$SLICER_DISCOVERY_SERVICE" "$SLICER_DISCOVERY_INIT"; then
      error_msg "Could not create the slicer discovery startup link."
      return
    fi
    linked=1
  fi
  if "$SLICER_DISCOVERY_INIT" start; then
    ok_msg "Slicer discovery is enabled. Select Octo/Klipper and Browse in OrcaSlicer."
  else
    [ "$linked" = 0 ] || rm "$SLICER_DISCOVERY_INIT"
    error_msg "Could not start slicer discovery."
  fi
}

function disable_slicer_discovery() {
  if [ "$(readlink "$SLICER_DISCOVERY_INIT")" != "$SLICER_DISCOVERY_SERVICE" ]; then
    error_msg "Slicer discovery is not enabled by this helper."
  elif "$SLICER_DISCOVERY_INIT" stop && rm "$SLICER_DISCOVERY_INIT"; then
    ok_msg "Slicer discovery is disabled."
  else
    error_msg "Could not disable slicer discovery."
  fi
}
