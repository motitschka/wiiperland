import QtQuick
import qs.services

// "11:10 PM" with a blinking colon. The digits are drawn as thin segments,
// or set in the owner's clock font when <assets>/fonts/clock.ttf exists.
Row {
    id: root
    property real digitHeight: 32
    property color color: Theme.greyText
    spacing: digitHeight * 0.16

    readonly property int h: Time.hours
    readonly property int m: Time.minutes
    readonly property bool useFont: Theme.clockFont !== ""

    Loader { sourceComponent: root.useFont ? fontDigits : segmentDigits }

    Component {
        id: segmentDigits
        Row {
            spacing: root.spacing
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
        }
    }

    Component {
        id: fontDigits
        Row {
            id: fd
            height: root.digitHeight
            // scale the font so that a "0" is exactly digitHeight tall
            TextMetrics { id: probe; font.family: Theme.clockFont; font.pixelSize: 100; text: "0" }
            readonly property real px: probe.tightBoundingRect.height > 0
                ? root.digitHeight * 100 / probe.tightBoundingRect.height : root.digitHeight * 1.38
            Text {
                text: (Time.use24h && root.h < 10 ? "0" : "") + root.h
                color: root.color
                font.family: Theme.clockFont; font.pixelSize: fd.px
                y: root.digitHeight - baselineOffset
            }
            Text {
                text: ":"
                color: root.color
                font.family: Theme.clockFont; font.pixelSize: fd.px
                y: root.digitHeight - baselineOffset
                opacity: Time.colonOn ? 1 : 0.15
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }
            Text {
                text: (root.m < 10 ? "0" : "") + root.m
                color: root.color
                font.family: Theme.clockFont; font.pixelSize: fd.px
                y: root.digitHeight - baselineOffset
            }
        }
    }

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
