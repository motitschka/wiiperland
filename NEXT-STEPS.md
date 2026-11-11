# Next steps (report written 2026-11-11, when usage neared the limit)

For whoever picks this up next, including a fresh chat on another account.
Read this, then `PLAN.md`, `ROADMAP.md` and `docs/development.md`.

## Where things stand
- Branch `main`, clean, pushed. Last commit: `821cb50 F8: menu music and
  retuned UI sounds`.
- Wii fidelity steps **F1 to F8 are done**: built, tested in the off-screen
  session, documented, committed, pushed. No step is half-finished and there
  is no handoff file (`F<n>-HANDOFF.md`) lying around.
- **Left: F9, F10, F11.** Then the plan is complete.

## How the owner wants the work done
- For every step: build → test in `dev/nested.sh --headless 1920x1200`
  (screenshots, logs) → update `docs/` and tick `ROADMAP.md` → commit and
  push. No permission needed for that routine.
- **Don't ask before starting the next step**; just go on (said on
  2026-11-11).
- **Keep it resumable**: at the start of a step write `F<n>-HANDOFF.md` at the
  repo root (goal, design decisions, a progress checklist), keep it current,
  delete it in the step's commit. When usage gets close to the limit, stop
  and update this file instead of starting something large.
- Commits end with a `Co-Authored-By:` line. `PLAN.md` names Opus 5.5; F3 to
  F8 were made by, and credit, `Claude Fable 5.2 <noreply@anthropic.com>`.
  Use the line for the model that actually did the work.
- Never commit Nintendo material or anything from `assets/ref/`. Committed
  screenshots must not show personal data: not the owner's town (the test
  config pins the forecast to Reykjavik), not their pictures, and not the
  channel picker (it lists their installed apps).

## F9. Motion (next)
PLAN.md, decision 9: re-tune zoom-in, preview open/close, white fade, page
slide and hover timings against the reference recording, and document the
measured durations.

1. Pull frames from `assets/ref/Screencast From 2026-11-11 07-28-00.mp4`
   around 14 to 36 s at 25 fps, e.g.
   `ffmpeg -ss 23 -t 3 -i "<file>" -vf fps=25,scale=480:-1 out/%03d.png`,
   and count frames for each motion. The table of what is where is in
   PLAN.md ("Reference recording"). The tile-to-preview zoom is around 24 s,
   the channel start (white fade) around 32 to 36 s, page slides and hover
   around 14 to 22 s.
2. Current values to compare against:
   - `quickshell/home/ChannelPreview.qml`: zoom `duration: 520`
     (`InOutCubic`); white fade `260` then a `450` pause; the band appears
     over the first third of the zoom (`bandIn`); title tab fades in from
     55% to 90% of the zoom.
   - `quickshell/home/ChannelGrid.qml`: page slide `duration: 450`
     (`OutCubic`).
   - `quickshell/home/ChannelTile.qml`: hover ring fade `130`, glow breathing
     `700` each way. `NameBubble.qml`: appears after `180`, fade `110`,
     scale `170`.
   - `quickshell/home/HomeScreen.qml`: waits `480` for a page slide before
     opening a preview by IPC; menu fade `220`.
   - `hypr/wiiperland/animations.lua`: window and workspace animations.
3. Put the measured durations in a table in `docs/preview-and-launch.md`
   (and `docs/shell.md` for the menu), tick F9.
4. Test: mid-animation screenshots (`sleep 0.25; dev/shot.sh`), as F4 did.

## F10. Welcome screen
PLAN.md, decision 10. Replaces `quickshell/overlays/Startup.qml`:
- Styled like our menus (striped background, the blue line, bar styling),
  showing just **"Welcome"**. Not a copy of the Wii's start-up notice.
- Shown **only on the first start of each calendar day**: keep the last shown
  date in the state folder (`$WIIPERLAND_STATE`, default
  `~/.local/state/wiiperland`), not in `$XDG_RUNTIME_DIR`.
