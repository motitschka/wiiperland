pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Shared state of the Wii Menu (current page, open preview, ...).
Singleton {
    id: root
    property int page: 0
    onPageChanged: Sound.play("page")
    readonly property int pageCount: Config.pageCount
    onPageCountChanged: if (page >= pageCount) page = Math.max(0, pageCount - 1)

    signal arrive()            // the menu just came into view: show "<brand> Menu"
    signal closePreviews()
    signal openPreview(int slot)
    signal startPreview()
    signal stepPreview(int dir)   // the preview's side arrows
    signal openBoard()
    signal openPicker(int slot)    // "add a channel" for an empty slot
    signal openContext(int slot)   // the right-click bubble of a tile
    signal carry(int slot)         // pick a tile up (Move)

    // The channels the picker offers besides installed apps.
    readonly property var builtins: [
        { key: "disc", label: "Disc Channel", glyph: "◎", color: "#7fa9c9", channel: { type: "disc", name: "Disc Channel" } },
        { key: "photos", label: "Photo Channel", glyph: "▣", color: "#e9a35b", channel: { type: "photos", name: "Photo Channel", dir: "~/Pictures" } },
        { key: "forecast", label: "Forecast Channel", glyph: "☀", color: "#4fb2f0", channel: { type: "forecast", name: "Forecast Channel" } },
        { key: "music", label: "Music Channel", glyph: "♪", color: "#8f7fd9", channel: { type: "music", name: "Music Channel" } }
    ]

    // A channel for `what`: a built-in key ("disc", "photos", ...) or a
    // desktop entry id or name.
    function channelFor(what: string): var {
        for (let i = 0; i < builtins.length; i++)
            if (builtins[i].key === what) return builtins[i].channel
        const e = Launcher.entryFor({ app: what })
        return e ? { type: "app", app: e.id, name: e.name } : { type: "app", app: what, name: what }
    }

    // Next filled slot in direction dir (+1/-1), wrapping around.
    function neighbour(slot: int, dir: int): int {
        const ch = Config.channels, n = ch.length
        for (let i = 1; i <= n; i++) {
            const j = ((slot + dir * i) % n + n) % n
            if (ch[j]) return j
        }
        return slot
    }

    function next(): void { if (page < pageCount - 1) page++ }
    function prev(): void { if (page > 0) page-- }

    IpcHandler {
        target: "menu"
        function next(): void { root.next() }
        function prev(): void { root.prev() }
        function page(n: int): void { root.page = Math.max(0, Math.min(n, root.pageCount - 1)) }
        function open(slot: int): void { root.page = Math.floor(slot / 12); root.openPreview(slot) }
        function close(): void { root.closePreviews() }
        function start(): void { root.startPreview() }
        function board(): void { root.openBoard() }
        function arrive(): void { root.arrive() }
        function move(from: int, to: int): bool { return Config.moveChannel(from, to) }
        function add(slot: int, what: string): bool { return Config.addChannel(slot, root.channelFor(what)) }
        function remove(slot: int): bool { return Config.removeChannel(slot) }
        function picker(slot: int): void { root.page = Math.floor(slot / 12); root.openPicker(slot) }
        function context(slot: int): void { root.page = Math.floor(slot / 12); root.openContext(slot) }
        function carry(slot: int): void { root.page = Math.floor(slot / 12); root.carry(slot) }
        function step(dir: int): void { root.stepPreview(dir) }
        function state(): string { return JSON.stringify({ page: root.page, pageCount: root.pageCount }) }
    }
}
