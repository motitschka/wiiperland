import QtQuick
import Quickshell.Widgets
import qs.services
import qs.channels

// The channel preview: the clicked tile zooms up to fill the screen, a panel
// with "<brand> Menu" and "Start" rises from the bottom, and arrows on the
// sides step through the other channels.
Item {
    id: root
    property real hh: height
    property int slot: -1
    readonly property var channel: slot >= 0 ? Config.channels[slot] ?? null : null
    readonly property bool active: slot >= 0
    property rect fromRect: Qt.rect(0, 0, width, height)
    property real progress: 0          // 0 = tile, 1 = full screen
    readonly property bool busy: anim.running || flash.running

    signal finished()

    visible: active
    enabled: active && progress > 0.98 && !flash.running

    function openFrom(s: int, r: rect): void {
        slot = s; fromRect = r
        anim.from = 0; anim.to = 1; anim.restart()
        Sound.play("open")
    }
    function close(): void {
        if (!active || anim.running) return
        anim.from = progress; anim.to = 0; anim.restart()
        Sound.play("back")
    }
    function reset(): void { anim.stop(); progress = 0; slot = -1; whiteOut.opacity = 0 }
    function start(): void {
        if (!channel || flash.running) return
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
        onFinished: if (root.progress === 0) { root.slot = -1; root.finished() }
    }

    function lerp(a: real, b: real): real { return a + (b - a) * progress }

    // dim/white backdrop behind the growing tile
    Rectangle {
        anchors.fill: parent
        color: "#f6f6f6"
        opacity: root.progress
    }

    ClippingRectangle {
        id: frame
        x: root.lerp(root.fromRect.x, 0)
        y: root.lerp(root.fromRect.y, 0)
        width: root.lerp(root.fromRect.width, root.width)
        height: root.lerp(root.fromRect.height, root.height)
        radius: root.lerp(root.fromRect.height * 0.16, 0)
        border.color: Theme.tileBorder
        border.width: root.lerp(Math.max(1.5, root.fromRect.height * 0.022), 0)
        contentInsideBorder: true
        color: "#ffffff"

        ChannelArt {
            anchors.fill: parent
            anchors.bottomMargin: parent.height * 0.2 * root.progress
            channel: root.channel
            large: root.progress > 0.5
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    // bottom panel
    Item {
        id: panel
        width: parent.width; height: root.hh * 0.2
        y: parent.height - height * root.progress
        opacity: Math.max(0, root.progress * 2 - 1)

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#f2f2f2" }
                GradientStop { position: 1.0; color: "#d4d5d7" }
            }
            Rectangle { width: parent.width; height: Math.max(2, root.hh * 0.005); color: Theme.blue }
            Rectangle { y: Math.max(2, root.hh * 0.005); width: parent.width; height: 1; color: "#ccffffff" }
        }
        Row {
            anchors.centerIn: parent
            spacing: root.hh * 0.12
            PillButton { hh: root.hh; text: Config.brand + " Menu"; onClicked: root.close() }
            PillButton { hh: root.hh; text: Launcher.isRunning(root.channel) ? "Resume" : "Start"; onClicked: root.start() }
        }
    }

    // side arrows
    PageArrow {
        pointsLeft: true
        width: root.hh * 0.045; height: root.hh * 0.07
        x: root.hh * 0.05; y: root.height * 0.4 - height / 2
        opacity: root.progress > 0.98 ? 1 : 0
        onClicked: root.step(-1)
    }
    PageArrow {
        width: root.hh * 0.045; height: root.hh * 0.07
        x: root.width - width - root.hh * 0.05; y: root.height * 0.4 - height / 2
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
