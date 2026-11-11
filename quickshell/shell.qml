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
    Startup {}

    // make sure the notification server and the pointer sizing start with the shell
    readonly property int _unread: Messages.unread
    readonly property int _cursorSize: Cursor.size

    IpcHandler {
        target: "shell"
        function home(): void { homeMenu.close(); Menu.closePreviews(); Menu.arrive() }
        function toast(title: string, body: string): void { Messages.local(title, body) }
        function osd(kind: string): void { osd.show(kind) }
    }
}
