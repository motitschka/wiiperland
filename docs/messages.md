# Message Board (notifications)

Wiiperland's shell **is** the notification server (`org.freedesktop.Notifications`),
so don't run dunst or mako alongside it.

- **Toasts**: each notification drops in as a small white card at the top of
  the focused screen, plays the `mail` sound and disappears after its timeout
  (5 s by default; hovering pauses it). Clicking runs the notification's
  default action.
- **Mail button**: shows the unread count and pulses blue while there are
  unread messages.
- **Message Board**: click the mail button. Every message is kept on a sheet
  of graph paper as a card with its icon, title, text, app and time. Click a
  card for its default action (while the sending app is still running).
  Hovering shows a × to delete it; **Clear All** empties the board. Opening the
  board marks everything as read. **Esc** or **Back** closes it.

Messages are saved to `~/.local/state/wiiperland/messages.json` (or
`$WIIPERLAND_STATE/messages.json`), so the board survives restarts. Up to 200
are kept.

## Settings (`config.json`)
```json
"messages": { "keep": 200 }
```

## IPC
| Command | Meaning |
|---|---|
| `wii ipc messages send "<title>" "<body>"` | Post a message from the desktop itself |
| `wii ipc messages read` | Mark all as read |
| `wii ipc messages clear` | Delete all |
| `wii ipc messages dnd true\|false` | Do not disturb: no toasts or sounds (critical messages still pop up) |
| `wii ipc messages state` | `{"unread":…,"kept":…,"toasts":…,"dnd":…}` |
| `wii ipc menu board` | Open the board |
| `wii ipc shell toast "<title>" "<body>"` | Same as `messages send` (used by `wii screenshot`) |

## Code
| File | Role |
|---|---|
| `services/Messages.qml` | NotificationServer, board and toast models, persistence, IPC |
| `overlays/Toasts.qml` | top-of-screen toast layer (`wiiperland-toast`) |
| `home/MessageBoard.qml` | the board overlay on the home screen |

## Tested
In the nested session (its own D-Bus bus, see [development.md](development.md)):
- `notify-send` twice: two toasts with icons drop in, mail button shows 2.
- Opening the board lists both cards; unread drops to 0 and is saved.
- `shell toast` while on another workspace still shows a toast.
