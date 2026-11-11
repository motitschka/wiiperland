import QtQuick
import qs.services

// "3:30 PM". The colon sits at this item's x = 0: the hours grow to the left
// and the minutes and AM/PM to the right, so nothing shifts when the hour
// gains or loses a digit. The digits are drawn as segments, or set in the
// owner's clock font when <assets>/fonts/clock.ttf exists.
Item {
    id: root
    property real digitHeight: 32
    property color color: "#9b9c9f"
    height: digitHeight

    readonly property int h: Time.hours
    readonly property int m: Time.minutes
    readonly property bool useFont: Theme.clockFont !== ""
    readonly property real gap: digitHeight * 0.11        // between two digits
    readonly property real colonHalf: digitHeight * 0.26  // colon centre to the nearest digit
    // How far the clock reaches to the left and to the right of the colon,
    // for a caller that wants to centre the clock as a whole.
    readonly property real leftExtent: useFont ? (fontClock.item ? fontClock.item.leftExtent : 0) : colonHalf + hours.width
    readonly property real rightExtent: ampm.visible ? ampm.x + ampm.width
        : useFont ? (fontClock.item ? fontClock.item.rightExtent : 0) : minutes.x + minutes.width

    // colon: two small squares
    Repeater {
        model: root.useFont ? 0 : 2
        Rectangle {
            required property int index
            width: root.digitHeight * 0.12; height: width; radius: width * 0.2
            x: -width / 2
            y: root.digitHeight * (index === 0 ? 0.29 : 0.71) - height / 2
            color: root.color
            opacity: Time.colonOn ? 1 : 0.15
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }
    }

    Row {
        id: hours
        visible: !root.useFont
        anchors.right: parent.left; anchors.rightMargin: root.colonHalf
        spacing: root.gap
        SegmentDigit {
            height: root.digitHeight; color: root.color
            value: Math.floor(root.h / 10)
            visible: Time.use24h || value > 0
        }
        SegmentDigit { height: root.digitHeight; color: root.color; value: root.h % 10 }
    }
    Row {
        id: minutes
        visible: !root.useFont
        x: root.colonHalf
        spacing: root.gap
        SegmentDigit { height: root.digitHeight; color: root.color; value: Math.floor(root.m / 10) }
        SegmentDigit { height: root.digitHeight; color: root.color; value: root.m % 10 }
    }

    // the owner's clock font instead of the drawn digits
    Loader {
        id: fontClock
        active: root.useFont
        sourceComponent: Item {
            // scale the font so that a "0" is exactly digitHeight tall
            TextMetrics { id: probe; font.family: Theme.clockFont; font.pixelSize: 100; text: "0" }
            readonly property real px: probe.tightBoundingRect.height > 0
                ? root.digitHeight * 100 / probe.tightBoundingRect.height : root.digitHeight * 1.38
            readonly property real minutesWidth: mm.width
            readonly property real leftExtent: colon.width / 2 + hh.width
            readonly property real rightExtent: colon.width / 2 + mm.width
            Text {
                id: colon
                text: ":"
                color: root.color
                font.family: Theme.clockFont; font.pixelSize: parent.px
                x: -width / 2; y: root.digitHeight - baselineOffset
                opacity: Time.colonOn ? 1 : 0.15
                Behavior on opacity { NumberAnimation { duration: 180 } }
            }
            Text {
                id: hh
                text: (Time.use24h && root.h < 10 ? "0" : "") + root.h
                color: root.color
                font.family: Theme.clockFont; font.pixelSize: parent.px
                anchors.right: colon.left
                y: root.digitHeight - baselineOffset
            }
            Text {
                id: mm
                text: (root.m < 10 ? "0" : "") + root.m
                color: root.color
                font.family: Theme.clockFont; font.pixelSize: parent.px
                anchors.left: colon.right
                y: root.digitHeight - baselineOffset
            }
        }
    }

    Text {
        id: ampm
        visible: !Time.use24h
        text: Time.pm ? "PM" : "AM"
        color: root.color
        font.family: Theme.fontBold; font.weight: Font.Bold
        font.pixelSize: root.digitHeight * 0.55
        x: (root.useFont && fontClock.item ? fontClock.item.minutesWidth + root.digitHeight * 0.2 : minutes.x + minutes.width)
           + root.digitHeight * 0.5
        // sit on the same baseline as the digits
        y: root.digitHeight - baselineOffset
    }
}
