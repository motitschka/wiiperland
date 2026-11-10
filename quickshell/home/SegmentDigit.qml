import QtQuick

// One thin seven-segment digit with rounded bars, like an LCD clock.
Item {
    id: root
    property int value: 0
    property color color: "#8e8e8e"
    property real thickness: height * 0.085

    width: height * 0.5

    readonly property var _map: [
        "abcdef", "bc", "abged", "abgcd", "fgbc", "afgcd", "afgecd", "abc", "abcdefg", "abcdfg"
    ]
    readonly property string _on: value >= 0 && value <= 9 ? _map[value] : ""
    readonly property real t: thickness
    readonly property real gap: t * 0.55

    component Seg: Rectangle {
        required property string name
        visible: root._on.indexOf(name) >= 0
        color: root.color
        radius: root.t / 2
        antialiasing: true
    }

    // horizontal
    Seg { name: "a"; x: root.gap; y: 0; width: root.width - 2 * root.gap; height: root.t }
    Seg { name: "g"; x: root.gap; y: (root.height - root.t) / 2; width: root.width - 2 * root.gap; height: root.t }
    Seg { name: "d"; x: root.gap; y: root.height - root.t; width: root.width - 2 * root.gap; height: root.t }
    // vertical
    Seg { name: "f"; x: 0; y: root.gap; width: root.t; height: root.height / 2 - root.gap * 1.5 }
    Seg { name: "b"; x: root.width - root.t; y: root.gap; width: root.t; height: root.height / 2 - root.gap * 1.5 }
    Seg { name: "e"; x: 0; y: root.height / 2 + root.gap / 2; width: root.t; height: root.height / 2 - root.gap * 1.5 }
    Seg { name: "c"; x: root.width - root.t; y: root.height / 2 + root.gap / 2; width: root.t; height: root.height / 2 - root.gap * 1.5 }
}
