import QtQuick
import Quickshell.Widgets
import qs.services
import qs.channels

// The channel preview: the clicked tile grows into a rounded "TV" panel on a
// black screen. The panel shows the channel's art with its name in a blue tab
// at the top right, and a beige band at the bottom with the "<brand> Menu"
// and "Start" pills. Arrows on the sides step through the other channels.
Item {
    id: root
    property real hh: height
    property int slot: -1
    readonly property var channel: slot >= 0 ? Config.channels[slot] ?? null : null
    readonly property bool active: slot >= 0
    property rect fromRect: Qt.rect(0, 0, width, height)
    property real progress: 0          // 0 = tile, 1 = full panel
    readonly property bool busy: anim.running || flash.running
    // Start is greyed out when the channel has nothing to start.
    readonly property bool canStart: Launcher.canStart(channel)

    // The panel at full size: inset a little from the screen edges.
    readonly property rect panelRect: Qt.rect(width * 0.012, height * 0.02, width * 0.976, height * 0.96)
    readonly property real bandShare: 0.235   // of the panel's height

    // The channel's jingle plays while its preview is open: from the moment
    // it opens (or steps to another channel) until it closes or starts.
    property bool leaving: false
    readonly property string jingle: active && !leaving && !flash.running && channel
        ? Assets.jingle(Launcher.label(channel), channel.jingle ?? "") : ""
    onJingleChanged: Sound.jingle(jingle)

    signal finished()

    visible: active
    enabled: active && progress > 0.98 && !flash.running

    function openFrom(s: int, r: rect): void {
        leaving = false; slot = s; fromRect = r
        anim.from = 0; anim.to = 1; anim.restart()
        Sound.play("open")
    }
    function close(): void {
        if (!active || anim.running) return
        leaving = true
        anim.from = progress; anim.to = 0; anim.restart()
        Sound.play("back")
    }
    function reset(): void { anim.stop(); progress = 0; slot = -1; leaving = false; whiteOut.opacity = 0 }
    function start(): void {
        if (!channel || !canStart || flash.running) return
        Sound.play("start")
        flash.restart()
    }
    function step(dir: int): void {
        const n = Menu.neighbour(slot, dir)
        if (n !== slot && n >= 0) { slot = n; Sound.play("page") }
    }

    NumberAnimation {
        id: anim
        target: root; property: "progress"
        duration: 520; easing.type: Easing.InOutCubic
        onFinished: if (root.progress === 0) { root.slot = -1; root.leaving = false; root.finished() }
    }

    function lerp(a: real, b: real): real { return a + (b - a) * progress }

    // the screen goes black around the growing panel
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.progress
    }

    ClippingRectangle {
        id: frame
        x: root.lerp(root.fromRect.x, root.panelRect.x)
        y: root.lerp(root.fromRect.y, root.panelRect.y)
        width: root.lerp(root.fromRect.width, root.panelRect.width)
        height: root.lerp(root.fromRect.height, root.panelRect.height)
        radius: root.lerp(root.fromRect.height * 0.12, root.panelRect.height * 0.078)
        border.color: Theme.tileBorder
        border.width: root.lerp(Math.max(1.5, root.fromRect.height * 0.014), 0)
        contentInsideBorder: true
        color: "#ffffff"

        // The band is there almost from the start of the zoom, so the panel
        // grows as a whole (as in the recording) instead of the band sliding
        // in afterwards.
        readonly property real bandIn: Math.min(1, root.progress * 3)
        readonly property real bandH: height * root.bandShare

        ChannelArt {
            anchors.fill: parent
            anchors.bottomMargin: frame.bandH * frame.bandIn
            channel: root.channel
            large: root.progress > 0.5
            playing: root.active
        }

        // blue title tab, top right
        Item {
            id: tab
            height: frame.height * 0.088
            width: title.implicitWidth + height * 1.5
            x: frame.width - width
            y: frame.height * 0.065
            opacity: Math.max(0, Math.min(1, (root.progress - 0.55) / 0.35))
            Rectangle {
                // runs past the panel's edge, so only the left end is rounded
                width: parent.width + radius; height: parent.height
                radius: height / 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#63cdf3" }
                    GradientStop { position: 1.0; color: "#1c97da" }
                }
                border.color: "#b0ffffff"; border.width: Math.max(1, tab.height * 0.035)
            }
            Rectangle {   // sheen
                x: tab.height * 0.4; y: tab.height * 0.1
                width: parent.width; height: tab.height * 0.36
                radius: height / 2
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#66ffffff" }
                    GradientStop { position: 1.0; color: "#00ffffff" }
                }
            }
            Text {
                id: title
                anchors.verticalCenter: parent.verticalCenter
                x: tab.height * 0.75
                text: Launcher.label(root.channel)
                font.family: Theme.fontBold; font.weight: Font.Bold
                font.pixelSize: tab.height * 0.56
                color: "#ffffff"
                style: Text.Raised; styleColor: "#14679c"
            }
        }

        // beige band with the two pills
        Item {
            id: band
            width: frame.width; height: frame.bandH
            y: frame.height - height * frame.bandIn

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#e9e7df" }
                    GradientStop { position: 1.0; color: "#d7d5cb" }
                }
            }
            Image {   // the same fine stripes as the menu, very faint
                anchors.fill: parent
                source: Theme.asset("img/stripes.png")
                fillMode: Image.Tile; smooth: false
                opacity: 0.25
            }
            Rectangle { width: parent.width; height: Math.max(1, band.height * 0.012); color: "#b9b7ac" }
            Rectangle { y: Math.max(1, band.height * 0.012); width: parent.width; height: Math.max(1, band.height * 0.012); color: "#99ffffff" }

            Row {
                anchors.centerIn: parent
                spacing: frame.width * 0.045
                PillButton {
                    width: frame.width * 0.29; height: frame.height * 0.148
                    text: Config.brand + " Menu"
                    onClicked: root.close()
                }
                PillButton {
                    width: frame.width * 0.29; height: frame.height * 0.148
                    text: Launcher.isRunning(root.channel) ? "Resume" : "Start"
                    available: root.canStart
                    onClicked: root.start()
                }
            }
        }
    }

    // side arrows, just inside the panel
    PageArrow {
        pointsLeft: true
        width: root.hh * 0.05; height: root.hh * 0.092
        x: root.panelRect.x + root.width * 0.016
        y: root.panelRect.y + root.panelRect.height * 0.38 - height / 2
        opacity: root.progress > 0.98 ? 1 : 0
        onClicked: root.step(-1)
    }
    PageArrow {
        width: root.hh * 0.05; height: root.hh * 0.092
        x: root.panelRect.x + root.panelRect.width - root.width * 0.016 - width
        y: root.panelRect.y + root.panelRect.height * 0.38 - height / 2
        opacity: root.progress > 0.98 ? 1 : 0
        onClicked: root.step(1)
    }

    // fade to white, launch, then quietly reset behind the new window
    Rectangle {
        id: whiteOut
        anchors.fill: parent
        color: "#ffffff"
        opacity: 0
    }
    SequentialAnimation {
        id: flash
        NumberAnimation { target: whiteOut; property: "opacity"; from: 0; to: 1; duration: 260; easing.type: Easing.InQuad }
        ScriptAction { script: Launcher.start(root.channel) }
        PauseAnimation { duration: 450 }
        ScriptAction { script: { root.reset(); root.finished() } }
    }

    focus: active
    Keys.onEscapePressed: close()
    Keys.onReturnPressed: start()
    Keys.onEnterPressed: start()
    Keys.onLeftPressed: step(-1)
    Keys.onRightPressed: step(1)
}
