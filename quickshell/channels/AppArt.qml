import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services

// Built-in art for a plain app channel: a full-bleed scene in the channel's
// colour with slow drifting lights and the app's icon floating in the middle.
// The tile shows no name (the name bubble does); the preview adds the name
// and description under the icon.
Item {
    id: root
    required property var channel
    required property var entry      // DesktopEntry or null
    property bool large: false       // preview screen version
    property bool playing: true

    readonly property color tint: channel.color ?? Theme.blue
    readonly property string iconName: channel.icon ?? (entry ? entry.icon : "application-x-executable")
    readonly property string label: channel.name ?? (entry ? entry.name : "Channel")
    // "" when the icon theme doesn't have it; then a drawn glyph is used.
    readonly property string iconSrc: Quickshell.iconPath(iconName, true)
    readonly property string glyph: channel.glyph ?? label.charAt(0).toUpperCase()

    // one slow clock drives everything, so the scene costs one animation
    property real t: 0
    NumberAnimation on t { from: 0; to: 1; duration: 24000; loops: Animation.Infinite; running: root.playing }
    function wave(k: real, phase: real): real { return Math.sin((t * k + phase) * 2 * Math.PI) }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.tint("#ffffff", Qt.alpha(root.tint, 0.16)) }
            GradientStop { position: 0.55; color: Qt.tint("#ffffff", Qt.alpha(root.tint, 0.38)) }
            GradientStop { position: 1.0; color: Qt.tint("#ffffff", Qt.alpha(root.tint, 0.66)) }
        }
    }

    // drifting lights
    Repeater {
        model: [
            { cx: 0.16, cy: 0.30, d: 0.95, k: 1, p: 0.00, a: 0.26 },
            { cx: 0.82, cy: 0.22, d: 0.70, k: 2, p: 0.30, a: 0.22 },
            { cx: 0.70, cy: 0.86, d: 1.10, k: 1, p: 0.55, a: 0.20 },
            { cx: 0.30, cy: 0.90, d: 0.60, k: 3, p: 0.80, a: 0.18 }
        ]
        Rectangle {
            required property var modelData
            width: root.height * modelData.d; height: width; radius: width / 2
            x: root.width * (modelData.cx + 0.05 * root.wave(modelData.k, modelData.p)) - width / 2
            y: root.height * (modelData.cy + 0.07 * root.wave(modelData.k, modelData.p + 0.25)) - height / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.alpha("#ffffff", modelData.a * 1.6) }
                GradientStop { position: 1.0; color: Qt.alpha("#ffffff", 0) }
            }
        }
    }
    // a soft band of light sweeping across
    Rectangle {
        width: root.height * 0.5; height: root.height * 2.4
        x: root.width * (0.5 + 0.75 * root.wave(1, 0.1)) - width / 2
        y: -root.height * 0.7
        rotation: 24
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#00ffffff" }
            GradientStop { position: 0.5; color: "#30ffffff" }
            GradientStop { position: 1.0; color: "#00ffffff" }
        }
    }

    Item {
        id: stage
        readonly property real size: root.height * (root.large ? 0.42 : 0.62)
        width: size; height: size
        x: (root.width - width) / 2
        y: root.height * (root.large ? 0.14 : 0.16) + root.height * 0.018 * root.wave(4, 0)

        // shadow on the "floor": shrinks a little as the icon rises
        Rectangle {
            width: stage.size * (0.62 - 0.04 * root.wave(4, 0)); height: stage.size * 0.09; radius: height / 2
            x: (stage.width - width) / 2
            y: stage.size * 1.04 - root.height * 0.018 * root.wave(4, 0)
            color: Qt.alpha(Qt.darker(root.tint, 1.8), 0.2)
        }
        IconImage {
            anchors.fill: parent
            visible: root.iconSrc !== ""
            source: root.iconSrc
            asynchronous: true
        }
        Rectangle {
            visible: root.iconSrc === ""
            anchors.fill: parent; anchors.margins: parent.width * 0.06
            radius: width * 0.24
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.lighter(root.tint, 1.35) }
                GradientStop { position: 1; color: root.tint }
            }
            border.color: Qt.darker(root.tint, 1.15); border.width: Math.max(1, width * 0.03)
            Text {
                anchors.centerIn: parent
                text: root.glyph
                font.family: Theme.fontBold; font.weight: Font.Bold
                font.pixelSize: parent.height * (root.glyph.length > 1 ? 0.42 : 0.6)
                color: "#ffffff"
                style: Text.Raised; styleColor: Qt.darker(root.tint, 1.4)
            }
        }
    }

    // preview only: name and description
    Column {
        visible: root.large
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.66
        spacing: root.height * 0.012
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: root.height * 0.1
            color: "#ffffff"
            style: Text.Raised; styleColor: Qt.alpha(Qt.darker(root.tint, 1.7), 0.55)
        }
        Text {
            visible: text !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.channel.description ?? (root.entry ? root.entry.comment : "")
            font.family: Theme.fontMedium
            font.pixelSize: root.height * 0.038
            color: Qt.alpha(Qt.darker(root.tint, 2.2), 0.75)
        }
    }
}
