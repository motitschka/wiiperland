# Cursor

An original pointing-hand cursor: a white glove with a dark grey outline, a
round blue badge with a white "1" on the back of the hand and a soft drop
shadow. It stands upright (no tilt) and its hotspot is the fingertip. It is
drawn in [`assets/cursor/hand.svg`](../assets/cursor/hand.svg) and built into
an XCursor theme in `assets/cursor/Wiiperland/` (sizes 24 to 160).

The theme only draws the normal pointer and the link hand (both are the same
hand, like on the Wii). Everything else (text beam, resize arrows, busy) is
inherited from **Adwaita**.

## Two sizes: big on the menu, normal in apps
The same hand is used everywhere, in two sizes:

| Where | Size |
|---|---|
| The menu (workspace 1), the HOME Menu, the lock screen, the startup screen | Wii-sized: **8% of the screen height** (96 px on a 1200 px screen, 86 px on 1080p) |
| Apps | `cursor_size`, default **48** |

How it works: Hyprland has no setting for "a different cursor size on one
workspace", so `services/Cursor.qml` runs `hyprctl setcursor Wiiperland <size>`
whenever the menu comes or goes, or an overlay that belongs to the menu opens
or closes. The switch takes 30 to 60 ms and the pointer keeps using
Hyprland's own cursor drawing, so it never lags behind the mouse.

(The other option was to hide the real pointer on the menu and draw the hand
in QML. That would trail the mouse by a frame and need a copy in every
overlay, so the size switch won.)

Change the menu size in `config.json`:

```json
"cursor": { "menuSize": "auto" }
```
| Value | Meaning |
|---|---|
| `"auto"` (default) | 8% of the screen height |
| a number, e.g. `120` | that many pixels |
| `0` | the same size as in apps |

`wii ipc cursor state` prints the theme, both sizes and which one is active.

Notes:
- Apps that draw their own pointer instead of asking the compositor (GTK3,
  XWayland) use `XCURSOR_SIZE`, which is the app size, so they are never
  affected by the menu size.
- If you keep your own theme with `setup({ cursor_theme = nil })`, the
  environment has no theme name for the shell to pass to `setcursor`, and
  the size stays as it is.

## How the theme is used
- `env.lua` sets `XCURSOR_THEME=Wiiperland`, `XCURSOR_SIZE` (default 48) and
  an `XCURSOR_PATH` that includes the repo, so it works before installing.
- `install.sh` also links the theme into `~/.local/share/icons/Wiiperland`
  so other tools can find it.
- Apps that use the Wayland cursor-shape protocol (GTK4, Qt6, Firefox)
  get Hyprland's cursor automatically.

Hyprland's `cursor.sync_gsettings_theme` is turned **off**. Otherwise
Hyprland copies its cursor theme into gsettings, which GNOME shares, and the
hand would show up in GNOME too. The trade-off: older GTK3 apps (which read
gsettings instead of asking the compositor) show the Adwaita arrow inside
Hyprland.

If GNOME already picked up the hand from an earlier version, reset it:

```bash
gsettings reset org.gnome.desktop.interface cursor-theme
gsettings reset org.gnome.desktop.interface cursor-size
```

Keep your own cursor with `setup({ cursor_theme = nil })`, or change the
app size with `setup({ cursor_size = 64 })`.

## Rebuilding
Edit the SVG, then:

```bash
python3 tools/make-cursor.py    # needs rsvg-convert and ImageMagick
```

The script writes XCursor files directly (no `xcursorgen` needed). If you
move the fingertip, update `HOT` in the script. A running Hyprland keeps the
old picture until the theme is loaded again (log in again, or
`hyprctl setcursor Wiiperland <another size>`).

## Tested
- The generated file parses as XCursor (11 sizes, hotspots at the
  fingertip).
- In the nested session at 1920×1200 (screenshots with the pointer): the
  hand is 96 px on the menu, the fingertip sits exactly on the pointer
  position, and sizes that aren't in the file (100) are scaled cleanly.
- Starting a channel switched to 48 px (hand on the window's header bar,
  Adwaita text beam in the text area); opening the HOME Menu over the app
  switched to 96 px and closing it back to 48 px; `wii home` gave 96 px
  again. `wii ipc cursor state` agreed at every step.
- GNOME's `cursor-theme` setting stays `Adwaita` while it runs.
- Still to check on real hardware: that the size switch looks smooth with a
  real mouse (the nested session has no hardware cursor plane).
