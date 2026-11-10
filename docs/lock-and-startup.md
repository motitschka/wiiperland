# Lock screen and startup screen

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
> shows its own "lock is dead" screen. Switch to a TTY (Ctrl+Alt+F3), log in,
> and run `WAYLAND_DISPLAY=wayland-1 qs -p ~/…/quickshell` to get the lock
> back, or `hyprctl --instance 0 'keyword misc:allow_session_lock_restore 1'`.

### PAM
The lock uses PAM's default `login` service through Quickshell. If your system
needs something else (fingerprint, ...), that is configured in
`/etc/pam.d/`.

## Startup screen
Once per Hyprland session, a white "HELLO AGAIN" screen asks you to take
breaks and stretch, and waits for a click or a key. It then fades into the
menu with the start sound. It's shown again only after logging in again (a
marker file lives in `$XDG_RUNTIME_DIR`).

```json
"startupScreen": true
```

IPC: `wii ipc startup show` / `dismiss`.

## Tested
- Startup screen appears on the first start of the nested session and
  dismisses with a fade.
- `wii lock` locks the nested session (lock surface renders). `isLocked`
  reports `true`.
- Unlocking in testing used the **dev-only** `lock devUnlock` IPC call, which
  works only when `WIIPERLAND_DEV_MODE` is set (the nested session). A real
  password was never typed, so the PAM unlock and wrong-password paths still
  need a check on real hardware.
