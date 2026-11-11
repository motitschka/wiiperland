# Sounds and music

Wiiperland plays short, soft UI sounds and a quiet music loop on the menu.
Both are **original**, synthesised from sine waves by scripts in `tools/`
(public domain / CC0). Nothing is sampled.

## UI sounds
Made by [`tools/make-sounds.py`](../tools/make-sounds.py) and stored as WAV
files in `quickshell/assets/sounds/`: glassy pings (a sine with faint
inharmonic overtones) and airy whooshes, peaking around -11 dBFS.

| Sound | When |
|---|---|
| `tick` | Hovering a tile, button or arrow |
| `click` | Clicking a round button |
| `page` | Flipping a page, stepping channels in the preview |
| `open` | A tile zooms into its preview |
| `back` | Going back from the preview to the grid |
| `start` | Start / Resume |
| `mail` | A new message arrives |
| `home` | The HOME Menu opens |

## Settings (`config.json`)
```json
"sounds": true,
"soundVolume": 0.6,
"music": true,
"musicVolume": 0.35
```
`music` and `musicVolume` can also be changed in the HOME Menu (SUPER+ESC):
the **Menu music** note button switches it off and on, the slider next to it
sets its level. Both are saved to `config.json`.

## How it works
`services/Sound.qml` asks `Assets.sound(name)` for the file (yours, else the
built-in), runs `pw-play --volume <v> <file>` and falls back to `paplay`. The
same sound isn't repeated within 45 ms, so sweeping the mouse across tiles
doesn't stack ticks.

With `WIIPERLAND_SILENT=1` in the environment, sounds are only logged.
`dev/nested.sh` sets it, so tests are quiet; `WP_SOUND=1 dev/nested.sh` lets
them play.

To change a sound, edit `tools/make-sounds.py` and run it:

```bash
python3 tools/make-sounds.py
```

To use your own sounds without touching the repo, put `<name>.wav` (or
`.ogg`) files in `~/.config/wiiperland/assets/sounds/`. Each one replaces
the built-in sound of that name; see [assets.md](assets.md).

## Menu music
One loop plays while the menu is showing:

- **Which file:** your `music/menu.*` in the asset folder
  ([assets.md](assets.md)), else the built-in `quickshell/assets/music/menu.ogg`,
  a 25-second loop made by [`tools/make-music.py`](../tools/make-music.py)
  (pads on four chords, a sparse bell melody, a light pulse; its tails wrap
  around so it loops without a seam).
- **Fades out** (0.9 s) when you leave the menu for an app, while a channel's
  jingle plays in its preview, and on the lock screen. It is paused once it
  is silent and **fades back in** when you return.
- **Ducks** to a quarter of its level while something else is playing: an
  MPRIS player that reports "playing", or any running audio stream that
  isn't Wiiperland's own (looked up with `pactl` every 3 seconds while the
  menu shows).
- Needs Qt Multimedia (`qt6-multimedia`, `qt6-multimedia-ffmpeg`). Without it
  there is simply no music; the log says so once.

`services/Music.qml` decides the level, `services/MusicPlayer.qml` is the
player. `wii ipc music state` prints what it is doing, `wii ipc music toggle`
and `wii ipc music volume 0.2` change the settings.

To change the built-in loop, edit `tools/make-music.py` and run it (needs
`ffmpeg`):

```bash
python3 tools/make-music.py
```

## Tested
- All eight WAVs generate, have sane levels (peak around -8 dBFS) and play
  through `pw-play`.
- In the nested session the shell logs `sound page`, `sound open`,
  `sound back` and `sound tick` for page flips, preview open/close and hovers.
- F8, sounds: the eight WAVs were regenerated; peaks are now -10.5 to
  -16 dBFS. **Nobody has listened to them yet**, so whether they sound right
  is still open.
- F8, music, in the test session: the state went `playing` on the menu,
  `off` on another workspace and after `music toggle`, and back. With the
  real player running at a near-silent level, its audio stream appeared and
  was recognised as Wiiperland's own; a silent stream from another program
  switched it to `ducked` and back to `playing` when that ended. The HOME
  Menu shows the new controls, and `music volume 0.2` was saved to the
  config. **Hearing** the loop, the fades and the ducking, and dragging the
  slider, still need a check on real hardware.
