import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.services

// Generic channel art: soft tinted background, big app icon, channel name.
Item {
    id: root
    required property var channel
    required property var entry      // DesktopEntry or null
    property real s: 1
    property bool large: false       // preview screen version

    readonly property color tint: channel.color ?? Theme.blue
    readonly property string iconName: channel.icon ?? (entry ? entry.icon : "application-x-executable")
    readonly property string label: channel.name ?? (entry ? entry.name : "Channel")
    // "" when the icon theme doesn't have it; then a drawn glyph is used.
    readonly property string iconSrc: Quickshell.iconPath(iconName, true)
    readonly property string glyph: channel.glyph ?? label.charAt(0).toUpperCase()

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ffffff" }
            GradientStop { position: 0.62; color: Qt.tint("#ffffff", Qt.alpha(root.tint, 0.10)) }
            GradientStop { position: 1.0; color: Qt.tint("#ffffff", Qt.alpha(root.tint, 0.28)) }
        }
    }
    // big faint icon echo in the corner
    IconImage {
        visible: root.iconSrc !== ""
        source: root.iconSrc
        width: parent.height * 1.1; height: width
        x: parent.width - width * 0.62; y: -height * 0.12
        opacity: 0.07
        asynchronous: true
    }
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -parent.height * 0.02
        spacing: parent.height * 0.04
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.height * (root.large ? 0.42 : 0.46); height: width
            IconImage {
                anchors.fill: parent
                visible: root.iconSrc !== ""
                source: root.iconSrc
                asynchronous: true
            }
            Rectangle {
                visible: root.iconSrc === ""
                anchors.fill: parent
                radius: width * 0.24
                gradient: Gradient {
                    GradientStop { position: 0; color: Qt.lighter(root.tint, 1.35) }
                    GradientStop { position: 1; color: root.tint }
                }
                border.color: Qt.darker(root.tint, 1.15); border.width: Math.max(1, width * 0.03)
                Text {
                    anchors.centerIn: parent
                    text: root.glyph
                    font.family: Theme.fontBold; font.weight: Font.Bold
                    font.pixelSize: parent.height * (root.glyph.length > 1 ? 0.42 : 0.6)
                    color: "#ffffff"
                    style: Text.Raised; styleColor: Qt.darker(root.tint, 1.4)
                }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: root.height * (root.large ? 0.09 : 0.15)
            color: "#7d8796"
            style: Text.Raised; styleColor: "#ffffff"
        }
    }
}
