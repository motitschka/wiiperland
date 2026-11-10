import QtQuick
import QtQuick.Shapes

// A simple envelope drawn with shapes.
Item {
    id: root
    property color color: "#9c9c9c"
    width: 60; height: 42

    Rectangle {
        anchors.fill: parent
        radius: height * 0.12
        color: root.color
    }
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeColor: "#f4f4f4"; strokeWidth: root.height * 0.09
            fillColor: "transparent"; capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: root.width * 0.08; startY: root.height * 0.14
            PathLine { x: root.width * 0.5; y: root.height * 0.58 }
            PathLine { x: root.width * 0.92; y: root.height * 0.14 }
        }
    }
}
