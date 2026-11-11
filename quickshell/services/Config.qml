pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Reads ~/.config/wiiperland/config.json (falls back to the repo's
// config/config.json) and reloads it whenever the file changes.
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string userPath: Quickshell.env("WIIPERLAND_CONFIG")
        || (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/wiiperland/config.json"
    readonly property string defaultPath: Quickshell.shellDir + "/../config/config.json"

    property var data: ({})
    property bool _userLoaded: false
    property bool _useFallback: false
    readonly property string brand: data.brand ?? "Hypr"
    readonly property bool clock24h: data.clock24h ?? false
    readonly property bool sounds: data.sounds ?? true
    readonly property var channels: data.channels ?? []
    readonly property int pageCount: Math.max(data.pages ?? 4, Math.ceil(channels.length / 12), 1)

    readonly property string repoRoot: Quickshell.env("WIIPERLAND_ROOT") || Quickshell.shellDir + "/.."

    // "~" -> $HOME, "${VAR}" -> environment (WIIPERLAND_ROOT always known)
    function expand(path: string): string {
        if (!path) return path
        let p = path.startsWith("~") ? home + path.slice(1) : path
        return p.replace(/\$\{(\w+)\}/g, (m, v) => v === "WIIPERLAND_ROOT" ? repoRoot : (Quickshell.env(v) ?? ""))
    }

    FileView {
        id: user
        path: root.userPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: { root._userLoaded = true; root.parse(text(), root.userPath) }
        onLoadFailed: { root._userLoaded = false; root._useFallback = true }
    }
    FileView {
        id: fallback
        path: root._useFallback ? root.defaultPath : ""
        onLoaded: if (!root._userLoaded) root.parse(text(), root.defaultPath)
    }

    function parse(txt: string, from: string): void {
        try {
            const parsed = JSON.parse(txt)
            // our own save coming back from the file watcher: nothing new
            if (_userLoaded && JSON.stringify(parsed) === JSON.stringify(data)) return
            data = parsed
            console.info("config loaded from", from, "-", channels.length, "channel slots")
        } catch (e) {
            console.warn("config: could not parse", from, ":", e)
        }
    }

    // ---- arranging channels from the menu -------------------------------
    // Each change updates `data` at once and rewrites the user's config.json
    // (every other key is kept; the file is replaced in one step).

    readonly property int slotCount: pageCount * 12

    // Writes are gathered for a moment, so dragging a slider is one write.
    function save(): void { writer.restart() }
    Timer {
        id: writer
        interval: 250
        onTriggered: {
            console.info("config: saving", root.userPath)
            Quickshell.execDetached(["sh", "-c",
                'mkdir -p "$(dirname "$1")" && printf "%s\\n" "$2" > "$1.tmp" && mv "$1.tmp" "$1"',
                "wii-config", root.userPath, JSON.stringify(root.data, null, 2)])
        }
    }

    // Change one top-level setting and save.
    function setValue(key: string, value: var): void {
        if (JSON.stringify(data[key]) === JSON.stringify(value)) return
        const d = Object.assign({}, data)
        d[key] = value
        data = d
        save()
    }

    function setChannels(list: var): void {
        const l = list.slice()
        while (l.length > 0 && !l[l.length - 1]) l.pop()
        for (let i = 0; i < l.length; i++) if (!l[i]) l[i] = null
        const d = Object.assign({}, data)
        d.channels = l
        data = d
        save()
    }

    function _padded(upTo: int): var {
        const l = channels.slice()
        while (l.length <= upTo) l.push(null)
        return l
    }
    function _valid(slot: int): bool { return slot >= 0 && slot < slotCount }

    // Put the channel in `from` into `to`; what was there goes to `from`.
    function moveChannel(from: int, to: int): bool {
        if (!_valid(from) || !_valid(to) || from === to || !channels[from]) return false
        const l = _padded(Math.max(from, to))
        const t = l[to]; l[to] = l[from]; l[from] = t
        setChannels(l)
        return true
    }
    // Fill an empty slot.
    function addChannel(slot: int, channel: var): bool {
        if (!_valid(slot) || channels[slot] || !channel) return false
        const l = _padded(slot)
        l[slot] = channel
        setChannels(l)
        return true
    }
    function removeChannel(slot: int): bool {
        if (!_valid(slot) || !channels[slot]) return false
        const l = channels.slice()
        l[slot] = null
        setChannels(l)
        return true
    }
}
