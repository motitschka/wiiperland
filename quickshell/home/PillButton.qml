import QtQuick
import qs.services

// Wide glossy pill with a light-blue rim: the buttons on the channel preview
// ("<brand> Menu" / "Start") and on the message board. Set `available: false`
// for the greyed-out look (no hover, no click). That is separate from
// `enabled`, which also turns false while a parent is busy animating.
Item {
    id: root
    property string text: ""
    property real hh: 720
    property bool available: true
    signal clicked()

    width: hh * 0.3; height: hh * 0.085
    readonly property bool hovered: available && mouse.containsMouse
    onHoveredChanged: if (hovered) Sound.play("tick")
    scale: mouse.pressed ? 0.96 : hovered ? 1.04 : 1
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

    Rectangle {   // hover glow
        anchors.fill: parent; anchors.margins: -root.height * 0.07
        radius: height / 2
        color: "transparent"
        border.color: Theme.blue; border.width: root.height * 0.06
        opacity: root.hovered ? 0.55 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }
    Rectangle {   // soft shadow under the pill
        visible: root.available
        anchors.fill: parent; anchors.topMargin: root.height * 0.05; anchors.bottomMargin: -root.height * 0.05
        radius: height / 2
        color: "#22000000"
    }
    Rectangle {
        id: body
        anchors.fill: parent
        radius: height / 2
        opacity: root.available ? 1 : 0.4
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.available ? "#fbfcfe" : "#e6e5df" }
            GradientStop { position: 0.4; color: root.available ? "#e2e8f1" : "#deddd6" }
            GradientStop { position: 0.78; color: root.available ? "#dbe2ed" : "#dcdbd4" }
            GradientStop { position: 1.0; color: root.available ? "#f1f4f9" : "#e2e1da" }
        }
        border.color: !root.available ? "#bdbcb4" : root.hovered ? Theme.blue : Theme.blueLine
        border.width: Math.max(2, root.height * 0.045)
    }
    Rectangle {   // gloss: a soft white sheen across the upper half
        visible: root.available
        x: root.height * 0.2; y: root.height * 0.09
        width: root.width - 2 * x; height: root.height * 0.36
        radius: height / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e6ffffff" }
            GradientStop { position: 1.0; color: "#00ffffff" }
        }
    }
    Text {
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.fontMedium; font.pixelSize: root.height * 0.4
        color: !root.available ? "#b3b2ab" : root.hovered ? Theme.blueDark : "#3d3e42"
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.available
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
