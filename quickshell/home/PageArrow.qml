import QtQuick
import QtQuick.Shapes
import qs.services

// Page arrow: a pale-cyan arrowhead with a hollowed back and a thin darker
// edge.
Item {
    id: root
    property bool pointsLeft: false
    // How far the click area reaches behind the arrow, toward the page it
    // sits next to. The grid shortens it so that it ends where the tiles begin.
    property real hitBack: width * 0.5
    readonly property real hoverScale: 1.12
    signal clicked()
    width: 34; height: 58
    readonly property bool hovered: mouse.containsMouse
    onHoveredChanged: if (hovered) Sound.play("tick")
    scale: mouse.pressed ? 0.92 : hovered ? hoverScale : 1
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
    Behavior on opacity { NumberAnimation { duration: 200 } }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        transform: Scale { origin.x: root.width / 2; xScale: root.pointsLeft ? -1 : 1 }
        // faint white edge so the arrow still reads on a darker background
        ShapePath {
            strokeColor: "#50ffffff"; strokeWidth: root.width * 0.16
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"
            startX: root.width * 0.1; startY: root.height * 0.04
            PathLine { x: root.width * 0.94; y: root.height * 0.5 }
            PathLine { x: root.width * 0.1; y: root.height * 0.96 }
            PathQuad { x: root.width * 0.1; y: root.height * 0.04; controlX: root.width * 0.34; controlY: root.height * 0.5 }
        }
        ShapePath {
            strokeColor: root.hovered ? Theme.blueDark : "#3592bb"; strokeWidth: root.width * 0.06
            joinStyle: ShapePath.RoundJoin
            fillGradient: LinearGradient {
                x1: 0; y1: 0; x2: root.width; y2: root.height
                GradientStop { position: 0; color: "#d2f8ff" }
                GradientStop { position: 0.5; color: "#90e6fb" }
                GradientStop { position: 1; color: "#5fcaeb" }
            }
            startX: root.width * 0.1; startY: root.height * 0.04
            PathLine { x: root.width * 0.94; y: root.height * 0.5 }
            PathLine { x: root.width * 0.1; y: root.height * 0.96 }
            PathQuad { x: root.width * 0.1; y: root.height * 0.04; controlX: root.width * 0.34; controlY: root.height * 0.5 }
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent; anchors.margins: -root.width * 0.5
        anchors.leftMargin: root.pointsLeft ? -root.width * 0.5 : -root.hitBack
        anchors.rightMargin: root.pointsLeft ? -root.hitBack : -root.width * 0.5
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
