import Quickshell
import Quickshell.Wayland
import QtQuick

// Test helper, started by dev/nested.sh: an invisible 4×4 surface in the
// top-left corner of every screen. dev/hover.sh parks the pointer on it
// before each move so that the shell sees the pointer arrive; see
// docs/development.md.
ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors { top: true; left: true }
            implicitWidth: 4; implicitHeight: 4
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "wiiperland-dev-park"
            color: "transparent"
        }
    }
}
