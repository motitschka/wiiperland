import QtQuick
import QtMultimedia
import qs.services

// A looping, silent video banner (mp4, webm, ...). Needs Qt Multimedia
// (qt6-multimedia and qt6-multimedia-ffmpeg). Loaded only by BannerArt.
Item {
    id: root
    property string path: ""
    property bool playing: true
    signal failed()

    function sync(): void {
        if (!path) return
        if (playing) player.play(); else player.pause()
    }
    onPlayingChanged: sync()

    MediaPlayer {
        id: player
        source: Assets.toUrl(root.path)
        videoOutput: out
        loops: MediaPlayer.Infinite
        // play() before the file is loaded is ignored, so start from here
        onMediaStatusChanged: if (mediaStatus === MediaPlayer.LoadedMedia) root.sync()
        // no audioOutput: banners are silent, the jingle is a separate file
        onErrorOccurred: (error, text) => { console.warn("video banner:", text); root.failed() }
    }
    VideoOutput {
        id: out
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }
}
