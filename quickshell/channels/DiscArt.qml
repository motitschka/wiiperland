import QtQuick
import QtQuick.Shapes
import qs.services

// Disc Channel: a drawn disc on a pale backdrop. With nothing plugged in the
// disc is dim and still, and the preview says "Please insert a disc.". When
// a USB stick, SD card or disc is mounted, the disc lights up and spins, and
// the preview shows the volume's name and how full it is.
Item {
    id: root
    required property var channel
    property bool large: false
    property bool playing: true
    readonly property var volume: Disc.current
    readonly property bool inserted: volume !== null

    property real spin: 0
    NumberAnimation on spin { from: 0; to: 360; duration: 9000; loops: Animation.Infinite; running: root.playing && root.inserted }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.inserted ? "#f4fbff" : "#f3f3f4" }
            GradientStop { position: 1.0; color: root.inserted ? "#bfe3f6" : "#cfd1d6" }
        }
    }
    Item {
        id: disc
        readonly property real d: root.height * (root.large ? 0.6 : 0.76)
        width: d; height: d
        x: root.large ? root.width * 0.2 - d / 2 + root.height * 0.2 : (root.width - d) / 2
        y: (root.height - d) / 2 - (root.large || !root.inserted ? 0 : root.height * 0.06)
        opacity: root.inserted ? 1 : 0.5
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            rotation: root.spin
            // the shiny side
            ShapePath {
                strokeColor: "#aab2bc"; strokeWidth: Math.max(1, disc.d * 0.008)
                fillGradient: ConicalGradient {
                    centerX: disc.d / 2; centerY: disc.d / 2; angle: 20
                    GradientStop { position: 0.00; color: "#f4f6f9" }
                    GradientStop { position: 0.10; color: "#c9e9fb" }
                    GradientStop { position: 0.18; color: "#f6e7ff" }
                    GradientStop { position: 0.26; color: "#eef1f5" }
                    GradientStop { position: 0.50; color: "#d5dae1" }
                    GradientStop { position: 0.60; color: "#fff3cf" }
                    GradientStop { position: 0.68; color: "#d2f5e2" }
                    GradientStop { position: 0.76; color: "#eef1f5" }
                    GradientStop { position: 1.00; color: "#f4f6f9" }
                }
                PathAngleArc { centerX: disc.d / 2; centerY: disc.d / 2; radiusX: disc.d / 2 - 1; radiusY: disc.d / 2 - 1; startAngle: 0; sweepAngle: 360 }
            }
        }
        // inner ring and hole (they don't need to turn)
        Rectangle {
            anchors.centerIn: parent
            width: disc.d * 0.34; height: width; radius: width / 2
            color: "#e9edf2"; border.color: "#b4bcc6"; border.width: Math.max(1, disc.d * 0.008)
        }
        Rectangle {
            anchors.centerIn: parent
            width: disc.d * 0.13; height: width; radius: width / 2
            color: root.inserted ? "#d5ecf9" : "#dcdde0"; border.color: "#a3abb5"; border.width: Math.max(1, disc.d * 0.008)
        }
    }

    // tile: the volume's name along the bottom when something is in
    Rectangle {
        visible: !root.large && root.inserted
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: root.height * 0.26
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#002a6f9c" }
            GradientStop { position: 1.0; color: "#c02a6f9c" }
        }
        Text {
            anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: root.height * 0.08 }
            horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
            text: root.inserted ? root.volume.name : ""
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: root.height * 0.13
            color: "#ffffff"
        }
    }

    // preview: what's in, or the invitation
    Column {
        visible: root.large
        x: root.width * 0.2 + root.height * 0.62
        width: root.width - x - root.width * 0.08
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.height * 0.025
        Text {
            width: parent.width; wrapMode: Text.WordWrap
            text: root.inserted ? root.volume.name : "Please insert a disc."
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: root.height * (root.inserted ? 0.1 : 0.085)
            color: root.inserted ? "#3f6f92" : "#7b7f87"
            style: Text.Raised; styleColor: "#ffffff"
        }
        Text {
            visible: root.inserted && root.volume.size > 0
            text: root.inserted ? Disc.human(root.volume.used) + " used of " + Disc.human(root.volume.size) : ""
            font.family: Theme.fontMedium
            font.pixelSize: root.height * 0.045
            color: "#6f8496"
        }
        // how full it is
        Rectangle {
            visible: root.inserted && root.volume.size > 0
            width: Math.min(parent.width, root.height * 0.9); height: root.height * 0.035; radius: height / 2
            color: "#ffffff"; border.color: "#a9c6d8"; border.width: 1
            Rectangle {
                x: 1; y: 1; height: parent.height - 2; radius: height / 2
                width: Math.max(height, (parent.width - 2) * (root.inserted && root.volume.size > 0 ? root.volume.used / root.volume.size : 0))
                color: Theme.blue
            }
        }
        Text {
            visible: root.inserted && Disc.volumes.length > 1
            text: "+ " + (Disc.volumes.length - 1) + " more"
            font.family: Theme.font
            font.pixelSize: root.height * 0.038
            color: "#6f8496"
        }
    }
}
