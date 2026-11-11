//@ pragma ShellId wiiperland
import QtQuick
import Quickshell
import Quickshell.Io
import qs.home
import qs.services
import qs.overlays

ShellRoot {
    Variants {
        model: Quickshell.screens
        HomeScreen {}
    }

    Toasts {}
    HomeMenu { id: homeMenu }
    Osd { id: osd }
    LockScreen { id: lock }
    Welcome {}

    // make sure the notification server, the pointer sizing and the music start with the shell
    readonly property int _unread: Messages.unread
    readonly property int _cursorSize: Cursor.size
    readonly property string _music: Music.mood     // the menu music

    IpcHandler {
        target: "shell"
        function home(): void { homeMenu.close(); Menu.closePreviews(); Menu.arrive() }
        function toast(title: string, body: string): void { Messages.local(title, body) }
        function osd(kind: string): void { osd.show(kind) }
    }
}
