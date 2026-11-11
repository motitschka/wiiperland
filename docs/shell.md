# Quickshell shell

The home screen, overlays and notifications are a [Quickshell](https://quickshell.org)
config in `quickshell/`. Hyprland starts it with `qs -p <repo>/quickshell`.

## Layout
```
quickshell/
  shell.qml              entry point: one HomeScreen per monitor, IPC handlers
  services/              singletons (import qs.services)
    Theme.qml            colours, fonts, brand label
    Assets.qml           the owner's asset folder (overrides for built-in files)
    Time.qml             clock state (12/24h, blinking colon, date text)
    Config.qml           loads and watches config.json
    Menu.qml             menu state (page, ...) + `menu` IPC target
    Launcher.qml         desktop entries, running detection, start/resume
    Weather.qml          wttr.in fetcher for the Forecast Channel
    Sound.qml            UI sounds
    Messages.qml         notification server + message board state
    Hypr.qml             Hyprland helpers (focused monitor, workspace)
    Cursor.qml           pointer size: big on the menu, normal in apps
  home/                  the Wii Menu (import qs.home)
    HomeScreen.qml       full-screen layer surface under all windows
    BottomBar.qml        pale grey panel: recess, thin blue line, sockets, buttons, date, arrival label
    SegmentClock.qml     "11:10 PM" built from SegmentDigit, colon on the centre line
    SegmentDigit.qml     seven-segment digit made of bars with pointed ends
    WiiButton.qml        round matte button with a pale-blue ring, hover and glow
    MailIcon.qml         envelope drawing
    ChannelGrid.qml      one strip of 4×3 pages, neighbours peeking at the edges, arrows, scrolling
    ChannelTile.qml      one slot: empty plate, hover ring, channel art
    NameBubble.qml       the bubble with the channel's name under a hovered tile
    PageArrow.qml        pale-blue arrowhead with a hollowed back
    ChannelPreview.qml   zoomed channel preview
    PillButton.qml       rounded preview/board buttons
    MessageBoard.qml     message board overlay
  overlays/              separate layer surfaces (import qs.overlays)
    Toasts.qml           notification toasts
    HomeMenu.qml         HOME Menu overlay (SUPER+ESC)
    Osd.qml              volume indicator
    LockScreen.qml       session lock + PAM + idle auto-lock
    Startup.qml          once-per-login "click to continue" screen
  channels/              tile art per channel type (import qs.channels)
    ChannelArt.qml       picks the art component for a channel type
    AppArt.qml           icon + name on a tinted background, glyph fallback
    PhotoArt.qml         photo collage from a folder
    ForecastArt.qml      weather tile / 3-day preview
    WeatherIcon.qml      drawn weather icons
    MusicArt.qml         MPRIS now playing + controls
  assets/
    fonts/               M PLUS Rounded 1c (OFL)
    img/stripes.png      1×6 px tile for the striped background
```
Built-in assets live inside `quickshell/` because Quickshell refuses relative
URLs that leave the config folder. Your own sounds, fonts and images go in
`~/.config/wiiperland/assets/` and override them; see [assets.md](assets.md).

## Sizing
Sizes are fractions of the surface height (`hh * 0.083` and so on), so the
menu scales to any resolution. Two things follow the screen **width** instead,
so the menu fills a screen of any shape:
- The channel grid: a tile is 20% of the screen wide (at most 2.1 times its
  height). Four of them leave room for one peeking column of the neighbouring
  page at each edge; very wide screens show more of the neighbours.
- The recess in the bottom bar: it follows the width up to 16:9 and isn't
  stretched beyond that.

The corner buttons keep their distance from the screen edges. Screens that
are taller than they are wide aren't supported: the clock would run into the
buttons.

## Home screen surface
- Layer `bottom`, namespace `wiiperland-home`, ignores exclusive zones.
- Shows the full menu while its monitor is on workspace 1. On other
  workspaces the tiles and bar fade out and only the striped background stays
  behind windows.

## The menu
Proportions, weights and tones follow a recording of the real console (see
[PLAN.md](../PLAN.md)). Everything is drawn in QML.

- **Grid**: all pages are one strip that slides sideways. The last column of
  the previous page and the first column of the next one peek in at the
  screen edges. Clicking a peeking tile flips to its page, like the arrows
  and the scroll wheel do.
- **Hover**: a pale-blue ring around the tile and, after a moment, a white
  bubble with the channel's name just under it. The tile doesn't grow. The
  bubble of a bottom-row tile lies over the bar, and a bubble never leaves
  the screen's side margins. A channel's name is its `name`, else its desktop
  entry's name, else the name of its type ("Photo Channel", ...).
- **Bottom bar**: a thin pale-blue line along the whole top edge with a soft
  shadow under it, a wide recess that holds the clock, the date below it
  (`Fri 4/18`), and a round button in a shallow socket at each end. The
  clock's colon stays on the centre line; the hours grow to the left.
- **Arrival label**: when the menu comes into view (after the start screen,
  on `wii home`, after a channel closes, on switching back to workspace 1)
  the recess shows "<brand> Menu" in blue for two seconds, then cross-fades
  to the clock.

## IPC
`bin/wii ipc <target> <function> [args]`, or `qs -p quickshell ipc call ...`.

| Target | Function | Meaning |
|---|---|---|
| `shell` | `home()` | Called by `wii home`: closes the HOME Menu, previews and the board, shows the arrival label |
| `shell` | `toast(title, body)` | Post a message (toast + board) |
| `shell` | `osd(kind)` | On-screen indicator, e.g. `volume` |
| `homemenu` | `toggle()` / `open()` / `close()` | HOME Menu |
| `menu` | `next()`, `prev()`, `page(n)`, `state()` | Pages, see [channels.md](channels.md#navigation) |
| `menu` | `open(slot)`, `start()`, `close()` | Channel preview, see [preview-and-launch.md](preview-and-launch.md) |
| `menu` | `board()` | Open the Message Board |
| `menu` | `arrive()` | Show the arrival label, as if the menu had just come into view |
| `assets` | `list()`, `reload()`, `sound(name)`, ... | The asset folder, see [assets.md](assets.md) |
| `cursor` | `state()` | Pointer theme and sizes, see [cursor.md](cursor.md) |

## Customising
See [channels.md](channels.md) for `config.json` (brand label, 24-hour
clock, channels).

## Tested
- Off-screen session at 1920×1200 and 1280×720: bar, recess, line, sockets,
  buttons, clock and date render with no QML warnings, and were compared
  with stills from the reference recording.
- The arrival label shows after the start screen and on `wii ipc menu arrive`,
  then gives way to the clock.
- Hovering with `dev/hover.sh` shows the ring and the name bubble; the bubble
  of a bottom-row tile lies over the bar; page 2 shows page 1's last column
  peeking in at the left edge.
- The clock in 12- and 24-hour mode, drawn and with a clock font: the colon
  stays on the centre line.
- Brand `"arch"`: fits the home button, the empty slots and the label.
- A tile at the edge of the page reacts over its whole width; the page arrow
  next to it doesn't take the pointer.
- The lock screen, which uses the same clock, still shows it centred.
- On an app workspace the menu fades out and only the stripes stay.
- `wii ipc shell toast …` reaches the shell.
