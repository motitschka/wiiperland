#!/usr/bin/env python3
"""Synthesise Wiiperland's UI sounds (original, CC0) into quickshell/assets/sounds.

Soft sine/bell tones with quick attacks and gentle decays. Run again after
changing anything here:  python3 tools/make-sounds.py
"""
import math
import os
import random
import struct
import wave

RATE = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "quickshell", "assets", "sounds")


def env(t, attack, decay):
    """Linear attack then exponential decay."""
    if t < attack:
        return t / attack
    return math.exp(-(t - attack) / decay)


def bell(freq, dur, start=0.0, amp=1.0, decay=0.12, attack=0.004, partials=((1, 1.0), (2.01, 0.25), (3.02, 0.08))):
    def f(t):
        t -= start
        if t < 0 or t > dur:
            return 0.0
        e = env(t, attack, decay)
        return amp * e * sum(a * math.sin(2 * math.pi * freq * m * t) for m, a in partials)
    return f


def glide(f0, f1, dur, amp=1.0, decay=0.03):
    def f(t):
        if t > dur:
            return 0.0
        k = t / dur
        freq = f0 + (f1 - f0) * k
        phase = 2 * math.pi * (f0 * t + (f1 - f0) * t * t / (2 * dur))
        return amp * env(t, 0.002, decay) * math.sin(phase)
    return f


def noise_sweep(dur, amp=0.4):
    rnd = random.Random(7)
    state = {"y": 0.0}

    def f(t):
        if t > dur:
            return 0.0
        k = t / dur
        a = 0.02 + 0.25 * math.sin(math.pi * k)  # filter opens then closes
        state["y"] += a * (rnd.uniform(-1, 1) - state["y"])
        return amp * math.sin(math.pi * k) * state["y"] * 3
    return f


def render(name, voices, dur, gain=0.5):
    n = int(RATE * dur)
    frames = []
    peak = 1e-9
    data = []
    for i in range(n):
        t = i / RATE
        v = sum(fn(t) for fn in voices)
        data.append(v)
        peak = max(peak, abs(v))
    scale = gain / peak
    fade = int(RATE * 0.01)
    for i, v in enumerate(data):
        if i > n - fade:
            v *= (n - i) / fade
        frames.append(struct.pack("<h", int(max(-1, min(1, v * scale)) * 32767)))
    path = os.path.join(OUT, name + ".wav")
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(frames))
    print(f"{path}  {dur:.2f}s")


def note(n):  # MIDI note -> Hz
    return 440 * 2 ** ((n - 69) / 12)


os.makedirs(OUT, exist_ok=True)

# hover: a tiny high tick
render("tick", [glide(2300, 2900, 0.035, decay=0.012)], 0.05, gain=0.25)
# click: short soft pop
render("click", [bell(note(88), 0.09, decay=0.03), glide(900, 500, 0.03, amp=0.4, decay=0.01)], 0.1, gain=0.35)
# page flip: airy swoosh plus a light tick
render("page", [noise_sweep(0.22, amp=0.5), bell(note(91), 0.08, start=0.12, amp=0.3, decay=0.03)], 0.25, gain=0.3)
# open preview: rising two-note chime (E6 -> B6)
render("open", [bell(note(88), 0.35, decay=0.1), bell(note(95), 0.4, start=0.07, decay=0.14)], 0.5, gain=0.4)
# back: falling two-note chime (B5 -> E5)
render("back", [bell(note(83), 0.3, decay=0.08), bell(note(76), 0.35, start=0.07, decay=0.12)], 0.45, gain=0.38)
# start: bright arpeggio C6 E6 G6 C7 with a sparkle
render("start", [bell(note(n), 0.7, start=i * 0.06, decay=0.18, amp=1 - i * 0.12) for i, n in enumerate((84, 88, 91, 96))]
       + [bell(note(103), 0.5, start=0.26, amp=0.25, decay=0.2)], 0.95, gain=0.42)
# mail: gentle two-bell ding (for new notifications)
render("mail", [bell(note(93), 0.8, decay=0.25), bell(note(100), 0.9, start=0.14, decay=0.3, amp=0.7)], 1.1, gain=0.35)
# home menu open/close
render("home", [bell(note(79), 0.4, decay=0.12), bell(note(86), 0.45, start=0.05, decay=0.14), bell(note(91), 0.5, start=0.1, decay=0.16)], 0.65, gain=0.38)
