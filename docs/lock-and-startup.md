# Lock screen and welcome screen

## Lock screen
A real session lock (`ext-session-lock`, via Quickshell's `WlSessionLock`)
in the menu style: big segment clock, the date, your user initial and name,
and a rounded password field. Press **Enter** to check the password with PAM.
A wrong password shakes the field and shows a message.

Locking:
- **SUPER+L**, `wii lock`, or **Lock** in the HOME Menu.
- Automatically after `lock.idleMinutes` of inactivity (default 10; apps that
  inhibit idle, like video players, are respected). `0` turns it off.

```json
"lock": { "idleMinutes": 10 }
```

IPC: `wii ipc lock lock`, `wii ipc lock isLocked`.

> If Quickshell crashes while locked, Hyprland keeps the session locked and
> shows its own "lock is dead" screen. Wiiperland sets
> `misc.allow_session_lock_restore`, so a restarted shell takes the lock back:
> switch to a TTY (Ctrl+Alt+F3), log in, and run
> `HYPRLAND_INSTANCE_SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr | head -1) hyprctl dispatch 'hl.dsp.exec_cmd("qs -p <repo>/quickshell")'`.

### PAM
The lock uses PAM's default `login` service through Quickshell. If your system
needs something else (fingerprint, ...), that is configured in
`/etc/pam.d/`.

## Welcome screen
On the **first start of each calendar day**, the menu's striped background
and bar appear with one word, **Welcome**. It stays until you **click
anywhere or press Enter**; there is no timeout and other keys do nothing. It
then fades into the menu with the start sound. The menu music waits until it
is gone.

![](img/welcome.png)

The day it was last shown is kept in `welcome-date` in the state folder
(`~/.local/state/wiiperland`, or `$WIIPERLAND_STATE`), so logging out or
rebooting on the same day doesn't bring it back.

```json
"welcomeScreen": true
```
`false` turns it off. The older name `startupScreen` is still read.

IPC: `wii ipc welcome open` (show it now, whatever the date),
`wii ipc welcome dismiss`, `wii ipc welcome state`. The old
`wii ipc startup dismiss` still works.

## Tested
- Welcome screen (F10) in the nested session: with no `welcome-date` it
  showed on start and wrote today's date; on the next start the same day it
  stayed away; with yesterday's date in the file it showed again. `welcome
  open` forces it, `dismiss` fades to the menu, and the music state was
  `off` while it showed and `playing` after. A real click and the Enter key
  can't be sent in the nested session and need a check on real hardware.
- `wii lock` locks the nested session (lock surface renders). `isLocked`
  reports `true`.
- Unlocking in testing used the **dev-only** `lock devUnlock` IPC call, which
  works only when `WIIPERLAND_DEV_MODE` is set (the nested session). A real
  password was never typed, so the PAM unlock and wrong-password paths still
  need a check on real hardware.
