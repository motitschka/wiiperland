pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Reads ~/.config/wiiperland/config.json (falls back to the repo's
// config/config.json) and reloads it whenever the file changes.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string userPath: (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/wiiperland/config.json"
    readonly property string defaultPath: Quickshell.shellDir + "/../config/config.json"

    property var data: ({})
    property bool _userLoaded: false
    readonly property string brand: data.brand ?? "Hypr"
    readonly property bool clock24h: data.clock24h ?? false
    readonly property bool sounds: data.sounds ?? true
    readonly property var channels: data.channels ?? []
    readonly property int pageCount: Math.max(data.pages ?? 4, Math.ceil(channels.length / 12), 1)

    function expand(path: string): string {
        return path && path.startsWith("~") ? home + path.slice(1) : path
    }

    FileView {
        id: user
        path: root.userPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: { root._userLoaded = true; root.parse(text(), root.userPath) }
        onLoadFailed: fallback.reload()
    }
    FileView {
        id: fallback
        path: root.defaultPath
        blockLoading: false
        onLoaded: if (!root._userLoaded) root.parse(text(), root.defaultPath)
    }

    function parse(txt: string, from: string): void {
        try {
            data = JSON.parse(txt)
            console.info("config loaded from", from, "-", channels.length, "channel slots")
        } catch (e) {
            console.warn("config: could not parse", from, ":", e)
        }
    }
}
