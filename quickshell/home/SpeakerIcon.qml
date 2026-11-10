import QtQuick
import QtQuick.Shapes

// Speaker with sound waves (or a cross when muted).
Item {
    id: root
    property color color: "#5a5a5a"
    property bool muted: false
    property real level: 1
    width: 40; height: 32

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: root.color; strokeColor: "transparent"
            startX: 0; startY: root.height * 0.34
            PathLine { x: root.width * 0.2; y: root.height * 0.34 }
            PathLine { x: root.width * 0.44; y: root.height * 0.08 }
            PathLine { x: root.width * 0.44; y: root.height * 0.92 }
            PathLine { x: root.width * 0.2; y: root.height * 0.66 }
            PathLine { x: 0; y: root.height * 0.66 }
        }
        ShapePath {   // waves
            strokeColor: root.muted ? "transparent" : root.color
            strokeWidth: root.width * 0.07; fillColor: "transparent"; capStyle: ShapePath.RoundCap
            startX: root.width * 0.58; startY: root.height * 0.32
            PathArc { x: root.width * 0.58; y: root.height * 0.68; radiusX: root.width * 0.2; radiusY: root.height * 0.22 }
        }
        ShapePath {
            strokeColor: root.muted || root.level < 0.5 ? "transparent" : root.color
            strokeWidth: root.width * 0.07; fillColor: "transparent"; capStyle: ShapePath.RoundCap
            startX: root.width * 0.7; startY: root.height * 0.14
            PathArc { x: root.width * 0.7; y: root.height * 0.86; radiusX: root.width * 0.34; radiusY: root.height * 0.4 }
        }
        ShapePath {   // mute cross
            strokeColor: root.muted ? "#e2574c" : "transparent"
            strokeWidth: root.width * 0.08; fillColor: "transparent"; capStyle: ShapePath.RoundCap
            startX: root.width * 0.62; startY: root.height * 0.3
            PathLine { x: root.width * 0.95; y: root.height * 0.7 }
            PathMove { x: root.width * 0.95; y: root.height * 0.3 }
            PathLine { x: root.width * 0.62; y: root.height * 0.7 }
        }
    }
}
