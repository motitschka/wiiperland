#!/usr/bin/env python3
"""Build the Wiiperland XCursor theme from assets/cursor/hand.svg.

Needs rsvg-convert and ImageMagick (magick). Output:
assets/cursor/Wiiperland/{index.theme,cursors/*}. Shapes this theme doesn't
draw (text beam, resize arrows, ...) are inherited from Adwaita.

    python3 tools/make-cursor.py
"""
import os
import struct
import subprocess
import tempfile

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
SRC = os.path.join(ROOT, "assets", "cursor", "hand.svg")
OUT = os.path.join(ROOT, "assets", "cursor", "Wiiperland")
SIZES = [24, 32, 48, 64, 96]
HOT = (15.0 / 64, 1.0 / 64)          # fingertip, as a fraction of the size
# every name apps use for the normal arrow and the link hand
NAMES = ["default", "left_ptr", "arrow", "top_left_arrow", "pointer", "hand1", "hand2",
         "pointing_hand", "center_ptr", "e29285e634086352946a0e7090d73106",
         "9d800788f1b08800ae810202380a0822"]


def rgba(size: int) -> bytes:
    with tempfile.TemporaryDirectory() as tmp:
        png = os.path.join(tmp, "c.png")
        subprocess.run(["rsvg-convert", "-w", str(size), "-h", str(size), SRC, "-o", png], check=True)
        return subprocess.run(["magick", png, "-depth", "8", "RGBA:-"], check=True, capture_output=True).stdout


def argb_premultiplied(raw: bytes) -> bytes:
    out = bytearray()
    for i in range(0, len(raw), 4):
        r, g, b, a = raw[i:i + 4]
        out += struct.pack("<I", (a << 24) | ((r * a // 255) << 16) | ((g * a // 255) << 8) | (b * a // 255))
    return bytes(out)


def xcursor(images):
    """images: list of (nominal, width, height, xhot, yhot, argb_bytes)"""
    header = struct.pack("<4sIII", b"Xcur", 16, 0x10000, len(images))
    toc, chunks = b"", b""
    pos = 16 + 12 * len(images)
    for nominal, w, h, xh, yh, px in images:
        chunk = struct.pack("<IIIIIIIII", 36, 0xFFFD0002, nominal, 1, w, h, xh, yh, 0) + px
        toc += struct.pack("<III", 0xFFFD0002, nominal, pos)
        chunks += chunk
        pos += len(chunk)
    return header + toc + chunks


def main():
    os.makedirs(os.path.join(OUT, "cursors"), exist_ok=True)
    images = []
    for n in SIZES:
        px = argb_premultiplied(rgba(n))
        images.append((n, n, n, round(HOT[0] * n), round(HOT[1] * n), px))
    main_file = os.path.join(OUT, "cursors", NAMES[0])
    with open(main_file, "wb") as f:
        f.write(xcursor(images))
    for name in NAMES[1:]:
        link = os.path.join(OUT, "cursors", name)
        if os.path.lexists(link):
            os.remove(link)
        os.symlink(NAMES[0], link)
    with open(os.path.join(OUT, "index.theme"), "w") as f:
        f.write("[Icon Theme]\nName=Wiiperland\nComment=Wii-style pointing hand\nInherits=Adwaita\n")
    with open(os.path.join(OUT, "cursor.theme"), "w") as f:
        f.write("[Icon Theme]\nInherits=Wiiperland\n")
    print("wrote", OUT, "sizes", SIZES)


if __name__ == "__main__":
    main()
