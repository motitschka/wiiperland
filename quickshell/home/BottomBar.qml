import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.services

// The pale grey bottom panel. A wide, gentle recess in the middle lets the
// striped background show through and holds the clock; a thin pale-blue line
// runs along the whole top edge. Round buttons sit in shallow sockets at both
// ends, and the date sits under the recess.
Item {
    id: root
    property int unread: 0
    signal homeClicked()
    signal mailClicked()

    readonly property real hh: height
    readonly property real ww: width
    // Widths follow the screen width up to 16:9. Narrower screens get a
    // narrower recess (it stays clear of the buttons), wider ones don't
    // stretch it.
    readonly property real dw: Math.min(ww, hh * 16 / 9)
    readonly property real y0: hh * 0.726          // bar top edge
    readonly property real y1: hh * 0.830          // bottom of the recess
    readonly property real cx: ww / 2
    readonly property real halfBottom: dw * 0.172
    readonly property real curveW: dw * 0.163
    readonly property real l2: cx - halfBottom
    readonly property real l1: l2 - curveW
    readonly property real r2: cx + halfBottom
    readonly property real r1: r2 + curveW
    readonly property real lineW: Math.max(1.5, hh * 0.0055)
    readonly property real btnR: hh * 0.083
    readonly property real btnX: hh * 0.154        // button centre, from the screen edge
    readonly property real btnY: hh * 0.841

    // Arriving on the menu shows "<brand> Menu" in the recess for two
    // seconds, then cross-fades to the clock.
    property real labelShown: 0
    function arrive(): void { toClock.stop(); labelShown = 1; hold.restart() }
    Timer { id: hold; interval: 2000; onTriggered: toClock.restart() }
    NumberAnimation { id: toClock; target: root; property: "labelShown"; to: 0; duration: 450; easing.type: Easing.InOutQuad }

    // The bar's top edge, `dy` lower. Used for the line and its soft shadow.
    component Edge: ShapePath {
        id: edge
        property real dy: 0
        fillColor: "transparent"
        startX: -root.hh * 0.02; startY: root.y0 + edge.dy
        PathLine { x: root.l1; y: root.y0 + edge.dy }
        PathCubic {
            x: root.l2; y: root.y1 + edge.dy
            control1X: root.l1 + root.curveW * 0.5; control1Y: root.y0 + edge.dy
            control2X: root.l2 - root.curveW * 0.5; control2Y: root.y1 + edge.dy
        }
        PathLine { x: root.r2; y: root.y1 + edge.dy }
        PathCubic {
            x: root.r1; y: root.y0 + edge.dy
            control1X: root.r2 + root.curveW * 0.5; control1Y: root.y1 + edge.dy
            control2X: root.r1 - root.curveW * 0.5; control2Y: root.y0 + edge.dy
        }
        PathLine { x: root.ww + root.hh * 0.02; y: root.y0 + edge.dy }
    }

    Shape {
        id: body
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        layer.enabled: true   // also the mask that keeps the shadow inside the bar

        ShapePath {
            strokeColor: "transparent"
            fillGradient: LinearGradient {
                x1: 0; y1: root.y0; x2: 0; y2: root.hh
                GradientStop { position: 0.0; color: Theme.barTop }
                GradientStop { position: 0.55; color: Theme.barBottom }
                GradientStop { position: 1.0; color: Qt.darker(Theme.barBottom, 1.03) }
            }
            startX: 0; startY: root.y0
            PathLine { x: root.l1; y: root.y0 }
            PathCubic {
                x: root.l2; y: root.y1
                control1X: root.l1 + root.curveW * 0.5; control1Y: root.y0
                control2X: root.l2 - root.curveW * 0.5; control2Y: root.y1
            }
            PathLine { x: root.r2; y: root.y1 }
            PathCubic {
                x: root.r1; y: root.y0
                control1X: root.r2 + root.curveW * 0.5; control1Y: root.y1
                control2X: root.r1 - root.curveW * 0.5; control2Y: root.y0
            }
            PathLine { x: root.ww; y: root.y0 }
            PathLine { x: root.ww; y: root.hh }
            PathLine { x: 0; y: root.hh }
            PathLine { x: 0; y: root.y0 }
        }
    }

    // Soft shadow under the edge, darkest right under the line and gone
    // `shadeDepth` below it. Many strokes centred on the edge, each wider and
    // fainter than the last, add up to a smooth falloff that follows the
    // curves; a light blur melts the steps between them, and the bar body
    // masks off their upper halves.
    readonly property int shadeSteps: 40
    readonly property real shadeDepth: hh * 0.1
    readonly property real shadeMax: 0.45            // darkness at the line
    function shade(i: int): real {                   // wanted darkness in step i
        return i >= shadeSteps ? 0 : shadeMax * Math.pow(1 - (i + 0.5) / shadeSteps, 1.25)
    }
    Item {
        anchors.fill: parent
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true; blur: 1; blurMax: Math.max(2, Math.round(root.hh * 0.006))
            maskEnabled: true; maskSource: body
        }
        Repeater {
            model: root.shadeSteps
            Shape {
                id: step
                required property int index
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                Edge {
                    strokeWidth: root.shadeDepth * 2 * (step.index + 1) / root.shadeSteps
                    // with the wider strokes under it, step i reaches shade(i)
                    strokeColor: Qt.alpha(Theme.barShade,
                        1 - (1 - root.shade(step.index)) / (1 - root.shade(step.index + 1)))
                }
            }
        }
    }

    // the thin pale-blue line along the whole edge, with a faint white halo
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        Edge { strokeWidth: root.lineW * 1.8; strokeColor: "#59ffffff" }
        Edge { strokeWidth: root.lineW; strokeColor: Theme.blueLine }
    }

    // Shallow sockets the buttons sit in: soft pockets that run off the screen
    // edge, a little darker toward their top, with a light lip and a soft
    // groove along the bottom and around the end that faces the middle. No
    // hard outline: the whole socket is blurred.
    readonly property real socketR: btnR * 1.28
    // Part of a socket's rim, `off` outside the pocket: the bottom edge from
    // the screen edge, then the round end from angle a0 to a1 (0 = facing the
    // middle, clockwise positive). Drawn for the left socket; the right one
    // is mirrored.
    component Rim: ShapePath {
        id: rim
        property real off: 0
        property real a0: Math.PI / 2
        property real a1: 0
        readonly property real cx: root.btnX + root.socketR
        readonly property real cy: root.socketR
        readonly property real rr: root.socketR + off
        fillColor: "transparent"; capStyle: ShapePath.RoundCap
        startX: rim.a0 > 1.57 ? 0 : rim.cx + rim.rr * Math.cos(rim.a0)
        startY: rim.cy + rim.rr * Math.sin(rim.a0)
        PathLine { x: rim.cx + rim.rr * Math.cos(rim.a0); y: rim.cy + rim.rr * Math.sin(rim.a0) }
        PathArc {
            x: rim.cx + rim.rr * Math.cos(rim.a1); y: rim.cy + rim.rr * Math.sin(rim.a1)
            radiusX: rim.rr; radiusY: rim.rr
            direction: PathArc.Counterclockwise
        }
    }
    component Socket: Item {
        id: socket
        property bool onRight: false
        readonly property real r: root.socketR
        readonly property real lip: root.hh * 0.007
        width: root.btnX + r * 2; height: r * 2
        x: onRight ? root.ww - root.btnX - r : -r
        y: root.btnY - r
        layer.enabled: true
        layer.effect: MultiEffect { blurEnabled: true; blur: 1; blurMax: Math.max(3, Math.round(root.hh * 0.016)) }
        Rectangle {   // the pocket
            anchors.fill: parent; radius: socket.r
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.alpha(Theme.barShade, 0.16) }
                GradientStop { position: 0.45; color: Qt.alpha(Theme.barShade, 0.05) }
                GradientStop { position: 1.0; color: Qt.alpha(Theme.barShade, 0.0) }
            }
        }
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            transform: Scale { origin.x: socket.width / 2; xScale: socket.onRight ? -1 : 1 }
            // groove just outside, then the light lip, both fading toward the top
            Rim { off: socket.lip * 1.6; strokeWidth: socket.lip; strokeColor: Qt.alpha(Theme.barShade, 0.2) }
            Rim { off: socket.lip * 1.6; a0: 0; a1: -Math.PI / 3; strokeWidth: socket.lip; strokeColor: Qt.alpha(Theme.barShade, 0.08) }
            Rim { off: socket.lip * 0.5; strokeWidth: socket.lip; strokeColor: "#80ffffff" }
            Rim { off: socket.lip * 0.5; a0: 0; a1: -Math.PI / 3; strokeWidth: socket.lip; strokeColor: "#38ffffff" }
        }
    }
    Socket {}
    Socket { onRight: true }

    // Clock in the recess (the colon is on the centre line) and the date below
    SegmentClock {
        digitHeight: root.hh * 0.075
        color: Theme.clockGrey
        x: root.cx
        y: root.hh * 0.768 - digitHeight / 2
        opacity: 1 - root.labelShown
    }
    Text {
        text: Config.brand + " Menu"
        opacity: root.labelShown
        visible: opacity > 0
        color: "#5fcbe6"
        font.family: Theme.fontMedium; font.weight: Font.Medium
        font.pixelSize: root.hh * 0.066
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.hh * 0.768 - height / 2
    }
    Text {
        text: Time.dateText
        color: Theme.dateGrey
        font.family: Theme.fontBold; font.weight: Font.Bold
        font.pixelSize: root.hh * 0.066
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.hh * 0.886 - height / 2
    }

    // Corner buttons
    WiiButton {
        radius: root.btnR
        x: root.btnX - radius; y: root.btnY - radius
        onClicked: root.homeClicked()
        // the owner's img/home-button.* replaces the brand word
        Image {
            id: homeFace
            anchors.centerIn: parent
            width: parent.width * 0.66; height: width
            source: Assets.image("home-button")
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            visible: status === Image.Ready
        }
        Text {
            visible: !homeFace.visible
            anchors.centerIn: parent
            text: Config.brand
            font.family: Theme.fontBold; font.weight: Font.Bold
            // cap height about a fifth of the button; longer brands get smaller
            font.pixelSize: Math.min(parent.height * 0.3, parent.width * 1.2 / Math.max(3, text.length))
            color: "#9c9da1"
            style: Text.Raised; styleColor: "#ffffff"
        }
    }
    WiiButton {
        radius: root.btnR
        x: root.ww - root.btnX - radius; y: root.btnY - radius
        glowing: root.unread > 0
        onClicked: root.mailClicked()
        // the owner's img/mail.* replaces the drawn envelope
        Image {
            id: mailFace
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * (root.unread > 0 ? 0.2 : 0.27)
            width: parent.width * 0.5; height: width * 0.8
            source: Assets.image("mail")
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectFit
            visible: status === Image.Ready
        }
        MailIcon {
            visible: !mailFace.visible
            color: "#9c9da1"; flapColor: "#d9dadf"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * (root.unread > 0 ? 0.25 : 0.33)
            width: parent.width * 0.52; height: width * 0.66
        }
        Text {
            visible: root.unread > 0
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.6
            text: root.unread > 99 ? "99+" : root.unread
            font.family: Theme.fontBold; font.weight: Font.Bold
            font.pixelSize: parent.height * 0.2
            color: "#9c9da1"
        }
    }
}
