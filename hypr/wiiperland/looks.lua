-- Look and feel: white/grey surfaces, rounded "channel tile" windows, a blue
-- glow on the focused window.
local P = require("wiiperland.palette")

return function(o)
  hl.config({
    general = {
      gaps_in  = 10,
      gaps_out = 28,
      border_size = 3,
      col = {
        active_border   = { colors = { "rgba(" .. P.blue .. "ff)", "rgba(" .. P.blue_light .. "ff)" }, angle = 90 },
        inactive_border = "rgba(" .. P.tile_border .. "ff)",
      },
      resize_on_border = true,
      layout = "dwindle",
    },

    decoration = {
      rounding       = 22,
      rounding_power = 2.6, -- slightly squircle, like the tiles
      shadow = {
        enabled      = true,
        range        = 18,
        render_power = 2,
        color          = "rgba(00000030)",
        color_inactive = "rgba(00000018)",
        offset       = "0 4",
      },
      glow = {
        enabled        = true,
        range          = 14,
        render_power   = 2,
        color          = "rgba(" .. P.blue .. "aa)",
        color_inactive = "rgba(00000000)",
      },
      blur = {
        enabled = true,
        size    = 6,
        passes  = 2,
      },
    },

    misc = {
      force_default_wallpaper = 0,
      disable_hyprland_logo   = true,
      disable_splash_rendering = true,
      background_color = "rgb(" .. P.bg .. ")",
      font_family      = "M PLUS Rounded 1c",
      focus_on_activate = true,
      animate_manual_resizes = true,
      allow_session_lock_restore = true, -- a restarted shell can take the lock back
    },

    dwindle = { preserve_split = true },
  })
end
