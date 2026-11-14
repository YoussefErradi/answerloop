#!/usr/bin/env python3
"""Draw every frame of the 40-second AnswerLoop customer story and encode MP4.

Requires Pillow and an ffmpeg executable with libx264. No stock footage, external
assets, or intermediate frame dump. Use --stills to review the seven keyframes.
Example: python3 script/render_feature_video.py --ffmpeg /path/to/ffmpeg
Set ANSWERLOOP_VIDEO_FONT to an Avenir Next compatible font collection if needed.
"""

import argparse
import math
import os
from pathlib import Path
import shutil
import subprocess

from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "public/media"
PREVIEWS = ROOT / "tmp/feature-video"
W, H, FPS, DURATION = 1600, 900, 30, 40
INK = "#153E39"
TEAL = "#087C6A"
MINT = "#DFF2E8"
MUTED = "#607871"
LINE = "#DBE7DF"
CREAM = "#FAFBF5"
FONT = os.environ.get("ANSWERLOOP_VIDEO_FONT", "/System/Library/Fonts/Avenir Next.ttc")
FONTS = {}
SCENES = [
    (0, 5, "The question"), (5, 11, "Find an answer"),
    (11, 17, "Ask for help"), (17, 24, "Work together"),
    (24, 30, "Close the loop"), (30, 36, "Learn & improve"),
    (36, 40, "AnswerLoop"),
]


def font(size, weight="regular"):
    key = (size, weight)
    if key not in FONTS:
        FONTS[key] = ImageFont.truetype(FONT, size, index={"bold": 0, "demi": 2, "regular": 7}[weight])
    return FONTS[key]


def clamp(value):
    return max(0, min(1, value))


def ease(value):
    value = clamp(value)
    return 1 - (1 - value) ** 3


def smooth(value):
    value = clamp(value)
    return value * value * (3 - 2 * value)


def rr(im, box, fill="white", radius=22, outline=None, width=1):
    ImageDraw.Draw(im).rounded_rectangle(tuple(round(v) for v in box), radius, fill=fill, outline=outline, width=width)


def text(im, xy, content, size=24, fill=INK, weight="regular", spacing=10, anchor=None):
    draw = ImageDraw.Draw(im)
    draw.multiline_text(xy, content, font=font(size, weight), fill=fill, spacing=spacing, anchor=anchor)


def line(im, points, fill=LINE, width=2):
    ImageDraw.Draw(im).line(points, fill=fill, width=width, joint="curve")


def ellipse(im, box, fill, outline=None, width=1):
    ImageDraw.Draw(im).ellipse(box, fill=fill, outline=outline, width=width)


def chip(im, x, y, label, fill=MINT, color=TEAL, size=18):
    length = ImageDraw.Draw(im).textlength(label, font=font(size, "demi"))
    rr(im, (x, y, x + length + 30, y + 36), fill, radius=18)
    text(im, (x + 15, y + 5), label, size, color, "demi")


def check(im, x, y, color=TEAL, size=19):
    line(im, [(x, y + size * .48), (x + size * .35, y + size * .84), (x + size, y)], color, 4)


def search_icon(im, x, y, color=MUTED):
    ellipse(im, (x, y, x + 21, y + 21), None, color, 3)
    line(im, [(x + 18, y + 18), (x + 29, y + 29)], color, 3)


def logo(im, x, y, size=48, label=True):
    rr(im, (x, y, x + size, y + size), INK, radius=int(size * .32))
    draw = ImageDraw.Draw(im)
    for offset in [.20, .42]:
        draw.ellipse((x + size * offset, y + size * .30, x + size * (offset + .38), y + size * .69), outline="white", width=max(2, round(size * .048)))
    if label:
        text(im, (x + size + 13, y + size * .03), "AnswerLoop", round(size * .66), INK, "bold")


def card(width, height, title="SUNDAY STUDIO", section="Help center"):
    im = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    rr(im, (0, 0, width - 1, height - 1), "white", 25, LINE, 2)
    line(im, [(0, 69), (width, 69)])
    rr(im, (25, 24, 49, 48), TEAL, 7)
    text(im, (64, 24), title, 18, INK, "bold")
    length = ImageDraw.Draw(im).textlength(section, font=font(16))
    text(im, (width - length - 28, 26), section, 16, MUTED)
    return im


