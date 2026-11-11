import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower
import qs.services
import qs.home

// The HOME Menu: available everywhere with SUPER+ESC. The screen dims, a top
// bar slides down, two big buttons pop in and a bottom bar with volume,
// battery and power options slides up.
Scope {
    id: root
    property bool open: false
    onOpenChanged: Cursor.hold("homemenu", open)

    function toggle(): void { open ? close() : show() }
    function show(): void { open = true; Sound.play("home") }
    function close(): void { if (open) { open = false; Sound.play("back") } }

    function run(cmd: list<string>): void { Quickshell.execDetached(cmd) }
    readonly property string wii: Quickshell.shellDir + "/../bin/wii"

    IpcHandler {
        target: "homemenu"
        function toggle(): void { root.toggle() }
        function open(): void { root.show() }
        function close(): void { root.close() }
    }

    PanelWindow {
        id: win
        screen: Quickshell.screens.find(s => s.name === Hypr.focusedMonitorName) ?? Quickshell.screens[0]
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "wiiperland-homemenu"
        WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: "transparent"
        visible: root.open || p.progress > 0

        readonly property real hh: height
        QtObject {
            id: p
            property real progress: root.open ? 1 : 0
            Behavior on progress { NumberAnimation { duration: 360; easing.type: Easing.OutCubic } }
        }

        // dim backdrop (Hyprland blurs what's behind it); click to close
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.45 * p.progress
            MouseArea { anchors.fill: parent; onClicked: root.close() }
        }

        // top bar
        Rectangle {
            id: top
            width: parent.width; height: win.hh * 0.13
            y: -height * (1 - p.progress)
            gradient: Gradient {
                GradientStop { position: 0; color: "#ee2b2f33" }
                GradientStop { position: 1; color: "#ee44494f" }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: Math.max(2, win.hh * 0.005); color: Theme.blue }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                x: win.hh * 0.06
                text: "HOME Menu"
                font.family: Theme.fontBold; font.weight: Font.Bold
                font.pixelSize: win.hh * 0.045
                color: "#ffffff"
            }
            BarButton {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right; anchors.rightMargin: win.hh * 0.05
                hh: win.hh; label: "✕  Close"
                onClicked: root.close()
            }
        }

        // big buttons
        Row {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -win.hh * 0.04
            spacing: win.hh * 0.07
            scale: 0.85 + 0.15 * p.progress
            opacity: p.progress
            BigButton {
                hh: win.hh; text: Config.brand + " Menu"
                onClicked: { root.close(); root.run([root.wii, "home"]) }
            }
            BigButton {
                hh: win.hh; text: "Close Channel"
                enabled: Hypr.activeWorkspace !== 1
                onClicked: { root.close(); root.run(["hyprctl", "dispatch", "hl.dsp.window.close()"]) }
            }
        }

        // bottom bar
        Rectangle {
            id: bottom
            width: parent.width; height: win.hh * 0.24
            y: parent.height - height * p.progress
            gradient: Gradient {
                GradientStop { position: 0; color: "#ee44494f" }
                GradientStop { position: 1; color: "#ee2b2f33" }
            }
            Rectangle { width: parent.width; height: Math.max(2, win.hh * 0.005); color: Theme.blue }

            Row {
                anchors.centerIn: parent
                spacing: win.hh * 0.045

                // volume
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: win.hh * 0.012
                    Text { text: "Volume"; font.family: Theme.fontMedium; font.pixelSize: win.hh * 0.026; color: "#d8dde2" }
                    Row {
                        spacing: win.hh * 0.02
                        BarButton {
                            hh: win.hh; square: true; onClicked: Audio.toggleMute()
                            SpeakerIcon { anchors.centerIn: parent; width: parent.height * 0.5; height: parent.height * 0.42; color: "#ffffff"; muted: Audio.muted; level: Audio.volume }
                        }
                        WiiSlider {
                            anchors.verticalCenter: parent.verticalCenter
                            hh: win.hh
                            width: win.hh * 0.24
                            value: Audio.volume
                            onMoved: v => Audio.setVolume(v)
                        }
                    }
                }

                // menu music: its own mute and level, saved to config.json
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: win.hh * 0.012
                    Text { text: "Menu music"; font.family: Theme.fontMedium; font.pixelSize: win.hh * 0.026; color: "#d8dde2" }
                    Row {
                        spacing: win.hh * 0.02
                        BarButton {
                            hh: win.hh; square: true; onClicked: Music.setEnabled(!Music.enabled)
                            Text {
                                anchors.centerIn: parent
                                text: "♪"
                                font.pixelSize: parent.height * 0.5
                                color: "#ffffff"; opacity: Music.enabled ? 1 : 0.35
                            }
                            // struck through when off
                            Rectangle {
                                visible: !Music.enabled
                                anchors.centerIn: parent
                                width: parent.height * 0.6; height: Math.max(2, parent.height * 0.05); radius: height / 2
                                color: "#ffffff"; rotation: -40
                            }
                        }
                        WiiSlider {
                            anchors.verticalCenter: parent.verticalCenter
                            hh: win.hh
                            width: win.hh * 0.2
                            opacity: Music.enabled ? 1 : 0.4
                            value: Music.volume
                            onMoved: v => Music.setVolume(v)
                        }
                    }
                }

                // battery (laptops)
                Column {
                    visible: UPower.displayDevice && UPower.displayDevice.isLaptopBattery
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: win.hh * 0.012
                    Text { text: "Battery"; font.family: Theme.fontMedium; font.pixelSize: win.hh * 0.026; color: "#d8dde2" }
                    Battery { hh: win.hh }
                }

                // power
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: win.hh * 0.012
                    Text { text: "Power"; font.family: Theme.fontMedium; font.pixelSize: win.hh * 0.026; color: "#d8dde2" }
                    Row {
                        spacing: win.hh * 0.015
                        BarButton { hh: win.hh; label: "Lock"; onClicked: { root.close(); root.run([root.wii, "lock"]) } }
                        BarButton { hh: win.hh; label: "Log Out"; confirm: true; onClicked: root.run(["hyprctl", "dispatch", "hl.dsp.exit()"]) }
                        BarButton { hh: win.hh; label: "Restart"; confirm: true; onClicked: root.run(["systemctl", "reboot"]) }
                        BarButton { hh: win.hh; label: "Shut Down"; confirm: true; onClicked: root.run(["systemctl", "poweroff"]) }
                    }
                }
            }
        }

        Item {
            focus: root.open
            Keys.onEscapePressed: root.close()
        }
    }

    // --- pieces ---------------------------------------------------------

    component BigButton: Item {
        id: bb
        property real hh: 720
        property string text
        signal clicked()
        width: hh * 0.36; height: hh * 0.15
        opacity: enabled ? 1 : 0.45
        readonly property bool hovered: ma.containsMouse && enabled
        onHoveredChanged: if (hovered) Sound.play("tick")
        scale: ma.pressed ? 0.96 : hovered ? 1.04 : 1
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
        Rectangle {
            anchors.fill: parent; anchors.margins: -bb.hh * 0.008
            radius: bb.hh * 0.04; color: "transparent"
            border.color: Theme.blue; border.width: bb.hh * 0.007
            opacity: bb.hovered ? 0.9 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
        Rectangle {
            anchors.fill: parent
            radius: bb.hh * 0.035
            gradient: Gradient {
                GradientStop { position: 0; color: "#ffffff" }
                GradientStop { position: 0.5; color: "#eceef0" }
                GradientStop { position: 1; color: "#d2d6da" }
            }
            border.color: "#aab1b8"; border.width: Math.max(1.5, bb.hh * 0.003)
            Text {
                anchors.centerIn: parent
                text: bb.text
                font.family: Theme.fontBold; font.weight: Font.Bold
                font.pixelSize: bb.hh * 0.038
                color: bb.hovered ? Theme.blueDark : Theme.darkText
            }
        }
        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { Sound.play("click"); bb.clicked() } }
    }

    component BarButton: Item {
        id: btn
        property real hh: 720
        property string label
        property bool square: false
        property bool confirm: false     // needs a second click within 3 s
        property bool armed: false
        signal clicked()
        width: square ? height : Math.max(hh * 0.13, txt.implicitWidth + hh * 0.05)
        height: hh * 0.058
        readonly property bool hovered: ma.containsMouse
        onHoveredChanged: if (hovered) Sound.play("tick")
        Timer { id: disarm; interval: 3000; onTriggered: btn.armed = false }
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: btn.armed ? "#e2574c" : btn.hovered ? "#5a6168" : "#3a3f45"
            border.color: btn.armed ? "#ff8a80" : btn.hovered ? Theme.blue : "#6b737b"
            border.width: Math.max(1.5, btn.hh * 0.003)
            Text {
                id: txt
                anchors.centerIn: parent
                text: btn.armed ? "Sure?" : btn.label
                font.family: Theme.fontMedium; font.pixelSize: btn.hh * 0.024
                color: "#ffffff"
            }
        }
        MouseArea {
            id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: {
                Sound.play("click")
                if (btn.confirm && !btn.armed) { btn.armed = true; disarm.restart(); return }
                btn.armed = false
                btn.clicked()
            }
        }
    }

    component WiiSlider: Item {
        id: sl
        property real hh: 720
        property real value: 0
        signal moved(real v)
        width: hh * 0.32; height: hh * 0.05
        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: sl.hh * 0.014; radius: height / 2
            color: "#23272b"; border.color: "#5d656d"; border.width: 1
            Rectangle {
                width: Math.max(height, parent.width * sl.value); height: parent.height; radius: height / 2
                gradient: Gradient { orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Theme.blueDark }
                    GradientStop { position: 1; color: Theme.blueLight }
                }
            }
        }
        Rectangle {
            width: sl.hh * 0.04; height: width; radius: width / 2
            x: (sl.width - width) * sl.value; anchors.verticalCenter: parent.verticalCenter
            gradient: Gradient {
                GradientStop { position: 0; color: "#ffffff" }
                GradientStop { position: 1; color: "#cfd4d9" }
            }
            border.color: Theme.blue; border.width: Math.max(1.5, width * 0.08)
        }
        MouseArea {
            anchors.fill: parent; anchors.margins: -sl.hh * 0.01
            cursorShape: Qt.PointingHandCursor
            function set(mx: real): void { sl.moved(Math.max(0, Math.min(1, mx / sl.width))) }
            onPressed: m => set(m.x)
            onPositionChanged: m => { if (pressed) set(m.x) }
        }
    }

    component Battery: Row {
        property real hh: 720
        readonly property var dev: UPower.displayDevice
        spacing: hh * 0.012
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: hh * 0.09; height: hh * 0.045; radius: height * 0.2
            color: "transparent"; border.color: "#d8dde2"; border.width: 2
            Rectangle {
                x: 4; y: 4; height: parent.height - 8; radius: 2
                width: (parent.width - 8) * (dev ? dev.percentage : 0)
                color: dev && dev.percentage < 0.2 ? "#e2574c" : Theme.blue
            }
            Rectangle { x: parent.width; anchors.verticalCenter: parent.verticalCenter; width: 4; height: parent.height * 0.4; color: "#d8dde2"; radius: 1 }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: dev ? Math.round(dev.percentage * 100) + "%" : ""
            font.family: Theme.fontMedium; font.pixelSize: hh * 0.028; color: "#ffffff"
        }
    }
}
