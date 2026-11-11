pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// UI sounds, played with pw-play (PipeWire) or paplay as a fallback. The
// built-in WAVs are made by tools/make-sounds.py; a file of the same name in
// the owner's asset folder (sounds/<name>.wav|ogg) replaces one.
// config.json: "sounds": true, "soundVolume": 0.6
// WIIPERLAND_SILENT=1 (set by dev/nested.sh) logs sounds without playing them.
Singleton {
    id: root
    readonly property bool enabled: Config.sounds
    readonly property real volume: Config.data.soundVolume ?? 0.6
    readonly property bool silent: (Quickshell.env("WIIPERLAND_SILENT") || "0") !== "0"
    property var _last: ({})

    function play(name: string): void {
        if (!enabled || volume <= 0) return
        // don't machine-gun the same sound (e.g. sweeping across tiles)
        const now = Date.now()
        if (_last[name] && now - _last[name] < 45) return
        _last[name] = now
        const file = Assets.sound(name)
        console.debug("sound", name, file)
        if (silent) return
        Quickshell.execDetached(["sh", "-c",
            'pw-play --volume "$1" "$2" 2>/dev/null || paplay --volume "$3" "$2"',
            "wii-sound", String(volume), file, String(Math.round(volume * 65536))])
    }

    // ---- channel jingle: one longer sound that can be stopped -----------
    // The preview plays the channel's jingle (banners/<name>.ogg) once while
    // it is open. jingle("") or stopJingle() cuts it off.
    property string jingleFile: ""     // what should be playing ("" = nothing)
    property string _started: ""       // what the player was last started with

    function jingle(file: string): void {
        const f = enabled && volume > 0 ? file : ""
        if (f === jingleFile) return
        jingleFile = f
        console.debug("jingle", f || "(stop)")
        if (silent) return
        if (player.running) player.running = false   // onExited starts the next one
        else _startJingle()
    }
    function stopJingle(): void { jingle("") }

    function _startJingle(): void {
        _started = jingleFile
        if (!jingleFile) return
        player.command = ["pw-play", "--volume", String(volume), jingleFile]
        player.running = true
    }

    Process {
        id: player
        // ended by itself: stay quiet. Killed for another jingle: start that one.
        onExited: if (root.jingleFile !== root._started) root._startJingle()
    }
}
