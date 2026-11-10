#!/usr/bin/env bash
# Stop the nested instance started by nested.sh.
source "$(dirname "$0")/env.sh"
wp_load_instance 2>/dev/null || exit 0
kill "$WP_PID" 2>/dev/null && echo "stopped $WP_PID"
for _ in $(seq 20); do kill -0 "$WP_PID" 2>/dev/null || break; sleep 0.2; done
rm -f "$WP_STATE/instance"
if [[ -f "$WP_STATE/dbus.pid" ]]; then kill "$(cat "$WP_STATE/dbus.pid")" 2>/dev/null; rm -f "$WP_STATE/dbus.pid"; fi
