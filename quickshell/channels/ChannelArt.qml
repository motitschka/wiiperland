import QtQuick
import qs.services

// What a channel shows on its tile and in its preview: the owner's banner if
// there is one (docs/assets.md), otherwise the built-in art for its type.
Item {
    id: root
    property var channel: null
    property bool large: false       // preview version
    property bool playing: true      // false: animations and video rest
    readonly property var entry: Launcher.entryFor(channel)
    readonly property string type: channel ? (channel.type ?? "app") : ""

    readonly property var banner: channel ? Assets.banner(Launcher.label(channel), channel.banner ?? "") : null
    // path plus modification time: changes when the file is replaced
    readonly property string bannerKey: banner ? Assets.fresh(banner.path) : ""
    // A banner that can't be shown (broken file, missing video support)
    // gives way to the built-in art until the file changes.
    property bool bannerFailed: false
    onBannerKeyChanged: bannerFailed = false
    readonly property bool useBanner: bannerKey !== "" && !bannerFailed

    Loader {
        anchors.fill: parent
        sourceComponent: !root.channel ? null
            : root.useBanner ? bannerArt
            : root.type === "photos" ? photoArt
            : root.type === "forecast" ? forecastArt
            : root.type === "music" ? musicArt
            : root.type === "disc" ? discArt
            : appArt
    }

    Component {
        id: bannerArt
        BannerArt {
            banner: root.banner; playing: root.playing
            onFailed: { console.warn("banner: can't show", root.banner ? root.banner.path : ""); root.bannerFailed = true }
        }
    }
    Component { id: appArt; AppArt { channel: root.channel; entry: root.entry; large: root.large; playing: root.playing } }
    Component { id: photoArt; PhotoArt { channel: root.channel; large: root.large; playing: root.playing } }
    Component { id: forecastArt; ForecastArt { channel: root.channel; large: root.large; playing: root.playing } }
    Component { id: discArt; DiscArt { channel: root.channel; large: root.large; playing: root.playing } }
    Component { id: musicArt; MusicArt { channel: root.channel; large: root.large; playing: root.playing } }
}
