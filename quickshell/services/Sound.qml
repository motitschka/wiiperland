pragma Singleton
import QtQuick
import Quickshell

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
}
