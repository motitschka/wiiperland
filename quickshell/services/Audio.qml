pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Default output volume via PipeWire.
Singleton {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false

    function setVolume(v: real): void { if (ready) sink.audio.volume = Math.max(0, Math.min(1, v)) }
    function toggleMute(): void { if (ready) sink.audio.muted = !sink.audio.muted }

    PwObjectTracker { objects: root.sink ? [root.sink] : [] }
}
