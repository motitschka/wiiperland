pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Small helpers around Quickshell.Hyprland.
Singleton {
    readonly property string focusedMonitorName: Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
    readonly property int activeWorkspace: Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace ? Hyprland.focusedMonitor.activeWorkspace.id : 1
}
