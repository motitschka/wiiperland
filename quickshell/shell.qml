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

    // make sure the notification server starts with the shell
    readonly property int _unread: Messages.unread

    IpcHandler {
        target: "shell"
        function home(): void { homeMenu.close(); Menu.closePreviews() }
        function toast(title: string, body: string): void { Messages.local(title, body) }
        function osd(kind: string): void { osd.show(kind) }
    }
}
