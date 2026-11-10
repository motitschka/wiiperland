import QtQuick
import qs.services

// Pages of 4×3 channel tiles with arrows; scroll or use arrows to flip.
Item {
    id: root
    property real hh: 720
    readonly property int page: Menu.page
    readonly property int pageCount: Menu.pageCount
    signal activated(var channel, Item tile)

    readonly property real tileH: hh * 0.148
    readonly property real tileW: Math.max(hh * 0.27, Math.min(width * 0.19, hh * 0.33))
    readonly property real gapX: hh * 0.018
    readonly property real gapY: hh * 0.016
    readonly property real gridTop: hh * 0.16

    function next(): void { Menu.next() }
    function prev(): void { Menu.prev() }

    Item {
        id: strip
        width: root.width * root.pageCount; height: root.height
        x: -root.page * root.width
        Behavior on x { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

        Repeater {
            model: root.pageCount
            Grid {
                id: grid
                required property int index
                readonly property int pageIndex: index
                x: pageIndex * root.width + (root.width - width) / 2
                y: root.gridTop
                columns: 4
                columnSpacing: root.gapX; rowSpacing: root.gapY
                Repeater {
                    model: 12
                    ChannelTile {
                        required property int index
                        width: root.tileW; height: root.tileH
                        s: root.hh / 720
                        channel: Config.channels[grid.pageIndex * 12 + index] ?? null
                        onActivated: (ch, tile) => root.activated(ch, tile)
                    }
                }
            }
        }
    }

    PageArrow {
        pointsLeft: false
        width: root.hh * 0.036; height: root.hh * 0.056
        x: root.width - width - root.hh * 0.04
        y: root.gridTop + root.tileH * 1.5 + root.gapY - height / 2
        opacity: root.page < root.pageCount - 1 ? 1 : 0
        visible: opacity > 0
        onClicked: root.next()
    }
    PageArrow {
        pointsLeft: true
        width: root.hh * 0.036; height: root.hh * 0.056
        x: root.hh * 0.04
        y: root.gridTop + root.tileH * 1.5 + root.gapY - height / 2
        opacity: root.page > 0 ? 1 : 0
        visible: opacity > 0
        onClicked: root.prev()
    }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        property real acc: 0
        onWheel: (ev) => {
            acc += ev.angleDelta.y !== 0 ? ev.angleDelta.y : -ev.angleDelta.x
            if (acc <= -120) { root.next(); acc = 0 }
            else if (acc >= 120) { root.prev(); acc = 0 }
        }
    }
}
