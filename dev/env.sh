# shellcheck shell=bash
# Shared helpers for the dev scripts. Source this file, don't run it.
WP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WP_STATE="$WP_ROOT/dev/.nested"
mkdir -p "$WP_STATE"

# Machine-specific settings (git-ignored), e.g. QS_PREFIX=...
# shellcheck disable=SC1091
[[ -f "$WP_ROOT/dev/local.env" ]] && source "$WP_ROOT/dev/local.env"

# Optional: use a Quickshell build extracted somewhere (no root needed).
# QS_PREFIX=/path/to/extracted/root  (containing usr/bin/qs)
if [[ -n "${QS_PREFIX:-}" ]]; then
  export PATH="$QS_PREFIX/usr/bin:$PATH"
  export LD_LIBRARY_PATH="$QS_PREFIX/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  export QML_IMPORT_PATH="$QS_PREFIX/usr/lib/qt6/qml${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
fi

# Load the signature/socket of the nested instance started by nested.sh.
wp_load_instance() {
  [[ -f "$WP_STATE/instance" ]] || { echo "no nested instance (run dev/nested.sh)" >&2; return 1; }
  # shellcheck disable=SC1091
  source "$WP_STATE/instance"
  export HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY
}
