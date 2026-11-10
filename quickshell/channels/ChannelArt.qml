import QtQuick
import qs.services

// Picks the right art for a channel type.
Loader {
    id: root
    property var channel: null
    property bool large: false
    readonly property var entry: Launcher.entryFor(channel)

    sourceComponent: !channel ? null : appArt
    Component { id: appArt; AppArt { channel: root.channel; entry: root.entry; large: root.large } }
}
