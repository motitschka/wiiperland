-- Key bindings.
--   SUPER (tap)      back to the Wii Menu
--   SUPER+ESC        HOME Menu overlay
--   SUPER+RETURN     terminal          SUPER+B browser     SUPER+E files
--   SUPER+Q          close window      SUPER+F fullscreen  SUPER+V float
--   SUPER+L          lock              SUPER+TAB next channel
--   SUPER+1..9       workspace (1 = menu), SUPER+SHIFT+1..9 move window
return function(o)
  local mod = o.mod
  local wii = o.root .. "/bin/wii"
  local x = hl.dsp.exec_cmd

  hl.bind(mod .. " + SUPER_L", x(wii .. " home"), { release = true, description = "Back to the Wii Menu" })
  hl.bind(mod .. " + Escape", x(wii .. " homemenu"), { description = "HOME Menu" })
  hl.bind(mod .. " + L", x(wii .. " lock"), { description = "Lock" })

  hl.bind(mod .. " + Return", x(wii .. " launch " .. o.terminal), { description = "Terminal" })
  hl.bind(mod .. " + B", x(wii .. " launch " .. o.browser), { description = "Browser" })
  hl.bind(mod .. " + E", x(wii .. " launch " .. o.files), { description = "Files" })

  hl.bind(mod .. " + Q", hl.dsp.window.close(), { description = "Close window" })
  hl.bind(mod .. " + F", hl.dsp.window.fullscreen(), { description = "Fullscreen" })
  hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
  hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"), { description = "Toggle split" })

  hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }), { description = "Next channel" })
  hl.bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous channel" })

  for _, d in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. d, hl.dsp.focus({ direction = d }))
    hl.bind(mod .. " + SHIFT + " .. d, hl.dsp.window.swap({ direction = d }))
  end

  for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
  end

  hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
  hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
  hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
  hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  hl.bind("Print", x(wii .. " screenshot"), { description = "Screenshot to ~/Pictures/Screenshots" })

  local held = { locked = true, repeating = true }
  hl.bind("XF86AudioRaiseVolume",  x(wii .. " volume up"),    held)
  hl.bind("XF86AudioLowerVolume",  x(wii .. " volume down"),  held)
  hl.bind("XF86AudioMute",         x(wii .. " volume mute"),  { locked = true })
  hl.bind("XF86AudioMicMute",      x("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
  hl.bind("XF86MonBrightnessUp",   x("brightnessctl -e4 -n2 set 5%+"), held)
  hl.bind("XF86MonBrightnessDown", x("brightnessctl -e4 -n2 set 5%-"), held)
  hl.bind("XF86AudioNext",  x("playerctl next"),       { locked = true })
  hl.bind("XF86AudioPrev",  x("playerctl previous"),   { locked = true })
  hl.bind("XF86AudioPlay",  x("playerctl play-pause"), { locked = true })
  hl.bind("XF86AudioPause", x("playerctl play-pause"), { locked = true })
end
