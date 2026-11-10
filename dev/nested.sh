#!/usr/bin/env bash
# Start a nested Hyprland (a window inside your current Wayland session)
# running this repo's config. Usage: dev/nested.sh [WIDTHxHEIGHT]
set -euo pipefail
source "$(dirname "$0")/env.sh"

"$WP_ROOT/dev/stop.sh" >/dev/null 2>&1 || true

export WIIPERLAND_ROOT="$WP_ROOT"
export XDG_CURRENT_DESKTOP=Hyprland
# Use the dev channel list unless told otherwise (apps that don't attach to
# an already running instance in your real session).
export WIIPERLAND_CONFIG="${WIIPERLAND_CONFIG:-$WP_ROOT/dev/test-config.json}"
# Keep the shell's saved state (message board, ...) out of your real ~/.local/state
export WIIPERLAND_STATE="${WIIPERLAND_STATE:-$WP_STATE/state}"
export WIIPERLAND_DEV_MODE="${1:-1280x720}"
# A private D-Bus session bus keeps the nested shell's notification server,
# MPRIS, etc. separate from your real desktop. WP_SHARED_DBUS=1 to opt out.
# (The config passes it to child processes via WIIPERLAND_DEV_BUS.)
if [[ "${WP_SHARED_DBUS:-0}" != 1 ]]; then
  read -r bus_addr bus_pid < <(dbus-daemon --session --fork --print-address=1 --print-pid=1 | paste -sd' ')
  echo "$bus_pid" >"$WP_STATE/dbus.pid"
  export WIIPERLAND_DEV_BUS="$bus_addr"
fi
# WP_ENTRY: test another entry point, e.g. one written by install.sh
Hyprland -c "${WP_ENTRY:-$WP_ROOT/hypr/hyprland.lua}" >"$WP_STATE/hyprland.log" 2>&1 &
pid=$!

for _ in $(seq 60); do
  sock=$(hyprctl instances -j 2>/dev/null | python3 -c "
import json,sys
for i in json.load(sys.stdin):
    if i['pid'] == $pid: print(i['instance'], i['wl_socket'])" 2>/dev/null || true)
  [[ -n "$sock" ]] && break
  kill -0 "$pid" 2>/dev/null || break
  sleep 0.25
done
[[ -n "${sock:-}" ]] || { echo "nested Hyprland failed to start; see $WP_STATE/hyprland.log" >&2; exit 1; }

read -r sig sock <<<"$sock"
printf 'HYPRLAND_INSTANCE_SIGNATURE=%s\nWAYLAND_DISPLAY=%s\nWP_PID=%s\nWP_BUS=%q\n' "$sig" "$sock" "$pid" "${WIIPERLAND_DEV_BUS:-}" >"$WP_STATE/instance"
echo "nested Hyprland pid=$pid socket=$sock"
