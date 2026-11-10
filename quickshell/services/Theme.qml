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

    readonly property string font: regular.name
    readonly property string fontMedium: medium.name
    readonly property string fontBold: bold.name

    readonly property url assets: Qt.resolvedUrl("../assets/")
    function asset(path: string): url { return Qt.resolvedUrl("../assets/" + path) }

    property list<QtObject> _fonts: [
        FontLoader { id: regular; source: Qt.resolvedUrl("../assets/fonts/MPLUSRounded1c-Regular.ttf") },
        FontLoader { id: medium; source: Qt.resolvedUrl("../assets/fonts/MPLUSRounded1c-Medium.ttf") },
        FontLoader { id: bold; source: Qt.resolvedUrl("../assets/fonts/MPLUSRounded1c-Bold.ttf") }
    ]
}