def place(canvas, layer, xy, reveal=1, rise=24):
    reveal = clamp(reveal)
    if reveal == 0:
        return
    layer = layer.copy()
    if reveal < 1:
        layer.putalpha(layer.getchannel("A").point(lambda a: round(a * reveal)))
    x, y = xy
    canvas.alpha_composite(layer, (round(x), round(y + (1 - reveal) * rise)))


def shadow(canvas, box, radius=25):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    rr(layer, (box[0], box[1] + 18, box[2], box[3] + 18), (20, 65, 52, 18), radius)
    canvas.alpha_composite(layer.filter(ImageFilter.GaussianBlur(24)))


def title_block(im, number, label, heading, copy, t):
    layer = Image.new("RGBA", (630, 470), (0, 0, 0, 0))
    text(layer, (0, 0), f"0{number}  /  {label.upper()}", 17, TEAL, "bold")
    text(layer, (0, 54), heading, 65, INK, "demi", spacing=0)
    text(layer, (0, 238), copy, 24, MUTED, spacing=11)
    place(im, layer, (96, 219), ease(t / .8))


def base(t):
    im = Image.new("RGBA", (W, H), CREAM)
    draw = ImageDraw.Draw(im)
    # A quiet, fixed dot grid and slow orbit keep the composition light.
    for x in range(820, 1600, 36):
        for y in range(122, 786, 36):
            draw.ellipse((x, y, x + 2, y + 2), fill="#DBE8DD")
    draw.arc((1020, -240, 1850, 590), 0, 340, fill="#E0EDE2", width=2)
    draw.arc((-330, 610, 230, 1170), 210, 350, fill="#E0EDE2", width=2)
    logo(im, 84, 54, 44)
    text(im, (1180, 64), "A CUSTOMER STORY", 17, MUTED, "demi")
    # An illustrative story, never a claim about an actual customer.
    text(im, (96, 810), "SUNDAY STUDIO  /  ILLUSTRATIVE WORKFLOW", 14, MUTED, "demi")
    text(im, (1390, 810), f"{min(int(t), 39):02d} / 40", 16, MUTED, "demi")
    rr(im, (96, 852, 1504, 855), "#DFE8DE", 2)
    if t > 0:
        rr(im, (96, 852, 96 + 1408 * clamp(t / DURATION), 855), TEAL, 2)
    return im


def intro(im, t):
    title_block(im, 1, "A very everyday problem", "One small question.\nA better support day.", "Meet Maya. Her order is packed.\nHer delivery address? The old one.", t)
    ui = card(700, 430, section="Order #1042")
    chip(ui, 36, 99, "Packed and ready", "#FFF0D9", "#9A6528")
    text(ui, (36, 157), "A little change of plans.", 34, INK, "demi")
    text(ui, (36, 216), "Shipping to", 18, MUTED)
    text(ui, (36, 250), "Maya’s old address", 26, INK, "demi")
    line(ui, [(36, 294), (656, 294)])
    text(ui, (36, 326), "Can I still update my delivery?", 23, MUTED)
    # The package is deliberately drawn from simple vector geometry.
    rr(ui, (525, 172, 637, 279), "#E9DBBC", 15)
    line(ui, [(581, 174), (581, 279)], "#C2A775", 12)
    rr(ui, (542, 223, 570, 242), CREAM, 4)
    shadow(im, (785, 228, 1485, 658))
    place(im, ui, (785, 228), ease((t - .45) / .85))
    bubble = Image.new("RGBA", (452, 102))
    rr(bubble, (0, 0, 451, 101), INK, 25)
    ellipse(bubble, (19, 23, 73, 77), "#DFF2E8")
    text(bubble, (34, 33), "M", 25, TEAL, "demi")
    text(bubble, (92, 29), "“I just moved. Help?”", 25, "white", "demi")
    place(im, bubble, (855, 622 - 4 * math.sin(t * 1.1)), ease((t - 1.5) / .7))


