-- Wiiperland: Hyprland config entry point (placeholder, filled in phase 1)
local dev_mode = os.getenv("WIIPERLAND_DEV_MODE")
hl.monitor({ output = "", mode = dev_mode or "preferred", position = "auto", scale = dev_mode and 1 or "auto" })
hl.config({ misc = { force_default_wallpaper = 0, disable_hyprland_logo = true, background_color = 0xffeeeeee } })
local src = debug.getinfo(1, "S").source
hl.notification.create({ text = "src=" .. src .. " path=" .. package.path, timeout = 20000 })
