pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// Menu music: one soft loop while the menu is showing. It is the owner's
// music/menu.* from the asset folder, else the built-in loop made by
// tools/make-music.py. It fades out when you leave the menu, when a channel's
// jingle plays and on the lock screen, fades back afterwards, and ducks while
// something else is playing audio.
// config.json: "music": true, "musicVolume": 0.35
// WIIPERLAND_SILENT=1 (set by dev/nested.sh) logs what it would do instead.
Singleton {
    id: root
    readonly property bool enabled: Config.data.music ?? true
    readonly property real volume: Math.max(0, Math.min(1, Config.data.musicVolume ?? 0.35))
    readonly property bool silent: (Quickshell.env("WIIPERLAND_SILENT") || "0") !== "0"
    readonly property string file: Assets.music("menu") || Assets.builtinDir + "/music/menu.ogg"
    readonly property bool custom: Assets.music("menu") !== ""

    property bool hold: false            // set by the lock screen
    property bool available: true        // false if the player can't be loaded or the file can't be played

    // Is anything else making sound? An MPRIS player that is playing, or an
    // audio stream that is running (checked every few seconds on the menu).
    property bool streamsBusy: false
    readonly property bool playersBusy: {
        const ps = Mpris.players.values
        for (let i = 0; i < ps.length; i++) if (ps[i].isPlaying) return true
        return false
    }
    readonly property bool otherAudio: playersBusy || streamsBusy

    readonly property bool onMenu: Hypr.activeWorkspace === 1
    readonly property bool jingle: Sound.jingleFile !== ""
    // 0 = silent, 0.25 = ducked, 1 = full
    readonly property real level: !enabled || !available || volume <= 0 || !onMenu || jingle || hold ? 0
        : otherAudio ? 0.25 : 1
    readonly property string mood: level === 0 ? "off" : level < 1 ? "ducked" : "playing"
    onMoodChanged: console.info("music:", mood, mood === "off" ? "" : file)

    // what the player hears: eased, so every change is a fade
    property real out: volume * level
    Behavior on out { NumberAnimation { duration: 900; easing.type: Easing.InOutQuad } }
    // keep playing until the fade-out has finished, then pause
    readonly property bool running: !silent && available && (level > 0 || out > 0.001)

    function setEnabled(on: bool): void { Config.setValue("music", on) }
    function setVolume(v: real): void { Config.setValue("musicVolume", Math.round(Math.max(0, Math.min(1, v)) * 100) / 100) }

    Loader {
        id: player
        active: !root.silent
        source: active ? Qt.resolvedUrl("MusicPlayer.qml") : ""
        onStatusChanged: if (status === Loader.Error) { root.available = false; console.warn("music: Qt Multimedia is missing, no menu music") }
        onLoaded: {
            item.source = Qt.binding(() => Assets.toUrl(root.file))
            item.volume = Qt.binding(() => root.out)
            item.active = Qt.binding(() => root.running)
        }
    }
    Connections {
        target: player.item
        ignoreUnknownSignals: true
        function onFailed(why: string): void { console.warn("music: can't play", root.file, "-", why); root.available = false }
    }
    // a new file (the owner dropped one in) gets a fresh chance
    onFileChanged: available = true

    // Running audio streams other than our own (this shell, pw-play).
    Process {
        id: probe
        command: ["sh", "-c", "pactl -f json list sink-inputs 2>/dev/null || echo '[]'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let busy = false
                try {
                    const list = JSON.parse(text)
                    for (let i = 0; i < list.length; i++) {
                        const p = list[i].properties ?? {}
                        // Qt's stream carries no binary name, only the application name
                        const ours = ["quickshell", "qs", ".quickshell-wrapped", "pw-play", "pw-cat", "paplay"]
                        const mine = ours.includes(p["application.process.binary"] ?? "")
                            || ours.includes(p["application.name"] ?? "") || ours.includes(p["media.name"] ?? "")
                        if (!mine && list[i].corked === false) { busy = true; break }
                    }
                } catch (e) {}
                root.streamsBusy = busy
            }
        }
    }
    Timer {
        interval: 3000; repeat: true; triggeredOnStart: true
        running: root.enabled && root.onMenu && !root.hold
        onTriggered: if (!probe.running) probe.running = true
    }

    IpcHandler {
        target: "music"
        function state(): string {
            return JSON.stringify({ enabled: root.enabled, volume: root.volume, level: root.level, mood: root.mood,
                                    otherAudio: root.otherAudio, file: root.file, custom: root.custom, available: root.available })
        }
        function toggle(): void { root.setEnabled(!root.enabled) }
        function volume(v: real): void { root.setVolume(v) }
    }
}
