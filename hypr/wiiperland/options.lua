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
  cursor_size = 32,
  light_apps  = true,           -- ask GTK/libadwaita apps for light themes
}
