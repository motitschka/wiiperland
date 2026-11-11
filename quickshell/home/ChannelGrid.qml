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

    // ---- arranging: drag a tile onto another slot to swap them ----------
    property int dragSlot: -1          // the tile being moved, or -1
    property bool carry: false         // picked up with "Move": no button held, click to drop
    property real dragX: 0             // pointer, in this item's coordinates
    property real dragY: 0
    readonly property bool arranging: dragSlot >= 0
    readonly property int dropSlot: arranging ? slotAt(dragX, dragY) : -1
    property int menuSlot: -1          // tile whose right-click bubble is open, or -1

    // The slot of the showing page under x,y (gaps count toward the nearest
    // tile), or -1 outside the grid.
    function slotAt(x: real, y: real): int {
        const col = Math.floor((x - left0 + gap / 2) / pitchX)
        const row = Math.floor((y - gridTop + gap / 2) / pitchY)
        if (col < 0 || col > 3 || row < 0 || row > 2) return -1
        return page * 12 + row * 4 + col
    }
    function slotCentre(slot: int): point {
        return Qt.point(left0 + (slot % 4) * pitchX + tileW / 2, gridTop + Math.floor((slot % 12) / 4) * pitchY + tileH / 2)
    }
    function beginDrag(slot: int, x: real, y: real, carried: bool): void {
        if (!Config.channels[slot]) return
        menuSlot = -1
        dragSlot = slot; dragX = x; dragY = y; carry = carried
        Sound.play("click")
    }
    function endDrag(apply: bool): void {
        if (!arranging) return
        const to = dropSlot
        if (apply && to >= 0 && to !== dragSlot && Config.moveChannel(dragSlot, to)) Sound.play("open")
        else Sound.play("back")
        dragSlot = -1; carry = false
    }
    function openMenu(slot: int): void { if (Config.channels[slot] && !arranging) { menuSlot = slot; Sound.play("tick") } }
    function startCarry(slot: int): void {
        const c = slotCentre(slot)
        beginDrag(slot, c.x, c.y, true)
    }
    signal emptyClicked(int slot)

    // holding the tile at a screen edge flips the page
    Timer {
        interval: 800; repeat: true
        running: root.arranging && (root.dragX < root.width * 0.05 || root.dragX > root.width * 0.95)
        onTriggered: { if (root.dragX < root.width * 0.5) root.prev(); else root.next() }
    }

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
                lifted: root.dragSlot === index
                onEmptyClicked: (slot) => root.emptyClicked(slot)
                onMenuRequested: (slot) => root.openMenu(slot)
                onHeld: (slot, x, y) => { const p = tile.mapToItem(root, x, y); root.beginDrag(slot, p.x, p.y, false) }
                onDragged: (x, y) => { const p = tile.mapToItem(root, x, y); root.dragX = p.x; root.dragY = p.y }
                onDropped: root.endDrag(true)
                onHoveredChanged: {
                    if (hovered) root.hoveredTile = tile
                    else if (root.hoveredTile === tile) root.hoveredTile = null
                }
            }
        }

        NameBubble {
            tile: root.arranging || root.menuSlot >= 0 ? null : root.hoveredTile
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

    // ---- while a tile is being moved --------------------------------------
    // ring on the slot it would land in
    Rectangle {
        visible: root.dropSlot >= 0 && root.dropSlot !== root.dragSlot
        readonly property point c: root.slotCentre(Math.max(0, root.dropSlot))
        x: c.x - width / 2; y: c.y - height / 2
        width: root.tileW + root.hh * 0.016; height: root.tileH + root.hh * 0.016
        radius: root.tileH * 0.14
        color: "#3034beed"
        border.color: Theme.blueHover; border.width: Math.max(2, root.hh * 0.006)
    }
    // carry mode: the pointer moves the tile without a button held
    MouseArea {
        anchors.fill: parent
        visible: root.carry
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: (ev) => { root.dragX = ev.x; root.dragY = ev.y }
        onClicked: (ev) => root.endDrag(ev.button === Qt.LeftButton)
    }
    // the tile itself, under the pointer
    ChannelTile {
        visible: root.arranging
        enabled: false
        width: root.tileW; height: root.tileH
        x: root.dragX - width / 2; y: root.dragY - height / 2
        channel: root.arranging ? Config.channels[root.dragSlot] ?? null : null
        scale: 1.08
        opacity: 0.92
        rotation: -2
    }

    // ---- right-click bubble: Move / Remove --------------------------------
    MouseArea {
        anchors.fill: parent
        visible: root.menuSlot >= 0
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true     // tiles underneath don't light up meanwhile
        onClicked: root.menuSlot = -1
    }
    Rectangle {
        id: bubble
        visible: root.menuSlot >= 0
        readonly property point c: root.slotCentre(Math.max(0, root.menuSlot))
        width: root.hh * 0.26; height: rows.height + root.hh * 0.03
        x: Math.max(root.hh * 0.02, Math.min(root.width - width - root.hh * 0.02, c.x - width / 2))
        y: c.y - root.hh * 0.02
        radius: root.hh * 0.03
        color: "#ffffff"
        border.color: Theme.blueLine; border.width: Math.max(2, root.hh * 0.004)
        Rectangle { z: -1; anchors.fill: parent; anchors.topMargin: root.hh * 0.006; anchors.bottomMargin: -root.hh * 0.006; radius: parent.radius; color: "#26000000" }
        Column {
            id: rows
            anchors.centerIn: parent
            width: parent.width - root.hh * 0.03
            Repeater {
                model: [
                    { label: "Move", run: () => { const s = root.menuSlot; root.startCarry(s) } },
                    { label: "Remove", run: () => { const s = root.menuSlot; root.menuSlot = -1; if (Config.removeChannel(s)) Sound.play("back") } }
                ]
                Rectangle {
                    id: row
                    required property var modelData
                    width: rows.width; height: root.hh * 0.07
                    radius: height / 2
                    color: rowArea.containsMouse ? "#e3f5fd" : "#00ffffff"
                    Text {
                        anchors.centerIn: parent
                        text: row.modelData.label
                        font.family: Theme.fontMedium
                        font.pixelSize: root.hh * 0.04
                        color: rowArea.containsMouse ? Theme.blueDark : Theme.darkText
                    }
                    MouseArea {
                        id: rowArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onContainsMouseChanged: if (containsMouse) Sound.play("tick")
                        onClicked: row.modelData.run()
                    }
                }
            }
        }
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
