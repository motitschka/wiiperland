pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Finds desktop entries for channels, tells whether a channel is running and
// starts or focuses it.
Singleton {
    id: root

    readonly property string wii: Quickshell.shellDir + "/../bin/wii"

    function entryFor(channel: var): var {
        if (!channel || !channel.app) return null
        DesktopEntries.applications.values.length // re-evaluate once entries load
        return DesktopEntries.byId(channel.app) ?? DesktopEntries.heuristicLookup(channel.app)
    }

    // The name shown for a channel (the bubble under its tile).
    function label(channel: var): string {
        if (!channel) return ""
        if (channel.name) return channel.name
        const e = entryFor(channel)
        if (e) return e.name
        const names = { photos: "Photo Channel", forecast: "Forecast Channel", music: "Music Channel", disc: "Disc Channel" }
        return names[channel.type ?? "app"] ?? "Channel"
    }

    function command(channel: var): list<string> {
        if (channel.exec) return ["sh", "-c", channel.exec]
        const e = entryFor(channel)
        if (e) return e.command
        // sensible defaults for the built-in channel types
        if (channel.type === "photos") return ["xdg-open", Config.expand(channel.dir ?? "~/Pictures")]
        // the Disc Channel opens what is plugged in, in the file manager
        if (channel.type === "disc") return Disc.current ? ["xdg-open", Disc.current.path] : []
        if (channel.type === "forecast") return ["xdg-open", "https://wttr.in/" + encodeURIComponent(Weather.location)]
        return []
    }

    // Regex matched against Wayland app ids of open windows.
    function classPattern(channel: var): var {
        if (!channel) return null
        if (channel["class"]) return new RegExp(channel["class"], "i")
        const ids = []
        const e = entryFor(channel)
        if (e) ids.push(e.id)
        if (channel.app) ids.push(channel.app)
        if (channel.exec) ids.push(channel.exec.split(" ")[0].split("/").pop())
        if (ids.length === 0) return null
        const esc = ids.map(s => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
        return new RegExp("^(" + esc.join("|") + ")$", "i")
    }

    function toplevelFor(channel: var): var {
        const re = classPattern(channel)
        if (!re) return null
        const tls = ToplevelManager.toplevels.values
        for (let i = 0; i < tls.length; i++)
            if (re.test(tls[i].appId)) return tls[i]
        return null
    }

    function isRunning(channel: var): bool {
        // touch the model so bindings re-evaluate when windows come and go
        ToplevelManager.toplevels.values.length
        return toplevelFor(channel) !== null
    }

    // False when Start would do nothing: no open window to jump to and no
    // command to run. The preview greys its Start button out then.
    function canStart(channel: var): bool {
        if (!channel) return false
        return isRunning(channel) || command(channel).length > 0
    }

    // Start the channel on a fresh workspace, or jump to it if running.
    function start(channel: var): void {
        const tl = toplevelFor(channel)
        if (tl) { tl.activate(); return }
        const cmd = command(channel)
        if (cmd.length === 0) { console.warn("launcher: nothing to run for", channel.name); return }
        Quickshell.execDetached([root.wii, "launch"].concat(cmd))
    }

    function goHome(): void {
        Quickshell.execDetached([root.wii, "home"])
    }
}
