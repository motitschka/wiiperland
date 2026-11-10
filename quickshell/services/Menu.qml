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

    signal closePreviews()
    signal openPreview(int slot)
    signal startPreview()
    signal openBoard()

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
        function state(): string { return JSON.stringify({ page: root.page, pageCount: root.pageCount }) }
    }
}