- Stays until a click anywhere or Enter. No auto-fade.
- The existing IPC `startup dismiss` is used by every test run; keep it
  working (or rename it and update `docs/development.md` and
  `docs/lock-and-startup.md`). Add a way to force it for tests, since the
  once-a-day rule would otherwise hide it on the second run.
- `config.json` has `startupScreen` (see `docs/channels.md`); keep or rename
  it consistently.
- The menu music (F8) should stay silent behind the welcome screen: set
  `Music.hold` the way `LockScreen.qml` does.

## F11. Wrap-up
PLAN.md, "Suggested order" item 11:
- Bring `README.md`, `ROADMAP.md` ("Status" section still describes the
  pre-fidelity phases) and every file in `docs/` up to date; retake all
  screenshots in `docs/img/` (`home-bar.png`, `home-menu.png`,
  `message-board.png` and `startup.png` predate F3 to F8; the HOME Menu now
  has the music controls and the message board has the glossy pills).
- Full end-to-end test: `install.sh` into a throwaway `HOME`, as described in
  `docs/install.md`.
- Check that `install.sh`, `uninstall.sh` and `config/config.json` know about
  everything added since (music folder, banners folder, Disc Channel,
  `music` / `musicVolume`).

## Things only the owner can check (also listed in ROADMAP.md)
Nothing below could be tested from the nested session:
- **Listening.** Nobody has heard the retuned UI sounds, the built-in menu
  music, its fades and ducking, or a channel jingle. The music will start
  playing at 35% the next time the owner logs into Hyprland; the HOME Menu
  (SUPER+ESC) has the note button and slider, or set `"music": false`.
- Real mouse: clicking the preview's pills and arrows, holding and dragging a
  tile (also across pages), the picker, right-click → Move / Remove.
- A real USB stick or disc in the Disc Channel, and Start opening it.
- A page full of video banners: how much it loads the laptop.
- A playing music player on the Music Channel tile (cover art, livelier bars).

## Changes made outside the repo on 2026-11-11
- `~/.config/wiiperland/config.json`: a Disc Channel was added in slot 8
  (the first empty slot on page 1), as PLAN.md asked. The file was rewritten
  as indented JSON with every other key kept.
- The owner installed `qt6-imageformats` (for `.webp` banners).

## Gotchas learned in F4 to F8 (beyond the list in PLAN.md)
- Saving a QML file reloads the shell: an open preview closes, so reopen it
  before a screenshot. The log is cumulative; old warnings stay in it.
- `dev/nested.sh` now runs on a **copy** of `dev/test-config.json`
  (`dev/.nested/config.json`), because the menu can rewrite its config.
  `WIIPERLAND_MEDIA` points the Disc Channel at `dev/.nested/media`.
- `WIIPERLAND_SILENT=1` (the default in tests) means no audio process or
  player is started at all. To exercise the real player without noise, run
  with `WP_SOUND=1` and a temporary config that has `"sounds": false` and
  `"musicVolume": 0.001`.
- Qt Multimedia: `play()` before the file has loaded is ignored. Start from
  `onMediaStatusChanged` when it reaches `LoadedMedia` (see
  `VideoBanner.qml`, `MusicPlayer.qml`). Qt's own audio stream has no
  `application.process.binary`; it is recognised by `media.name`.
- Pass a banner's path and kind as **one object**; as two properties they
  change one after the other and an image loader briefly gets a video file.
- A component that should survive a missing QML module (video, music) goes
  in its own file behind `Loader { source: Qt.resolvedUrl(...) }`.
- `PillButton` has `available` for the greyed look; `enabled` also goes
  false while a parent animates and would grey it mid-zoom.
- QML: don't name a property `top` (or `left`); it is final on `Item`.
- A cleanup like `rm -f "$DIR"/*` is refused by the agent's safety check;
  remove files by their literal paths.
- A `Time.qml` warning ("Unable to assign [undefined] to QDateTime") appears
  once at start-up and on reload. It predates F4 and is harmless, but F11
  could tidy it.
