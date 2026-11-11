import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.services

// The welcome screen: the menu's striped background and bar with one word,
// "Welcome". It shows on the first start of each calendar day and stays
// until you click anywhere or press Enter.
// config.json: "welcomeScreen": true   (the older "startupScreen" still works)
Scope {
    id: root
    property bool shown: false
    onShownChanged: { Cursor.hold("welcome", shown); Music.setHold("welcome", shown) }
    readonly property bool wanted: Config.data.welcomeScreen ?? Config.data.startupScreen ?? true

    // The day it was last shown lives in the state folder, so it survives
    // logging out and rebooting.
    readonly property string stateDir: Messages.stateDir
    readonly property string today: Qt.formatDate(new Date(), "yyyy-MM-dd")
    property string lastShown: ""

    function show(): void { out.opacity = 0; shown = true }
    function dismiss(): void {
        if (!shown || fadeOut.running) return
        Sound.play("start")
        fadeOut.restart()
    }
    function firstStartToday(): void {
        if (lastShown === today) return
        lastShown = today
        Quickshell.execDetached(["sh", "-c", 'mkdir -p "$1" && printf "%s\\n" "$2" > "$1/welcome-date"', "wii-welcome", stateDir, today])
        if (wanted) show()
    }

    FileView {
        path: root.stateDir + "/welcome-date"
        printErrors: false
        onLoaded: { root.lastShown = text().trim(); root.firstStartToday() }
        onLoadFailed: root.firstStartToday()
    }

    IpcHandler {
        target: "welcome"
        // not "show": `qs ipc call <target> show` lists the target instead of calling it
        function open(): void { root.show() }
        function dismiss(): void { root.dismiss() }
        function state(): string { return JSON.stringify({ shown: root.shown, lastShown: root.lastShown, today: root.today }) }
    }
    // the screen's old name, kept so that existing scripts go on working
    IpcHandler {
        target: "startup"
        function dismiss(): void { root.dismiss() }
    }

    PanelWindow {
        id: win
        visible: root.shown
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "wiiperland-welcome"
        WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: Theme.bg
        readonly property real hh: height
        readonly property real barH: hh * 0.27

        Image {
            anchors.fill: parent
            source: Theme.asset("img/stripes.png")
            fillMode: Image.Tile
            smooth: false
        }

        Item {
            anchors.fill: parent
            focus: root.shown
            Keys.onReturnPressed: root.dismiss()
            Keys.onEnterPressed: root.dismiss()
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.dismiss() }

        // the one word, gently breathing
        Text {
            id: word
            anchors.horizontalCenter: parent.horizontalCenter
            y: (win.hh - win.barH) / 2 - height / 2
            text: "Welcome"
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: win.hh * 0.15
            color: Theme.blue
            style: Text.Raised; styleColor: "#ffffff"
            SequentialAnimation on scale {
                running: root.shown; loops: Animation.Infinite
                NumberAnimation { to: 1.025; duration: 1800; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 1800; easing.type: Easing.InOutSine }
            }
        }

        // the bar: the menu's colours and thin blue line, without the recess
        Item {
            id: bar
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
            height: win.barH
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.barTop }
                    GradientStop { position: 1.0; color: Theme.barBottom }
                }
            }
            Image {
                anchors.fill: parent
                source: Theme.asset("img/stripes-bar.png")
                fillMode: Image.Tile; smooth: false
            }
            // soft shadow under the top edge, then the line itself
            Rectangle {
                width: parent.width; height: win.hh * 0.03
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.alpha(Theme.barShade, 0.16) }
                    GradientStop { position: 1.0; color: Qt.alpha(Theme.barShade, 0.0) }
                }
            }
            Rectangle { width: parent.width; height: Math.max(2, win.hh * 0.0045); color: Theme.blueLine }

            Text {
                anchors.centerIn: parent
                text: "Click anywhere or press Enter"
                font.family: Theme.fontBold; font.weight: Font.Bold
                font.pixelSize: win.hh * 0.042
                color: Theme.dateGrey
                SequentialAnimation on opacity {
                    running: root.shown; loops: Animation.Infinite
                    NumberAnimation { to: 0.35; duration: 1000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1; duration: 1000; easing.type: Easing.InOutSine }
                }
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
            ScriptAction { script: { root.shown = false; Menu.arrive() } }
        }
    }
}
