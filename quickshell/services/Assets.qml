pragma Singleton
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

// The owner's asset folder: ~/.config/wiiperland/assets, or $WIIPERLAND_ASSETS.
// A file there wins over the built-in file of the same name; everything else
// falls back to quickshell/assets. See docs/assets.md for names and formats.
//
// File names are matched without regard to case. The folder is indexed with
// `find` at startup, whenever a file or folder appears or goes away, and each
// time the menu comes back into view (which catches files changed in place).
Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string dir: _trim(Quickshell.env("WIIPERLAND_ASSETS")
        || (Quickshell.env("XDG_CONFIG_HOME") || home + "/.config") + "/wiiperland/assets")
    readonly property string builtinDir: Quickshell.shellDir + "/assets"

    // lower-cased relative path -> { rel: real relative path, t: modification time }
    property var index: ({})
    property var folders: []        // sub-folders found by the last scan
    property bool exists: false     // the asset folder is there
    property bool ready: false      // the first scan has finished
    property int revision: 0        // goes up after every scan that changed something

    readonly property var soundExts: ["wav", "ogg", "oga", "flac", "mp3"]
    readonly property var musicExts: ["ogg", "oga", "mp3", "flac", "wav", "m4a", "opus"]
    readonly property var imageExts: ["png", "svg", "jpg", "jpeg", "webp"]
    readonly property var fontExts: ["ttf", "otf"]
    readonly property var videoExts: ["mp4", "webm", "mkv", "mov"]
    // a moving banner wins over a still one of the same name
    readonly property var bannerExts: videoExts.concat(["gif", "webp", "png", "jpg", "jpeg"])

    function _trim(p: string): string { return p.length > 1 && p.endsWith("/") ? p.slice(0, -1) : p }

    // Absolute path -> file:// URL (spaces, '#', '?' and friends escaped).
    function toUrl(path: string): string {
        return path ? "file://" + path.split("/").map(encodeURIComponent).join("/") : ""
    }

    // Like toUrl, plus "?v=<mtime>" so that an image or font replaced under
    // the same name is loaded again. Not for media players: they want toUrl.
    function fresh(path: string): string {
        if (!path) return ""
        const hit = path.startsWith(dir + "/") ? index[path.slice(dir.length + 1).toLowerCase()] : null
        return toUrl(path) + (hit ? "?v=" + hit.t : "")
    }

    // Absolute path of the owner's file `rel` (e.g. "sounds/tick.wav"), or "".
    function userFile(rel: string): string {
        const hit = index[rel.toLowerCase()]
        return hit ? dir + "/" + hit.rel : ""
    }

    // First of the owner's files "<sub>/<name>.<ext>", or "".
    function find(sub: string, name: string, exts: var): string {
        if (!name) return ""
        for (let i = 0; i < exts.length; i++) {
            const f = userFile(sub + "/" + name + "." + exts[i])
            if (f) return f
        }
        return ""
    }

    // URL of `rel` ("img/stripes.png"): the owner's file if there is one,
    // otherwise the built-in file.
    function url(rel: string): url {
        const f = userFile(rel)
        return f ? fresh(f) : Qt.resolvedUrl("../assets/" + rel)
    }

    // URL of the owner's image "img/<name>.<png|svg|...>", or "" if there is none.
    function image(name: string): string { return fresh(find("img", name, imageExts)) }

    // Path of a UI sound: the owner's "sounds/<name>.<wav|ogg|...>" or the built-in WAV.
    function sound(name: string): string {
        return find("sounds", name, soundExts) || builtinDir + "/sounds/" + name + ".wav"
    }

    // Path of the owner's "music/<name>.<ogg|mp3|...>", or "".
    function music(name: string): string { return find("music", name, musicExts) }

    // ---- channel banners and jingles (banners/<channel name>.*) ----------

    // A channel name as a file name: "/" can't be in one.
    function bannerName(name: string): string { return name.replace(/\//g, "_") }

    // An explicit path from config.json ("banner" / "jingle"): "~" and
    // ${VAR} are expanded; a relative path is looked up in the asset folder.
    function _explicit(path: string): string {
        const p = Config.expand(path)
        return p.startsWith("/") ? p : dir + "/" + p
    }

    function _ext(path: string): string {
        const dot = path.lastIndexOf(".")
        return dot < 0 ? "" : path.slice(dot + 1).toLowerCase()
    }

    // The banner of a channel, or null: { path, kind } with kind "image",
    // "animated" (gif, webp) or "video". `explicit` is the channel's
    // "banner" value from config.json, which wins over the banners folder.
    function banner(name: string, explicit: string): var {
        const p = explicit ? _explicit(explicit) : find("banners", bannerName(name), bannerExts)
        if (!p) return null
        const e = _ext(p)
        return { path: p, kind: videoExts.includes(e) ? "video" : (e === "gif" || e === "webp") ? "animated" : "image" }
    }

    // Path of a channel's jingle (banners/<channel name>.ogg|wav|...), or "".
    function jingle(name: string, explicit: string): string {
        return explicit ? _explicit(explicit) : find("banners", bannerName(name), soundExts)
    }

    // Path of the owner's font for a role, or "". Roles: "ui-regular",
    // "ui-medium", "ui-bold" (plain "ui" stands in for any of them) and "clock".
    function font(role: string): string {
        const chains = {
            "ui-regular": ["ui-regular", "ui", "ui-medium", "ui-bold"],
            "ui-medium": ["ui-medium", "ui", "ui-regular", "ui-bold"],
            "ui-bold": ["ui-bold", "ui", "ui-medium", "ui-regular"]
        }
        const names = chains[role] ?? [role]
        for (let i = 0; i < names.length; i++) {
            const f = find("fonts", names[i], fontExts)
            if (f) return f
        }
        return ""
    }

    // ---- indexing -------------------------------------------------------

    function rescan(): void { debounce.restart() }

    Timer {
        id: debounce
        interval: 120
        onTriggered: { if (scan.running) scan.again = true; else scan.running = true }
    }

    Process {
        id: scan
        property bool again: false
        running: true
        command: ["sh", "-c",
            '[ -d "$1" ] || { echo "!missing"; exit 0; }; ' +
            'find -L "$1" -mindepth 1 -maxdepth 4 \\( -type f -o -type d \\) -printf "%y\\t%T@\\t%P\\n"',
            "wii-assets", root.dir]
        stdout: StdioCollector {
            onStreamFinished: root._apply(text)
        }
        onExited: if (again) { again = false; running = true }
    }

    function _apply(text: string): void {
        const idx = {}, dirs = []
        let there = true
        const lines = text.split("\n")
        for (let i = 0; i < lines.length; i++) {
            const parts = lines[i].split("\t")
            if (parts[0] === "!missing") { there = false; continue }
            if (parts.length < 3) continue
            const rel = parts.slice(2).join("\t")
            if (parts[0] === "d") { dirs.push(rel); continue }
            idx[rel.toLowerCase()] = { rel: rel, t: parts[1] }
        }
        dirs.sort()
        const changed = JSON.stringify(idx) !== JSON.stringify(index) || there !== exists
        if (JSON.stringify(dirs) !== JSON.stringify(folders)) folders = dirs
        exists = there
        if (changed || !ready) {
            index = idx      // one assignment: paths and times change together
            revision++
            console.info("assets:", there ? Object.keys(idx).length + " file(s) in " + dir : "no folder at " + dir)
        }
        ready = true
    }

    // Folder watchers. Each one only says "something changed here"; the scan
    // above does the real work. The parent folder is watched too, so creating
    // the asset folder later is noticed.
    readonly property var _watched: {
        const cut = dir.lastIndexOf("/")
        const list = [{ path: cut > 0 ? dir.slice(0, cut) : "/", dirsOnly: true }]
        if (exists) {
            list.push({ path: dir, dirsOnly: false })
            for (let i = 0; i < folders.length; i++) list.push({ path: dir + "/" + folders[i], dirsOnly: false })
        }
        return list
    }

    Instantiator {
        model: root._watched
        delegate: FolderListModel {
            required property var modelData
            folder: root.toUrl(modelData.path)
            showDirs: true
            showFiles: !modelData.dirsOnly
            showDotAndDotDot: false
            property bool armed: false
            onStatusChanged: if (status === FolderListModel.Ready) armed = true
            onCountChanged: if (armed) root.rescan()
        }
    }

    // Coming back to the menu is a good moment to look again.
    readonly property int _workspace: Hypr.activeWorkspace
    on_WorkspaceChanged: if (_workspace === 1) rescan()

    IpcHandler {
        target: "assets"
        function reload(): void { root.rescan() }
        function dir(): string { return root.dir }
        function list(): string { return Object.values(root.index).map(e => e.rel).sort().join("\n") }
        function resolve(rel: string): string { return String(root.url(rel)) }
        function sound(name: string): string { return root.sound(name) }
        function font(role: string): string { return root.font(role) }
        function banner(name: string): string { const b = root.banner(name, ""); return b ? b.kind + " " + b.path : "" }
        function jingle(name: string): string { return root.jingle(name, "") }
    }
}
