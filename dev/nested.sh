#!/usr/bin/env bash
# Start a nested Hyprland (a window inside your current Wayland session)
# running this repo's config. Usage: dev/nested.sh [WIDTHxHEIGHT]
set -euo pipefail
source "$(dirname "$0")/env.sh"

"$WP_ROOT/dev/stop.sh" >/dev/null 2>&1 || true

export WIIPERLAND_ROOT="$WP_ROOT"
export XDG_CURRENT_DESKTOP=Hyprland
export WIIPERLAND_DEV_MODE="${1:-1280x720}"
Hyprland -c "$WP_ROOT/hypr/hyprland.lua" >"$WP_STATE/hyprland.log" 2>&1 &
pid=$!

for _ in $(seq 60); do
  line=$(hyprctl instances -j 2>/dev/null | python3 -c "
import json,sys
for i in json.load(sys.stdin):
    if i['pid']==$pid: print(i['instance'], i['wl_socket'])" 2>/dev/null || true)
  [[ -n "$line" ]] && break
  sleep 0.25
done
[[ -n "${line:-}" ]] || { echo "nested Hyprland failed to start; see $WP_STATE/hyprland.log" >&2; exit 1; }

read -r sig sock <<<"$line"
printf 'HYPRLAND_INSTANCE_SIGNATURE=%s\nWAYLAND_DISPLAY=%s\nWP_PID=%s\n' "$sig" "$sock" "$pid" >"$WP_STATE/instance"
echo "nested Hyprland pid=$pid socket=$sock"
