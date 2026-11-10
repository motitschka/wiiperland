# Sounds

Wiiperland plays short, soft UI sounds. They are **original**, synthesised by
[`tools/make-sounds.py`](../tools/make-sounds.py) (sine and bell tones,
public domain / CC0), and stored as WAV files in `quickshell/assets/sounds/`.

| Sound | When |
|---|---|
| `tick` | Hovering a tile, button or arrow |
| `click` | Clicking a round button |
| `page` | Flipping a page, stepping channels in the preview |
| `open` | A tile zooms into its preview |
| `back` | Going back from the preview to the grid |
| `start` | Start / Resume |
| `mail` | A new message arrives (phase 7) |
| `home` | The HOME Menu opens (phase 8) |

## Settings (`config.json`)
```json
"sounds": true,
"soundVolume": 0.6
```

## How it works
`services/Sound.qml` runs `pw-play --volume <v> <file>` and falls back to
`paplay`. The same sound isn't repeated within 45 ms, so sweeping the mouse
across tiles doesn't stack ticks.

To change a sound, edit `tools/make-sounds.py` and run it:

```bash
python3 tools/make-sounds.py
```

You can also drop your own `<name>.wav` files into
`quickshell/assets/sounds/`.

## Tested
- All eight WAVs generate, have sane levels (peak around -8 dBFS) and play
  through `pw-play`.
- In the nested session the shell logs `sound page`, `sound open`,
  `sound back` and `sound tick` for page flips, preview open/close and hovers.
