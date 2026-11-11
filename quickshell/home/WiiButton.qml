import QtQuick
import QtQuick.Effects
import qs.services

// Round corner button (home button, mail button): a matte grey face inside
// a thin pale-blue ring.
Item {
    id: root
    property real radius: 56
    property bool glowing: false   // e.g. unread mail
    default property alias content: face.data
    signal clicked()

    width: radius * 2; height: radius * 2
    readonly property bool hovered: mouse.containsMouse
    onHoveredChanged: if (hovered) {
        Sound.play("tick")
        glowRing.opacity = 0.6   // the pulse has stopped wherever it was
    }
    scale: mouse.pressed ? 0.95 : hovered ? 1.05 : 1
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

    // soft drop shadow
    Rectangle {
        anchors.centerIn: parent; anchors.verticalCenterOffset: root.radius * 0.07
        width: parent.width * 1.04; height: width; radius: width / 2
        color: "#2a000000"
        layer.enabled: true
        layer.effect: MultiEffect { blurEnabled: true; blur: 1; blurMax: Math.max(2, Math.round(root.radius * 0.1)) }
    }
    // outer blue glow when hovered / glowing. The parent fades it in and out;
    // the ring itself pulses while glowing.
    Item {
        anchors.fill: parent
        opacity: root.hovered || root.glowing ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
        Rectangle {
            id: glowRing
            anchors.centerIn: parent
            width: parent.width * 1.13; height: width; radius: width / 2
            color: "transparent"
            border.color: Theme.blue; border.width: root.radius * 0.07
            opacity: 0.6
            SequentialAnimation on opacity {
                running: root.glowing && !root.hovered; loops: Animation.Infinite
                NumberAnimation { from: 0.1; to: 0.7; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.7; to: 0.1; duration: 900; easing.type: Easing.InOutSine }
            }
        }
    }
    // soft pale halo, then the pale-blue ring
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 1.06; height: width; radius: width / 2
        color: "#38ffffff"
    }
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * 1.03; height: width; radius: width / 2
        color: "#80ffffff"
    }
    Rectangle {
        anchors.fill: parent; radius: width / 2
        color: root.hovered ? Theme.blue : Theme.blueLine
        Behavior on color { ColorAnimation { duration: 140 } }
    }
    // matte face
    Rectangle {
        id: face
        anchors.fill: parent; anchors.margins: root.radius * 0.075
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#dfe0e4" }
            GradientStop { position: 0.5; color: "#d5d6db" }
            GradientStop { position: 1.0; color: "#c8c9cf" }
        }
        // a whisper of light on the upper half; no gloss
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.06
            width: parent.width * 0.78; height: parent.height * 0.42; radius: height / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#26ffffff" }
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
