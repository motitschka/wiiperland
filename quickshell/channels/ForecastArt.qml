import QtQuick
import qs.services

// Forecast Channel: current weather on the tile, three days on the preview.
Item {
    id: root
    required property var channel
    property bool large: false
    readonly property string label: channel.name ?? "Forecast Channel"

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#f4fbff" }
            GradientStop { position: 1.0; color: "#d3ecfb" }
        }
    }

    // tile
    Row {
        visible: !root.large
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -root.height * 0.1
        spacing: root.height * 0.06
        WeatherIcon { kind: Weather.kind; width: root.height * 0.46; height: width }
        Text {
            visible: Weather.ready
            anchors.verticalCenter: parent.verticalCenter
            text: Weather.temp + "°"
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: root.height * 0.26
            color: "#6f7f92"
        }
    }
    Text {
        visible: !root.large
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.68
        text: root.label
        font.family: Theme.fontBold; font.weight: Font.Bold
        font.pixelSize: root.height * 0.14
        color: "#7d8796"
        style: Text.Raised; styleColor: "#ffffff"
    }

    // preview
    Column {
        visible: root.large
        anchors.centerIn: parent
        spacing: root.height * 0.04
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Weather.place || root.label
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: root.height * 0.07
            color: "#6f7f92"
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.height * 0.04
            WeatherIcon { kind: Weather.kind; width: root.height * 0.24; height: width }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: Weather.ready ? Weather.temp + "°" + (Weather.metric ? "C" : "F") : "…"
                    font.family: Theme.fontBold; font.weight: Font.Bold
                    font.pixelSize: root.height * 0.11
                    color: "#5f6f82"
                }
                Text {
                    text: Weather.desc
                    font.family: Theme.font; font.pixelSize: root.height * 0.04
                    color: "#7d8796"
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.height * 0.03
            Repeater {
                model: Weather.days
                Rectangle {
                    required property var modelData
                    width: root.height * 0.2; height: root.height * 0.24
                    radius: height * 0.12
                    color: "#b3ffffff"; border.color: "#c5dbe8"; border.width: 1
                    Column {
                        anchors.centerIn: parent
                        spacing: root.height * 0.005
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.name; font.family: Theme.fontMedium; font.pixelSize: root.height * 0.035; color: "#6f7f92" }
                        WeatherIcon { anchors.horizontalCenter: parent.horizontalCenter; kind: modelData.kind; width: root.height * 0.1; height: width }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.max + "° / " + modelData.min + "°"; font.family: Theme.font; font.pixelSize: root.height * 0.032; color: "#7d8796" }
                    }
                }
            }
        }
    }
}
