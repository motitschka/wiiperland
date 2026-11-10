pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Weather for the Forecast Channel, from wttr.in (no API key).
// config.json: "forecast": { "location": "Prague", "units": "metric", "enabled": true }
// An empty location lets wttr.in guess from your IP address.
Singleton {
    id: root
    readonly property var cfg: Config.data.forecast ?? ({})
    readonly property bool enabled: cfg.enabled ?? true
    readonly property string location: cfg.location ?? ""
    readonly property bool metric: (cfg.units ?? "metric") !== "imperial"

    property bool ready: false
    property string place: ""
    property int temp: 0
    property string desc: ""
    property string kind: "sun"           // sun|partly|cloud|fog|rain|snow|storm
    property var days: []                 // [{ name, max, min, kind }]

    function kindFor(code: int): string {
        if (code === 113) return "sun"
        if (code === 116) return "partly"
        if (code === 119 || code === 122) return "cloud"
        if ([143, 248, 260].includes(code)) return "fog"
        if ([200, 386, 389, 392, 395].includes(code)) return "storm"
        if ([179, 182, 227, 230, 317, 320, 323, 326, 329, 332, 335, 338, 350, 362, 365, 368, 371, 374, 377].includes(code)) return "snow"
        return "rain"
    }

    function refresh(): void { if (enabled && !proc.running) proc.running = true }
    onLocationChanged: refresh()

    Process {
        id: proc
        command: ["curl", "-sf", "--max-time", "20", "https://wttr.in/" + encodeURIComponent(root.location) + "?format=j1"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const j = JSON.parse(text)
                    const c = j.current_condition[0]
                    root.temp = parseInt(root.metric ? c.temp_C : c.temp_F)
                    root.desc = c.weatherDesc[0].value
                    root.kind = root.kindFor(parseInt(c.weatherCode))
                    const a = j.nearest_area && j.nearest_area[0]
                    root.place = root.location || (a ? a.areaName[0].value : "")
                    root.days = j.weather.map(d => ({
                        name: Qt.formatDate(new Date(d.date + "T12:00:00"), "ddd"),
                        max: parseInt(root.metric ? d.maxtempC : d.maxtempF),
                        min: parseInt(root.metric ? d.mintempC : d.mintempF),
                        kind: root.kindFor(parseInt(d.hourly[4].weatherCode))
                    }))
                    root.ready = true
                } catch (e) {
                    console.warn("weather: bad response", e)
                }
            }
        }
    }

    Timer {
        interval: 30 * 60 * 1000
        running: root.enabled
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