def search(im, t):
    title_block(im, 2, "Public help center", "An answer,\nwithout the wait.", "Maya searches Sunday Studio’s\nhelp center for a quick answer.", t)
    ui = card(770, 480)
    text(ui, (36, 101), "How can we help?", 35, INK, "demi")
    rr(ui, (36, 165, 734, 228), "#F8FAF7", 13, "#BFD4C8", 2)
    search_icon(ui, 57, 182)
    query = "change delivery address"
    n = int(clamp((t - 1.05) / 1.5) * len(query))
    text(ui, (104, 180), query[:n], 24)
    if t > 1 and t < 2.9:
        end = ImageDraw.Draw(ui).textlength(query[:n], font=font(24))
        line(ui, [(106 + end, 182), (106 + end, 213)], TEAL, 2)
    results = Image.new("RGBA", (700, 184))
    rr(results, (0, 0, 698, 183), "#EDF7F0", 17)
    text(results, (24, 20), "Update your delivery details", 27, INK, "demi")
    text(results, (24, 68), "Already packed? Send us your order number.\nOur support team will take it from there.", 21, MUTED, spacing=9)
    text(results, (24, 142), "Read the guide", 19, TEAL, "demi")
    place(ui, results, (36, 259), ease((t - 2.7) / .65))
    shadow(im, (734, 204, 1504, 684))
    place(im, ui, (734, 204), ease((t - .35) / .8))
    chip_layer = Image.new("RGBA", (460, 42))
    chip(chip_layer, 0, 0, "Published knowledge. Easy to find.")
    place(im, chip_layer, (855, 713), ease((t - 3.2) / .7))


def ticket(im, t):
    title_block(im, 3, "A simple support request", "Need a hand?\nKeep it simple.", "Her order needs a human touch.\nMaya sends one clear request.", t)
    ui = card(770, 516, section="Contact support")
    text(ui, (36, 96), "Let’s sort it out.", 33, INK, "demi")
    text(ui, (36, 155), "SUBJECT", 15, MUTED, "demi")
    rr(ui, (36, 188, 734, 243), "#F7F9F5", 10, LINE)
    text(ui, (54, 200), "Delivery update · Order #1042", 23)
    text(ui, (36, 272), "YOUR MESSAGE", 15, MUTED, "demi")
    rr(ui, (36, 304, 734, 399), "#F7F9F5", 10, LINE)
    message = "I just moved. Can you update my address?"
    n = int(clamp((t - 1.0) / 1.7) * len(message))
    text(ui, (54, 330), message[:n], 22)
    pressed = smooth((t - 3.2) / .25)
    rr(ui, (36, 429, 265, 481), TEAL if pressed < 1 else INK, 12)
    text(ui, (60, 440), "Send request" if t < 3.5 else "Request sent", 23, "white", "demi")
    text(ui, (291, 444), "A private link arrives by email.", 18, MUTED)
    shadow(im, (734, 188, 1504, 704))
    place(im, ui, (734, 188), ease((t - .3) / .8))
    toast = Image.new("RGBA", (446, 76))
    rr(toast, (0, 0, 445, 75), INK, 18)
    ellipse(toast, (19, 19, 56, 56), "#DFF2E8")
    check(toast, 28, 29, TEAL, 18)
    text(toast, (75, 22), "You’re in the right hands.", 23, "white", "demi")
    place(im, toast, (918, 665), ease((t - 3.5) / .65))


