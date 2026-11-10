pragma Singleton
import QtQuick
import Quickshell

// UI sounds (assets/sounds/*.wav, made by tools/make-sounds.py), played with
// pw-play (PipeWire) or paplay as a fallback.
// config.json: "sounds": true, "soundVolume": 0.6
Singleton {
    id: root
    readonly property bool enabled: Config.sounds
    readonly property real volume: Config.data.soundVolume ?? 0.6
    readonly property string dir: Quickshell.shellDir + "/assets/sounds/"
    property var _last: ({})

    function play(name: string): void {
        if (!enabled || volume <= 0) return
        // don't machine-gun the same sound (e.g. sweeping across tiles)
        const now = Date.now()
        if (_last[name] && now - _last[name] < 45) return
        _last[name] = now
        console.debug("sound", name)
        Quickshell.execDetached(["sh", "-c",
            'pw-play --volume "$1" "$2" 2>/dev/null || paplay --volume "$3" "$2"',
            "wii-sound", String(volume), dir + name + ".wav", String(Math.round(volume * 65536))])
    }
}
