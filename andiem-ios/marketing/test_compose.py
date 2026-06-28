import os, sys, subprocess, tempfile, shutil
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))

def main():
    # Run entirely in a temp output dir (MARKETING_OUT) so we never overwrite the
    # real captures in raw/ or the real listing/. Frame + fonts are read from ROOT.
    import compose_listing as C  # only for the FRAMES list
    out = tempfile.mkdtemp(prefix="phorm-compose-test-")
    try:
        os.makedirs(os.path.join(out, "raw"), exist_ok=True)
        for fr in C.FRAMES:
            Image.new("RGB", (1206, 2622), (0x8C, 0x2A, 0x22)).save(os.path.join(out, "raw", fr["shot"]))

        env = {**os.environ, "MARKETING_OUT": out}
        subprocess.run([sys.executable, os.path.join(ROOT, "compose_listing.py")], env=env, check=True)

        one = os.path.join(out, "listing", "iphone-6.9", "01.png")
        assert os.path.exists(one), "6.9 frame 01 not generated"
        assert Image.open(one).size == (1290, 2796), "wrong 6.9 size"
        assert Image.open(os.path.join(out, "listing", "iphone-6.5", "01.png")).size == (1242, 2688), "wrong 6.5 size"
        assert os.path.exists(os.path.join(out, "contact-sheet.png")), "contact sheet missing"
        print("OK: compose_listing produces correctly-sized frames (real raw/ untouched)")
    finally:
        shutil.rmtree(out, ignore_errors=True)

if __name__ == "__main__":
    main()
