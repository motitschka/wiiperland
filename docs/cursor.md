# Cursor

An original pointing-hand cursor (white glove, slate outline, blue cuff),
drawn in [`assets/cursor/hand.svg`](../assets/cursor/hand.svg) and built
into an XCursor theme in `assets/cursor/Wiiperland/` (sizes 24 to 96).
The hotspot is the fingertip.

The theme only draws the normal pointer and the link hand (both are the same
hand, like on the Wii). Everything else (text beam, resize arrows, busy) is
inherited from **Adwaita**.

## How it's used
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
size with `setup({ cursor_size = 64 })`.

## Rebuilding
Edit the SVG, then:

```bash
python3 tools/make-cursor.py    # needs rsvg-convert and ImageMagick
```

The script writes XCursor files directly (no `xcursorgen` needed).

## Tested
- The generated file parses as XCursor (5 sizes, hotspots at the
  fingertip).
- In the nested session, `grim -c` shows the hand as Hyprland's pointer,
  and GNOME's `cursor-theme` setting stays `Adwaita` while it runs.
