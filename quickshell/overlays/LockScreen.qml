import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.services
import qs.home

// Session lock in the Wii Menu style: big segment clock, date, a rounded
// password field. Uses PAM to check the password.
// config.json: "lock": { "idleMinutes": 10 }   (0 = never lock on idle)
Scope {
    id: root
    property bool locked: false
    onLockedChanged: { Cursor.hold("lock", locked); Music.setHold("lock", locked) }
    property string password: ""
    property string message: ""
    property bool failed: false
    readonly property string user: Quickshell.env("USER") ?? ""
    readonly property int idleMinutes: Config.data.lock?.idleMinutes ?? 10

    signal shake()

    function lock(): void { if (!locked) { password = ""; message = ""; failed = false; locked = true } }

    function submit(): void {
        if (pam.active || password === "") return
        message = ""; failed = false
        pam.start()
    }

    PamContext {
        id: pam
        user: root.user
        onResponseRequiredChanged: if (responseRequired) { respond(root.password); root.password = "" }
        onPamMessage: if (messageIsError) root.message = message
        onCompleted: result => {
            if (result === PamResult.Success) {
                root.locked = false
                Sound.play("start")
            } else {
                root.failed = true
                root.message = "That didn't work. Try again."
                root.shake()
                Sound.play("back")
            }
        }
        onError: err => { root.failed = true; root.message = "Couldn't check the password (" + PamError.toString(err) + ")" }
    }

    IdleMonitor {
        enabled: root.idleMinutes > 0 && !root.locked
        timeout: root.idleMinutes * 60
        respectInhibitors: true
        onIsIdleChanged: if (isIdle) root.lock()
    }

    IpcHandler {
        target: "lock"
        function lock(): void { root.lock() }
        function isLocked(): bool { return root.locked }
        // Only for the nested dev session, where there is no real user to type.
        function devUnlock(): void { if (Quickshell.env("WIIPERLAND_DEV_MODE")) root.locked = false }
    }

    WlSessionLock {
        locked: root.locked

        WlSessionLockSurface {
            id: surface
            color: Theme.bg
            readonly property real hh: height

            Image {
                anchors.fill: parent
                source: Theme.asset("img/stripes.png")
                fillMode: Image.Tile
                smooth: false
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                y: surface.hh * 0.2
                spacing: surface.hh * 0.03

                // The clock itself has no width (its x is the colon), and a
                // Column leaves out items without one, so it gets a box that
                // is as wide as the whole clock and is centred as a whole.
                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: lockClock.leftExtent + lockClock.rightExtent
                    height: lockClock.height
                    SegmentClock {
                        id: lockClock
                        x: leftExtent
                        digitHeight: surface.hh * 0.12
                        color: Theme.greyText
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Time.now, "dddd, MMMM d")
                    font.family: Theme.font; font.pixelSize: surface.hh * 0.035
                    color: Theme.greyText
                }
            }

            Column {
                id: form
                anchors.horizontalCenter: parent.horizontalCenter
                y: surface.hh * 0.56
                spacing: surface.hh * 0.025

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: surface.hh * 0.02
                    Rectangle {
                        width: surface.hh * 0.06; height: width; radius: width / 2
                        color: "#ffffff"; border.color: Theme.blue; border.width: Math.max(2, width * 0.06)
                        Text { anchors.centerIn: parent; text: root.user.charAt(0).toUpperCase(); font.family: Theme.fontBold; font.weight: Font.Bold; font.pixelSize: parent.height * 0.5; color: Theme.blue }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.user
                        font.family: Theme.fontMedium; font.pixelSize: surface.hh * 0.032
                        color: Theme.darkText
                    }
                }

                Item {
                    id: field
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: surface.hh * 0.48; height: surface.hh * 0.075
                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        color: "#ffffff"
                        border.color: root.failed ? "#e2574c" : Theme.blue
                        border.width: Math.max(2, height * 0.05)
                    }
                    TextInput {
                        id: input
                        anchors.fill: parent
                        anchors.leftMargin: field.height * 0.5; anchors.rightMargin: field.height * 0.5
                        verticalAlignment: TextInput.AlignVCenter
                        horizontalAlignment: TextInput.AlignHCenter
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        font.family: Theme.font; font.pixelSize: field.height * 0.38
                        color: Theme.darkText
                        enabled: !pam.active
                        focus: true
                        text: root.password
                        onTextEdited: { root.password = text; root.failed = false }
                        onAccepted: root.submit()
                        Text {
                            anchors.centerIn: parent
                            visible: input.text === ""
                            text: pam.active ? "Checking…" : "Password"
                            font: input.font
                            color: "#b5b5b5"
                        }
                    }
                    SequentialAnimation {
                        id: shakeAnim
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -14; duration: 50 }
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 14; duration: 70 }
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -8; duration: 60 }
                        NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
                    }
                    Connections { target: root; function onShake(): void { shakeAnim.restart() } }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.message !== "" ? root.message : "Type your password and press Enter"
                    font.family: Theme.font; font.pixelSize: surface.hh * 0.024
                    color: root.failed ? "#d0493f" : Theme.greyText
                }
            }

            // blue line along the bottom, like the bar edge
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: surface.hh * 0.12
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.barTop }
                    GradientStop { position: 1; color: Theme.barBottom }
                }
                Rectangle { width: parent.width; height: Math.max(2, surface.hh * 0.005); color: Theme.blue }
            }
        }
    }
}
