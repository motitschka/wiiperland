-- Environment for apps started by Hyprland.
return function(o)
  hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
  hl.env("XDG_SESSION_TYPE", "wayland")
  hl.env("XDG_SESSION_DESKTOP", "Hyprland")
  hl.env("QT_QPA_PLATFORM", "wayland;xcb")
  hl.env("GDK_BACKEND", "wayland,x11,*")
  hl.env("XCURSOR_SIZE", tostring(o.cursor_size))
  hl.env("HYPRCURSOR_SIZE", tostring(o.cursor_size))
  if o.cursor_theme then
    hl.env("XCURSOR_THEME", o.cursor_theme)
    -- find the theme in the repo even before install.sh links it into ~/.local/share/icons
    local home = os.getenv("HOME") or ""
    hl.env("XCURSOR_PATH", table.concat({
      o.root .. "/assets/cursor", home .. "/.local/share/icons", home .. "/.icons",
      "/usr/share/icons", "/usr/share/pixmaps" }, ":"))
  end
  hl.env("WIIPERLAND_ROOT", o.root)

  -- dev/nested.sh: give children a private session bus
  local dev_bus = os.getenv("WIIPERLAND_DEV_BUS")
  if dev_bus and dev_bus ~= "" then hl.env("DBUS_SESSION_BUS_ADDRESS", dev_bus) end

  -- The Wii look is bright: ask apps for their light theme, without touching
  -- the global GNOME/gsettings preference.
  if o.light_apps then
    hl.env("ADW_DEBUG_COLOR_SCHEME", "prefer-light") -- libadwaita (GTK4)
    hl.env("GTK_THEME", "Adwaita")                   -- GTK3
    hl.env("QT_QUICK_CONTROLS_STYLE", "Basic")
  end
end