def teamwork(im, t):
    title_block(im, 4, "The shared support inbox", "The right person.\nThe full picture.", "Leo picks up the ticket and\nchecks with the warehouse.", t)
    ui = card(820, 490, section="Support inbox")
    text(ui, (30, 100), "#1042  Delivery update", 29, INK, "demi")
    chip(ui, 30, 155, "Open", "#E9F2FF", "#446B94")
    line(ui, [(572, 88), (572, 465)])
    text(ui, (600, 106), "ASSIGNED TO", 15, MUTED, "demi")
    if t > .9:
        ellipse(ui, (600, 147, 643, 190), MINT)
        text(ui, (614, 152), "L", 24, TEAL, "demi")
        text(ui, (655, 155), "Leo", 23, INK, "demi")
    text(ui, (600, 235), "PRIORITY", 15, MUTED, "demi")
    text(ui, (600, 271), "Normal", 23)
    text(ui, (30, 215), "Maya", 19, INK, "demi")
    text(ui, (30, 251), "“Can you update my address?\nMy order is already packed.”", 23, MUTED, spacing=8)
    note = Image.new("RGBA", (510, 110))
    rr(note, (0, 0, 508, 109), "#FFF5DF", 13)
    text(note, (18, 13), "INTERNAL NOTE · LEO", 14, "#9A7529", "demi")
    text(note, (18, 49), "Warehouse checked. We can update it.", 20, INK)
    place(ui, note, (30, 335), ease((t - 2.1) / .8))
    shadow(im, (684, 214, 1504, 704))
    place(im, ui, (684, 214), ease((t - .35) / .8))
    hint = Image.new("RGBA", (570, 45))
    chip(hint, 0, 0, "Shared context. Private notes. Clear ownership.", size=17)
    place(im, hint, (762, 732), ease((t - 3.0) / .7))


def resolution(im, t):
    title_block(im, 5, "A private conversation", "A human reply.\nA happy customer.", "Maya opens her secure email link.\nLeo has a reassuring update.", t)
    ui = card(770, 490, section="Your support ticket")
    chip(ui, 36, 100, "Private conversation")
    text(ui, (36, 164), "Delivery update · #1042", 29, INK, "demi")
    reply = Image.new("RGBA", (680, 115))
    rr(reply, (0, 0, 678, 114), "#F0F5F0", 18)
    text(reply, (22, 17), "Leo · Support team", 18, TEAL, "demi")
    text(reply, (22, 53), "All set, Maya. Your address is updated.", 24)
    place(ui, reply, (36, 220), ease((t - 1.0) / .7))
    thanks = Image.new("RGBA", (390, 72))
    rr(thanks, (0, 0, 388, 71), INK, 17)
    text(thanks, (22, 19), "Perfect. Thanks so much!", 24, "white")
    place(ui, thanks, (343, 353), ease((t - 2.4) / .7))
    shadow(im, (734, 205, 1504, 695))
    place(im, ui, (734, 205), ease((t - .35) / .8))
    badge = Image.new("RGBA", (240, 68))
    rr(badge, (0, 0, 238, 66), "#D0EDDC", 33)
    check(badge, 26, 24, TEAL, 22)
    text(badge, (68, 17), "Resolved", 25, TEAL, "demi")
    place(im, badge, (999, 665), ease((t - 3.3) / .7))


def improve(im, t):
    title_block(im, 6, "Knowledge meets insights", "Make the next\nanswer easier.", "The team sharpens the guide and\nlearns what customers search for.", t)
    ui = card(770, 490, section="Team workspace")
    text(ui, (36, 102), "One clearer guide.", 32, INK, "demi")
    rr(ui, (36, 161, 734, 270), "#EDF7F0", 18)
    text(ui, (57, 179), "Update your delivery details", 26, INK, "demi")
    chip(ui, 57, 223, "Published", "#CDEAD8", TEAL, 16)
    check(ui, 676, 203, TEAL, 22)
    metrics = Image.new("RGBA", (700, 168))
    for x, value, label in [(0, "1", "Resolved ticket"), (239, "0", "Open tickets"), (478, "1", "Help search")]:
        rr(metrics, (x, 0, x + 220, 158), "#F6F8F2", 18, LINE)
        text(metrics, (x + 22, 17), value, 54, INK, "demi")
        text(metrics, (x + 22, 108), label, 18, MUTED)
    place(ui, metrics, (36, 302), ease((t - 1.7) / .8))
    shadow(im, (734, 205, 1504, 695))
    place(im, ui, (734, 205), ease((t - .35) / .8))
    hint = Image.new("RGBA", (480, 42))
    chip(hint, 0, 0, "Every conversation can improve the next.", size=18)
    place(im, hint, (862, 723), ease((t - 2.8) / .7))


