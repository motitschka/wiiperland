#!/usr/bin/env bash
# Wiiperland installer.
#
#   ./install.sh            check dependencies and install for the current user
#   ./install.sh --deps     also install missing packages with pacman (asks for sudo)
#   ./install.sh --dry-run  only print what would happen
#
# What it does (nothing outside your home folder, except --deps):
#   - backs up ~/.config/hypr/hyprland.lua and hyprland.conf
#   - writes a new ~/.config/hypr/hyprland.lua that loads Wiiperland from this repo
#   - copies config/config.json to ~/.config/wiiperland/ (only if missing),
#     leaving out channels whose apps aren't installed
#   - creates ~/.config/wiiperland/assets/ for your own sounds, fonts and art
#   - links the cursor theme and font into ~/.local/share
# Undo with ./uninstall.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
STAMP="$(date +%Y%m%d-%H%M%S)"
DRY=0; DEPS=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --deps) DEPS=1 ;;
    -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
run()  { if [[ $DRY == 1 ]]; then echo "    would run: $*"; else "$@"; fi }

# --- dependencies -----------------------------------------------------------
say "Checking dependencies"
declare -A PKG=( [Hyprland]=hyprland [qs]=quickshell [grim]=grim [curl]=curl
                 [pw-play]=pipewire [wpctl]=wireplumber [rsvg-convert]=librsvg )
declare -A OPT=( [playerctl]=playerctl [brightnessctl]=brightnessctl [kitty]=kitty )
missing=(); optional=()
for c in "${!PKG[@]}"; do command -v "$c" >/dev/null || missing+=("${PKG[$c]}"); done
for c in "${!OPT[@]}"; do command -v "$c" >/dev/null || optional+=("${OPT[$c]}"); done

if command -v Hyprland >/dev/null; then
  ver=$(Hyprland --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
  if [[ -n "$ver" ]] && [[ "$(printf '%s\n0.57.0\n' "$ver" | sort -V | head -1)" != "0.57.0" ]]; then
    warn "Hyprland $ver found; Wiiperland needs 0.57 or newer (Lua config)."
  fi
fi

if ((${#missing[@]})); then
  warn "Missing: ${missing[*]}"
  if [[ $DEPS == 1 ]]; then
    run sudo pacman -S --needed "${missing[@]}"
  else
    echo "    Install them with:  sudo pacman -S --needed ${missing[*]}"
    echo "    (or run ./install.sh --deps)"
  fi
fi
((${#optional[@]})) && echo "    Optional, for media keys / brightness / the default terminal: ${optional[*]}"

# --- back up the current Hyprland config -------------------------------------
HYPR="$CONF/hypr"
BACKUP="$HYPR/wiiperland-backup-$STAMP"
run mkdir -p "$HYPR"
for f in hyprland.lua hyprland.conf; do
  if [[ -e "$HYPR/$f" ]] && ! grep -q 'WIIPERLAND_INSTALLED' "$HYPR/$f" 2>/dev/null; then
    say "Backing up $HYPR/$f -> $BACKUP/"
    run mkdir -p "$BACKUP"
    run mv "$HYPR/$f" "$BACKUP/$f"
  fi
done

# --- pick a terminal ---------------------------------------------------------
term=kitty
for t in kitty foot alacritty wezterm ghostty ptyxis kgx gnome-terminal konsole xterm; do
  command -v "$t" >/dev/null && { term=$t; break; }
done

# --- write the entry point -----------------------------------------------------
say "Writing $HYPR/hyprland.lua"
entry=$(cat <<LUA
-- WIIPERLAND_INSTALLED: written by $ROOT/install.sh on $STAMP
-- Your previous config (if any) is in $HYPR/wiiperland-backup-*/

package.path = "$ROOT/hypr/?.lua;$ROOT/hypr/?/init.lua;" .. package.path

require("wiiperland").setup({
  root      = "$ROOT",
  terminal  = "$term",
  -- browser   = "firefox",
  -- files     = "nautilus",
  -- kb_layout = "us",
  -- monitor   = { output = "", mode = "preferred", position = "auto", scale = "auto" },
})

-- Add your own hl.* settings below; they override Wiiperland's.
LUA
)
if [[ $DRY == 1 ]]; then echo "$entry" | sed 's/^/    | /'; else printf '%s\n' "$entry" >"$HYPR/hyprland.lua"; fi

# --- channel config ------------------------------------------------------------
WCONF="$CONF/wiiperland/config.json"
if [[ -e "$WCONF" ]]; then
  say "Keeping your existing $WCONF"
else
  say "Writing $WCONF"
  run mkdir -p "$(dirname "$WCONF")"
  if [[ $DRY == 0 ]]; then
    python3 - "$ROOT/config/config.json" "$WCONF" "$term" <<'PY'
import json, os, shutil, sys
src, dst, term = sys.argv[1:4]
cfg = json.load(open(src))
dirs = [os.path.expanduser("~/.local/share")] + os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":")
def has_entry(app):
    return any(os.path.exists(os.path.join(d, "applications", app + ".desktop")) for d in dirs)
def available(ch):
    if ch is None or ch.get("type", "app") != "app":
        return True
    if "exec" in ch:
        return shutil.which(ch["exec"].split()[0]) is not None
    return has_entry(ch.get("app", ""))
out = []
for ch in cfg["channels"]:
    if ch and ch.get("name") == "Terminal":
        ch["exec"] = term; ch["app"] = term
    out.append(ch if available(ch) else None)
    if ch and out[-1] is None:
        print(f"    leaving out '{ch.get('name')}' (not installed)")
cfg["channels"] = out
json.dump(cfg, open(dst, "w"), indent=2)
PY
  fi
fi

# --- your own assets -------------------------------------------------------------
ASSETS="${WIIPERLAND_ASSETS:-$CONF/wiiperland/assets}"
say "Making sure $ASSETS exists (your own sounds, music, fonts, images, banners)"
run mkdir -p "$ASSETS"/{sounds,music,fonts,img,banners}

# --- cursor theme and font -------------------------------------------------------
say "Linking cursor theme and font into $DATA"
run mkdir -p "$DATA/icons" "$DATA/fonts"
run ln -sfn "$ROOT/assets/cursor/Wiiperland" "$DATA/icons/Wiiperland"
run ln -sfn "$ROOT/quickshell/assets/fonts" "$DATA/fonts/wiiperland"
command -v fc-cache >/dev/null && run fc-cache -f "$DATA/fonts" >/dev/null

say "Done."
cat <<TXT

  Log out and pick "Hyprland" on the login screen (or run start-hyprland
  from a TTY). Inside Hyprland:
    SUPER (tap)   back to the menu        SUPER+ESC   HOME Menu
    SUPER+RETURN  terminal ($term)        SUPER+L     lock
  Channels live in $WCONF.
  Your own sounds, fonts and art go in $ASSETS (docs/assets.md).
  Undo everything with: $ROOT/uninstall.sh
TXT
