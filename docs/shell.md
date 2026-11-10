# Quickshell shell

The home screen, overlays and notifications are a [Quickshell](https://quickshell.org)
config in `quickshell/`. Hyprland starts it with `qs -p <repo>/quickshell`.

## Layout
```
quickshell/
  shell.qml              entry point: one HomeScreen per monitor, IPC handlers
  services/              singletons (import qs.services)
    Theme.qml            colours, fonts, asset paths, brand label
    Time.qml             clock state (12/24h, blinking colon, date text)
    Config.qml           loads and watches config.json
    Menu.qml             menu state (page, ...) + `menu` IPC target
  home/                  the Wii Menu (import qs.home)
    HomeScreen.qml       full-screen layer surface under all windows
    BottomBar.qml        grey panel, recess with blue outline, pockets, buttons
    SegmentClock.qml     "11:10 PM" built from SegmentDigit
    SegmentDigit.qml     thin seven-segment digit made of rounded bars
    WiiButton.qml        round glossy button with blue ring, hover and glow
    MailIcon.qml         envelope drawing
    ChannelGrid.qml      pages of 4×3 tiles, arrows, scrolling
    ChannelTile.qml      one slot: empty style, hover glow, channel art
    PageArrow.qml        blue triangle arrow
  channels/              tile art per channel type (import qs.channels)
    AppArt.qml           icon + name on a tinted background, glyph fallback
  assets/
    fonts/               M PLUS Rounded 1c (OFL)
    img/stripes.png      1×6 px tile for the striped background
```
Assets live inside `quickshell/` because Quickshell refuses to load files from
outside the config folder.

## Sizing
Everything is designed against a 720 px tall screen. Sizes are fractions of the
surface height (`hh * 0.079` and so on), so the menu scales to any resolution.
Horizontal positions are measured from the centre or the edges, so wide screens
keep the right proportions instead of stretching.

## Home screen surface
- Layer `bottom`, namespace `wiiperland-home`, ignores exclusive zones.
- Shows the full menu while its monitor is on workspace 1. On other
  workspaces the tiles and bar fade out and only the striped background stays
  behind windows.

## IPC
`bin/wii ipc <target> <function> [args]`, or `qs -p quickshell ipc call ...`.

| Target | Function | Meaning |
|---|---|---|
| `shell` | `home()` | Called by `wii home` (menu animations hook in here) |
| `shell` | `toast(title, body)` | Small popup message (filled in in phase 7) |
| `shell` | `osd(kind)` | On-screen indicator, e.g. `volume` (phase 8) |

## Customising
See [channels.md](channels.md) for `config.json` (brand label, 24-hour
clock, channels).

## Tested
- Nested Hyprland at 1280×720: bar, recess, blue outline, pockets, buttons,
  clock and date render with no QML warnings.
- On an app workspace the menu fades out and only the stripes stay.
- `wii ipc shell toast …` reaches the shell.
