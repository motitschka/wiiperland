import QtQuick
import QtQuick.Shapes

// One seven-segment digit, like an LCD clock: seven separate bars with
// pointed ends and a hair of space between them.
Item {
    id: root
    property int value: 0
    property color color: "#9b9c9f"
    property real thickness: height * 0.12

    width: height * 0.58

    readonly property var _map: [
        "abcdef", "bc", "abged", "abgcd", "fgbc", "afgcd", "afgecd", "abc", "abcdefg", "abcdfg"
    ]
    readonly property string _on: value >= 0 && value <= 9 ? _map[value] : ""
    readonly property real t: thickness
    readonly property real h2: t / 2
    readonly property real g: t * 0.16            // space between two bars
    readonly property real mid: height / 2

    function lit(name: string): color { return _on.indexOf(name) >= 0 ? color : "transparent" }

    // a horizontal bar on the line y = c, from x = a to x = b
    function hbar(c: real, a: real, b: real): var {
        return [Qt.point(a, c), Qt.point(a + h2, c - h2), Qt.point(b - h2, c - h2), Qt.point(b, c),
                Qt.point(b - h2, c + h2), Qt.point(a + h2, c + h2), Qt.point(a, c)]
    }
    // a vertical bar on the line x = c, from y = a to y = b
    function vbar(c: real, a: real, b: real): var {
        return [Qt.point(c, a), Qt.point(c + h2, a + h2), Qt.point(c + h2, b - h2), Qt.point(c, b),
                Qt.point(c - h2, b - h2), Qt.point(c - h2, a + h2), Qt.point(c, a)]
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath { strokeColor: "transparent"; fillColor: root.lit("a"); PathPolyline { path: root.hbar(root.h2, root.h2 + root.g, root.width - root.h2 - root.g) } }
        ShapePath { strokeColor: "transparent"; fillColor: root.lit("g"); PathPolyline { path: root.hbar(root.mid, root.h2 + root.g, root.width - root.h2 - root.g) } }
        ShapePath { strokeColor: "transparent"; fillColor: root.lit("d"); PathPolyline { path: root.hbar(root.height - root.h2, root.h2 + root.g, root.width - root.h2 - root.g) } }
        ShapePath { strokeColor: "transparent"; fillColor: root.lit("f"); PathPolyline { path: root.vbar(root.h2, root.h2 + root.g, root.mid - root.g) } }
        ShapePath { strokeColor: "transparent"; fillColor: root.lit("b"); PathPolyline { path: root.vbar(root.width - root.h2, root.h2 + root.g, root.mid - root.g) } }
        ShapePath { strokeColor: "transparent"; fillColor: root.lit("e"); PathPolyline { path: root.vbar(root.h2, root.mid + root.g, root.height - root.h2 - root.g) } }
        ShapePath { strokeColor: "transparent"; fillColor: root.lit("c"); PathPolyline { path: root.vbar(root.width - root.h2, root.mid + root.g, root.height - root.h2 - root.g) } }
    }
}
