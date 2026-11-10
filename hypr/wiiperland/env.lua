-- Environment for apps started by Hyprland.
return function(o)
  hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
  hl.env("XDG_SESSION_TYPE", "wayland")
  hl.env("XDG_SESSION_DESKTOP", "Hyprland")
  hl.env("QT_QPA_PLATFORM", "wayland;xcb")
  hl.env("GDK_BACKEND", "wayland,x11,*")
  hl.env("XCURSOR_SIZE", tostring(o.cursor_size))
  hl.env("HYPRCURSOR_SIZE", tostring(o.cursor_size))
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
