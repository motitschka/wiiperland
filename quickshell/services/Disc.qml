pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// What is plugged in, for the Disc Channel: USB sticks, SD cards and discs
// that the desktop mounted under /run/media/$USER (the udisks default).
// $WIIPERLAND_MEDIA names another folder (dev/nested.sh uses an empty one).
// The folder is looked at every few seconds while the menu is showing.
Singleton {
    id: root
    readonly property string dir: Quickshell.env("WIIPERLAND_MEDIA")
        || "/run/media/" + (Quickshell.env("USER") || "")

    property var volumes: []      // [{ name, path, size, used }], sizes in bytes
    readonly property var current: volumes.length > 0 ? volumes[0] : null
    readonly property bool inserted: current !== null

    // 1536 -> "1.5 KB", 32e9 -> "32 GB"
    function human(bytes: real): string {
        const units = ["B", "KB", "MB", "GB", "TB"]
        let v = bytes, i = 0
        while (v >= 1000 && i < units.length - 1) { v /= 1000; i++ }
        return (v >= 100 || i === 0 ? Math.round(v) : Math.round(v * 10) / 10) + " " + units[i]
    }

    function refresh(): void { if (!scan.running) scan.running = true }

    Process {
        id: scan
        running: true
        // one line per sub-folder: size, used, path (tab-separated)
        command: ["sh", "-c",
            'for d in "$1"/*/; do [ -d "$d" ] || continue; d=${d%/}; ' +
            'set -- "$1" $(df -B1 --output=size,used "$d" 2>/dev/null | tail -1); ' +
            'printf "%s\\t%s\\t%s\\n" "${2:-0}" "${3:-0}" "$d"; done',
            "wii-disc", root.dir]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = []
                const lines = text.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const p = lines[i].split("\t")
                    if (p.length < 3) continue
                    const path = p.slice(2).join("\t")
                    list.push({ name: path.split("/").pop(), path: path, size: Number(p[0]), used: Number(p[1]) })
                }
                if (JSON.stringify(list) !== JSON.stringify(root.volumes)) {
                    root.volumes = list
                    console.info("disc:", list.length ? list.map(v => v.name).join(", ") : "nothing inserted")
                }
            }
        }
    }

    Timer {
        interval: 3000; repeat: true
        running: Hypr.activeWorkspace === 1
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    IpcHandler {
        target: "disc"
        function state(): string { return JSON.stringify(root.volumes) }
        function refresh(): void { root.refresh() }
        function dir(): string { return root.dir }
    }
}
