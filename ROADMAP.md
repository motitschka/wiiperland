# Wiiperland Roadmap

Goal: a Hyprland desktop that looks and feels like the Wii home menu: a white,
finely striped home screen, a 4×3 grid of rounded "channel" tiles, a curved
bottom bar with a big thin clock, zoom-in channel previews, soft UI sounds, and
a "HOME Menu" overlay you can open from anywhere.

All artwork, sounds and fonts are original or openly licensed. Nintendo logos,
Mii art, system sounds and music are **not** included.

## Architecture

| Piece | Tech | Where |
|---|---|---|
| Compositor config | Hyprland 0.57 Lua config | `hypr/` |
| Shell (home menu, bar, overlays, notifications, lock) | Quickshell (QML) | `quickshell/` |
| Channel list and settings | JSON, read by Quickshell | `config/` → `~/.config/wiiperland/` |
| Sounds | Generated WAVs (original), played with `pw-play` | `quickshell/assets/sounds/` |
| Font | M PLUS Rounded 1c (OFL) | `quickshell/assets/fonts/` |
| Cursor | Original hyprcursor/XCursor hand pointer | `assets/cursor/` (build input) |
| Dev harness | Nested Hyprland and grim screenshots | `dev/` |

### Interaction model
- **Workspace 1 is the Wii Menu.** It stays empty of windows; the Quickshell
  home surface is shown there.
- **Clicking a channel** zooms it into a preview screen with
  `Wii Menu` / `Start` buttons. **Start** launches the app on a fresh, empty
  workspace (one channel per workspace, like the Wii). If the app is already
  running, Start just jumps to it.
- **SUPER** (tap) goes back to the menu. **SUPER+ESC** opens the HOME Menu
  overlay (go to menu, close the channel, volume, power).
- **Mail button**: a message board that collects desktop notifications.

## Phases
Each phase must be **built → tested in nested Hyprland (screenshot) →
documented in `docs/` → committed and pushed** before the next one starts.

- [x] **0. Foundation**: repo, roadmap, dev harness (`dev/nested.sh`,
      `dev/shot.sh`), font, base README.
- [x] **1. Hyprland base**: Lua config split into modules (look, animations,
      binds, rules, autostart), Wii palette, zoom-style animations, workspace 1
      kept as the home menu. Docs: `docs/hyprland.md`.
- [x] **2. Home screen shell**: Quickshell skeleton, theme singleton, striped
      background, bottom bar with curved notch, thin segment clock, date,
      round corner buttons. Docs: `docs/shell.md`.
- [x] **3. Channel grid**: 4×3 tiles, empty slot style, hover glow and scale,
      pages with arrow buttons and scrolling, `channels.json`.
      Docs: `docs/channels.md`.
- [x] **4. Channel preview and launch**: zoom transition, preview screen,
      `Wii Menu` / `Start`, launch on an empty workspace, focus if already
      running, running indicator.
- [x] **5. Live channel art**: Photo (slideshow from `~/Pictures`), Forecast
      (weather), Music (MPRIS now playing), Clock/Calendar, plain app tiles
      with icon art.
- [x] **6. Sounds**: original hover, click, back and start sounds, with a
      setting to turn them off.
- [x] **7. Message board**: notification server, mail button glow and count,
      board panel, popups.
- [x] **8. HOME Menu overlay**: top and bottom bars slide in, go to menu,
      close channel, volume slider, battery, power menu.
- [x] **9. Lock screen and startup screen**: "click to continue" splash and a
      session lock in the same style.
- [x] **10. Cursor**: original hand pointer theme (hyprcursor and XCursor).
- [x] **11. Install / uninstall**: dependency check, backups of the existing
      config, symlinks, README with screenshots, full end-to-end test.

## Testing approach
- `Hyprland --verify-config -c hypr/hyprland.lua` for every config change.
- `dev/nested.sh` starts a nested Hyprland window using this repo's config.
  `dev/shot.sh` grabs a screenshot into `dev/screenshots/` for visual checks.
- Quickshell logs are checked for QML errors and warnings after every change.

## Status
All phases are done and tested in a nested Hyprland session. Still to check on
real hardware (they can't be driven from a nested session):
- tapping SUPER alone to go home, and the keyboard shortcuts inside the
  preview, board and HOME Menu;
- unlocking with a real password (PAM);
- power buttons and the volume slider (they'd act on the real machine).

## Wii fidelity
Making it feel like the real Wii menu. The agreed plan, with every decision
and the reference notes, is in [PLAN.md](PLAN.md). Same rule as above: each
step is built, tested in `dev/nested.sh 1920x1200`, documented and pushed
before the next one starts.

- [x] **F1. Asset folder**: `~/.config/wiiperland/assets/` (sounds, music,
      fonts, images, banners) overrides the built-in files through one
      resolver. Docs: `docs/assets.md`.
- [ ] **F2. Cursor**: redrawn hand (white, dark grey outline, blue "1"
      badge), Wii-sized on the menu and normal size in apps.
- [ ] **F3. Menu fidelity pass**: lighter bar with a thin pale-blue recess
      line, bigger clock, `Fri 4/18` date, edge-to-edge grid with peeking
      neighbour pages, name bubbles instead of the hover grow, the
      "<brand> Menu" label on arrival.
- [ ] **F4. Preview rebuild**: rounded "TV" panel on black, blue title tab,
      big blue arrows, beige band, glossy pills, greyed-out Start.
- [ ] **F5. Channel banners**: full-bleed image / animated / video banners
      and jingles from the asset folder, redesigned built-in art for the
      rest.
- [ ] **F6. Disc Channel**: "Please insert a disc." or the mounted drive.
- [ ] **F7. Arranging channels**: hold and drag to swap, click an empty
      slot to add, right-click to move or remove.
- [ ] **F8. Sound and music**: retuned UI sounds, menu music that fades and
      ducks.
- [ ] **F9. Motion**: timings measured from the reference recording.
- [ ] **F10. Welcome screen**: once per calendar day, replaces the startup
      screen.
- [ ] **F11. Wrap-up**: README, docs, screenshots, full install test.

## Ideas for later
- Animated channel banners (per-channel QML art packs).
- A Settings channel for `config.json` (drag tiles to reorder).
- Calendar channel, disc/USB channel for removable drives.
- Optional original background music loop for the menu.
