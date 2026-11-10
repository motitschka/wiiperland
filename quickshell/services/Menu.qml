pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Shared state of the Wii Menu (current page, open preview, ...).
Singleton {
    id: root
    property int page: 0
    readonly property int pageCount: Config.pageCount
    onPageCountChanged: if (page >= pageCount) page = Math.max(0, pageCount - 1)

    function next(): void { if (page < pageCount - 1) page++ }
    function prev(): void { if (page > 0) page-- }

    IpcHandler {
        target: "menu"
        function next(): void { root.next() }
        function prev(): void { root.prev() }
        function page(n: int): void { root.page = Math.max(0, Math.min(n, root.pageCount - 1)) }
        function state(): string { return JSON.stringify({ page: root.page, pageCount: root.pageCount }) }
    }
}
