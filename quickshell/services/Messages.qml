pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// The Message Board: Wiiperland's notification server.
// Every notification is kept on the board (saved to
// ~/.local/state/wiiperland/messages.json) and shown briefly as a toast.
Singleton {
    id: root

    property int unread: 0
    readonly property alias board: boardModel     // newest first
    readonly property alias toasts: toastModel
    readonly property int maxKept: Config.data.messages?.keep ?? 200
    property bool doNotDisturb: false

    property var _live: ({})                      // id -> Notification
    property int _localId: 1000000

    ListModel { id: boardModel }
    ListModel { id: toastModel }

    NotificationServer {
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: false
        imageSupported: true
        actionsSupported: true
        onNotification: n => {
            n.tracked = true
            root._live[n.id] = n
            n.closed.connect(() => { delete root._live[n.id] })
            root.add({
                nid: n.id,
                app: n.appName || "",
                icon: n.image || (n.appIcon ? Quickshell.iconPath(n.appIcon, true) : ""),
                summary: n.summary || "",
                body: n.body || "",
                urgency: n.urgency,
                hasAction: n.actions.length > 0,
                timeout: n.expireTimeout
            })
        }
    }

    function add(m: var): void {
        const msg = {
            nid: m.nid ?? root._localId++,
            app: m.app ?? "",
            icon: m.icon ?? "",
            summary: m.summary ?? "",
            body: (m.body ?? "").replace(/<[^>]*>/g, ""),
            time: Date.now(),
            urgency: m.urgency ?? 1,
            hasAction: m.hasAction ?? false,
            read: false
        }
        boardModel.insert(0, msg)
        while (boardModel.count > maxKept) boardModel.remove(boardModel.count - 1)
        unread++
        if (!doNotDisturb || msg.urgency === 2) {
            toastModel.append(Object.assign({ timeout: m.timeout > 0 ? m.timeout : 5000 }, msg))
            Sound.play("mail")
        }
        save()
    }

    // A message from the desktop itself (screenshots etc.).
    function local(summary: string, body: string): void {
        add({ app: "Wiiperland", summary: summary, body: body, icon: "" })
    }

    function activate(nid: int): void {
        const n = _live[nid]
        if (n && n.actions.length > 0) {
            const def = n.actions.find(a => a.identifier === "default") ?? n.actions[0]
            def.invoke()
        }
    }

    function dismissToast(index: int): void {
        if (index >= 0 && index < toastModel.count) toastModel.remove(index)
    }

    function remove(index: int): void {
        const m = boardModel.get(index)
        if (!m) return
        const n = _live[m.nid]
        if (n) n.dismiss()
        boardModel.remove(index)
        save()
    }

    function clear(): void {
        for (const k in _live) _live[k].dismiss()
        boardModel.clear()
        unread = 0
        save()
    }

    function markAllRead(): void {
        unread = 0
        for (let i = 0; i < boardModel.count; i++) boardModel.setProperty(i, "read", true)
        save()
    }

    // persistence
    readonly property string stateDir: Quickshell.env("WIIPERLAND_STATE")
        || (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/wiiperland"

    FileView {
        id: store
        path: root.stateDir + "/messages.json"
        printErrors: false
        atomicWrites: true
        onLoaded: {
            try {
                const d = JSON.parse(text())
                boardModel.clear()
                for (const m of d.messages ?? []) boardModel.append(m)
                root.unread = d.unread ?? 0
            } catch (e) { console.warn("messages: could not read", path, e) }
        }
    }
    Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", root.stateDir])
    Timer { id: saveTimer; interval: 400; onTriggered: root._write() }
    function save(): void { saveTimer.restart() }
    function _write(): void {
        const list = []
        for (let i = 0; i < boardModel.count; i++) {
            const m = boardModel.get(i)
            list.push({ nid: m.nid, app: m.app, icon: m.icon.startsWith("image://") ? "" : m.icon,
                        summary: m.summary, body: m.body, time: m.time, urgency: m.urgency, hasAction: false, read: m.read })
        }
        store.setText(JSON.stringify({ unread: root.unread, messages: list }, null, 1))
    }

    IpcHandler {
        target: "messages"
        function send(summary: string, body: string): void { root.local(summary, body) }
        function clear(): void { root.clear() }
        function read(): void { root.markAllRead() }
        function dnd(on: bool): void { root.doNotDisturb = on }
        function state(): string { return JSON.stringify({ unread: root.unread, kept: boardModel.count, toasts: toastModel.count, dnd: root.doNotDisturb }) }
    }
}
