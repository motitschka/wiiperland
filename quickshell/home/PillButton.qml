import QtQuick
import qs.services

// Wide rounded button used on the channel preview ("Menu" / "Start").
Item {
    id: root
    property string text: ""
    property real hh: 720
    signal clicked()

    width: hh * 0.3; height: hh * 0.085
    readonly property bool hovered: mouse.containsMouse
    onHoveredChanged: if (hovered) Sound.play("tick")
    scale: mouse.pressed ? 0.95 : hovered ? 1.04 : 1
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

    Rectangle {   // hover glow
        anchors.fill: parent; anchors.margins: -root.height * 0.09
        radius: height / 2
        color: "transparent"
        border.color: Theme.blue; border.width: root.height * 0.07
        opacity: root.hovered ? 0.7 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 0.5; color: "#f3f3f3" }
            GradientStop { position: 1.0; color: "#dedede" }
        }
        border.color: root.hovered ? Theme.blue : "#b9b9b9"
        border.width: Math.max(1.5, root.height * 0.035)
        Text {
            anchors.centerIn: parent
            text: root.text
            font.family: Theme.fontMedium; font.pixelSize: root.height * 0.38
            color: root.hovered ? Theme.blueDark : Theme.darkText
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
