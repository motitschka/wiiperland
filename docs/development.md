# Development

Everything can be developed and tested without logging out of your current
session. The `dev/` scripts run a **nested Hyprland**: a window inside your
current Wayland session that uses this repo's config.

## Requirements
- Hyprland 0.57+ (Lua config)
- `grim` for screenshots
- Quickshell 0.3+ (`qs`) on `PATH`, **or** a Quickshell package extracted
  somewhere (no root needed) and pointed to with `QS_PREFIX`:

  ```bash
  mkdir -p ~/qs-prefix && cd ~/qs-prefix
  for u in $(pacman -Sp quickshell cpptrace jemalloc libdwarf); do curl -sfLO "$u"; done
  for f in *.pkg.tar.zst; do bsdtar -xf "$f"; done
  ln -sf quickshell usr/bin/qs   # the packaged symlink is absolute
  export QS_PREFIX=~/qs-prefix
  ```

## Scripts
| Script | What it does |
|---|---|
| `dev/nested.sh [WxH]` | Start a nested Hyprland with `hypr/hyprland.lua` (default 1280x720). Stops any previous one. |
| `dev/hctl.sh …` | `hyprctl` against the nested instance, e.g. `dev/hctl.sh clients`. |
| `dev/run.sh cmd …` | Run a program inside the nested instance. |
| `dev/shot.sh [name]` | Screenshot the nested instance to `dev/screenshots/<name>.png`. |
| `dev/stop.sh` | Stop the nested instance. |

Put machine-specific settings such as `QS_PREFIX=...` in `dev/local.env` (git-ignored).

Logs are written to `dev/.nested/` (git-ignored).

## Isolation from your real session
`dev/nested.sh` keeps tests away from your desktop:
- a **private D-Bus session bus** (its own `dbus-daemon`), so the nested
  shell can own the notification service and test apps don't attach to your
  running ones (opt out with `WP_SHARED_DBUS=1`);
- `WIIPERLAND_CONFIG=dev/test-config.json`: a channel list of apps that open
  their own instance;
- `WIIPERLAND_STATE=dev/.nested/state`: saved state such as the message board.

`dev/run.sh` uses the same bus, so `dev/run.sh notify-send hi` reaches the
nested shell.

## Environment variables the config understands
| Variable | Meaning |
|---|---|
| `WIIPERLAND_ROOT` | Repo location. Set by the dev scripts; normal installs find it automatically. |
| `WIIPERLAND_DEV_MODE` | Forces the monitor mode (e.g. `1280x720`) and scale 1. Set by `dev/nested.sh`. |
| `WIIPERLAND_DEV_BUS` | D-Bus address the config hands to child processes (dev only). |
| `WIIPERLAND_CONFIG` | Path of `config.json` to use. |
| `WIIPERLAND_STATE` | Folder for saved state (default `~/.local/state/wiiperland`). |

## Checklist for every change
1. `Hyprland --verify-config -c hypr/hyprland.lua`
2. `dev/nested.sh`, then `dev/shot.sh <name>` and look at the result.
3. Check `dev/.nested/hyprland.log` and the Quickshell log for errors.
4. Update the docs in `docs/`.
5. Commit and push.
