#!/usr/bin/env bash
# Undo install.sh: restore the newest backup of your Hyprland config and remove
# the links. Your ~/.config/wiiperland (config.json and your assets) and the
# message board stay unless you pass --purge.
set -euo pipefail
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}"
HYPR="$CONF/hypr"
PURGE=0; [[ "${1:-}" == "--purge" ]] && PURGE=1

if [[ -f "$HYPR/hyprland.lua" ]] && grep -q WIIPERLAND_INSTALLED "$HYPR/hyprland.lua"; then
  rm "$HYPR/hyprland.lua"; echo "removed $HYPR/hyprland.lua"
fi
latest=$(ls -d "$HYPR"/wiiperland-backup-* 2>/dev/null | sort | tail -1 || true)
if [[ -n "$latest" ]]; then
  for f in "$latest"/*; do
    [[ -e "$HYPR/$(basename "$f")" ]] && { echo "not overwriting $HYPR/$(basename "$f")"; continue; }
    mv "$f" "$HYPR/" && echo "restored $(basename "$f") from $latest"
  done
  rmdir "$latest" 2>/dev/null || true
fi
for l in "$DATA/icons/Wiiperland" "$DATA/fonts/wiiperland"; do
  [[ -L "$l" ]] && rm "$l" && echo "removed $l"
done
command -v fc-cache >/dev/null && fc-cache -f "$DATA/fonts" >/dev/null 2>&1 || true
if [[ $PURGE == 1 ]]; then
  rm -rf "$CONF/wiiperland" "$STATE/wiiperland" && echo "removed $CONF/wiiperland and $STATE/wiiperland"
fi
echo "Wiiperland removed."
