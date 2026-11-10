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
- [ ] **6. Sounds**: original hover, click, back and start sounds, with a
      setting to turn them off.
- [ ] **7. Message board**: notification server, mail button glow and count,
      board panel, popups.
- [ ] **8. HOME Menu overlay**: top and bottom bars slide in, go to menu,
      close channel, volume slider, battery, power menu.
- [ ] **9. Lock screen and startup screen**: "click to continue" splash and a
      session lock in the same style.
- [ ] **10. Cursor**: original hand pointer theme (hyprcursor and XCursor).
- [ ] **11. Install / uninstall**: dependency check, backups of the existing
      config, symlinks, README with screenshots, full end-to-end test.

## Testing approach
- `Hyprland --verify-config -c hypr/hyprland.lua` for every config change.
- `dev/nested.sh` starts a nested Hyprland window using this repo's config.
  `dev/shot.sh` grabs a screenshot into `dev/screenshots/` for visual checks.
- Quickshell logs are checked for QML errors and warnings after every change.
