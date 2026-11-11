import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.channels

// One slot of the grid: a rounded tile with a grey edge and a white inner rim
// around the channel's art. Empty slots are a faint grey plate.
Item {
    id: root
    property var channel: null
    property int slot: -1
    property bool current: true        // on the page that is showing, not a peeking neighbour
    readonly property bool empty: !channel
    readonly property var entry: Launcher.entryFor(channel)
    readonly property string label: Launcher.label(channel)
    readonly property bool running: !empty && Launcher.isRunning(channel)
    readonly property bool hovered: mouse.containsMouse && !empty && current
    onHoveredChanged: if (hovered) Sound.play("tick")
    signal activated(int slot, Item tile)
    signal flip()                      // a peeking tile was clicked

    readonly property real r: height * 0.12
    readonly property real bw: Math.max(1.5, height * 0.014)
    readonly property real ow: height * 0.042      // hover ring
    readonly property real ringOut: height * 0.022 // how far the ring reaches past the tile's edge
    readonly property real glowW: height * 0.009   // one band of the glow around the ring

    ClippingRectangle {
        id: body
        anchors.fill: parent
        radius: root.r
        color: root.empty ? "#cccfd0d5" : "#ffffff"
        border.color: root.hovered ? Theme.blueHover : Theme.tileBorder
        border.width: root.bw
        contentInsideBorder: true

        // empty slot
        Text {
            visible: root.empty
            anchors.centerIn: parent
            text: Config.brand
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: parent.height * 0.3
            color: "#c9cace"
            style: Text.Sunken; styleColor: "#e6e7ea"
            opacity: 0.8
        }

        ChannelArt {
            anchors.fill: parent
            channel: root.channel
            // animations and video rest while the tile is out of view
            playing: root.current && Hypr.activeWorkspace === 1
        }

        // running indicator
        Rectangle {
            visible: root.running
            width: parent.height * 0.09; height: width; radius: width / 2
            anchors { right: parent.right; bottom: parent.bottom; margins: parent.height * 0.08 }
            color: Theme.blue
            border.color: "#ffffff"; border.width: Math.max(1, width * 0.18)
        }

        // soft light on the upper edge
        Rectangle {
            visible: !root.empty
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: parent.height * 0.36
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#38ffffff" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
        }

        // white inner rim
        Rectangle {
            anchors.fill: parent
            radius: root.r - root.bw
            color: "transparent"
            border.color: root.empty ? "#55ffffff" : "#ffffff"
            border.width: root.bw * 1.1
        }
    }

    // hover: a pale-blue ring over the tile's edge with a soft glow that
    // gently breathes. The outer item fades in and out; the glow breathes.
    Item {
        anchors.fill: parent
        opacity: root.hovered ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 130 } }

        Item {
            id: glow
            anchors.fill: parent
            SequentialAnimation {
                running: root.hovered; loops: Animation.Infinite
                NumberAnimation { target: glow; property: "opacity"; to: 0.55; duration: 700; easing.type: Easing.InOutSine }
                NumberAnimation { target: glow; property: "opacity"; to: 1; duration: 700; easing.type: Easing.InOutSine }
            }
            // glow: bands fading outwards from the ring, and a little inwards
            Repeater {
                model: [0.34, 0.2, 0.1, 0.04]
                Rectangle {
                    required property real modelData
                    required property int index
                    readonly property real out: root.ringOut + root.glowW * (index + 1)
                    anchors.fill: parent; anchors.margins: -out
                    radius: root.r + out
                    color: "transparent"
                    border.color: Qt.alpha(Theme.blueHover, modelData); border.width: root.glowW
                }
            }
            Repeater {
                model: [0.3, 0.12]
                Rectangle {
                    required property real modelData
                    required property int index
                    readonly property real inset: root.ow - root.ringOut + root.glowW * index
                    anchors.fill: parent; anchors.margins: inset
                    radius: Math.max(0, root.r - inset)
                    color: "transparent"
                    border.color: Qt.alpha(Theme.blueHover, modelData); border.width: root.glowW
                }
            }
        }
        Rectangle {
            anchors.fill: parent; anchors.margins: -root.ringOut
            radius: root.r + root.ringOut
            color: "transparent"
            border.color: Theme.blueHover; border.width: root.ow
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: (root.empty && root.current) ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: {
            if (!root.current) root.flip()
            else if (!root.empty) root.activated(root.slot, root)
        }
    }
}
