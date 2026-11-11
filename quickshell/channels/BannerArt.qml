import QtQuick
import qs.services

// The owner's banner for a channel, full-bleed: a still image, an animated
// gif/webp, or a looping silent video. The picture is cropped to fill.
Item {
    id: root
    // { path, kind } from Assets.banner(); kind: image | animated | video.
    // One object, so that path and kind always change together.
    property var banner: null
    readonly property string path: banner ? banner.path : ""
    readonly property string kind: banner ? banner.kind : "image"
    property bool playing: true
    signal failed()

    Rectangle { anchors.fill: parent; color: "#101114" }

    Loader {
        anchors.fill: parent
        active: root.kind !== "video"
        sourceComponent: root.kind === "animated" ? moving : still
    }
    Component {
        id: still
        Image {
            source: Assets.fresh(root.path)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            mipmap: true
            onStatusChanged: if (status === Image.Error) root.failed()
        }
    }
    Component {
        id: moving
        AnimatedImage {
            source: Assets.fresh(root.path)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            playing: root.playing
            onStatusChanged: if (status === AnimatedImage.Error) root.failed()
        }
    }

    // Video lives in its own file so that a system without Qt Multimedia
    // only loses video banners: the Loader fails and the built-in art shows.
    Loader {
        id: video
        anchors.fill: parent
        active: root.kind === "video"
        source: active ? Qt.resolvedUrl("VideoBanner.qml") : ""
        onStatusChanged: if (status === Loader.Error) root.failed()
        onLoaded: { item.path = Qt.binding(() => root.path); item.playing = Qt.binding(() => root.playing) }
    }
    Connections {
        target: video.item
        ignoreUnknownSignals: true
        function onFailed(): void { root.failed() }
    }
}
