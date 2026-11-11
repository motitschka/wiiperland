pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Pointer size: Wii-sized on the menu, normal in apps.
//
// The same cursor theme is used everywhere; only its size changes. Hyprland
// has no config key for that, so this runs `hyprctl setcursor <theme> <size>`
// when the menu (workspace 1) comes or goes, and while an overlay that
// belongs to the menu (HOME Menu, lock screen, welcome screen) holds it.
//
// config.json: "cursor": { "menuSize": "auto" }
//   "auto"  8% of the screen height (96 px on a 1200 px screen)
//   number  that many pixels
//   0       the same size as in apps
Singleton {
    id: root

    readonly property string theme: Quickshell.env("XCURSOR_THEME") || ""
    readonly property int appSize: parseInt(Quickshell.env("XCURSOR_SIZE") || "") || 24
    readonly property var setting: (Config.data.cursor ?? {}).menuSize ?? "auto"

    readonly property real screenHeight: {
        const scr = Quickshell.screens.find(s => s.name === Hypr.focusedMonitorName) ?? Quickshell.screens[0]
        return scr ? scr.height : 0
    }
    readonly property int menuSize: {
        if (setting === "auto") return screenHeight > 0 ? Math.max(appSize, Math.round(screenHeight * 0.08)) : appSize
        const n = Number(setting)
        return n > 0 ? Math.round(n) : appSize
    }

    // Overlays ask for the big pointer with hold("name", true/false).
    property var holders: ({})
    function hold(who: string, on: bool): void {
        if (!!holders[who] === on) return
        const h = Object.assign({}, holders)
        if (on) h[who] = true; else delete h[who]
        holders = h
    }

    readonly property bool big: Hypr.activeWorkspace === 1 || Object.keys(holders).length > 0
    readonly property int size: big ? menuSize : appSize
    property int applied: -1

    onSizeChanged: apply()
    Component.onCompleted: apply()

    function apply(): void {
        if (!theme || size <= 0 || proc.running || size === applied) return
        proc.target = size
        proc.running = true
    }

    Process {
        id: proc
        property int target: -1
        command: ["hyprctl", "setcursor", root.theme, String(target)]
        onExited: (code) => {
            if (code === 0) root.applied = target
            else console.warn("cursor: hyprctl setcursor failed with", code)
            if (code === 0 && root.size !== root.applied) root.apply()   // changed again meanwhile
        }
    }

    IpcHandler {
        target: "cursor"
        function state(): string {
            return JSON.stringify({ theme: root.theme, appSize: root.appSize, menuSize: root.menuSize,
                                    big: root.big, size: root.size, applied: root.applied,
                                    holders: Object.keys(root.holders) })
        }
    }
}
