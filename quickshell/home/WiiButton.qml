import QtQuick
import qs.services

// Round glossy corner button with a blue ring (home button, mail button).
Item {
    id: root
    property real radius: 56
    property bool glowing: false   // e.g. unread mail
    default property alias content: face.data
    signal clicked()

    width: radius * 2; height: radius * 2
    readonly property bool hovered: mouse.containsMouse
    onHoveredChanged: if (hovered) Sound.play("tick")
    scale: mouse.pressed ? 0.95 : hovered ? 1.05 : 1
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

    // soft drop shadow
    Rectangle {
        anchors.centerIn: parent; anchors.verticalCenterOffset: root.radius * 0.06
        width: parent.width * 1.04; height: width; radius: width / 2
        color: "#26000000"
    }
    // outer blue glow when hovered / glowing
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 1.14; height: width; radius: width / 2
        color: "transparent"
        border.color: "#34beed"; border.width: root.radius * 0.07
        opacity: root.hovered ? 0.55 : root.glowing ? glowPulse.value : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
        QtObject { id: glowPulse; property real value: 0.2 }
        SequentialAnimation {
            running: root.glowing && !root.hovered; loops: Animation.Infinite
            NumberAnimation { target: glowPulse; property: "value"; from: 0.1; to: 0.7; duration: 900; easing.type: Easing.InOutSine }
            NumberAnimation { target: glowPulse; property: "value"; from: 0.7; to: 0.1; duration: 900; easing.type: Easing.InOutSine }
        }
    }
    // blue ring
    Rectangle {
        anchors.fill: parent; radius: width / 2
        color: "#34beed"
    }
    // glossy face
    Rectangle {
        id: face
        anchors.fill: parent; anchors.margins: root.radius * 0.055
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#fbfbfb" }
            GradientStop { position: 0.55; color: "#e4e4e4" }
            GradientStop { position: 1.0; color: "#cfcfcf" }
        }
        // top highlight
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.06
            width: parent.width * 0.74; height: parent.height * 0.42; radius: height / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#e6ffffff" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { Sound.play("click"); root.clicked() }
    }
}
