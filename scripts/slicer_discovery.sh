#!/bin/sh

stop_slicer_discovery() {
  "$SLICER_DISCOVERY_SERVICE" stop || return 1
  if [ "$(readlink "$SLICER_DISCOVERY_INIT")" = "$SLICER_DISCOVERY_SERVICE" ]; then
    rm "$SLICER_DISCOVERY_INIT"
  fi
}

set_slicer_discovery() (
  exec 8>"$SLICER_DISCOVERY_LOCK" || return 1
  flock -x 8 || return 1
  if [ "$1" = enable ]; then
    if [ ! -d "$MOONRAKER_FOLDER" ] || [ ! -d "$NGINX_FOLDER" ]; then
      echo "Install Moonraker and Nginx before enabling slicer discovery." >&2
      return 1
    fi
    created_link=
    if [ "$(readlink "$SLICER_DISCOVERY_INIT")" != "$SLICER_DISCOVERY_SERVICE" ]; then
      [ ! -d "$SLICER_DISCOVERY_INIT" ] && ln -s "$SLICER_DISCOVERY_SERVICE" "$SLICER_DISCOVERY_INIT" || return 1
      created_link=$SLICER_DISCOVERY_INIT
    fi
    if ! "$SLICER_DISCOVERY_SERVICE" start 8>&-; then
      if [ -n "$created_link" ]; then stop_slicer_discovery; fi
      return 1
    fi
    ok_msg "Octo/Klipper discovery is enabled on port 4408."
  else
    stop_slicer_discovery || return 1
    ok_msg "Octo/Klipper discovery is disabled."
  fi
)

enable_slicer_discovery() {
  set_slicer_discovery enable || error_msg "Could not enable slicer discovery."
}

disable_slicer_discovery() {
  set_slicer_discovery disable || error_msg "Could not disable slicer discovery."
}
