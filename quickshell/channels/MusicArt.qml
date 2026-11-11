import QtQuick
import Quickshell.Services.Mpris
import qs.services
import qs.home

// Music Channel: what's playing (any MPRIS player). The tile is a full-bleed
// scene: equaliser bars and rising notes that liven up while something
// plays, or the track's cover art with its title when the player has one.
// The preview shows cover, title and artist with playback controls.
Item {
    id: root
    required property var channel
    property bool large: false
    property bool playing: true      // the scene's animations run
    readonly property string label: channel.name ?? "Music Channel"

    readonly property var players: Mpris.players.values
    readonly property var player: {
        const ps = players
        for (let i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
        return ps.length > 0 ? ps[0] : null
    }
    readonly property bool hasTrack: player !== null && (player.trackTitle ?? "") !== ""

    readonly property bool sounding: player !== null && player.isPlaying
    readonly property string artUrl: player ? (player.trackArtUrl ?? "") : ""

    property real t: 0
    NumberAnimation on t { from: 0; to: 1; duration: 8000; loops: Animation.Infinite; running: root.playing }
    function wave(k: real, phase: real): real { return Math.sin((t * k + phase) * 2 * Math.PI) }
    // slides from idle (0) to playing (1) so the bars swell instead of jumping
    property real energy: sounding ? 1 : 0
    Behavior on energy { NumberAnimation { duration: 900; easing.type: Easing.InOutQuad } }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#b99be6" }
            GradientStop { position: 0.6; color: "#8f7fd9" }
            GradientStop { position: 1.0; color: "#6c8fe0" }
        }
    }
    // cover art, full-bleed, on the tile
    Image {
        id: backdrop
        visible: !root.large && status === Image.Ready
        anchors.fill: parent
        source: root.large ? "" : root.artUrl
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize.height: 480
    }

    // equaliser bars along the bottom
    Row {
        id: bars
        readonly property int n: 14
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        spacing: root.width * 0.018
        opacity: backdrop.visible ? 0.75 : 1
        Repeater {
            model: bars.n
            Rectangle {
                required property int index
                readonly property real level: 0.12 + (0.1 + 0.42 * root.energy) * (0.5 + 0.5 * root.wave(2 + index % 4, index * 0.31))
                    + 0.1 * (0.5 + 0.5 * root.wave(1, index * 0.07))
                anchors.bottom: parent.bottom
                width: (root.width * 0.92 - bars.spacing * (bars.n - 1)) / bars.n
                height: root.height * (root.large ? 0.8 : 1) * level
                radius: width * 0.3
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f2ffffff" }
                    GradientStop { position: 1.0; color: "#66ffffff" }
                }
            }
        }
    }

    // notes rising (tile, when there is no cover to show)
    Repeater {
        model: root.large || backdrop.visible ? 0 : 3
        Text {
            required property int index
            readonly property real p: (root.t * (1 + index % 2) + index * 0.37) % 1
            text: index === 1 ? "♫" : "♪"
            font.pixelSize: root.height * (0.42 - index * 0.07)
            color: "#ffffff"
            style: Text.Raised; styleColor: "#407050b0"
            x: root.width * (0.2 + index * 0.28) + root.height * 0.05 * root.wave(2, index * 0.3)
            y: root.height * (0.62 - p * 0.75)
            opacity: Math.min(1, p * 4) * Math.min(1, (1 - p) * 3) * 0.95
            rotation: 8 * root.wave(3, index * 0.2)
        }
    }

    // tile with a track: title and artist on a dark strip
    Rectangle {
        visible: !root.large && root.hasTrack
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: root.height * 0.36
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#b0201838" }
        }
        Column {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: root.height * 0.07 }
            Text {
                width: parent.width; elide: Text.ElideRight
                text: root.hasTrack ? root.player.trackTitle : ""
                font.family: Theme.fontBold; font.weight: Font.Bold
                font.pixelSize: root.height * 0.13
                color: "#ffffff"
            }
            Text {
                width: parent.width; elide: Text.ElideRight
                visible: text !== ""
                text: root.hasTrack ? (root.player.trackArtist ?? "") : ""
                font.family: Theme.fontMedium
                font.pixelSize: root.height * 0.09
                color: "#e6ffffff"
            }
        }
    }

    Row {
        visible: root.large
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -root.height * 0.08
        spacing: root.height * 0.07

        // cover art or a drawn note
        Rectangle {
            width: root.height * (root.large ? 0.4 : 0.62); height: width
            anchors.verticalCenter: parent.verticalCenter
            radius: width * 0.1
            color: "#ffffff"; border.color: "#d2c3e6"; border.width: Math.max(1, width * 0.02)
            clip: true
            Image {
                id: cover
                anchors.fill: parent; anchors.margins: parent.border.width
                source: root.player ? (root.player.trackArtUrl ?? "") : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
            Text {
                visible: !cover.visible
                anchors.centerIn: parent
                text: "♪"
                font.pixelSize: parent.height * 0.62
                color: "#a98ad1"
                style: Text.Raised; styleColor: "#ffffff"
            }
            // spinning-record shimmer while playing
            Rectangle {
                visible: root.player && root.player.isPlaying
                width: parent.width * 0.16; height: width; radius: width / 2
                anchors { right: parent.right; bottom: parent.bottom; margins: parent.width * 0.06 }
                color: Theme.blue; border.color: "#ffffff"; border.width: Math.max(1, width * 0.15)
                SequentialAnimation on scale { loops: Animation.Infinite; NumberAnimation { to: 1.25; duration: 500 } NumberAnimation { to: 1; duration: 500 } }
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: root.width * (root.large ? 0.42 : 0.4)
            spacing: root.height * 0.02
            Text {
                width: parent.width; elide: Text.ElideRight
                text: root.hasTrack ? root.player.trackTitle : root.label
                font.family: Theme.fontBold; font.weight: Font.Bold
                font.pixelSize: root.height * (root.large ? 0.07 : 0.15)
                color: "#ffffff"
                style: Text.Raised; styleColor: "#506040a0"
            }
            Text {
                width: parent.width; elide: Text.ElideRight
                visible: text !== ""
                text: root.hasTrack ? (root.player.trackArtist ?? "") : (root.large ? "Nothing is playing" : "")
                font.family: Theme.font
                font.pixelSize: root.height * (root.large ? 0.045 : 0.11)
                color: "#e6ffffff"
            }
            Row {
                visible: root.large && root.player !== null
                spacing: root.height * 0.03
                topPadding: root.height * 0.02
                Repeater {
                    model: [
                        { g: "⏮", f: () => root.player.previous(), ok: root.player && root.player.canGoPrevious },
                        { g: root.player && root.player.isPlaying ? "⏸" : "▶", f: () => root.player.togglePlaying(), ok: root.player && root.player.canTogglePlaying },
                        { g: "⏭", f: () => root.player.next(), ok: root.player && root.player.canGoNext }
                    ]
                    WiiButton {
                        required property var modelData
                        radius: root.height * 0.045
                        opacity: modelData.ok ? 1 : 0.4
                        onClicked: if (modelData.ok) modelData.f()
                        Text {
                            anchors.centerIn: parent
                            text: modelData.g
                            font.pixelSize: parent.height * 0.42
                            color: "#8a8a8a"
                        }
                    }
                }
            }
        }
    }
}
