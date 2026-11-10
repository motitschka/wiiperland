-- Wiiperland for Hyprland.
--
--   local wii = require("wiiperland")
--   wii.setup({ terminal = "foot", kb_layout = "de" })
--
-- See docs/hyprland.md for every option.
local M = {}

local function repo_root()
  -- This file lives at <root>/hypr/wiiperland/init.lua
  local src = debug.getinfo(1, "S").source:gsub("^@", "")
  return (src:gsub("/hypr/wiiperland/init%.lua$", ""))
end

function M.setup(user)
  local o = {}
  for k, v in pairs(require("wiiperland.options")) do o[k] = v end
  for k, v in pairs(user or {}) do o[k] = v end
  o.root = o.root or os.getenv("WIIPERLAND_ROOT") or repo_root()
  M.options = o

  for _, part in ipairs({ "env", "input", "looks", "animations", "rules", "binds", "autostart" }) do
    require("wiiperland." .. part)(o)
  end
  return o
end

return M
