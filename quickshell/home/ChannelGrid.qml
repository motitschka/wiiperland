import QtQuick
import qs.services

// The channel grid: one continuous strip of tiles, four columns and three
// rows to a page. The screen is a little wider than a page, so the first or
// last column of the neighbouring pages peeks in at the edges; clicking a
// peeking tile, an arrow, or scrolling flips the page.
Item {
    id: root
    property real hh: 720
    readonly property int page: Menu.page
    readonly property int pageCount: Menu.pageCount
    signal activated(int slot, Item tile)

    // Heights follow the screen height, widths the screen width, so the grid
    // runs almost edge to edge on any screen. Very wide screens cap the tile
    // width and simply show more of the neighbours.
    readonly property real tileH: hh * 0.189
    readonly property real tileW: Math.min(width * 0.2005, tileH * 2.1)
    readonly property real gap: hh * 0.0217
    readonly property real gridTop: hh * 0.088
    readonly property real pitchX: tileW + gap
    readonly property real pitchY: tileH + gap
    readonly property real pageW: 4 * pitchX
    readonly property real left0: (width - 4 * tileW - 3 * gap) / 2

    property Item hoveredTile: null

    function tileAt(slot: int): Item { return tiles.itemAt(slot) }
    function next(): void { Menu.next() }
    function prev(): void { Menu.prev() }

    Item {
        id: strip
        x: -root.page * root.pageW
        Behavior on x { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

        Repeater {
            id: tiles
            model: root.pageCount * 12
            ChannelTile {
                id: tile
                required property int index
                readonly property int pg: Math.floor(index / 12)
                x: root.left0 + (pg * 4 + index % 4) * root.pitchX
                y: root.gridTop + Math.floor((index % 12) / 4) * root.pitchY
                width: root.tileW; height: root.tileH
                slot: index
                channel: Config.channels[index] ?? null
                current: pg === root.page
                onActivated: (slot, t) => root.activated(slot, t)
                onFlip: Menu.page = pg
                onHoveredChanged: {
                    if (hovered) root.hoveredTile = tile
                    else if (root.hoveredTile === tile) root.hoveredTile = null
                }
            }
        }

        NameBubble {
            tile: root.hoveredTile
            hh: root.hh
            viewLeft: -strip.x
            viewRight: -strip.x + root.width
        }
    }

    // Arrows over the peeking columns, a little above the middle row's centre.
    // They keep clear of the current page: on narrow screens they move
    // outward, and even when hovered (and so a little bigger) their click
    // area ends where the page's tiles begin.
    readonly property real arrowW: hh * 0.057
    readonly property real arrowC: Math.max(arrowW * 0.6, Math.min(hh * 0.083, left0 - arrowW * 0.56 - hh * 0.004))   // centre, from the screen edge
    readonly property real arrowBack: Math.max(0, Math.min(arrowW * 0.5, (left0 - arrowC) / nextArrow.hoverScale - arrowW / 2))

    PageArrow {
        id: nextArrow
        pointsLeft: false
        width: root.arrowW; height: root.hh * 0.096
        x: root.width - root.arrowC - width / 2
        hitBack: root.arrowBack
        y: root.gridTop + root.tileH * 1.5 + root.gap - height / 2 - root.hh * 0.009
        opacity: root.page < root.pageCount - 1 ? 1 : 0
        visible: opacity > 0
        onClicked: root.next()
    }
    PageArrow {
        pointsLeft: true
        width: root.arrowW; height: root.hh * 0.096
        x: root.arrowC - width / 2
        hitBack: root.arrowBack
        y: root.gridTop + root.tileH * 1.5 + root.gap - height / 2 - root.hh * 0.009
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