def outro(im, t):
    # A centered final composition gives the story a satisfying pause.
    content = Image.new("RGBA", (W, H))
    logo(content, 630, 220, 62)
    text(content, (800, 352), "Less back-and-forth.\nMore answers.", 78, INK, "demi", spacing=3, anchor="ma")
    text(content, (800, 576), "KNOWLEDGE     ·     SUPPORT     ·     INSIGHTS", 20, TEAL, "demi", anchor="ma")
    rr(content, (552, 655, 1048, 720), INK, 17)
    text(content, (800, 670), "Bring your team into the loop.", 25, "white", "demi", anchor="ma")
    place(im, content, (0, 0), ease(t / .85), rise=25)


RENDERERS = [intro, search, ticket, teamwork, resolution, improve, outro]


def scene_layer(index, local_time):
    layer = Image.new("RGBA", (W, H))
    RENDERERS[index](layer, local_time)
    return layer


def render(t):
    im = base(t)
    index = next((i for i, (start, end, _) in enumerate(SCENES) if start <= t < end), 6)
    start = SCENES[index][0]
    local = t - start
    layer = scene_layer(index, local)
    if index > 0 and local < .68:
        mix = smooth(local / .68)
        previous_start = SCENES[index - 1][0]
        previous = scene_layer(index - 1, t - previous_start)
        previous.putalpha(previous.getchannel("A").point(lambda a: round(a * (1 - mix))))
        im.alpha_composite(previous, (round(-34 * mix), 0))
        layer.putalpha(layer.getchannel("A").point(lambda a: round(a * mix)))
        im.alpha_composite(layer, (round(42 * (1 - mix)), 0))
    else:
        im.alpha_composite(layer)
    return im.convert("RGB")


def stills():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    PREVIEWS.mkdir(parents=True, exist_ok=True)
    frames = []
    for index, (start, end, _) in enumerate(SCENES):
        frame = render(min(start + 4.2, end - .2))
        frame.save(PREVIEWS / f"scene-{index + 1:02}.png")
        frames.append(frame.resize((640, 360), Image.Resampling.LANCZOS))
    sheet = Image.new("RGB", (1280, 1440), CREAM)
    for i, frame in enumerate(frames):
        sheet.paste(frame, ((i % 2) * 640, (i // 2) * 360))
    sheet.save(PREVIEWS / "storyboard.jpg", quality=92)
    render(3.6).save(OUTPUT / "answerloop-story-poster.jpg", quality=94, optimize=True)
    print(f"Storyboard: {PREVIEWS / 'storyboard.jpg'}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stills", action="store_true")
    parser.add_argument("--ffmpeg", default=shutil.which("ffmpeg"))
    args = parser.parse_args()
    stills()
    if args.stills:
        return
    if not args.ffmpeg:
        parser.error("ffmpeg is required; pass --ffmpeg /path/to/ffmpeg")
    command = [args.ffmpeg, "-y", "-hide_banner", "-loglevel", "error",
               "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{W}x{H}",
               "-r", str(FPS), "-i", "pipe:0", "-an", "-c:v", "libx264",
               "-preset", "medium", "-crf", "20", "-pix_fmt", "yuv420p",
               "-movflags", "+faststart", "-metadata", "title=AnswerLoop: A better support day",
               str(OUTPUT / "answerloop-customer-story.mp4")]
    process = subprocess.Popen(command, stdin=subprocess.PIPE)
    try:
        for frame in range(DURATION * FPS):
            process.stdin.write(render(frame / FPS).tobytes())
            if frame % (FPS * 5) == 0:
                print(f"Rendered {frame}/{DURATION * FPS} frames", flush=True)
    finally:
        process.stdin.close()
    if process.wait() != 0:
        raise RuntimeError("ffmpeg failed to encode the story")
    print(f"Video: {OUTPUT / 'answerloop-customer-story.mp4'}", flush=True)


if __name__ == "__main__":
    main()
