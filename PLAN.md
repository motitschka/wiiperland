# Plan: make Wiiperland feel like the real Wii menu

This plan was agreed with the owner in a design interview. It is written to be
picked up by a **fresh chat** with no earlier context. Read it fully, plus
`ROADMAP.md`, `docs/development.md` and `docs/shell.md`, before changing
anything.

## How to work (owner's rules)
- Start by turning the steps below into a checklist in `ROADMAP.md`
  (a new "Wii fidelity" section).
- For **every step**: build it → **test it** in the nested session
  (screenshots, logs) → **write/update the docs** in `docs/` → **commit and
  push**. Only then move to the next step.
- Make regular commits and pushes. Don't ask for permission for routine work.
- End commit messages with:
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
- The GitHub repo is private (`motitschka/wiiperland`), but **never commit
  Nintendo assets** (sounds, music, logos, channel art, fonts, footage). The
  owner supplies those locally (see step 1). Everything in the repo stays
  original or openly licensed.
- Screenshots committed to `docs/img/` must not show personal data (user
  name, city from the weather, the owner's media or pictures). Use
  `dev/test-config.json` and `dev/sample-photos/`.

## Where things stand
Wiiperland is installed on the owner's laptop (Arch, Hyprland 0.57.2, Quickshell
0.3.2, 1920×1200 screen). `~/.config/hypr/hyprland.lua` loads the config
straight from this repo, so pushed changes reach the owner's desktop as soon
as they reload.

- `hypr/wiiperland/*.lua`: Hyprland Lua modules (looks, animations,
  binds, rules, env, autostart). See `docs/hyprland.md`.
- `quickshell/`: the shell: home menu (`home/`), channel art
  (`channels/`), overlays (`overlays/`), singletons (`services/`).
- `bin/wii`: command hub (home, launch, homemenu, lock, ipc, ...).
- `tools/make-sounds.py`, `tools/make-cursor.py`: generate the original
  sounds and cursor.
- The owner's channel list is `~/.config/wiiperland/config.json`.

### Dev harness (read `docs/development.md`)
- `dev/nested.sh [WxH]` starts a nested Hyprland with its own D-Bus bus,
  `dev/test-config.json` and state in `dev/.nested/state`. Use
  `dev/nested.sh 1920x1200` to match the owner's screen.
- `dev/run.sh <cmd>` runs inside it, `dev/hctl.sh` is hyprctl for it,
  `dev/shot.sh <name>` screenshots, `dev/stop.sh` stops it.
