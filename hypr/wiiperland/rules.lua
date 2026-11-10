-- Window, layer and workspace rules.
--
-- Workspace 1 is the Wii Menu: the Quickshell home screen is shown there and
-- it is kept free of windows. Anything that opens on it is sent to a fresh,
-- empty workspace, so every app gets its own "channel".
return function(o)
  hl.workspace_rule({ workspace = "1", default = true, persistent = true, default_name = "menu" })

  hl.on("window.open", function(w)
    local ws = w and w.workspace
    if ws and ws.id == 1 and not w.floating then
      hl.dispatch(hl.dsp.window.move({ workspace = "empty", window = "address:" .. w.address }))
    end
  end)

  hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
  })

  -- Small utility windows float, centred, like Wii dialogs.
  for _, cls in ipairs({
    "^(pavucontrol|org.pulseaudio.pavucontrol)$",
    "^(nm-connection-editor)$",
    "^(blueman-manager)$",
    "^(org.gnome.Calculator)$",
    "^(xdg-desktop-portal-gtk)$",
  }) do
    hl.window_rule({ name = "float-" .. cls, match = { class = cls }, float = true, center = true })
  end
  hl.window_rule({ name = "float-dialogs", match = { title = "^(Open File|Save As|Open Folder|File Upload).*" }, float = true, center = true })

  hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
  })

  -- Quickshell surfaces. The home screen animates itself; overlays get blur.
  hl.layer_rule({ name = "wp-home",     match = { namespace = "^wiiperland-home$" },     no_anim = true })
  hl.layer_rule({ name = "wp-homemenu", match = { namespace = "^wiiperland-homemenu$" }, no_anim = true, blur = true, ignore_alpha = 0.2 })
  hl.layer_rule({ name = "wp-board",    match = { namespace = "^wiiperland-board$" },    blur = true, ignore_alpha = 0.2 })
  hl.layer_rule({ name = "wp-toast",    match = { namespace = "^wiiperland-toast$" },    animation = "slide top" })
end
