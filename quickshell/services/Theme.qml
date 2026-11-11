pragma Singleton
import QtQuick
import Quickshell

// Colours, fonts and sizing shared by the whole shell.
// Sizes are designed against a 720 px tall screen and scaled by `s`
// (screen height / 720), which each surface computes for itself.
Singleton {
    id: theme

    readonly property color blue: "#34beed"
    readonly property color blueLight: "#8adcf7"
    readonly property color blueDark: "#0e9fd8"
    readonly property color bg: "#f3f3f3"
    readonly property color tileBorder: "#c4c4c4"
    readonly property color tileEmpty: "#dcdcdc"
    readonly property color barTop: "#dcdddf"
    readonly property color barBottom: "#c6c7c9"
    readonly property color greyText: "#8e8e8e"
    readonly property color darkText: "#5a5a5a"
    readonly property color white: "#ffffff"

    // Font families. The owner's fonts in <assets>/fonts win (docs/assets.md).
    readonly property string font: regular.name
    readonly property string fontMedium: medium.name
    readonly property string fontBold: bold.name
    // "" unless the owner supplies fonts/clock.ttf; the clock then uses it
    // instead of the drawn segment digits.
    property string clockFont: ""

    // An asset by relative path: the owner's file if present, else the built-in.
    function asset(path: string): url { return Assets.url(path) }

    function _font(role: string, builtin: string): url {
        const f = Assets.font(role)
        return f ? Assets.fresh(f) : Qt.resolvedUrl("../assets/fonts/" + builtin)
    }

    property list<QtObject> _fonts: [
        FontLoader { id: regular; source: theme._font("ui-regular", "MPLUSRounded1c-Regular.ttf") },
        FontLoader { id: medium; source: theme._font("ui-medium", "MPLUSRounded1c-Medium.ttf") },
        FontLoader { id: bold; source: theme._font("ui-bold", "MPLUSRounded1c-Bold.ttf") }
    ]

    // Loaded only while the file exists (a FontLoader with no source complains).
    Instantiator {
        model: Assets.font("clock") ? [Assets.font("clock")] : []   // rebuilt when the index changes
        delegate: FontLoader {
            required property string modelData
            source: Assets.fresh(modelData)
            onStatusChanged: if (status === FontLoader.Ready) theme.clockFont = name
            Component.onDestruction: theme.clockFont = ""
        }
    }
}
