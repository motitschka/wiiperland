#!/usr/bin/env bash
# Run a command inside the nested instance. Usage: dev/run.sh <cmd> [args]
source "$(dirname "$0")/env.sh"
wp_load_instance || exit 1
export WIIPERLAND_ROOT="$WP_ROOT"
exec "$@"
