import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services

// A friendly "click to continue" screen shown once per login, in the spirit
// of the Wii's start-up notice (with its own text).
// config.json: "startupScreen": true
Scope {
    id: root
    property bool shown: false
    onShownChanged: Cursor.hold("startup", shown)
    readonly property bool wanted: Config.data.startupScreen ?? true
    readonly property string marker: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/wiiperland-started-" + (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "x")

    function show(): void { shown = true; out.opacity = 0 }
    function dismiss(): void {
        if (!shown || fadeOut.running) return
        Sound.play("start")
        fadeOut.restart()
    }

    // Only once per Hyprland session: a marker file in the runtime dir.
    FileView {
        path: root.marker
        printErrors: false
        onLoadFailed: {
            if (root.wanted) root.show()
            Quickshell.execDetached(["touch", root.marker])
        }
    }

    IpcHandler {
        target: "startup"
        function show(): void { root.show() }
        function dismiss(): void { root.dismiss() }
    }

    PanelWindow {
        visible: root.shown
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "wiiperland-startup"
        WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: "#ffffff"
        readonly property real hh: height

        Item {
            anchors.fill: parent
            focus: root.shown
            Keys.onPressed: root.dismiss()
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.dismiss() }

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -parent.height * 0.06
            spacing: parent.height * 0.05
            width: parent.width * 0.7

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: parent.parent.height * 0.02
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.parent.parent.height * 0.07; height: width; radius: width / 2
                    color: Theme.blue
                    Text { anchors.centerIn: parent; text: "!"; font.family: Theme.fontBold; font.weight: Font.Bold; font.pixelSize: parent.height * 0.7; color: "#ffffff" }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "HELLO AGAIN"
                    font.family: Theme.fontBold; font.weight: Font.Bold
                    font.pixelSize: parent.parent.parent.height * 0.065
                    font.letterSpacing: 2
                    color: Theme.blue
                }
            }
            Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: parent.width * 0.8; height: 2; color: "#d8eef8" }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                text: "Sit back, get comfy, and remember to look away from\nthe screen and stretch every now and then."
                font.family: Theme.fontMedium
                font.pixelSize: parent.parent.height * 0.036
                lineHeight: 1.3
                color: Theme.darkText
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.8
            text: "Click anywhere or press a key to continue."
            font.family: Theme.fontMedium; font.pixelSize: parent.height * 0.032
            color: Theme.greyText
            SequentialAnimation on opacity {
                running: root.shown; loops: Animation.Infinite
                NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
            }
        }

        // fade to the menu
        Rectangle {
            id: out
            anchors.fill: parent
            color: Theme.bg
            opacity: 0
        }
        SequentialAnimation {
            id: fadeOut
            NumberAnimation { target: out; property: "opacity"; to: 1; duration: 350 }
            ScriptAction { script: root.shown = false }
        }
    }
}
