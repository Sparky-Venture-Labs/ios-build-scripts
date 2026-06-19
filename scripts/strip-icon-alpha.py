#!/usr/bin/env python3
"""
Flatten an App Store icon so it has no alpha channel.

The App Store rejects the 1024x1024 marketing icon if it has an alpha
(transparency) channel. Icons exported from most design tools are RGBA by
default, so this trips people up at upload time.

This takes an RGBA PNG, paints it onto a solid background color, and saves a
flat RGB PNG that passes Apple's check. The image looks the same; it just
drops transparency.

Needs Pillow:  pip install Pillow

Usage:
    python3 strip-icon-alpha.py in.png out.png
    python3 strip-icon-alpha.py in.png out.png "#121212"   (background hex; default white)
"""

import sys
from PIL import Image


def hex_to_rgb(value):
    value = value.lstrip("#")
    if len(value) != 6:
        raise ValueError("Background must be a 6-digit hex color, e.g. #121212")
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4))


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 strip-icon-alpha.py in.png out.png [#bgcolor]")
        sys.exit(1)

    src = sys.argv[1]
    dst = sys.argv[2]
    bg = hex_to_rgb(sys.argv[3]) if len(sys.argv) > 3 else (255, 255, 255)

    img = Image.open(src)

    if img.mode in ("RGBA", "LA") or (img.mode == "P" and "transparency" in img.info):
        img = img.convert("RGBA")
        flat = Image.new("RGB", img.size, bg)
        flat.paste(img, mask=img.split()[-1])  # use alpha as the paste mask
    else:
        flat = img.convert("RGB")

    flat.save(dst, "PNG")
    print(f"Saved {dst} as flat RGB ({flat.size[0]}x{flat.size[1]}, no alpha).")


if __name__ == "__main__":
    main()
