import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.channels

// One slot of the 4×3 grid. Empty slots show an embossed brand label.
Item {
    id: root
    property var channel: null
    property real s: 1
    readonly property bool empty: !channel
    readonly property var entry: channel && channel.app ? DesktopEntries.heuristicLookup(channel.app) : null
    readonly property bool hovered: mouse.containsMouse && !empty
    signal activated(var channel, Item tile)

    readonly property real r: height * 0.16
    readonly property real bw: Math.max(1.5, height * 0.022)

    // hover glow
    Rectangle {
        anchors.fill: parent; anchors.margins: -root.bw * 2.4
        radius: root.r + root.bw * 2.4
        color: "transparent"
        border.color: Theme.blue; border.width: root.bw * 2.2
        opacity: root.hovered ? pulse.v : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
        QtObject { id: pulse; property real v: 0.9 }
        SequentialAnimation {
            running: root.hovered; loops: Animation.Infinite
            NumberAnimation { target: pulse; property: "v"; to: 0.45; duration: 650; easing.type: Easing.InOutSine }
            NumberAnimation { target: pulse; property: "v"; to: 0.95; duration: 650; easing.type: Easing.InOutSine }
        }
    }

    ClippingRectangle {
        id: body
        anchors.fill: parent
        radius: root.r
        color: root.empty ? "#80d6d6d6" : "#ffffff"
        border.color: root.hovered ? Theme.blue : root.empty ? "#c6c6c6" : Theme.tileBorder
        border.width: root.bw
        contentInsideBorder: true

        // empty slot
        Text {
            visible: root.empty
            anchors.centerIn: parent
            text: Config.brand
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: parent.height * 0.36
            color: "#d3d3d3"
            style: Text.Sunken; styleColor: "#f4f4f4"
        }

        Loader {
            anchors.fill: parent
            active: !root.empty
            sourceComponent: root.channel && root.channel.type === "app" ? appArt : appArt
        }
        Component {
            id: appArt
            AppArt { channel: root.channel; entry: root.entry; s: root.s }
        }

        // glossy top edge
        Rectangle {
            visible: !root.empty
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: parent.height * 0.42
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#55ffffff" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.empty ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: if (!root.empty) root.activated(root.channel, root)
    }
}
