# Channel preview and launching

Clicking a channel doesn't start it right away. Like on the Wii:

1. The tile **zooms up** from its place in the grid to fill the screen (the
   rest of the menu fades out).
2. A panel rises from the bottom with two buttons:
   **`<brand> Menu`** (zoom back to the grid) and **Start**. If the app is
   already running, Start says **Resume**.
3. Arrows on both sides step to the previous or next channel.
4. **Start** fades the screen to white, then:
   - if a window of the channel is open, it is activated (Hyprland jumps to
     its workspace);
   - otherwise the channel's command runs through `wii launch`, which opens it
     on a fresh, empty workspace.
   The preview then resets quietly behind the new window, so the menu is
   normal when you come back with SUPER.

Keyboard in the preview: **Esc** back, **Enter** start, **←/→** other channels.

## Running indicator
A tile shows a small blue dot when one of its windows is open. Windows are
matched by Wayland app id against:
- the channel's `class` regex, if set; otherwise
- the desktop entry id, the `app` value, and the first word of `exec`.

Set `class` when an app's window id differs from its desktop file
(e.g. `"class": "^(Code|codium)$"`).

## Code
| File | Role |
|---|---|
| `services/Launcher.qml` | desktop entry lookup, running detection, `start()` |
| `services/Menu.qml` | `menu` IPC: `open <slot>`, `start`, `close`, `next`, `prev`, `page <n>`, `state` |
| `home/ChannelPreview.qml` | zoom animation, bottom panel, arrows, white fade |
| `home/PillButton.qml` | rounded preview buttons |
| `channels/ChannelArt.qml` | picks the art for a channel type (used by tiles and the preview) |

## Testing without touching your real session
`dev/nested.sh` sets `WIIPERLAND_CONFIG=dev/test-config.json`, a channel list
with apps that open their own instance (`gnome-text-editor --standalone`,
`cool-retro-term`), so test launches don't open windows in your real desktop.

```bash
dev/run.sh bin/wii ipc menu open 0   # zoom into slot 0
dev/run.sh bin/wii ipc menu start    # press Start
dev/run.sh bin/wii home              # back to the menu
```

## Tested
- `menu open 1`: zoom (mid-animation and final frames captured), panel and
  arrows shown.
- `menu start` on the Text Editor channel: white fade, window opened on
  workspace 2, focus followed. After `wii home` the grid is back and the tile
  shows the running dot.
- `menu close`: zooms back to the grid.
- Keyboard shortcuts in the preview can't be injected into the nested
  session; they need a check on real hardware.
