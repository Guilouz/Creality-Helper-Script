#!/bin/sh

stop_slicer_discovery() {
  "$SLICER_DISCOVERY_SERVICE" stop || return 1
  if [ "$(readlink "$SLICER_DISCOVERY_INIT")" = "$SLICER_DISCOVERY_SERVICE" ]; then
    rm "$SLICER_DISCOVERY_INIT"
  fi
}

edit_slicer_discovery_config() {
  PYTHONPATH="$MOONRAKER_FOLDER/moonraker" "$MOONRAKER_FOLDER/moonraker-env/bin/python" \
    "$HS_FILES/moonraker/slicer-discovery.py" "$1" "$MOONRAKER_CFG"
}

discovery_api() {
  "$CURL" -fsS --noproxy '*' --max-time 5 "http://127.0.0.1:4408/$1"
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
    if ! "$SLICER_DISCOVERY_SERVICE" start 8>&- || ! edit_slicer_discovery_config enable; then
      if [ -n "$created_link" ]; then stop_slicer_discovery; fi
      return 1
    fi
    wanted=true
  else
    stop_slicer_discovery || return 1
    owner=$(edit_slicer_discovery_config disable) || return 1
    if [ "$owner" = user-configured ]; then
      ok_msg "Helper discovery is disabled. Moonraker uses your zeroconf settings."
      return 0
    fi
    wanted=false
  fi

  # Compare with the running component on every attempt, including retries after a print.
  active=$(discovery_api server/info | jq -r '.result |
    if (.failed_components // [] | index("zeroconf")) != null then "failed"
    else (.components | arrays | index("zeroconf") != null) end')
  if [ "$active" = "$wanted" ]; then
    ok_msg "Slicer discovery settings applied."
  elif [ -n "$active" ] && discovery_api 'printer/objects/query?webhooks=state&print_stats=state&virtual_sdcard=is_active&pause_resume=is_paused' | jq -e '
      .result.status | .webhooks.state == "ready" and
      (.print_stats.state == "standby" or .print_stats.state == "complete" or .print_stats.state == "cancelled") and
      .virtual_sdcard.is_active == false and .pause_resume.is_paused == false' >/dev/null; then
    "$INITD_FOLDER/S56moonraker_service" restart 8>&- || return 1
    ok_msg "Slicer discovery configured. Moonraker is restarting."
  else
    echo "Configuration saved. When the printer is idle, repeat this option or restart Moonraker with Tools option 7."
  fi
)

enable_slicer_discovery() {
  set_slicer_discovery enable || error_msg "Could not enable slicer discovery."
}

disable_slicer_discovery() {
  set_slicer_discovery disable || error_msg "Could not disable slicer discovery."
}
