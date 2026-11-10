import QtQuick
import Qt.labs.folderlistmodel
import qs.services

// Photo Channel: a little collage of pictures from a folder that shuffles
// every few seconds.
Item {
    id: root
    required property var channel
    property bool large: false
    readonly property string label: channel.name ?? "Photo Channel"
    readonly property string dir: Config.expand(channel.dir ?? "~/Pictures")

    FolderListModel {
        id: files
        folder: "file://" + root.dir
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.JPEG", "*.PNG"]
        showDirs: false
        sortField: FolderListModel.Time
    }
    property int offset: 0
    Timer {
        interval: 7000; repeat: true
        running: files.count > 3
        onTriggered: root.offset = (root.offset + 1) % files.count
    }
    function pick(i: int): string {
        return files.count > 0 ? files.get((root.offset + i) % files.count, "fileUrl") : ""
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#fff8ef" }
            GradientStop { position: 1.0; color: "#f6dfc4" }
        }
    }

    // header strip with the name
    Rectangle {
        id: header
        width: parent.width; height: parent.height * (root.large ? 0.12 : 0.24)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e9a35b" }
            GradientStop { position: 1.0; color: "#c97a34" }
        }
        Text {
            anchors.centerIn: parent
            text: root.label
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: parent.height * 0.6
            color: "#ffffff"
            style: Text.Raised; styleColor: "#9a5a22"
        }
    }

    Item {
        id: board
        anchors { left: parent.left; right: parent.right; top: header.bottom; bottom: parent.bottom }
        readonly property int n: root.large ? 5 : 3

        Repeater {
            model: board.n
            Item {
                id: photo
                required property int index
                readonly property real ph: board.height * (root.large ? 0.5 : 0.78)
                width: ph * 1.3; height: ph
                x: board.width / 2 - width / 2 + (index - (board.n - 1) / 2) * width * (root.large ? 0.85 : 0.62)
                y: (board.height - height) / 2 + (index % 2 ? height * 0.06 : -height * 0.03)
                rotation: [-7, 4, -3, 6, -5][index]
                z: index === Math.floor(board.n / 2) ? 2 : 1

                Rectangle {  // shadow
                    anchors.fill: parent; anchors.topMargin: 3; anchors.leftMargin: 2
                    color: "#30000000"; radius: 2
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"; radius: 2
                    Image {
                        id: img
                        anchors.fill: parent; anchors.margins: Math.max(2, parent.height * 0.05)
                        source: root.pick(photo.index)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.height: root.large ? 600 : 200
                        opacity: status === Image.Ready ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 500 } }
                    }
                    Rectangle {  // placeholder when the folder is empty
                        visible: files.count === 0
                        anchors.fill: img
                        gradient: Gradient {
                            GradientStop { position: 0; color: ["#9fd3f5", "#b7e3a1", "#f5c29f", "#d4b8f0", "#f7e08f"][photo.index] }
                            GradientStop { position: 1; color: "#ffffff" }
                        }
                    }
                }
            }
        }
    }
}
