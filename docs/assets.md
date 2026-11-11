# Your own assets

Wiiperland ships only original or openly licensed sounds, fonts and art. To
use your own files instead, put them in the **asset folder**:

```
~/.config/wiiperland/assets/        (or the folder named by $WIIPERLAND_ASSETS)
  sounds/     UI sounds
  music/      menu music
  fonts/      UI font and clock font
  img/        small pieces of the menu
  banners/    channel banners and jingles
```

A file there **wins over the built-in one**; anything you don't supply keeps
the built-in. The folder is outside the repo and is never committed.
`install.sh` creates the empty folders.

Rules that hold for every folder:
- File names are matched **without regard to case** (`Tick.WAV` = `tick.wav`).
- When several formats of one name exist, the first in the listed order wins.
- Files are picked up **while the shell runs**: adding or deleting a file
  shows at once. A file replaced under the same name is noticed the next time
  you come back to the menu, or right away with `wii ipc assets reload`.

## `sounds/`: UI sounds
`<name>.wav`, `.ogg`, `.oga`, `.flac` or `.mp3`, played with `pw-play`.
Keep them short; they are played at `soundVolume` from `config.json`.

| Name | When it plays |
|---|---|
| `tick` | hovering a tile, button or arrow |
| `click` | clicking a round button |
| `page` | flipping a page, stepping channels in the preview |
| `open` | a tile zooms into its preview, the message board opens |
| `back` | going back (preview, board, HOME Menu) |
| `start` | Start / Resume, unlocking |
| `mail` | a new message arrives |
| `home` | the HOME Menu opens |

Example: `~/.config/wiiperland/assets/sounds/tick.wav`.

## `fonts/`: UI font and clock font
`.ttf` or `.otf`.

| File | Role |
|---|---|
| `ui-regular` | body text |
| `ui-medium` | buttons, labels |
| `ui-bold` | headings, channel names, the date |
| `ui` | stands in for any of the three above that is missing |
| `clock` | the clock digits. Without it the clock is drawn as thin segments. |

If you supply only some of the `ui-*` files, the others borrow the nearest
one you did supply, so the built-in font isn't mixed in. The clock font is
scaled so that its `0` is as tall as the drawn digits.

## `img/`: pieces of the menu
`.png`, `.svg`, `.jpg`, `.jpeg` or `.webp`.

| File | Replaces |
|---|---|
| `stripes.png` | the 1×6 px tile repeated as the striped background (keep this exact name and format) |
| `home-button` | the brand word on the round home button (drawn inside the button, square) |
| `mail` | the drawn envelope on the mail button |

## `music/` and `banners/`
Menu music (`music/menu.*`) and channel banners and jingles
(`banners/<channel name>.*`) are read from here too. They are wired up in
roadmap steps F8 and F5; this page gets their details then.

## How it works
`services/Assets.qml` is the one resolver. It indexes the folder with
`find` and answers:

| Call | Returns |
|---|---|
| `Theme.asset("img/stripes.png")` / `Assets.url(rel)` | URL of your file, else of the built-in |
| `Assets.image(name)` | URL of your `img/<name>.*`, else `""` |
| `Assets.sound(name)` | path of your `sounds/<name>.*`, else the built-in WAV |
| `Assets.music(name)` | path of your `music/<name>.*`, else `""` |
| `Assets.font(role)` | path of your font for a role, else `""` |
| `Assets.find(sub, name, exts)` | path of your `<sub>/<name>.<ext>`, else `""` |

Your files are loaded by absolute `file://` URL (Quickshell refuses relative
URLs that leave its config folder). Image and font URLs carry the file's
modification time (`?v=…`), which is what makes a replaced file load again.

IPC, handy for checking what is in use:

```bash
wii ipc assets dir                 # the asset folder
wii ipc assets list                # every file found in it
wii ipc assets sound tick          # which file plays for "tick"
wii ipc assets font ui-bold        # which font file a role uses ("" = built-in)
wii ipc assets resolve img/stripes.png
wii ipc assets reload              # index again now
```

## Tested
In the nested session, with a test folder:
- No folder: everything is built-in. Creating the folder and dropping files
  in while the shell runs switched the striped background, the UI font
  (one `ui-bold.ttf` was used for all three weights), the clock font, the
  home button image and the mail image at once.
- `sounds/tick.ogg` was chosen for `tick`; `click` stayed built-in.
- Mixed-case names (`Mail.PNG`, `Clock.TTF`, `Photo Channel.PNG`) resolved,
  including a name with a space.
- Overwriting `stripes.png` and `ui.ttf` in place showed after
  `assets reload`.
- Deleting the folder put every built-in back, with no warnings in the log.
