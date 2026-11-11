import QtQuick
import qs.services

// Forecast Channel: a full-bleed sky for the current weather (sun, drifting
// clouds, falling rain or snow) with the temperature in the corner. The
// preview puts today's weather and the next three days on a card over it.
Item {
    id: root
    required property var channel
    property bool large: false
    property bool playing: true
    readonly property string label: channel.name ?? "Forecast Channel"

    readonly property string kind: Weather.ready ? Weather.kind : "partly"
    readonly property bool wet: kind === "rain" || kind === "storm"
    readonly property bool grey: wet || kind === "cloud" || kind === "fog"
    readonly property bool snowy: kind === "snow"
    readonly property color cloudColor: kind === "storm" ? "#8f99a5" : wet ? "#c2cad3" : grey ? "#e3e8ed" : "#ffffff"

    // two clocks: a slow one for the clouds, a fast one for rain and snow
    property real drift: 0
    property real fall: 0
    NumberAnimation on drift { from: 0; to: 1; duration: 90000; loops: Animation.Infinite; running: root.playing }
    NumberAnimation on fall { from: 0; to: 1; duration: 6000; loops: Animation.Infinite; running: root.playing && (root.wet || root.snowy) }
    function frac(v: real): real { return v - Math.floor(v) }

    // sky
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.kind === "storm" ? "#5d6b7c" : root.wet ? "#8194a8" : root.snowy ? "#a9bfd4" : root.grey ? "#9fb4c8" : "#4fb2f0" }
            GradientStop { position: 1.0; color: root.kind === "storm" ? "#98a5b3" : root.wet ? "#c1ccd7" : root.snowy ? "#e8f0f7" : root.grey ? "#dbe5ee" : "#c8ecff" }
        }
    }

    // sun with a soft halo
    Item {
        visible: root.kind === "sun" || root.kind === "partly"
        width: root.height * 0.9; height: width
        x: root.width * 0.2 - width / 2; y: root.height * 0.3 - height / 2
        Rectangle {
            anchors.fill: parent; radius: width / 2
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#70fff6c2" }
                GradientStop { position: 1.0; color: "#00fff6c2" }
            }
        }
        WeatherIcon { anchors.centerIn: parent; kind: "sun"; width: parent.width * 0.62; height: width }
    }

    // clouds drifting across, wrapping around
    component Cloud: Item {
        id: cloud
        property real size: 100
        property real lane: 0.2      // vertical position, share of the height
        property real offset: 0      // where on the loop it starts
        property int laps: 1         // loops per cycle of the slow clock
        width: size; height: size * 0.5
        x: root.frac(root.drift * laps + offset) * (root.width + width) - width
        y: root.height * lane
        opacity: 0.94
        Rectangle { width: cloud.width * 0.42; height: width; radius: width / 2; x: cloud.width * 0.08; y: cloud.height * 0.3; color: root.cloudColor }
        Rectangle { width: cloud.width * 0.52; height: width; radius: width / 2; x: cloud.width * 0.28; y: 0; color: root.cloudColor }
        Rectangle { width: cloud.width * 0.38; height: width; radius: width / 2; x: cloud.width * 0.58; y: cloud.height * 0.34; color: root.cloudColor }
        Rectangle { x: cloud.width * 0.1; y: cloud.height * 0.62; width: cloud.width * 0.82; height: cloud.height * 0.42; radius: height / 2; color: root.cloudColor }
    }
    Cloud { visible: root.kind !== "sun" || root.large; size: root.height * 0.95; lane: 0.06; offset: 0.42; laps: 1 }
    Cloud { size: root.height * 0.6; lane: 0.3; offset: 0.82; laps: 2 }
    Cloud { visible: root.grey || root.snowy; size: root.height * 0.8; lane: 0.16; offset: 0.08; laps: 1 }
    Cloud { visible: root.grey || root.snowy; size: root.height * 0.7; lane: 0.02; offset: 0.66; laps: 2 }

    // rain
    Repeater {
        model: root.wet ? 22 : 0
        Rectangle {
            required property int index
            readonly property real p: root.frac(root.fall * (4 + index % 3) + index * 0.137)
            width: Math.max(2, root.height * 0.016); height: root.height * 0.1; radius: width / 2
            color: "#eaf6ff"; opacity: 0.9
            rotation: 14
            x: root.width * root.frac(index * 0.618 + 0.05) - p * root.height * 0.2
            y: root.height * (0.3 + p * 0.8)
        }
    }
    // snow
    Repeater {
        model: root.snowy ? 18 : 0
        Rectangle {
            required property int index
            readonly property real p: root.frac(root.fall * (1 + index % 2) + index * 0.173)
            width: root.height * (0.03 + (index % 3) * 0.008); height: width; radius: width / 2
            color: "#ffffff"; opacity: 0.92
            x: root.width * root.frac(index * 0.618 + 0.1) + root.height * 0.04 * Math.sin((p * 2 + index) * Math.PI)
            y: root.height * (0.2 + p * 0.9)
        }
    }
    // lightning: a brief flash now and then
    Rectangle {
        visible: root.kind === "storm"
        anchors.fill: parent
        color: "#ffffff"
        opacity: root.frac(root.drift * 12) > 0.985 ? 0.5 : 0
    }

    // ground: a soft hill
    Rectangle {
        width: root.width * 1.5; height: root.height * 0.7; radius: height / 2
        x: -root.width * 0.25; y: root.height * 0.8
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.snowy ? "#ffffff" : root.grey ? "#9cc38a" : "#a5df7f" }
            GradientStop { position: 0.5; color: root.snowy ? "#e6eef5" : root.grey ? "#7fa972" : "#74c257" }
        }
    }

    // tile: temperature in the corner
    Text {
        visible: !root.large && Weather.ready
        anchors { right: parent.right; bottom: parent.bottom; rightMargin: root.height * 0.1; bottomMargin: root.height * 0.04 }
        text: Weather.temp + "°"
        font.family: Theme.fontBold; font.weight: Font.Bold
        font.pixelSize: root.height * 0.36
        color: "#ffffff"
        style: Text.Outline; styleColor: "#5a000000"
    }

    // preview: today and the next days on a card
    Rectangle {
        visible: root.large
        anchors.centerIn: parent
        anchors.verticalCenterOffset: root.height * 0.03
        width: info.width + root.height * 0.14; height: info.height + root.height * 0.1
        radius: root.height * 0.05
        color: "#d9ffffff"; border.color: "#ffffff"; border.width: Math.max(1, root.height * 0.004)

        Column {
            id: info
            anchors.centerIn: parent
            spacing: root.height * 0.03
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Weather.place || root.label
                font.family: Theme.fontBold; font.weight: Font.Bold
                font.pixelSize: root.height * 0.06
                color: "#5f6f82"
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.height * 0.04
                WeatherIcon { kind: Weather.kind; width: root.height * 0.2; height: width }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: Weather.ready ? Weather.temp + "°" + (Weather.metric ? "C" : "F") : "…"
                        font.family: Theme.fontBold; font.weight: Font.Bold
                        font.pixelSize: root.height * 0.1
                        color: "#5f6f82"
                    }
                    Text {
                        text: Weather.desc
                        font.family: Theme.font; font.pixelSize: root.height * 0.038
                        color: "#7d8796"
                    }
                }
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.height * 0.025
                Repeater {
                    model: Weather.days
                    Rectangle {
                        required property var modelData
                        width: root.height * 0.19; height: root.height * 0.22
                        radius: height * 0.12
                        color: "#ffffff"; border.color: "#c5dbe8"; border.width: 1
                        Column {
                            anchors.centerIn: parent
                            spacing: root.height * 0.004
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.name; font.family: Theme.fontMedium; font.pixelSize: root.height * 0.034; color: "#6f7f92" }
                            WeatherIcon { anchors.horizontalCenter: parent.horizontalCenter; kind: modelData.kind; width: root.height * 0.095; height: width }
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.max + "° / " + modelData.min + "°"; font.family: Theme.font; font.pixelSize: root.height * 0.031; color: "#7d8796" }
                        }
                    }
                }
            }
        }
    }
}
