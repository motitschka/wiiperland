pragma Singleton
import QtQuick
import Quickshell

// Wall clock used by the bottom bar.
Singleton {
    readonly property bool use24h: Config.clock24h
    readonly property date now: clock.date ?? new Date()   // the clock has no date for an instant at start-up
    readonly property int hours12: { const h = now.getHours() % 12; return h === 0 ? 12 : h }
    readonly property int hours: use24h ? now.getHours() : hours12
    readonly property int minutes: now.getMinutes()
    readonly property bool pm: now.getHours() >= 12
    readonly property bool colonOn: now.getSeconds() % 2 === 0
    readonly property string dateText: Qt.formatDate(now, "ddd M/d")   // "Fri 4/18"

    SystemClock { id: clock; precision: SystemClock.Seconds }
}
