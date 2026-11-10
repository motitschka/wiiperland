pragma Singleton
import QtQuick
import Quickshell

// Wall clock used by the bottom bar.
Singleton {
    property bool use24h: false
    readonly property date now: clock.date
    readonly property int hours12: { const h = now.getHours() % 12; return h === 0 ? 12 : h }
    readonly property int hours: use24h ? now.getHours() : hours12
    readonly property int minutes: now.getMinutes()
    readonly property bool pm: now.getHours() >= 12
    readonly property bool colonOn: now.getSeconds() % 2 === 0
    readonly property string dateText: Qt.formatDate(now, "ddd, M/d")

    SystemClock { id: clock; precision: SystemClock.Seconds }
}
