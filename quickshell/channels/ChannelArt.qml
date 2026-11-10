import QtQuick
import qs.services

// Picks the right art for a channel type.
Loader {
    id: root
    property var channel: null
    property bool large: false
    readonly property var entry: Launcher.entryFor(channel)

    readonly property string type: channel ? (channel.type ?? "app") : ""
    sourceComponent: !channel ? null
        : type === "photos" ? photoArt
        : type === "forecast" ? forecastArt
        : type === "music" ? musicArt
        : appArt

    Component { id: appArt; AppArt { channel: root.channel; entry: root.entry; large: root.large } }
    Component { id: photoArt; PhotoArt { channel: root.channel; large: root.large } }
    Component { id: forecastArt; ForecastArt { channel: root.channel; large: root.large } }
    Component { id: musicArt; MusicArt { channel: root.channel; large: root.large } }
}
