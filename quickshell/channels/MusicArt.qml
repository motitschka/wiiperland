import QtQuick
import Quickshell.Services.Mpris
import qs.services
import qs.home

// Music Channel: what's playing (any MPRIS player), with controls on the
// preview screen.
Item {
    id: root
    required property var channel
    property bool large: false
    readonly property string label: channel.name ?? "Music Channel"

    readonly property var players: Mpris.players.values
    readonly property var player: {
        const ps = players
        for (let i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
        return ps.length > 0 ? ps[0] : null
    }
    readonly property bool hasTrack: player !== null && (player.trackTitle ?? "") !== ""

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#fbf6ff" }
            GradientStop { position: 1.0; color: "#e4d6f5" }
        }
    }

    Row {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.large ? -root.height * 0.04 : 0
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
                color: "#7a6a92"
                style: Text.Raised; styleColor: "#ffffff"
            }
            Text {
                width: parent.width; elide: Text.ElideRight
                visible: text !== ""
                text: root.hasTrack ? (root.player.trackArtist ?? "") : (root.large ? "Nothing is playing" : "")
                font.family: Theme.font
                font.pixelSize: root.height * (root.large ? 0.045 : 0.11)
                color: "#9a8bb0"
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
