import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services

// The Message Board: all kept notifications as cards on graph paper.
Item {
    id: root
    property real hh: height
    property bool open: false
    property real progress: open ? 1 : 0
    Behavior on progress { NumberAnimation { duration: 380; easing.type: Easing.InOutCubic } }
    visible: progress > 0
    enabled: open

    function show(): void { open = true; Sound.play("open"); Messages.markAllRead(); focusItem.forceActiveFocus() }
    function hide(): void { if (open) { open = false; Sound.play("back") } }

    function timeText(ms: real): string {
        const d = new Date(ms), now = new Date()
        const sameDay = d.toDateString() === now.toDateString()
        const t = Qt.formatTime(d, Config.clock24h ? "HH:mm" : "h:mm AP")
        return sameDay ? t : Qt.formatDate(d, "M/d") + " " + t
    }

    // graph-paper backdrop
    Rectangle {
        anchors.fill: parent
        opacity: root.progress
        gradient: Gradient {
            GradientStop { position: 0; color: "#f7fbfe" }
            GradientStop { position: 1; color: "#e3eef6" }
        }
        Canvas {
            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d"), step = root.hh * 0.04
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = "rgba(52,190,237,0.10)"; ctx.lineWidth = 1
                for (let x = 0; x < width; x += step) { ctx.beginPath(); ctx.moveTo(x + 0.5, 0); ctx.lineTo(x + 0.5, height); ctx.stroke() }
                for (let y = 0; y < height; y += step) { ctx.beginPath(); ctx.moveTo(0, y + 0.5); ctx.lineTo(width, y + 0.5); ctx.stroke() }
            }
            onWidthChanged: requestPaint(); onHeightChanged: requestPaint()
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: root.progress
        scale: 0.94 + 0.06 * root.progress

        // header
        Rectangle {
            id: header
            width: parent.width; height: root.hh * 0.13
            gradient: Gradient {
                GradientStop { position: 0; color: "#ffffff" }
                GradientStop { position: 1; color: "#eef2f5" }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: Math.max(2, root.hh * 0.005); color: Theme.blue }
            Column {
                anchors.centerIn: parent
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Message Board"
                    font.family: Theme.fontBold; font.weight: Font.Bold
                    font.pixelSize: root.hh * 0.042
                    color: Theme.darkText
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDate(Time.now, "dddd, MMMM d") + "  ·  " + Messages.board.count + (Messages.board.count === 1 ? " message" : " messages")
                    font.family: Theme.font; font.pixelSize: root.hh * 0.024
                    color: Theme.greyText
                }
            }
        }

        // cards
        GridView {
            id: grid
            anchors { top: header.bottom; bottom: footer.top; horizontalCenter: parent.horizontalCenter; topMargin: root.hh * 0.03 }
            readonly property int cols: Math.max(1, Math.min(3, Math.floor(root.width / (root.hh * 0.48))))
            width: cols * cellWidth
            cellWidth: root.hh * 0.46; cellHeight: root.hh * 0.2
            clip: true
            model: Messages.board
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: card
                required property int index
                required property string summary
                required property string body
                required property string app
                required property string icon
                required property int nid
                required property real time
                required property bool read
                width: grid.cellWidth; height: grid.cellHeight
                readonly property bool hovered: mouse.containsMouse || del.hovered

                Rectangle {
                    anchors.fill: parent; anchors.margins: root.hh * 0.012
                    anchors.topMargin: root.hh * 0.016
                    radius: root.hh * 0.02; color: "#1a000000"
                }
                Rectangle {
                    id: paper
                    anchors.fill: parent; anchors.margins: root.hh * 0.012
                    radius: root.hh * 0.02
                    color: "#ffffff"
                    border.color: card.hovered ? Theme.blue : "#cfd8e0"
                    border.width: Math.max(1.5, root.hh * 0.003)
                    rotation: (card.index % 3 - 1) * 0.6

                    Row {
                        anchors.fill: parent; anchors.margins: root.hh * 0.022
                        spacing: root.hh * 0.02
                        Item {
                            width: root.hh * 0.06; height: width
                            IconImage { anchors.fill: parent; source: card.icon; visible: card.icon !== "" }
                            Rectangle {
                                visible: card.icon === ""
                                anchors.fill: parent; radius: width * 0.25
                                color: "#e7f6fd"; border.color: "#bfe6f7"
                                Text { anchors.centerIn: parent; text: "✉"; font.pixelSize: parent.height * 0.55; color: Theme.blue }
                            }
                        }
                        Column {
                            width: parent.width - root.hh * 0.08
                            spacing: root.hh * 0.004
                            Text {
                                width: parent.width; elide: Text.ElideRight
                                text: card.summary || card.app
                                font.family: Theme.fontBold; font.weight: Font.Bold
                                font.pixelSize: root.hh * 0.026
                                color: Theme.darkText
                            }
                            Text {
                                width: parent.width
                                text: card.body
                                visible: text !== ""
                                wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight
                                font.family: Theme.font; font.pixelSize: root.hh * 0.021
                                color: "#6d747b"
                            }
                        }
                    }
                    Text {
                        anchors { right: parent.right; bottom: parent.bottom; margins: root.hh * 0.014 }
                        text: (card.app ? card.app + " · " : "") + root.timeText(card.time)
                        font.family: Theme.font; font.pixelSize: root.hh * 0.017
                        color: "#a0a7ae"
                    }
                    Rectangle {
                        visible: !card.read
                        width: root.hh * 0.014; height: width; radius: width / 2
                        anchors { right: parent.right; top: parent.top; margins: root.hh * 0.016 }
                        color: Theme.blue
                    }
                }
                MouseArea {
                    id: mouse
                    anchors.fill: paper
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: Sound.play("tick")
                    onClicked: { Sound.play("click"); Messages.activate(card.nid) }
                }
                // delete button
                Rectangle {
                    id: del
                    property bool hovered: delMouse.containsMouse
                    visible: card.hovered
                    width: root.hh * 0.036; height: width; radius: width / 2
                    x: paper.x + paper.width - width * 0.6; y: paper.y - height * 0.4
                    color: hovered ? "#e85d5d" : "#ffffff"
                    border.color: hovered ? "#c94343" : "#c9cfd6"; border.width: 1.5
                    Text { anchors.centerIn: parent; text: "×"; font.pixelSize: parent.height * 0.7; color: del.hovered ? "#ffffff" : "#8a9097" }
                    MouseArea { id: delMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { Sound.play("back"); Messages.remove(card.index) } }
                }
            }
        }

        // empty state
        Column {
            visible: Messages.board.count === 0
            anchors.centerIn: parent
            spacing: root.hh * 0.02
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "✉"; font.pixelSize: root.hh * 0.12; color: "#c5d6e2" }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "No messages"; font.family: Theme.fontMedium; font.pixelSize: root.hh * 0.03; color: Theme.greyText }
        }

        // footer
        Item {
            id: footer
            anchors.bottom: parent.bottom
            width: parent.width; height: root.hh * 0.17
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#f2f2f2" }
                    GradientStop { position: 1.0; color: "#d4d5d7" }
                }
                Rectangle { width: parent.width; height: Math.max(2, root.hh * 0.005); color: Theme.blue }
            }
            Row {
                anchors.centerIn: parent
                spacing: root.hh * 0.12
                PillButton { hh: root.hh; text: "Back"; onClicked: root.hide() }
                PillButton { hh: root.hh; text: "Clear All"; enabled: Messages.board.count > 0; opacity: enabled ? 1 : 0.5; onClicked: { Sound.play("back"); Messages.clear() } }
            }
        }
    }

    Item {
        id: focusItem
        focus: root.open
        Keys.onEscapePressed: root.hide()
    }
}
