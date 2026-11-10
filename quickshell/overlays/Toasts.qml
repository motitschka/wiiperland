import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.services
import qs.home

// Small message cards that drop in at the top centre of the focused screen.
PanelWindow {
    id: win
    screen: Quickshell.screens.find(s => s.name === Hypr.focusedMonitorName) ?? Quickshell.screens[0]
    anchors { top: true }
    margins.top: 14
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wiiperland-toast"
    color: "transparent"
    readonly property real hh: screen ? screen.height : 720
    implicitWidth: hh * 0.62
    implicitHeight: Math.max(1, column.implicitHeight + 20)
    visible: Messages.toasts.count > 0

    Column {
        id: column
        width: parent.width - 20
        x: 10; y: 4
        spacing: 8
        Repeater {
            model: Messages.toasts
            delegate: Item {
                id: toast
                required property int index
                required property string summary
                required property string body
                required property string app
                required property string icon
                required property int nid
                required property int timeout
                width: column.width
                height: win.hh * 0.1

                Rectangle {
                    anchors.fill: parent; anchors.topMargin: 3
                    radius: height * 0.3; color: "#22000000"
                }
                Rectangle {
                    id: card
                    anchors.fill: parent
                    radius: height * 0.3
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#ffffff" }
                        GradientStop { position: 1; color: "#eef1f4" }
                    }
                    border.color: mouse.containsMouse ? Theme.blue : "#c9cfd6"
                    border.width: Math.max(1.5, height * 0.03)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: parent.height * 0.22; anchors.rightMargin: parent.height * 0.3
                        spacing: parent.height * 0.2
                        Item {
                            width: card.height * 0.56; height: width
                            anchors.verticalCenter: parent.verticalCenter
                            IconImage { anchors.fill: parent; source: toast.icon; visible: toast.icon !== "" }
                            MailIcon { anchors.centerIn: parent; visible: toast.icon === ""; width: parent.width; height: width * 0.68; color: Theme.blue }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - card.height * 0.8
                            Text {
                                width: parent.width; elide: Text.ElideRight
                                text: toast.summary || toast.app
                                font.family: Theme.fontBold; font.weight: Font.Bold
                                font.pixelSize: card.height * 0.23
                                color: Theme.darkText
                            }
                            Text {
                                width: parent.width; elide: Text.ElideRight
                                visible: text !== ""
                                text: toast.body
                                font.family: Theme.font; font.pixelSize: card.height * 0.19
                                color: Theme.greyText
                            }
                        }
                    }
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { Messages.activate(toast.nid); Messages.dismissToast(toast.index) }
                }
                Timer {
                    running: !mouse.containsMouse
                    interval: toast.timeout
                    onTriggered: Messages.dismissToast(toast.index)
                }
                // drop in
                NumberAnimation on y { from: -toast.height; duration: 380; easing.type: Easing.OutBack }
            }
        }
    }
}
