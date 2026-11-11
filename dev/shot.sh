#!/usr/bin/env bash
# Screenshot the nested instance. Usage: dev/shot.sh [name]  -> dev/screenshots/<name>.png
# WP_CURSOR=1 includes the pointer.
source "$(dirname "$0")/env.sh"
wp_load_instance || exit 1
mkdir -p "$WP_ROOT/dev/screenshots"
out="$WP_ROOT/dev/screenshots/${1:-shot}.png"
args=()
[[ "${WP_CURSOR:-0}" == 1 ]] && args+=(-c)
[[ -n "${WP_OUTPUT:-}" ]] && args+=(-o "$WP_OUTPUT")
# A nested window that is hidden or covered isn't drawn, and grim would wait
# for it forever.
if timeout 10 grim "${args[@]}" "$out"; then
  echo "$out"
else
  echo "screenshot timed out: is the nested window hidden? Try dev/nested.sh --headless" >&2
  exit 1
fi
