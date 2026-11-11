#!/usr/bin/env bash
# Start a nested Hyprland (a window inside your current Wayland session)
# running this repo's config.
#
#   dev/nested.sh [--headless] [WIDTHxHEIGHT]
#
# --headless (or WP_HEADLESS=1) moves the session onto an off-screen output
# and closes the window: nothing shows on your desktop, the size is exact,
# and screenshots work even while you use other windows.
set -euo pipefail
source "$(dirname "$0")/env.sh"

headless="${WP_HEADLESS:-0}"
if [[ "${1:-}" == "--headless" ]]; then headless=1; shift; fi

"$WP_ROOT/dev/stop.sh" >/dev/null 2>&1 || true

export WIIPERLAND_ROOT="$WP_ROOT"
export XDG_CURRENT_DESKTOP=Hyprland
# Use the dev channel list unless told otherwise (apps that don't attach to
# an already running instance in your real session).
export WIIPERLAND_CONFIG="${WIIPERLAND_CONFIG:-$WP_ROOT/dev/test-config.json}"
# Keep the shell's saved state (message board, ...) out of your real ~/.local/state
export WIIPERLAND_STATE="${WIIPERLAND_STATE:-$WP_STATE/state}"
# The owner's asset folder may hold files that must never end up in a
# screenshot, so tests get their own (empty unless a test fills it).
export WIIPERLAND_ASSETS="${WIIPERLAND_ASSETS:-$WP_STATE/assets}"
# Tests don't make noise: sounds are logged, not played. WP_SOUND=1 to hear them.
[[ "${WP_SOUND:-0}" == 1 ]] || export WIIPERLAND_SILENT=1
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
output=""
if [[ "$headless" == 1 ]]; then
  # Add an off-screen output, then drop the one that is a window on the desktop.
  output="WP-HEADLESS"
  export HYPRLAND_INSTANCE_SIGNATURE="$sig"
  for _ in $(seq 40); do hyprctl monitors >/dev/null 2>&1 && break; sleep 0.1; done
  hyprctl output create headless "$output" >/dev/null
  for o in $(hyprctl monitors -j | python3 -c "
import json,sys
print(' '.join(m['name'] for m in json.load(sys.stdin) if m['name'] != '$output'))"); do
    hyprctl output remove "$o" >/dev/null
  done
  hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })' >/dev/null
fi
printf 'HYPRLAND_INSTANCE_SIGNATURE=%s\nWAYLAND_DISPLAY=%s\nWP_PID=%s\nWP_BUS=%q\nWP_OUTPUT=%s\n' "$sig" "$sock" "$pid" "${WIIPERLAND_DEV_BUS:-}" "$output" >"$WP_STATE/instance"
echo "nested Hyprland pid=$pid socket=$sock${output:+ output=$output (headless)}"
