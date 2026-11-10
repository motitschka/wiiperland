import QtQuick
import qs.services

// "11:10 PM" in thin segment digits with a blinking colon.
Row {
    id: root
    property real digitHeight: 32
    property color color: Theme.greyText
    spacing: digitHeight * 0.16

    readonly property int h: Time.hours
    readonly property int m: Time.minutes

    SegmentDigit {
        height: root.digitHeight; color: root.color
        value: Math.floor(root.h / 10)
        opacity: (Time.use24h || value > 0) ? 1 : 0
    }
    SegmentDigit { height: root.digitHeight; color: root.color; value: root.h % 10 }

    Item {
        width: root.digitHeight * 0.32; height: root.digitHeight
        Repeater {
            model: 2
            Rectangle {
                required property int index
                width: root.digitHeight * 0.085; height: width; radius: width / 2
                x: (parent.width - width) / 2
                y: root.digitHeight * (index === 0 ? 0.3 : 0.66)
                color: root.color
                opacity: Time.colonOn ? 1 : 0.15
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }
        }
    }

    SegmentDigit { height: root.digitHeight; color: root.color; value: Math.floor(root.m / 10) }
    SegmentDigit { height: root.digitHeight; color: root.color; value: root.m % 10 }

    Text {
        visible: !Time.use24h
        text: Time.pm ? "PM" : "AM"
        color: root.color
        font.family: Theme.font
        font.pixelSize: root.digitHeight * 0.42
        height: root.digitHeight
        verticalAlignment: Text.AlignBottom
        bottomPadding: -root.digitHeight * 0.05
    }
}
