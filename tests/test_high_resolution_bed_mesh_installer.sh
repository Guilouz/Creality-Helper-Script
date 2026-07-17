#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

HS_CONFIG_FOLDER="$TEST_ROOT/config/Helper-Script"
KLIPPER_EXTRAS_FOLDER="$TEST_ROOT/klipper/extras"
PRINTER_CFG="$TEST_ROOT/config/printer.cfg"
HIGH_RES_BED_MESH_FILE="$HS_CONFIG_FOLDER/high-resolution-bed-mesh.cfg"
HIGH_RES_BED_MESH_URL="$ROOT/files/high-resolution-bed-mesh/high-resolution-bed-mesh.cfg"
PRTOUCH_EXTENDED_POINTS_FILE="$KLIPPER_EXTRAS_FOLDER/prtouch_extended_points.py"
PRTOUCH_EXTENDED_POINTS_URL="$ROOT/files/high-resolution-bed-mesh/prtouch_extended_points.py"
white=""
yellow=""
cyan=""
restart_count=0

mkdir -p "$HS_CONFIG_FOLDER" "$KLIPPER_EXTRAS_FOLDER"
printf '%s\n' '[include printer_params.cfg]' > "$PRINTER_CFG"

top_line() { :; }
title() { :; }
inner_line() { :; }
hr() { :; }
bottom_line() { :; }
ok_msg() { :; }
error_msg() { echo "$*" >&2; return 1; }
install_msg() { printf -v "$2" 'y'; }
remove_msg() { printf -v "$2" 'y'; }
restart_klipper() { restart_count=$((restart_count + 1)); }

# Normalize the script's target GNU/BusyBox `sed -i` form for BSD sed too.
sed() {
  if [[ "$1" == "-i" ]]; then
    shift
    local target="${*: -1}"
    if [[ "$1" == *"printer_params"* && "$1" == *"/a "* ]]; then
      perl -0pi -e 's|(\[include printer_params\.cfg\])|$1\n[include Helper-Script/high-resolution-bed-mesh.cfg]|' "$target"
    else
      command sed -i.bak "$@"
      rm -f "$target.bak"
    fi
  else
    command sed "$@"
  fi
}

source "$ROOT/scripts/high_resolution_bed_mesh.sh"

install_high_resolution_bed_mesh
install_high_resolution_bed_mesh

[[ -L "$HIGH_RES_BED_MESH_FILE" ]]
[[ -L "$PRTOUCH_EXTENDED_POINTS_FILE" ]]
[[ "$(readlink "$HIGH_RES_BED_MESH_FILE")" == "$HIGH_RES_BED_MESH_URL" ]]
[[ "$(readlink "$PRTOUCH_EXTENDED_POINTS_FILE")" == "$PRTOUCH_EXTENDED_POINTS_URL" ]]
[[ "$(grep -c 'include Helper-Script/high-resolution-bed-mesh.cfg' "$PRINTER_CFG")" == "1" ]]
[[ "$restart_count" == "2" ]]

remove_high_resolution_bed_mesh

[[ ! -e "$HIGH_RES_BED_MESH_FILE" ]]
[[ ! -e "$PRTOUCH_EXTENDED_POINTS_FILE" ]]
! grep -q 'include Helper-Script/high-resolution-bed-mesh.cfg' "$PRINTER_CFG"
[[ "$restart_count" == "3" ]]

printf '%s\n' 'installer/remove simulation passed'
