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
    color: Theme.bg

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
    // The menu is "open" while this monitor shows workspace 1.
    readonly property bool menuOpen: !monitor || !monitor.activeWorkspace || monitor.activeWorkspace.id === 1
    readonly property real s: height / 720

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

        ChannelGrid {
            id: grid
            anchors.fill: parent
            hh: win.height
            onActivated: (ch, tile) => console.log("activate", ch.name)
        }

        BottomBar {
            anchors.fill: parent
            unread: 0
            onHomeClicked: console.log("home clicked")
            onMailClicked: console.log("mail clicked")
        }
    }
}
