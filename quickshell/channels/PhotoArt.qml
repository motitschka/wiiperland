import QtQuick
import Qt.labs.folderlistmodel
import qs.services

// Photo Channel. The tile is one picture from the folder, full-bleed, slowly
// zooming and cross-fading to the next every few seconds. The preview is a
// collage of five. With an empty folder both show pastel placeholder frames.
Item {
    id: root
    required property var channel
    property bool large: false
    property bool playing: true
    readonly property bool collage: large || files.count === 0
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
        running: root.playing && files.count > (root.collage ? 3 : 1)
        onTriggered: {
            root.offset = (root.offset + 1) % files.count
            if (!root.collage) root.showNext()
        }
    }
    function pick(i: int): string {
        return files.count > 0 ? files.get((root.offset + i) % files.count, "fileUrl") : ""
    }

    // ---- tile: full-bleed slideshow on two layers -----------------------
    property int front: 0          // which layer is showing
    function showNext(): void {
        const next = 1 - front
        slides.itemAt(next).source = pick(0)
        front = next
    }
    readonly property int count: files.count
    onCountChanged: if (count > 0 && slides.count === 2 && !slides.itemAt(front).source.toString()) slides.itemAt(front).source = pick(0)

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#fff8ef" }
            GradientStop { position: 1.0; color: "#f6dfc4" }
        }
    }

    Repeater {
        id: slides
        model: 2
        Image {
            id: slide
            required property int index
            readonly property bool showing: root.front === index
            visible: !root.collage && opacity > 0
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.height: 480
            opacity: showing && status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 1400; easing.type: Easing.InOutQuad } }
            // slow push-in, restarted each time this layer comes up
            transformOrigin: index === 0 ? Item.TopLeft : Item.BottomRight
            onShowingChanged: if (showing) zoom.restart()
            NumberAnimation { id: zoom; target: slide; property: "scale"; from: 1.0; to: 1.16; duration: 9000 }
            Component.onCompleted: { if (index === root.front && root.count > 0) source = root.pick(0); if (showing) zoom.restart() }
        }
    }

    Item {
        id: board
        visible: root.collage
        anchors.fill: parent
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
                rotation: [-7, 4, -3, 6, -5][index] + sway
                property real sway: 0
                SequentialAnimation on sway {
                    running: root.playing && root.collage; loops: Animation.Infinite
                    NumberAnimation { to: 1.2; duration: 2600 + photo.index * 300; easing.type: Easing.InOutSine }
                    NumberAnimation { to: -1.2; duration: 2600 + photo.index * 300; easing.type: Easing.InOutSine }
                }
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
                        source: root.collage ? root.pick(photo.index) : ""
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
