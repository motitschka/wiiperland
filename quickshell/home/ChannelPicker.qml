import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services

// "Add a channel": opens when an empty slot is clicked. Lists the built-in
// channels first, then every installed app; picking one fills the slot.
Item {
    id: root
    property real hh: height
    property int slot: -1
    property bool open: false
    property real progress: open ? 1 : 0
    Behavior on progress { NumberAnimation { duration: 300; easing.type: Easing.InOutCubic } }
    visible: progress > 0
    enabled: open

    function show(s: int): void {
        if (Config.channels[s]) return
        slot = s; open = true
        list.positionViewAtBeginning()
        Sound.play("open"); keys.forceActiveFocus()
    }
    function hide(): void { if (open) { open = false; Sound.play("back") } }
    function pick(channel: var): void {
        if (Config.addChannel(slot, channel)) Sound.play("click")
        open = false
    }

    // built-ins, then apps by name
    readonly property var items: {
        const out = Menu.builtins.map(b => ({ label: b.label, glyph: b.glyph, color: b.color, icon: "", channel: b.channel }))
        const apps = DesktopEntries.applications.values.filter(e => !e.noDisplay && e.name)
        apps.sort((a, b) => a.name.localeCompare(b.name))
        for (let i = 0; i < apps.length; i++) {
            const e = apps[i]
            out.push({ label: e.name, glyph: e.name.charAt(0).toUpperCase(), color: Theme.blue, icon: e.icon ?? "",
                       channel: { type: "app", app: e.id, name: e.name } })
        }
        return out
    }

    // the menu stays faintly visible behind
    Rectangle { anchors.fill: parent; color: "#f3f4f6"; opacity: root.progress * 0.86 }
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onClicked: root.hide(); onWheel: (w) => w.accepted = true }

    Rectangle {
        id: panel
        width: parent.width * 0.8; height: parent.height * 0.84
        anchors.centerIn: parent
        radius: root.hh * 0.05
        color: "#ffffff"
        border.color: Theme.blueLine; border.width: Math.max(2, root.hh * 0.004)
        opacity: root.progress
        scale: 0.94 + 0.06 * root.progress
        MouseArea { anchors.fill: parent }   // clicks on the panel don't close it

        Text {
            id: heading
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.hh * 0.03
            text: "Add a channel"
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: root.hh * 0.05
            color: Theme.dateGrey
        }
        Rectangle { id: rule; y: root.hh * 0.115; width: parent.width; height: Math.max(1, root.hh * 0.003); color: Theme.blueLine }

        GridView {
            id: list
            anchors { left: parent.left; right: parent.right; top: rule.bottom; bottom: footer.top; margins: root.hh * 0.03 }
            clip: true
            readonly property int columns: 5
            cellWidth: width / columns; cellHeight: root.hh * 0.2
            model: root.items
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: cell
                required property var modelData
                width: list.cellWidth; height: list.cellHeight
                readonly property bool hovered: area.containsMouse
                onHoveredChanged: if (hovered) Sound.play("tick")
                readonly property string iconSrc: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""

                Rectangle {
                    anchors.fill: parent; anchors.margins: root.hh * 0.008
                    radius: root.hh * 0.025
                    color: cell.hovered ? "#eaf7fd" : "#00ffffff"
                    border.color: cell.hovered ? Theme.blueHover : "#00ffffff"
                    border.width: Math.max(2, root.hh * 0.004)
                }
                Column {
                    anchors.centerIn: parent
                    spacing: root.hh * 0.008
                    Item {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: root.hh * 0.09; height: width
                        IconImage { anchors.fill: parent; visible: cell.iconSrc !== ""; source: cell.iconSrc; asynchronous: true }
                        Rectangle {
                            visible: cell.iconSrc === ""
                            anchors.fill: parent; radius: width * 0.24
                            gradient: Gradient {
                                GradientStop { position: 0; color: Qt.lighter(cell.modelData.color, 1.3) }
                                GradientStop { position: 1; color: cell.modelData.color }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: cell.modelData.glyph
                                font.family: Theme.fontBold; font.weight: Font.Bold
                                font.pixelSize: parent.height * 0.56
                                color: "#ffffff"
                            }
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: list.cellWidth - root.hh * 0.04
                        horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                        wrapMode: Text.WordWrap; maximumLineCount: 2; lineHeight: 0.9
                        text: cell.modelData.label
                        font.family: Theme.fontMedium
                        font.pixelSize: root.hh * 0.026
                        color: cell.hovered ? Theme.blueDark : Theme.darkText
                    }
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pick(cell.modelData.channel)
                }
            }
        }
        // scroll position
        Rectangle {
            visible: list.contentHeight > list.height
            anchors.right: parent.right; anchors.rightMargin: root.hh * 0.012
            width: Math.max(3, root.hh * 0.006); radius: width / 2
            y: list.y + list.visibleArea.yPosition * list.height
            height: Math.max(root.hh * 0.03, list.visibleArea.heightRatio * list.height)
            color: Theme.blueLine
        }

        Item {
            id: footer
            anchors.bottom: parent.bottom
            width: parent.width; height: root.hh * 0.13
            Rectangle { width: parent.width; height: Math.max(1, root.hh * 0.003); color: Theme.blueLine }
            PillButton { anchors.centerIn: parent; hh: root.hh; text: "Back"; onClicked: root.hide() }
        }
    }

    Item {
        id: keys
        focus: root.open
        Keys.onEscapePressed: root.hide()
    }
}
