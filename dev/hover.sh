#!/usr/bin/env bash
# Move the pointer in the nested instance so that the shell notices.
# Usage: dev/hover.sh X Y
#
# hyprctl's cursor.move sends the motion without a wl_pointer frame event,
# and Qt waits for the frame before it handles a motion, so a plain move
# inside one surface is never seen. Entering a surface does come with a
# frame. So this parks the pointer on the helper surface in the top-left
# corner first (dev/pointer-park, started by nested.sh) and then moves: the
# shell gets an "enter" at X,Y.
source "$(dirname "$0")/env.sh"
wp_load_instance || exit 1
[[ $# -eq 2 ]] || { echo "usage: dev/hover.sh X Y" >&2; exit 2; }
hyprctl dispatch 'hl.dsp.cursor.move({ x = 1, y = 1 })' >/dev/null
sleep 0.15
hyprctl dispatch "hl.dsp.cursor.move({ x = $1, y = $2 })" >/dev/null
