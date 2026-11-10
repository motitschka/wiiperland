#!/usr/bin/env bash
# hyprctl against the nested instance. Usage: dev/hctl.sh <hyprctl args>
source "$(dirname "$0")/env.sh"
wp_load_instance || exit 1
exec hyprctl "$@"
