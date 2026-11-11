# Install

## Requirements
| Package | Why |
|---|---|
| `hyprland` ≥ 0.57 | compositor with the Lua config |
| `quickshell` ≥ 0.3 | the shell (menu, overlays, notifications, lock) |
| `pipewire`, `wireplumber` | sounds (`pw-play`) and volume (`wpctl`) |
| `curl` | Forecast Channel |
| `grim` | screenshots (Print key) |
| `librsvg` | only to rebuild the cursor |
| optional: `playerctl`, `brightnessctl`, a terminal (`kitty` by default) | media/brightness keys, SUPER+RETURN |
| optional: `qt6-multimedia` + `qt6-multimedia-ffmpeg`, `qt6-imageformats` | menu music and video banners, `.webp` banners ([assets.md](assets.md)) |

Don't run another notification daemon (dunst, mako, swaync) or bar; the shell
does that job.

## Steps
```bash
./install.sh            # check deps and install (prints the pacman command if something is missing)
./install.sh --deps     # same, but runs: sudo pacman -S --needed <missing>
./install.sh --dry-run  # show what would happen
```

What the installer touches (all in your home folder):

| Path | What happens |
|---|---|
| `~/.config/hypr/hyprland.lua`, `hyprland.conf` | moved to `~/.config/hypr/wiiperland-backup-<date>/` |
| `~/.config/hypr/hyprland.lua` | new file that loads Wiiperland from the repo and holds your overrides |
| `~/.config/wiiperland/config.json` | created from `config/config.json` if missing; channels whose apps aren't installed are left out |
| `~/.config/wiiperland/assets/` | empty folders for your own sounds, music, fonts, images and banners ([assets.md](assets.md)) |
| `~/.local/share/icons/Wiiperland` | link to the cursor theme |
| `~/.local/share/fonts/wiiperland` | link to the font (then `fc-cache`) |

The repo stays where it is; the config points at it, so `git pull` updates
your desktop. Keep the repo folder in place after installing.

Then log out and choose **Hyprland** on the login screen.

## Your own settings
Add them to `~/.config/hypr/hyprland.lua`, either through `setup({...})`
options ([hyprland.md](hyprland.md#options-setup)) or as plain `hl.*`
calls after it, for example:

```lua
require("wiiperland").setup({ terminal = "foot", kb_layout = "de" })
hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1 })
```

## Uninstall
```bash
./uninstall.sh          # restore the backup, remove links
./uninstall.sh --purge  # also delete ~/.config/wiiperland (config and your assets) and the saved message board
```

## Tested
In a throwaway home folder:
- `install.sh` backed up an existing `hyprland.lua` and `hyprland.conf`,
  wrote the entry point and `config.json` (leaving out the uninstalled
  terminal), and linked the cursor and font.
- `Hyprland --verify-config` passes on the generated `hyprland.lua`. A nested
  Hyprland started from it shows the welcome screen, the menu with the
  installed channels, toasts, the channel preview and the HOME Menu.
- `uninstall.sh` restored both original files and removed the links.
