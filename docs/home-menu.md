# HOME Menu and volume indicator

## HOME Menu (SUPER+ESC)
Opens on top of everything, on the focused screen:

- The screen dims and Hyprland blurs what's behind it.
- A dark **top bar** slides down with the title and a **Close** button.
- Two big buttons pop in:
  - **`<brand> Menu`**: back to the Wii Menu (workspace 1).
  - **Close Channel**: closes the focused window (greyed out on the menu).
- A **bottom bar** slides up with:
  - **Volume**: mute button and a draggable blue slider (PipeWire default output).
  - **Battery**: level and percentage (laptops only, via UPower).
  - **Power**: Lock, Log Out, Restart, Shut Down. The last three ask
    "Sure?" and need a second click within 3 seconds.

**Esc**, the Close button or a click on the dimmed area closes it.
`wii homemenu` toggles it; IPC: `wii ipc homemenu toggle|open|close`.

## Volume indicator
A white pill with a speaker and ten blue bars appears at the bottom centre for
1.5 s whenever the output volume or mute changes, whether from the volume keys
(`wii volume up|down|mute`), the HOME Menu slider or another app.
`wii ipc shell osd volume` shows it by hand.

## Back to the menu when a channel closes
When the last window on a workspace closes, Hyprland returns to workspace 1,
like quitting a channel on the Wii. Turn it off with
`setup({ home_on_empty = false })`.

## Code
| File | Role |
|---|---|
| `overlays/HomeMenu.qml` | overlay layer `wiiperland-homemenu` (blurred by a layer rule) |
| `overlays/Osd.qml` | volume indicator layer `wiiperland-osd` (click-through) |
| `services/Audio.qml` | PipeWire default sink volume/mute |
| `home/SpeakerIcon.qml` | drawn speaker icon |
| `hypr/wiiperland/rules.lua` | `window.close` hook for back-to-menu |

## Tested
- With a channel open: HOME Menu renders over the blurred, dimmed app; the
  volume indicator shows the current level.
- `hl.dsp.window.close()` (what Close Channel runs) closes the window, and
  the back-to-menu hook switches to workspace 1 with no Lua errors.
- Power buttons and dragging the slider weren't clicked in testing, since
  they'd act on the real machine (power, volume).
