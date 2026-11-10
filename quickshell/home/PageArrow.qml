import QtQuick
import QtQuick.Shapes
import qs.services

// Blue triangular page arrow with a white outline.
Item {
    id: root
    property bool pointsLeft: false
    signal clicked()
    width: 34; height: 48
    scale: mouse.pressed ? 0.9 : mouse.containsMouse ? 1.15 : 1
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
    Behavior on opacity { NumberAnimation { duration: 200 } }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        transform: Scale { origin.x: root.width / 2; xScale: root.pointsLeft ? -1 : 1 }
        ShapePath {
            strokeColor: "#ffffff"; strokeWidth: root.width * 0.16
            joinStyle: ShapePath.RoundJoin
            fillGradient: LinearGradient {
                x1: 0; y1: 0; x2: 0; y2: root.height
                GradientStop { position: 0; color: Theme.blueLight }
                GradientStop { position: 1; color: Theme.blueDark }
            }
            startX: root.width * 0.18; startY: root.height * 0.12
            PathLine { x: root.width * 0.86; y: root.height * 0.5 }
            PathLine { x: root.width * 0.18; y: root.height * 0.88 }
            PathLine { x: root.width * 0.18; y: root.height * 0.12 }
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent; anchors.margins: -root.width * 0.4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
