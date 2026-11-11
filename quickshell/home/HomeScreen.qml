import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services

// The Wii Menu: a full-screen surface under all windows.
PanelWindow {
    id: win
    required property var modelData
    screen: modelData

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "wiiperland-home"
    WlrLayershell.keyboardFocus: preview.active || board.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand
    color: Theme.bg

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    // The menu is "open" while this monitor shows workspace 1.
    readonly property bool menuOpen: !monitor || !monitor.activeWorkspace || monitor.activeWorkspace.id === 1
    readonly property real s: height / 720

    // Leaving the menu (e.g. a channel opened) closes any preview instantly.
    // Coming back shows "<brand> Menu" in the recess for a moment.
    onMenuOpenChanged: {
        if (menuOpen) bar.arrive()
        else { if (!preview.busy) preview.reset(); board.open = false }
    }
    Component.onCompleted: if (menuOpen) bar.arrive()

    Connections {
        target: Menu
        function onArrive(): void { if (win.menuOpen) bar.arrive() }
        function onClosePreviews(): void { preview.close(); board.hide() }
        function onOpenBoard(): void { if (win.menuOpen) board.show() }
        function onOpenPreview(slot: int): void {
            if (!win.menuOpen || !Config.channels[slot]) return
            // wait for the page slide so the tile is in place
            openTimer.slot = slot; openTimer.restart()
        }
        function onStartPreview(): void { if (preview.active) preview.start() }
        function onStepPreview(dir: int): void { if (preview.active && !preview.busy) preview.step(dir) }
    }

    Timer {
        id: openTimer
        property int slot: -1
        interval: 480
        onTriggered: {
            const t = grid.tileAt(slot)
            if (t) preview.openFrom(slot, t.mapToItem(menu, 0, 0, t.width, t.height))
        }
    }

    Image {
        anchors.fill: parent
        source: Theme.asset("img/stripes.png")
        fillMode: Image.Tile
        smooth: false
    }

    Item {
        id: menu
        anchors.fill: parent
        opacity: win.menuOpen ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        BottomBar {
            id: bar
            anchors.fill: parent
            opacity: 1 - Math.max(preview.progress, board.progress)
            enabled: !preview.active && !board.open
            unread: Messages.unread
            onHomeClicked: Menu.page = 0
            onMailClicked: board.show()
        }

        // above the bar: the name bubble of a bottom-row tile overlaps it
        ChannelGrid {
            id: grid
            anchors.fill: parent
            hh: win.height
            opacity: 1 - Math.max(preview.progress, board.progress)
            enabled: !preview.active && !board.open
            onActivated: (slot, tile) => preview.openFrom(slot, tile.mapToItem(menu, 0, 0, tile.width, tile.height))
        }

        ChannelPreview {
            id: preview
            anchors.fill: parent
            hh: win.height
        }

        MessageBoard {
            id: board
            anchors.fill: parent
            hh: win.height
        }
    }
}
