-- Default options. Override any of these with wii.setup({ ... }) in
-- ~/.config/hypr/hyprland.lua.
return {
  root        = nil,            -- repo path; worked out automatically if nil
  terminal    = "kitty",
  browser     = "firefox",
  files       = "nautilus",
  qs          = "qs",           -- Quickshell binary
  mod         = "SUPER",
  kb_layout   = "us",
  kb_variant  = "",
  kb_options  = "",
  monitor     = { output = "", mode = "preferred", position = "auto", scale = "auto" },
  cursor_size = 48,
  cursor_theme = "Wiiperland",  -- the hand pointer; nil keeps your own theme
  light_apps  = true,
  home_on_empty = true,         -- closing a channel's last window returns to the menu           -- ask GTK/libadwaita apps for light themes
}
