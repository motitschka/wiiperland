-- Keyboard / mouse / monitor basics.
return function(o)
  local dev_mode = os.getenv("WIIPERLAND_DEV_MODE")
  if dev_mode then
    hl.monitor({ output = "", mode = dev_mode, position = "auto", scale = 1 })
  else
    hl.monitor(o.monitor)
  end

  hl.config({
    input = {
      kb_layout  = o.kb_layout,
      kb_variant = o.kb_variant,
      kb_options = o.kb_options,
      follow_mouse = 1,
      touchpad = { natural_scroll = true, tap_to_click = true },
    },
    cursor = { hide_on_key_press = false },
  })

  hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
end
