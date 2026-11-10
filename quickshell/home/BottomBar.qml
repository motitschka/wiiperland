import QtQuick
import QtQuick.Shapes
import qs.services

// The grey bottom panel: a recess in the middle (where the striped background
// shows through and the clock sits), outlined by a blue line, plus round
// buttons in pockets at both ends.
Item {
    id: root
    property real s: height / 720
    property int unread: 0
    signal homeClicked()
    signal mailClicked()

    readonly property real hh: height
    readonly property real ww: width
    readonly property real y0: hh * 0.727          // bar top edge
    readonly property real y1: hh * 0.852          // bottom of the recess
    readonly property real cx: ww / 2
    readonly property real halfBottom: hh * 0.167
    readonly property real curveW: hh * 0.19
    readonly property real flatW: hh * 0.084
    readonly property real l2: cx - halfBottom
    readonly property real l1: l2 - curveW
    readonly property real pocketW: hh * 0.27
    readonly property real pocketInset: hh * 0.1
    readonly property real l0: pocketW - pocketInset - hh * 0.05
    readonly property real r2: cx + halfBottom
    readonly property real r1: r2 + curveW
    readonly property real r0: ww - l0
    readonly property real lineW: Math.max(2, hh * 0.0055)

    // Bar body
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            fillGradient: LinearGradient {
                x1: 0; y1: root.y0; x2: 0; y2: root.hh
                GradientStop { position: 0.0; color: Theme.barTop }
                GradientStop { position: 1.0; color: Theme.barBottom }
            }
            startX: 0; startY: root.y0
            PathLine { x: root.l1; y: root.y0 }
            PathCubic {
                x: root.l2; y: root.y1
                control1X: root.l1 + root.curveW * 0.55; control1Y: root.y0
                control2X: root.l2 - root.curveW * 0.45; control2Y: root.y1
            }
            PathLine { x: root.r2; y: root.y1 }
            PathCubic {
                x: root.r1; y: root.y0
                control1X: root.r2 + root.curveW * 0.45; control1Y: root.y1
                control2X: root.r1 - root.curveW * 0.55; control2Y: root.y0
            }
            PathLine { x: root.ww; y: root.y0 }
            PathLine { x: root.ww; y: root.hh }
            PathLine { x: 0; y: root.hh }
            PathLine { x: 0; y: root.y0 }
        }

        // white bevel just under the outline
        ShapePath {
            strokeColor: "#b3ffffff"; strokeWidth: root.lineW * 0.8
            fillColor: "transparent"; capStyle: ShapePath.RoundCap
            startX: 0; startY: root.y0 + root.lineW * 1.2
            PathLine { x: root.l1; y: root.y0 + root.lineW * 1.2 }
            PathCubic {
                x: root.l2; y: root.y1 + root.lineW * 1.2
                control1X: root.l1 + root.curveW * 0.55; control1Y: root.y0 + root.lineW * 1.2
                control2X: root.l2 - root.curveW * 0.45; control2Y: root.y1 + root.lineW * 1.2
            }
            PathLine { x: root.r2; y: root.y1 + root.lineW * 1.2 }
            PathCubic {
                x: root.r1; y: root.y0 + root.lineW * 1.2
                control1X: root.r2 + root.curveW * 0.45; control1Y: root.y1 + root.lineW * 1.2
                control2X: root.r1 - root.curveW * 0.55; control2Y: root.y0 + root.lineW * 1.2
            }
            PathLine { x: root.ww; y: root.y0 + root.lineW * 1.2 }
        }

        // grey edge outside the blue part
        ShapePath {
            strokeColor: "#bfc0c2"; strokeWidth: root.lineW * 0.6; fillColor: "transparent"
            startX: 0; startY: root.y0
            PathLine { x: root.ww; y: root.y0 }
        }

        // the blue outline of the recess
        ShapePath {
            strokeColor: Theme.blue; strokeWidth: root.lineW
            fillColor: "transparent"; capStyle: ShapePath.RoundCap; joinStyle: ShapePath.RoundJoin
            startX: root.l0; startY: root.y0
            PathLine { x: root.l1; y: root.y0 }
            PathCubic {
                x: root.l2; y: root.y1
                control1X: root.l1 + root.curveW * 0.55; control1Y: root.y0
                control2X: root.l2 - root.curveW * 0.45; control2Y: root.y1
            }
            PathLine { x: root.r2; y: root.y1 }
            PathCubic {
                x: root.r1; y: root.y0
                control1X: root.r2 + root.curveW * 0.45; control1Y: root.y1
                control2X: root.r1 - root.curveW * 0.55; control2Y: root.y0
            }
            PathLine { x: root.r0; y: root.y0 }
        }
    }

    // Button pockets
    component Pocket: Rectangle {
        width: root.pocketW; height: root.hh * 0.36
        y: root.y0
        radius: root.hh * 0.1
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#e2e3e5" }
            GradientStop { position: 1.0; color: "#c9cacc" }
        }
        border.color: "#b8b9bb"; border.width: Math.max(1, root.hh * 0.0018)
        Rectangle {
            anchors.fill: parent; anchors.margins: parent.border.width
            radius: parent.radius - parent.border.width
            color: "transparent"; border.color: "#90ffffff"; border.width: parent.border.width
        }
    }
    Pocket { x: -root.pocketInset }
    Pocket { x: root.ww - width + root.pocketInset }

    // Clock in the recess and the date under it
    SegmentClock {
        digitHeight: root.hh * 0.052
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.hh * 0.012
        y: root.hh * 0.767 - digitHeight / 2
    }
    Text {
        text: Time.dateText
        color: Theme.greyText
        font.family: Theme.font
        font.pixelSize: root.hh * 0.03
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.hh * 0.882 - height / 2
    }

    // Corner buttons
    WiiButton {
        radius: root.hh * 0.079
        x: root.hh * 0.142 - radius; y: root.hh * 0.858 - radius
        onClicked: root.homeClicked()
        Text {
            anchors.centerIn: parent
            text: Theme.brand
            font.family: Theme.fontBold; font.pixelSize: parent.height * 0.3; font.weight: Font.Bold
            color: "#a3a3a3"
            style: Text.Raised; styleColor: "#ffffff"
        }
    }
    WiiButton {
        radius: root.hh * 0.079
        x: root.ww - root.hh * 0.142 - radius; y: root.hh * 0.858 - radius
        glowing: root.unread > 0
        onClicked: root.mailClicked()
        MailIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * (root.unread > 0 ? 0.24 : 0.32)
            width: parent.width * 0.5; height: width * 0.68
        }
        Text {
            visible: root.unread > 0
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.6
            text: root.unread > 99 ? "99+" : root.unread
            font.family: Theme.fontMedium; font.pixelSize: parent.height * 0.22
            color: "#9c9c9c"
        }
    }
}
