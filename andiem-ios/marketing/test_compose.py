import os, sys, subprocess
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))

def main():
    # Synthesize a stand-in "raw" screenshot for every frame the compositor expects.
    import compose_listing as C
    os.makedirs(os.path.join(ROOT, "raw"), exist_ok=True)
    for fr in C.FRAMES:
        Image.new("RGB", (1206, 2622), (0x8C, 0x2A, 0x22)).save(os.path.join(ROOT, "raw", fr["shot"]))

    subprocess.run([sys.executable, os.path.join(ROOT, "compose_listing.py")], check=True)

    one = os.path.join(ROOT, "listing", "iphone-6.9", "01.png")
    assert os.path.exists(one), "6.9 frame 01 not generated"
    assert Image.open(one).size == (1290, 2796), "wrong 6.9 size"
    assert Image.open(os.path.join(ROOT, "listing", "iphone-6.5", "01.png")).size == (1242, 2688), "wrong 6.5 size"
    assert os.path.exists(os.path.join(ROOT, "contact-sheet.png")), "contact sheet missing"
    print("OK: compose_listing produces correctly-sized frames")

if __name__ == "__main__":
    main()
