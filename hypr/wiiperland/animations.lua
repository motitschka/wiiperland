-- Animations: channels zoom in from the centre with a slight overshoot,
-- workspaces cross-fade like the Wii's fade-through transitions.
return function(o)
  hl.config({ animations = { enabled = true } })

  hl.curve("wiiZoom",   { type = "bezier", points = { {0.18, 1.0}, {0.32, 1.12} } }) -- small overshoot
  hl.curve("wiiEase",   { type = "bezier", points = { {0.25, 0.8}, {0.25, 1.0} } })
  hl.curve("wiiFade",   { type = "bezier", points = { {0.4, 0.0}, {0.2, 1.0} } })
  hl.curve("linear",    { type = "bezier", points = { {0, 0}, {1, 1} } })

  hl.animation({ leaf = "global",        enabled = true, speed = 6,   bezier = "wiiEase" })
  hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.5, bezier = "wiiZoom", style = "popin 40%" })
  hl.animation({ leaf = "windowsOut",    enabled = true, speed = 3,   bezier = "wiiEase", style = "popin 70%" })
  hl.animation({ leaf = "windowsMove",   enabled = true, speed = 4,   bezier = "wiiEase" })
  hl.animation({ leaf = "border",        enabled = true, speed = 6,   bezier = "wiiEase" })
  hl.animation({ leaf = "fadeIn",        enabled = true, speed = 3,   bezier = "wiiFade" })
  hl.animation({ leaf = "fadeOut",       enabled = true, speed = 3,   bezier = "wiiFade" })
  hl.animation({ leaf = "layersIn",      enabled = true, speed = 3.5, bezier = "wiiZoom", style = "popin 90%" })
  hl.animation({ leaf = "layersOut",     enabled = true, speed = 2.5, bezier = "wiiEase", style = "fade" })
  hl.animation({ leaf = "workspaces",    enabled = true, speed = 4,   bezier = "wiiFade", style = "fade" })
end
