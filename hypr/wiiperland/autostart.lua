-- Things started once when Hyprland starts.
return function(o)
  hl.on("hyprland.start", function()
    if not os.getenv("WIIPERLAND_DEV_MODE") then
      hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE WIIPERLAND_ROOT")
    end
    hl.exec_cmd(o.qs .. " -p " .. o.root .. "/quickshell")
  end)
end
