import QtQuick
import QtQuick.Shapes

// Soft, drawn weather icons: sun, partly, cloud, fog, rain, snow, storm.
Item {
    id: root
    property string kind: "sun"
    width: 100; height: 100

    readonly property bool hasSun: kind === "sun" || kind === "partly"
    readonly property bool hasCloud: kind !== "sun"
    readonly property color cloudColor: kind === "storm" ? "#9aa3ad" : kind === "rain" ? "#c3cad2" : "#e9edf1"

    // sun
    Item {
        visible: root.hasSun
        width: root.width * (root.kind === "sun" ? 0.8 : 0.6); height: width
        x: root.kind === "sun" ? (root.width - width) / 2 : root.width * 0.08
        y: root.kind === "sun" ? (root.height - height) / 2 : root.height * 0.02
        RotationAnimation on rotation { from: 0; to: 360; duration: 40000; loops: Animation.Infinite }
        Repeater {
            model: 8
            Rectangle {
                required property int index
                width: parent.width * 0.07; height: parent.height * 0.2; radius: width / 2
                color: "#ffc93c"
                x: parent.width / 2 - width / 2; y: 0
                transform: Rotation { origin.x: width / 2; origin.y: parent.height / 2; angle: index * 45 }
            }
        }
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.56; height: width; radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0; color: "#ffe27a" }
                GradientStop { position: 1; color: "#ffb21f" }
            }
        }
    }

    // cloud
    Item {
        id: cloud
        visible: root.hasCloud
        width: root.width * 0.86; height: root.height * 0.5
        x: (root.width - width) / 2 + (root.kind === "partly" ? root.width * 0.06 : 0)
        y: root.height * (root.kind === "partly" ? 0.36 : 0.18)
        component Puff: Rectangle { radius: width / 2; color: root.cloudColor; border.color: Qt.darker(root.cloudColor, 1.12); border.width: Math.max(1, root.width * 0.012) }
        Puff { width: cloud.width * 0.42; height: width; x: cloud.width * 0.1; y: cloud.height * 0.3 }
        Puff { width: cloud.width * 0.52; height: width; x: cloud.width * 0.3; y: 0 }
        Puff { width: cloud.width * 0.36; height: width; x: cloud.width * 0.58; y: cloud.height * 0.36 }
        Rectangle {
            x: cloud.width * 0.12; y: cloud.height * 0.62
            width: cloud.width * 0.78; height: cloud.height * 0.42; radius: height / 2
            color: root.cloudColor
        }
    }

    // rain / snow / fog / storm details
    Repeater {
        model: root.kind === "rain" || root.kind === "storm" ? 3 : 0
        Rectangle {
            required property int index
            width: root.width * 0.05; height: root.height * 0.16; radius: width / 2
            color: "#4fb3ea"; rotation: 18
            x: root.width * (0.3 + index * 0.18); y: root.height * 0.74
            SequentialAnimation on opacity { loops: Animation.Infinite; PauseAnimation { duration: index * 250 } NumberAnimation { from: 1; to: 0.3; duration: 600 } NumberAnimation { from: 0.3; to: 1; duration: 600 } }
        }
    }
    Repeater {
        model: root.kind === "snow" ? 3 : 0
        Rectangle {
            required property int index
            width: root.width * 0.08; height: width; radius: width / 2
            color: "#ffffff"; border.color: "#b8c8d8"; border.width: 1
            x: root.width * (0.28 + index * 0.18); y: root.height * (0.76 + (index % 2) * 0.08)
        }
    }
    Repeater {
        model: root.kind === "fog" ? 2 : 0
        Rectangle {
            required property int index
            width: root.width * (0.62 - index * 0.14); height: root.height * 0.05; radius: height / 2
            color: "#c9d1d9"
            x: (root.width - width) / 2; y: root.height * (0.76 + index * 0.1)
        }
    }
    Shape {
        visible: root.kind === "storm"
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: "#ffcf3a"; strokeColor: "#e0a400"; strokeWidth: 1
            startX: root.width * 0.52; startY: root.height * 0.6
            PathLine { x: root.width * 0.4; y: root.height * 0.8 }
            PathLine { x: root.width * 0.5; y: root.height * 0.8 }
            PathLine { x: root.width * 0.44; y: root.height * 0.98 }
            PathLine { x: root.width * 0.62; y: root.height * 0.74 }
            PathLine { x: root.width * 0.52; y: root.height * 0.74 }
            PathLine { x: root.width * 0.6; y: root.height * 0.6 }
        }
    }
}
