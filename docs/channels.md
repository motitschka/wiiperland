# Channels and `config.json`

The menu reads `~/.config/wiiperland/config.json` (or the file named by
`$WIIPERLAND_CONFIG`). If that file doesn't exist
it falls back to the repo's [`config/config.json`](../config/config.json). The
file is watched, so saving it updates the menu immediately.

```json
{
  "brand": "Hypr",
  "clock24h": false,
  "sounds": true,
  "pages": 4,
  "channels": [
    { "type": "app", "app": "firefox", "name": "Internet", "color": "#ff9a3c" },
    { "type": "photos", "name": "Photo Channel", "dir": "~/Pictures" },
    null,
    { "type": "app", "name": "Terminal", "exec": "kitty", "glyph": ">_", "color": "#4b4b4b" }
  ]
}
```

## Top-level settings
| Key | Default | Meaning |
|---|---|---|
| `brand` | `"Hypr"` | Word embossed on empty slots and on the home button, and the "<brand> Menu" label shown when the menu comes into view |
| `clock24h` | `false` | 24-hour clock (hides AM/PM) |
| `sounds` | `true` | UI sounds (see [sounds.md](sounds.md)) |
| `soundVolume` | `0.6` | 0 to 1 |
| `pages` | `4` | Minimum number of pages (each holds 12 slots). More are added automatically if `channels` is longer. |
| `startupScreen` | `true` | "Click to continue" screen once per login ([lock-and-startup.md](lock-and-startup.md)) |
| `lock.idleMinutes` | `10` | Lock after this many idle minutes; `0` = never |
| `cursor.menuSize` | `"auto"` | Pointer size on the menu: `"auto"` (8% of the screen height), a number of pixels, or `0` for the app size ([cursor.md](cursor.md)) |
| `forecast` | | Weather settings, see below |
| `messages.keep` | `200` | How many messages the board keeps |
| `channels` | `[]` | Slots in order: page 1 is slots 1–12, left to right, top to bottom. `null` leaves a slot empty. |

## Channel fields
| Field | Meaning |
|---|---|
| `type` | `app` (default), or a live type: `photos`, `forecast`, `music` (see below) |
| `app` | Desktop entry id or name (e.g. `firefox`, `org.gnome.Nautilus`). Supplies icon, name and launch command. |
| `name` | The channel's name: its name bubble, the preview's title tab, and the file name of its banner (overrides the desktop entry's name) |
| `exec` | Command to run (overrides the desktop entry's command) |
| `icon` | Icon theme name (overrides the desktop entry's icon) |
| `glyph` | Text drawn on a coloured badge when the icon isn't found (default: first letter of the name) |
| `color` | Colour of the built-in scene and badge |
| `banner` | Picture, animation or video shown instead of the built-in art ([assets.md](assets.md#banners-channel-banners-and-jingles)). Without it, `banners/<name>.*` in the asset folder is used if present. |
| `jingle` | Sound played while the preview is open. Without it, `banners/<name>.ogg` (or another sound format) is used if present. |
| `description` | Line under the name on the preview of the built-in app art (default: the desktop entry comment) |
| `class` | Window app-id regex used to tell whether the channel is running (see [preview-and-launch.md](preview-and-launch.md)) |

## What a tile shows
1. The channel's **banner**, if it has one: full-bleed, cropped to fill.
2. Otherwise the **built-in art** for its type. Every built-in tile is a
   full-bleed scene that moves gently and carries no name (hover shows the
   name bubble):
   - `app`: the channel's `color` as a soft backdrop with drifting lights and
     the app's icon floating in the middle. The preview adds the name and
     the description.
   - `photos`, `forecast`, `music`: see below.

Scenes, animated banners and videos rest while their page isn't the one
showing and while you are in an app.

## Live channel types

### `photos`: Photo Channel
The tile is one picture from `dir` (default `~/Pictures`, not recursive),
full-bleed, slowly zooming, cross-fading to the next every 7 seconds. The
preview is a collage of five that sways a little. Start opens the folder with
`xdg-open` unless `exec` is set.

```json
{ "type": "photos", "name": "Photo Channel", "dir": "~/Pictures/Screenshots" }
```

### `forecast`: Forecast Channel
The tile is a sky for the current weather: sun, drifting clouds, falling
rain or snow, an occasional flash in a storm, with the temperature in the
corner. The preview puts the place, conditions and a three-day forecast on a
card over the same sky. Data comes from [wttr.in](https://wttr.in) through `curl` every
30 minutes. Settings go in a top-level `forecast` object:

```json
"forecast": { "location": "Oslo", "units": "metric", "enabled": true }
```
| Key | Default | Meaning |
|---|---|---|
| `location` | `""` | City or place. Empty lets wttr.in guess from your IP address. |
| `units` | `"metric"` | `"metric"` (°C) or `"imperial"` (°F) |
| `enabled` | `true` | `false` stops all network requests |

The sky and the icons (sun, partly cloudy, cloud, fog, rain, snow, storm) are
drawn in QML.

### `music`: Music Channel
Follows any MPRIS player (the playing one first). The tile shows equaliser
bars and rising notes that liven up while something plays; when the player
supplies cover art, the cover fills the tile with the title and artist along
the bottom. The preview shows cover, title and artist with previous /
play-pause / next buttons.
Set `app` (e.g. `"app": "vlc"`) so Start opens your player.

### Paths
`dir` and other paths understand `~` and `${VAR}` (environment variables;
`${WIIPERLAND_ROOT}` is always the repo folder).

## Navigation
- The neighbouring pages peek in at the screen edges. Clicking a peeking
  tile or an arrow, or scrolling with the wheel or the touchpad, flips pages.
- Hovering a tile gives it a pale-blue ring and shows its name in a bubble
  under it.
- `bin/wii ipc menu next|prev`, `bin/wii ipc menu page <n>`, and
  `bin/wii ipc menu state` (prints `{"page":…,"pageCount":…}`).

## Tested
- Built-in scenes in the nested session (F5): app tiles with a theme icon
  and with a glyph badge, the photo slideshow tile and collage preview, the
  forecast sky for real wttr.in weather (rain and sun seen; snow, fog and
  storm are drawn by the same code but weren't in the weather on the day),
  the idle music tile and preview. A **playing** MPRIS player (livelier
  bars, cover art on the tile) was not re-tested in F5.
- Banners and jingles: see [assets.md](assets.md).
- Default config: 9 channels and 3 empty slots on page 1, 4 pages, arrows
  shown or hidden at the ends.
- Missing icons fall back to the glyph badge.
- `menu next` / `menu prev` / `menu page <n>` slide the strip and the
  neighbouring page peeks in; hovering shows the ring and the name bubble.
