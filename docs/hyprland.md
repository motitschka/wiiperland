# Hyprland config

Wiiperland uses Hyprland's **Lua config** (Hyprland 0.57+). Everything lives in
`hypr/wiiperland/` and is loaded with one call:

```lua
-- ~/.config/hypr/hyprland.lua
package.path = "/path/to/wiiperland/hypr/?.lua;/path/to/wiiperland/hypr/?/init.lua;" .. package.path
require("wiiperland").setup({
  terminal  = "kitty",
  kb_layout = "us",
})
-- Your own hl.* settings go below and override Wiiperland's.
```

## Modules
| File | What it sets up |
|---|---|
| `options.lua` | Default options (see below) |
| `palette.lua` | Wii colours shared by the modules |
| `env.lua` | Session environment, light theme for GTK/libadwaita apps |
| `input.lua` | Monitor, keyboard, touchpad, 3-finger workspace swipe |
| `looks.lua` | Gaps, squircle rounding, blue glow on the focused window, shadows, blur, background colour |
| `animations.lua` | Zoom-in window opens with a small overshoot, fading workspaces |
| `rules.lua` | Keeps workspace 1 (the menu) free of windows, floating dialogs, layer rules for the shell |
| `binds.lua` | Key bindings |
| `autostart.lua` | Starts the Quickshell shell |

## Options (`setup({...})`)
| Option | Default | Meaning |
|---|---|---|
| `root` | auto | Repo path. Worked out from where `init.lua` lives. |
| `terminal` | `kitty` | Used by SUPER+RETURN |
| `browser` | `firefox` | Used by SUPER+B |
| `files` | `nautilus` | Used by SUPER+E |
| `qs` | `qs` | Quickshell binary |
| `mod` | `SUPER` | Main modifier |
| `kb_layout` / `kb_variant` / `kb_options` | `us` / `""` / `""` | Keyboard |
| `monitor` | `{ output = "", mode = "preferred", position = "auto", scale = "auto" }` | Passed to `hl.monitor` |
| `cursor_size` | `32` | XCursor/hyprcursor size |
| `light_apps` | `true` | Sets `ADW_DEBUG_COLOR_SCHEME=prefer-light` and `GTK_THEME=Adwaita` so apps match the white UI, without changing your global gsettings |

## How the "menu workspace" works
Workspace 1 is persistent and named `menu`. The Quickshell home screen is
shown there. A `window.open` hook moves any tiled window that opens on
workspace 1 to a fresh empty workspace and follows it, so each app gets its
own "channel". Apps launched through `bin/wii launch` go straight to an empty
workspace.

## Key bindings
| Keys | Action |
|---|---|
| SUPER (tap and release) | Back to the Wii Menu |
| SUPER+ESC | HOME Menu overlay |
| SUPER+L | Lock |
| SUPER+RETURN / B / E | Terminal / browser / files (each on a new channel) |
| SUPER+Q | Close window |
| SUPER+F / V / J | Fullscreen / toggle floating / toggle split |
| SUPER+TAB, SUPER+SHIFT+TAB | Next / previous channel |
| SUPER+arrows, SUPER+SHIFT+arrows | Focus / swap windows |
| SUPER+1..9, SUPER+SHIFT+1..9 | Go to / move window to a workspace (1 = menu) |
| SUPER+scroll | Cycle channels |
| SUPER+LMB / RMB drag | Move / resize |
| Print | Screenshot to `~/Pictures/Screenshots` |
| Media, volume and brightness keys | As labelled (volume shows the Wii-style indicator) |

## `bin/wii`
A small command hub the binds and the shell call. Run `bin/wii help`.

```
wii home                 go back to the Wii Menu (workspace 1)
wii homemenu             toggle the HOME Menu overlay
wii lock                 lock the session
wii launch <cmd...>      start an app on a fresh, empty workspace
wii screenshot           save a screenshot to ~/Pictures/Screenshots
wii volume up|down|mute  change volume (and show the on-screen indicator)
wii ipc <target> <fn>    raw Quickshell IPC call
```

## Tested
- `Hyprland --verify-config` passes.
- In a nested instance: windows opened on workspace 1 move to workspace 2;
  `wii launch` opens on the next empty workspace; `wii home` returns to 1.
- The bind list shows the SUPER_L *release* bind. A physical tap of SUPER
  can't be simulated in the nested window; check it on real hardware.
