#!/usr/bin/env bash
# Screenshot the nested instance. Usage: dev/shot.sh [name]  -> dev/screenshots/<name>.png
source "$(dirname "$0")/env.sh"
wp_load_instance || exit 1
mkdir -p "$WP_ROOT/dev/screenshots"
out="$WP_ROOT/dev/screenshots/${1:-shot}.png"
grim "$out" && echo "$out"
