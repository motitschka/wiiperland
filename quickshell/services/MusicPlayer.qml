import QtQuick
import QtMultimedia

// The player behind services/Music.qml: one looping file with a volume that
// Music.qml eases up and down. Kept in its own file so that a system
// without Qt Multimedia only loses the music.
Item {
    id: root
    property string source: ""     // file:// URL
    property real volume: 0        // 0..1
    property bool active: false    // play (true) or pause (false)
    signal failed(string why)

    function sync(): void {
        if (!source) return
        if (active) player.play(); else player.pause()
    }
    onActiveChanged: sync()

    MediaPlayer {
        id: player
        source: root.source
        loops: MediaPlayer.Infinite
        audioOutput: AudioOutput { volume: root.volume }
        // play() before the file is loaded is ignored, so start from here too
        onMediaStatusChanged: if (mediaStatus === MediaPlayer.LoadedMedia) root.sync()
        onErrorOccurred: (error, text) => root.failed(text)
    }
}
