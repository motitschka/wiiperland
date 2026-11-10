//@ pragma ShellId wiiperland
import QtQuick
import Quickshell
import Quickshell.Io
import qs.home
import qs.services

ShellRoot {
    Variants {
        model: Quickshell.screens
        HomeScreen {}
    }

    IpcHandler {
        target: "shell"
        function home(): void { }
        function toast(title: string, body: string): void { console.log("toast", title, body) }
        function osd(kind: string): void { console.log("osd", kind) }
    }
}
