import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.services
import qs.home

// Wii-style volume indicator: a speaker and ten blue bars, bottom centre.
Scope {
    id: root
    property string kind: ""
    property bool shown: false

    function show(k: string): void { kind = k; shown = true; hideTimer.restart() }
    Timer { id: hideTimer; interval: 1500; onTriggered: root.shown = false }

    // pop up by itself when the volume changes (keys, other apps)
    Connections {
        target: Audio
        function onVolumeChanged(): void { if (Audio.ready && !initTimer.running) root.show("volume") }
        function onMutedChanged(): void { if (Audio.ready && !initTimer.running) root.show("volume") }
    }
    Timer { id: initTimer; interval: 2000; running: true }

    PanelWindow {
        id: win
        visible: root.shown || card.opacity > 0
        screen: Quickshell.screens.find(s => s.name === Hypr.focusedMonitorName) ?? Quickshell.screens[0]
        anchors { bottom: true }
        margins.bottom: hh * 0.08
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "wiiperland-osd"
        color: "transparent"
        readonly property real hh: screen ? screen.height : 720
        implicitWidth: hh * 0.42; implicitHeight: hh * 0.1
        mask: Region {}

        Rectangle {
            id: card
            anchors.fill: parent
            radius: height / 2
            opacity: root.shown ? 1 : 0
            scale: root.shown ? 1 : 0.9
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            gradient: Gradient {
                GradientStop { position: 0; color: "#f8ffffff" }
                GradientStop { position: 1; color: "#f0e6eaee" }
            }
            border.color: Theme.blue; border.width: Math.max(2, height * 0.04)

            Row {
                anchors.centerIn: parent
                spacing: card.height * 0.18
                SpeakerIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    width: card.height * 0.42; height: card.height * 0.34
                    muted: Audio.muted; level: Audio.volume
                    color: Theme.darkText
                }
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: card.height * 0.07
                    Repeater {
                        model: 10
                        Rectangle {
                            required property int index
                            anchors.bottom: parent.bottom
                            width: card.height * 0.13
                            height: card.height * (0.22 + index * 0.04)
                            radius: width / 3
                            readonly property bool lit: !Audio.muted && Audio.volume * 10 > index + 0.01
                            color: lit ? Theme.blue : "#d3d8dd"
                            border.color: lit ? Theme.blueDark : "#c2c8ce"; border.width: 1
                        }
                    }
                }
            }
        }
    }
}