- The mouse can't be clicked in the nested session. Drive the UI through IPC
  (`dev/run.sh bin/wii ipc menu open 2`, `... menu start`,
  `... welcome dismiss`, ...) and add IPC entry points for new features so
  they can be tested. Hover can be triggered with `dev/hover.sh 600 300`
  (a plain `hyprctl` cursor move isn't seen by Qt; see `docs/development.md`).
  `grim -c` (with the instance env loaded) captures the cursor too.
- Logs: `dev/run.sh qs -p quickshell log`. Runtime **Lua** errors show up only
  as notifications in the top-right of a screenshot, not in
  `hyprctl configerrors`.
- Quickshell is installed system-wide now; `QS_PREFIX` / `dev/local.env` are
  no longer needed.

### Gotchas already learned
- Hyprland 0.57 Lua: `hl.timer(fn, { timeout = ms, type = "oneshot" })` needs
  `type`. Static window rules can't match the workspace at open time; use
  `hl.on("window.open", ...)`. `hyprctl dispatch` takes Lua expressions
  (`'hl.dsp.focus({ workspace = 1 })'`).
- `cursor.sync_gsettings_theme = false` must stay; otherwise the cursor
  leaks into the owner's GNOME session.
- Quickshell refuses **relative** URLs that leave `quickshell/` (they resolve
  to `qrc:/qs-blackhole`). Absolute `file://` paths work (the photo channel
  already loads `~/Pictures` that way), so user assets must be loaded by
  absolute path.
- QML: property names can't start with a capital letter; don't name
  properties `left`/`top` (FINAL on Item); inside a singleton whose id is
  `root`, a property also called `root` gets shadowed.
- `Launcher.entryFor()` reads `DesktopEntries.applications.values.length` so
  bindings update once desktop entries load. Keep that pattern.

### Reference recording
`assets/ref/Screencast From 2026-11-11 07-28-00.mp4` (git-ignored, never
commit). It's 46 s, 1920×1200, a capture of real-Wii footage; the picture
fills y≈63–1120 (1057 px tall). Pull frames with
`ffmpeg -ss <t> -i "<file>" -frames:v 1 out.png`.

| Time | Shows |
|---|---|
| 0–13 s | setup screens: pill buttons, blue-outlined option rows, the cursor |
| ~14–22 s | the Wii Menu: grid, hover outline, **name bubbles**, bottom bar, "Wii Menu" label in the recess, the clock |
| ~24 s | Disc Channel preview ("Please insert a disc.", greyed Start) |
| ~26–30 s | Mii / Photo channel previews (title tab, arrows, pills) |
| ~32–36 s | channel start animation |
| ~38–46 s | Forecast and News previews, a dialog box |

Observations already made from it:
- **Cursor**: white hand pointing up, dark grey outline, a light-blue round
  badge with a white "1" on the back of the hand, soft drop shadow. It is
  about 8% of the picture height.
- **Bottom bar**: lighter than ours, a pale grey gradient. The recess outline
  is a **thin, pale** light-blue line, not a thick saturated one, and the
  recess curve is wide and gentle.
- **Clock**: large thin segment digits, mid grey, with a small bold "PM"
  beside them. **Date**: bold, dark grey, format `Fri 4/18` (no comma).
- **Corner buttons**: matte light grey with a thin pale-blue ring; "Wii" is
  embossed grey. An SD-card button sits next to the home button; **we leave
  it out**.
- **Grid**: runs almost edge to edge; the first column of the next page peeks
  in at the right edge.
- **Hover**: light-blue outline plus a white speech bubble with the channel
  name just under the tile. **No grow.**
- **Preview**: a rounded "TV screen" panel inset on black. The channel title
  sits in a blue tab at the top right, big blue arrows on both sides, a beige
  lower band, and wide glossy "Wii Menu" / "Start" pills with a light-blue
  rim. Start is greyed out when there's nothing to start.

## Decisions (all agreed)

### 1. The owner's asset folder
- `~/.config/wiiperland/assets/` (or `$WIIPERLAND_ASSETS`), **outside the
  repo**. Any file there wins over the built-in one; otherwise the built-in
  one is used:
  - `sounds/<name>.wav|ogg` (tick, click, page, open, back, start, mail, home)
  - `music/menu.ogg|mp3|wav`
  - `fonts/*.ttf|otf` (UI font and clock font; document file names/roles)
  - `img/<name>.png|svg` (home button face, mail icon, ...)
  - `banners/<channel name>.{gif,webp,png,jpg,mp4,webm}` and
    `banners/<channel name>.ogg` (jingle)
- Add a resolver (e.g. `Theme.asset(path)` → user file if it exists, else
  built-in) and use it everywhere. Load by absolute `file://` path.
- `assets/ref/` is already in `.gitignore`. Also ignore any
  `assets/user/` or similar if you create one.
- Document exact names and formats in `docs/assets.md`.

### 2. Cursor
- Draw it ourselves (original art), matching the recording: **white hand,
  dark grey outline, blue badge with a white "1", soft shadow**. Rewrite
  `assets/cursor/hand.svg` and rebuild with `tools/make-cursor.py`.
- **Same art everywhere**, **Wii-sized on the menu** (~8% of screen
  height, ≈ 96 px on 1200 px) and **normal size in apps** (~48 px).
  No lean or tilt.
- Text, resize and busy cursors stay Adwaita (the theme already inherits).
- Implementation is open. Try switching the Hyprland cursor size when
  workspace 1 is active/inactive (check whether 0.57's Lua API or `hyprctl`
  can set the cursor size at runtime). If not, draw the hand in QML on the home
  surface (set `Qt.BlankCursor` there) using the same PNG. Pick whichever
  looks identical and lags least, and document it.

### 3. Menu fidelity pass (match the recording)
- Bottom bar: lighter colours, thin pale-blue recess line, wider and gentler
  recess curve; matte grey corner buttons with thin pale-blue rings.
- Clock: larger segment digits, small bold AM/PM. Date `ddd M/d`, bold, dark
  grey.
- Grid: nearly edge to edge, with the neighbouring pages' first/last column
  peeking in at the screen edges; clicking a peeking tile flips the page.
- Hover: keep the blue outline, add the **name bubble** below the tile,
  **no grow**.
- When arriving on the menu (start, `wii home`, closing a channel), show
  **"<brand> Menu"** in blue in the recess for ~2 s, then cross-fade to the
  clock.
- Set `"brand": "arch"` (lowercase) in the owner's
  `~/.config/wiiperland/config.json`. The repo default stays `"Hypr"`.

### 4. Channel banners
- A tile is a **full-bleed banner**: `banners/<channel name>.*` from the asset
  folder or an explicit `"banner": "<path>"` in `config.json`. Support
  png/jpg, animated gif/webp (`AnimatedImage`), and mp4/webm (needs Qt
  Multimedia, see step 8).
- `banners/<channel name>.ogg`: jingle that plays when that channel's preview
  opens; it stops when the preview closes.
- Channels without a banner: **redesign the built-in art** as full-bleed,
  gently animated scenes (not icon + label). Keep the live channels' data
  (photos, forecast, music).

### 5. Preview screen rebuild
Match the recording: a rounded "TV" panel inset on black, a blue title tab at
the top right with the channel name, big blue side arrows, a beige lower band,
wide glossy **"<brand> Menu"** / **"Start"** pills with light-blue rims.
Start is greyed out and disabled when there's nothing to start. Keep the
current zoom-from-tile, white fade and IPC (`menu open/start/close`).

### 6. Disc Channel
- New channel type `"disc"`. With nothing inserted: disc art and
  **"Please insert a disc."**, Start greyed out. With a USB stick, SD card or
  disc mounted under `/run/media/$USER/*`: show its name and size, and Start
  opens it in the file manager.
- Put it in the **first empty slot on page 1** of the owner's config. The
  owner will rearrange later.

### 7. Arranging channels from the menu
- **Hold a tile ~0.5 s, then drag** it onto another slot: they swap.
  Dragging to the screen edge flips the page. Save to `config.json`
  (preserve all other keys; write atomically).
- **Click an empty slot** → a picker listing installed apps (desktop entries)
  plus the built-in channels (Disc, Photo, Forecast, Music); picking one
  fills the slot.
- **Right-click a tile** → **Move** (enters drag mode) / **Remove**.
- Add IPC for testing, e.g. `menu move <from> <to>`, `menu add <slot> <app>`,
  `menu remove <slot>`.

### 8. Sound and music
- Retune `tools/make-sounds.py` toward the Wii's character: short, soft,
  glassy "pings", airy whooshes, quieter overall. Files in the owner's
  `assets/sounds/` still override them per name.
- **Menu music**: loop `music/menu.*` from the asset folder, or an **original**
  soft loop generated by a script in `tools/` if none is given. It fades out
  when a channel opens or the preview jingle plays, fades back on return to
  the menu, and ducks while other apps play audio (check PipeWire streams).
  Music volume and mute go in the HOME Menu; settings go in `config.json`.
- Needs **Qt Multimedia**. The owner must run
  `sudo pacman -S qt6-multimedia qt6-multimedia-ffmpeg` (check with
  `pacman -Q qt6-multimedia`; ask them if it's missing). Add it to
  `install.sh`'s dependency list.

### 9. Motion
Re-tune zoom-in, preview open/close, white fade, page slide and hover timings
against frames from the recording (step through ~14–36 s at 10–25 fps).
Document the measured durations in the docs.

### 10. Welcome screen (replaces the current startup screen)
- **Not** like the Wii's start-up notice: style it like the rest of our
  menus (striped background, our blue line, bar styling) and show just
  **"Welcome"**.
- Shown **only on the first start of each calendar day** (store the last
  shown date in the state folder, not `$XDG_RUNTIME_DIR`).
- It stays until the user **clicks anywhere or presses Enter**. No auto-fade.

### 11. Unchanged on purpose
- No status bar inside apps ("pure Wii"). SUPER / the HOME Menu bring you
  back.
- No SD-card button.

## Suggested order
1. Asset folder + resolver (everything else uses it)
2. Cursor
3. Menu fidelity pass (+ brand "arch" in the owner's config)
4. Preview rebuild
5. Banners + redesigned fallback art + jingles
6. Disc Channel (+ place it in the owner's config)
7. Drag / picker / right-click arranging
8. Sounds retune + menu music (after Qt Multimedia is installed)
9. Motion tuning against the recording
10. Welcome screen
11. Update `README.md`, `ROADMAP.md`, `docs/` and screenshots; full
    end-to-end test (`install.sh` into a throwaway `HOME`, as in
    `docs/install.md`)

## Done means
Every step above is built, tested in `dev/nested.sh 1920x1200` with
screenshots checked against the recording, documented in `docs/`, and
pushed. Note anything that can only be verified on real hardware
(dragging with a real mouse, hearing the music ducking, the cursor
size switching) in `ROADMAP.md` under "Still to check on real hardware".
