import QtQuick
import qs.services

// The white speech bubble with the channel's name that pops up just under a
// hovered tile. It lives in the same coordinates as the tiles.
Item {
    id: root
    property Item tile: null           // the hovered tile, or null
    property real hh: 720
    property real viewLeft: 0          // the visible span, in the parent's coordinates
    property real viewRight: 0

    property Item anchorTile: null     // stays set while the bubble fades out
    property string text: ""
    property bool shown: false
    // While fading out the bubble keeps the span it was placed in, so it
    // slides away with its tile when the page flips instead of clinging to
    // the screen edge.
    property real heldLeft: 0
    property real heldRight: 0
    readonly property real spanLeft: tile ? viewLeft : heldLeft
    readonly property real spanRight: tile ? viewRight : heldRight
    onTileChanged: {
        if (tile) { anchorTile = tile; text = tile.label; appear.restart() }
        else { heldLeft = viewLeft; heldRight = viewRight; appear.stop(); shown = false }
    }
    Timer { id: appear; interval: 80; onTriggered: root.shown = true }

    readonly property real edge: (spanRight - spanLeft) * 0.069   // keep this far from the screen edges
    width: Math.min(label.implicitWidth + hh * 0.13, (spanRight - spanLeft) * 0.36)
    height: hh * 0.085
    x: anchorTile ? Math.max(spanLeft + edge, Math.min(spanRight - edge - width,
                                                       anchorTile.x + anchorTile.width / 2 - width / 2)) : 0
    y: anchorTile ? anchorTile.y + anchorTile.height + hh * 0.019 : 0

    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.88
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: 130 } }
    Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutBack } }

    // soft shadow
    Repeater {
        model: 3
        Rectangle {
            required property int index
            readonly property real grow: root.hh * 0.003 * (index + 1)
            x: -grow; y: -grow + root.hh * 0.005
            width: root.width + grow * 2; height: root.height + grow * 2
            radius: height / 2
            color: "#12000000"
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: "#ffffff"
        border.color: "#dcdde1"; border.width: Math.max(1, root.hh * 0.0015)
    }
    Text {
        id: label
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width - root.hh * 0.1)
        elide: Text.ElideRight
        text: root.text
        font.family: Theme.fontMedium
        font.pixelSize: root.hh * 0.054
        color: "#56575b"
    }
}
