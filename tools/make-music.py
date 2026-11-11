#!/usr/bin/env python3
"""Synthesise Wiiperland's built-in menu music (original, CC0).

A slow, soft loop: warm pads on four chords, a sparse bell melody and a light
plucked pulse. Everything is made here from sine waves; nothing is sampled or
transcribed from anywhere. Notes that ring past the end wrap around to the
start, so the file loops without a seam.

    python3 tools/make-music.py        # writes quickshell/assets/music/menu.ogg

Needs ffmpeg (for the Ogg Vorbis encoding). Your own music/menu.* in the asset
folder replaces this file; see docs/assets.md.
"""
import array
import math
import os
import random
import subprocess
import sys
import tempfile
import wave

RATE = 32000
BPM = 76
BEAT = 60 / BPM
BARS = 8
LENGTH = int(RATE * BEAT * 4 * BARS)
OUT = os.path.join(os.path.dirname(__file__), "..", "quickshell", "assets", "music", "menu.ogg")

left = array.array("d", bytes(8 * LENGTH))
right = array.array("d", bytes(8 * LENGTH))


def hz(n):  # MIDI note -> Hz
    return 440 * 2 ** ((n - 69) / 12)


def add(start_beat, note, beats, amp, attack, release, partials, pan=0.0, vibrato=0.0):
    """Mix one note in. It may run past the end: the rest wraps to the start."""
    f = hz(note)
    hold = beats * BEAT
    n = int((hold + release) * RATE)
    s0 = int(start_beat * BEAT * RATE)
    gl, gr = amp * (1 - pan) / 2, amp * (1 + pan) / 2
    two_pi = 2 * math.pi
    for i in range(n):
        t = i / RATE
        e = t / attack if t < attack else 1.0
        if t > hold:
            e *= math.exp(-(t - hold) / (release / 4))
        ph = two_pi * f * t + (vibrato * math.sin(two_pi * 4.5 * t) if vibrato else 0.0)
        v = 0.0
        for mult, a, decay in partials:
            v += a * math.sin(ph * mult) * (math.exp(-t / decay) if decay else 1.0)
        v *= e
        j = (s0 + i) % LENGTH
        left[j] += v * gl
        right[j] += v * gr


PAD = ((1, 1.0, 0), (2, 0.18, 0), (3, 0.05, 0))
BELL = ((1, 1.0, 0.9), (2.0, 0.3, 0.5), (3.01, 0.12, 0.25), (4.2, 0.05, 0.12))
PLUCK = ((1, 1.0, 0.35), (2, 0.35, 0.2), (3, 0.1, 0.1))
BASS = ((1, 1.0, 1.2), (2, 0.25, 0.6))

# Two bars each: Fmaj9, Dm9, Bbmaj7, C6/9 (root, then the pad's voicing)
CHORDS = [
    (41, (57, 60, 64, 67)),
    (38, (57, 60, 65, 64)),
    (34, (58, 62, 65, 69)),
    (36, (55, 60, 64, 69)),
]
# Sparse bell melody, (beat within the 2-bar phrase, note, length in beats)
MELODY = [
    [(0.5, 72, 1.5), (2.5, 76, 1), (4, 79, 2), (6.5, 77, 1)],
    [(0, 77, 2), (3, 74, 1), (4.5, 72, 1.5), (7, 69, 1)],
    [(0.5, 74, 1.5), (2.5, 77, 1), (4, 81, 2.5), (7, 77, 1)],
    [(0, 76, 2), (2.5, 72, 1), (4, 74, 1.5), (6, 72, 2)],
]

rnd = random.Random(11)
for k, (root, voicing) in enumerate(CHORDS):
    at = k * 8
    for i, n in enumerate(voicing):
        add(at, n, 7.6, 0.11, attack=0.9, release=2.4, partials=PAD, pan=(-0.5, 0.5, -0.2, 0.2)[i], vibrato=0.6)
    add(at, root, 3.5, 0.22, attack=0.03, release=1.5, partials=BASS)
    add(at + 4, root + 7, 1.5, 0.14, attack=0.03, release=1.2, partials=BASS)
    add(at + 6, root, 1.5, 0.16, attack=0.03, release=1.2, partials=BASS)
    # a light off-beat pulse on chord tones
    for b in range(8):
        n = voicing[(b * 3 + k) % 4] + 12
        add(at + b + 0.5, n, 0.25, 0.045 + 0.015 * rnd.random(), attack=0.004, release=0.5, partials=PLUCK,
            pan=0.6 if b % 2 else -0.6)
    for beat, n, length in MELODY[k]:
        add(at + beat, n, length * 0.5, 0.13, attack=0.006, release=2.2, partials=BELL, pan=0.15 * math.sin(beat))

peak = max(max(abs(v) for v in left), max(abs(v) for v in right))
scale = 0.6 / peak          # about -4.4 dBFS: the shell plays it quietly anyway
frames = array.array("h")
for l, r in zip(left, right):
    frames.append(int(l * scale * 32767))
    frames.append(int(r * scale * 32767))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
    wav = tmp.name
try:
    with wave.open(wav, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(frames.tobytes())
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", wav, "-c:a", "libvorbis", "-q:a", "3", OUT], check=True)
finally:
    os.unlink(wav)
print(f"{OUT}  {LENGTH / RATE:.1f}s  {os.path.getsize(OUT) // 1024} KB")
