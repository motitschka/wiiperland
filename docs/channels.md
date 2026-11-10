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
| `brand` | `"Hypr"` | Word embossed on empty slots and on the home button |
| `clock24h` | `false` | 24-hour clock (hides AM/PM) |
| `sounds` | `true` | UI sounds (phase 6) |
| `pages` | `4` | Minimum number of pages (each holds 12 slots). More are added automatically if `channels` is longer. |
| `channels` | `[]` | Slots in order: page 1 is slots 1–12, left to right, top to bottom. `null` leaves a slot empty. |

## Channel fields
| Field | Meaning |
|---|---|
| `type` | `app` (default art), `photos`, `forecast`, `music` (live art, phase 5) |
| `app` | Desktop entry id or name (e.g. `firefox`, `org.gnome.Nautilus`). Supplies icon, name and launch command. |
| `name` | Label on the tile (overrides the desktop entry's name) |
| `exec` | Command to run (overrides the desktop entry's command) |
| `icon` | Icon theme name (overrides the desktop entry's icon) |
| `glyph` | Text drawn on a coloured badge when the icon isn't found (default: first letter of the name) |
| `color` | Tint of the tile background and badge |
| `description` | Line under the name on the preview screen (default: the desktop entry comment) |
| `class` | Window app-id regex used to tell whether the channel is running (see [preview-and-launch.md](preview-and-launch.md)) |

## Navigation
- Arrows at the screen edges, mouse wheel or touchpad scroll flip pages.
- Hovering a tile gives it the pulsing blue outline.
- `bin/wii ipc menu next|prev`, `bin/wii ipc menu page <n>`, and
  `bin/wii ipc menu state` (prints `{"page":…,"pageCount":…}`).

## Tested
- Default config: 9 channels and 3 empty slots on page 1, 4 pages, arrows
  shown or hidden at the ends.
- Missing icons fall back to the glyph badge.
- `menu next` / `menu prev` slide pages; hovering shows the blue outline.
