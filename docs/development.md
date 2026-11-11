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
| `dev/nested.sh [--headless] [WxH]` | Start a nested Hyprland with `hypr/hyprland.lua` (default 1280x720). Stops any previous one. |
| `dev/hctl.sh …` | `hyprctl` against the nested instance, e.g. `dev/hctl.sh clients`. |
| `dev/run.sh cmd …` | Run a program inside the nested instance. |
| `dev/shot.sh [name]` | Screenshot the nested instance to `dev/screenshots/<name>.png`. `WP_CURSOR=1` includes the pointer. |
| `dev/hover.sh X Y` | Put the pointer at X,Y in the nested instance so that the shell reacts (hover rings, name bubbles). |
| `dev/stop.sh` | Stop the nested instance. |

### Headless mode
`dev/nested.sh --headless 1920x1200` (or `WP_HEADLESS=1`) adds an off-screen
output called `WP-HEADLESS` and removes the one that is a window on your
desktop. Use it for automated testing:
- nothing pops up on your desktop or takes focus;
- the size is exact (a window is shrunk by your desktop's panels);
- screenshots always work. A nested *window* that is hidden, covered or on
  another workspace isn't drawn, and `grim` would wait for it forever
  (`dev/shot.sh` gives up after 10 seconds and says so).

The off-screen output draws the pointer into the picture, so screenshots
show the cursor even without `WP_CURSOR=1`.

### Pointer and hover
The mouse can't be clicked in the nested session, so the UI is driven through
IPC (`dev/run.sh bin/wii ipc menu open 2`, ...). Hover can be tested:
`dev/hover.sh X Y` puts the pointer at X,Y.

Don't use `hyprctl dispatch 'hl.dsp.cursor.move(...)'` on its own for that.
It sends the motion without the frame event that ends a group of pointer
events, and Qt waits for that frame, so the shell never sees a move that
stays inside one surface. Entering a surface does come with a frame. So
`dev/nested.sh` starts a tiny invisible surface in the top-left corner
(`dev/pointer-park/`), and `dev/hover.sh` parks the pointer there before each
move: the shell then gets "the pointer entered at X,Y". The pointer therefore
always arrives from outside. Gliding from one tile straight to the next can
only be tried with a real mouse.

Put machine-specific settings such as `QS_PREFIX=...` in `dev/local.env` (git-ignored).

Logs are written to `dev/.nested/` (git-ignored).

## Isolation from your real session
`dev/nested.sh` keeps tests away from your desktop:
- a **private D-Bus session bus** (its own `dbus-daemon`), so the nested
  shell can own the notification service and test apps don't attach to your
  running ones (opt out with `WP_SHARED_DBUS=1`);
- `WIIPERLAND_CONFIG=dev/.nested/config.json`: a fresh copy of
  `dev/test-config.json` on every start, because the menu can rewrite its
  config (arranging channels). It is a channel list of apps that open their
  own instance, with a fixed `forecast.location` so that a screenshot never
  shows where you are (wttr.in would otherwise guess from your IP);
- `WIIPERLAND_STATE=dev/.nested/state`: saved state such as the message board;
- `WIIPERLAND_ASSETS=dev/.nested/assets`: an asset folder for tests (empty
  unless a test fills it), so your own files in `~/.config/wiiperland/assets`
  can't end up in a screenshot;
- `WIIPERLAND_MEDIA=dev/.nested/media`: where the Disc Channel looks for
  plugged-in drives, instead of `/run/media/$USER`. Make a sub-folder there
  to "insert" one (`mkdir dev/.nested/media/STICK`); its size is that of
  your own disk;
- `WIIPERLAND_SILENT=1`: UI sounds are logged, not played. Start with
  `WP_SOUND=1 dev/nested.sh` to hear them.

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
| `WIIPERLAND_ASSETS` | Your asset folder (default `~/.config/wiiperland/assets`), see [assets.md](assets.md). |
| `WIIPERLAND_MEDIA` | Folder the Disc Channel watches (default `/run/media/$USER`). |
| `WIIPERLAND_SILENT` | `1` logs UI sounds instead of playing them. |

## Good to know
- Quickshell reloads the shell when a QML file is saved. The reload fails
  with `<Name> is not a type` after an inline `component <Name>: ...` was
  added, renamed or removed in a file that was already loaded, and the old
  picture stays on screen. Restart with `dev/nested.sh`.
- Run the shell only through `dev/nested.sh`. Started by hand
  (`qs -p quickshell`) it has no test environment: it reads your real
  `config.json` and plays sounds.
- QML: a `Behavior` on a property never advances while that property's
  binding changes on every frame (for example an `opacity` bound to a value
  that another animation is pulsing), because each change restarts it. Fade
  a parent item with the Behavior and run the pulse on a child.

- The log is cumulative: after a reload the old warnings are still in it.
  A reload also closes an open preview, so open it again before a
  screenshot.
- `WIIPERLAND_SILENT=1` (the default here) means no audio process or player
  is started at all. To exercise the real music player without noise, start
  with `WP_SOUND=1` and a temporary config that has `"sounds": false` and
  `"musicVolume": 0.001`.
- Qt Multimedia ignores `play()` until the file has loaded; start from
  `onMediaStatusChanged` at `LoadedMedia` (see `VideoBanner.qml`,
  `MusicPlayer.qml`). Qt's own audio stream has no
  `application.process.binary`; it is recognised by `media.name`.
- Anything that should survive a missing QML module (video, music) goes in
  its own file behind `Loader { source: Qt.resolvedUrl(...) }`.
- Hand a component values that belong together (a banner's path and kind)
  as one object. As two properties they change one after the other, and for
  an instant an image loader gets a video file.
- An IPC function can't be called `show`: `qs ipc call <target> show` lists
  the target instead. Use `open`.
- `PillButton` has `available` for the greyed-out look; `enabled` also turns
  false while a parent animates.
- Don't commit a screenshot of the channel picker (it lists the installed
  apps) or of a Forecast preview taken with another config than
  `dev/test-config.json` (it would name the town).

## Checklist for every change
1. `Hyprland --verify-config -c hypr/hyprland.lua`
2. `dev/nested.sh`, then `dev/shot.sh <name>` and look at the result.
3. Check `dev/.nested/hyprland.log` and the Quickshell log for errors.
4. Update the docs in `docs/`.
5. Commit and push.
