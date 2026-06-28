#!/usr/bin/env python3
"""Compose App Store listing frames: a two-tone serif headline over a real
iPhone 16 Pro render (frameit device PNG) with a Phorm screenshot composited in."""
import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.dirname(os.path.abspath(__file__))
SHOTS = os.path.join(ROOT, "raw")
FRAMES_DIR = os.path.join(ROOT, "frames")
FONTS_DIR = os.path.join(ROOT, "fonts")
OUT69 = os.path.join(ROOT, "listing", "iphone-6.9")
OUT65 = os.path.join(ROOT, "listing", "iphone-6.5")
for d in (OUT69, OUT65):
    os.makedirs(d, exist_ok=True)

SERIF = os.path.join(FONTS_DIR, "NotoSerifDisplay[wdth,wght].ttf")

def font(size, weight="Bold"):
    f = ImageFont.truetype(SERIF, size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f

def hx(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

W, H = 1290, 2796  # App Store 6.9"

FRAME_FILE = "Apple iPhone 16 Pro Black Titanium.png"
# Screen cutout measured by flood-filling the frame's transparent screen region
# (see README). Exactly 1206×2622 — the iPhone 16 Pro / iPhone 17 screenshot size.
SCREEN_BOX = (72, 69, 1278, 2691)   # left, top, right, bottom (frame-native px)
_cache = {}

def load_frame():
    if "frame" not in _cache:
        _cache["frame"] = Image.open(os.path.join(FRAMES_DIR, FRAME_FILE)).convert("RGBA")
    return _cache["frame"]

def screen_mask(frame):
    """Exact screen-hole mask (L): the transparent region connected to the frame's
    centre, dilated a few px so the shot tucks under the bezel. Clipping the shot to
    this mask fills precisely the rounded screen shape — no exterior corner 'ears',
    no cream gap on the straight edges — regardless of the frame's corner geometry."""
    if "mask" not in _cache:
        alpha = frame.split()[3].copy()                 # 0 = hole, 255 = body
        fw, fh = frame.size
        ImageDraw.floodfill(alpha, (fw // 2, fh // 2), 128, thresh=8)  # tag the screen hole
        mask = alpha.point(lambda p: 255 if p == 128 else 0)
        mask = mask.filter(ImageFilter.MaxFilter(7))     # dilate ~3px under the bezel
        _cache["mask"] = mask
    return _cache["mask"]

def make_device(screen_path, target_w):
    """Screenshot clipped to the exact screen-hole mask, behind the titanium body."""
    frame = load_frame()
    fw, fh = frame.size
    sx, sy, ex, ey = SCREEN_BOX
    shot = Image.open(screen_path).convert("RGB").resize((ex - sx, ey - sy), Image.LANCZOS)
    layer = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    layer.paste(shot, (sx, sy))
    layer.putalpha(screen_mask(frame))                  # show shot only in the screen hole
    dev = Image.new("RGBA", (fw, fh), (0, 0, 0, 0))
    dev.alpha_composite(layer)
    dev.alpha_composite(frame)
    scale = target_w / fw
    return dev.resize((target_w, round(fh * scale)), Image.LANCZOS)

# hero first; captions are locked in the plan's Global Constraints.
FRAMES = [
    dict(shot="01-leaderboard.png", lead="Ấn vàng",      pop="cho người dẫn đầu."),
    dict(shot="02-round-entry.png", lead="N–1 ô số.",    pop="Ô cuối tự cộng."),
    dict(shot="03-summary.png",     lead="Kết bàn.",     pop="Lưu lại."),
    dict(shot="04-history.png",     lead="Mọi phiên cũ", pop="vẫn ở chỗ cũ."),
    dict(shot="05-new-session.png", lead="Đặt tên.",     pop="Vào bàn ngay."),
    dict(shot="06-empty.png",       lead="Mở app",       pop="là chơi."),
]

BG  = hx("F3E8D2")   # cream card
INK = hx("5A1612")   # cinnabar-deep lead
POP = hx("D9B25A")   # gold accent

MARGIN = 104
HEAD_TOP = 170
DEVICE_W = 1130
DEV_TOP = 612
LH = 1.04

def fit_size(draw, lead, pop, maxw, hi=150, lo=82):
    for s in range(hi, lo - 1, -2):
        f = font(s, "Bold")
        if draw.textlength(lead, font=f) <= maxw and draw.textlength(pop, font=f) <= maxw:
            return s
    return lo

def main():
    for i, fr in enumerate(FRAMES, 1):
        canvas = Image.new("RGBA", (W, H), BG + (255,))
        draw = ImageDraw.Draw(canvas)
        maxw = W - 2 * MARGIN

        size = fit_size(draw, fr["lead"], fr["pop"], maxw)
        hfont = font(size, "Bold")
        lh = int(size * LH)
        draw.text((MARGIN, HEAD_TOP), fr["lead"], font=hfont, fill=INK)
        draw.text((MARGIN, HEAD_TOP + lh), fr["pop"], font=hfont, fill=POP)

        dev = make_device(os.path.join(SHOTS, fr["shot"]), DEVICE_W)
        dev_x = (W - DEVICE_W) // 2

        alpha = dev.split()[3]
        sil = Image.composite(Image.new("RGBA", dev.size, (0, 0, 0, 70)),
                              Image.new("RGBA", dev.size, (0, 0, 0, 0)), alpha)
        shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        shadow.alpha_composite(sil, (dev_x, DEV_TOP + 30))
        shadow = shadow.filter(ImageFilter.GaussianBlur(46))
        canvas.alpha_composite(shadow)
        canvas.alpha_composite(dev, (dev_x, DEV_TOP))

        out = f"{i:02d}.png"
        rgb = canvas.convert("RGB")
        rgb.save(os.path.join(OUT69, out))
        rgb.resize((1242, 2688), Image.LANCZOS).save(os.path.join(OUT65, out))
        print("✓", out, f'{fr["lead"]} {fr["pop"]}')

    # contact sheet
    TH_H = 828
    TH_W = round(TH_H * W / H)
    GAP, PAD_CS = 18, 22
    sheet_w = len(FRAMES) * TH_W + (len(FRAMES) - 1) * GAP + 2 * PAD_CS
    sheet = Image.new("RGB", (sheet_w, TH_H + 2 * PAD_CS), (255, 255, 255))
    for i in range(1, len(FRAMES) + 1):
        th = Image.open(os.path.join(OUT69, f"{i:02d}.png")).resize((TH_W, TH_H), Image.LANCZOS)
        sheet.paste(th, (PAD_CS + (i - 1) * (TH_W + GAP), PAD_CS))
    sheet.save(os.path.join(ROOT, "contact-sheet.png"))
    print("✓ contact-sheet.png")
    print("\nDone →", OUT69)

if __name__ == "__main__":
    main()
