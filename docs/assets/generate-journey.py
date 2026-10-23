"""Generate the README's illustrative GIF. Requires Python and Pillow.

Run from any directory: python docs/assets/generate-journey.py
No university records, screenshots, external images, or network calls are used.
"""

from pathlib import Path
import math

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
FONT_DIR = ROOT / "InternshipManagementSystem/InternshipManagementSystem/Assets/fonts"
FONT = next(FONT_DIR.glob("*NotoSans*Variable*.ttf"), None)
if FONT is None:
    FONT = next(path for path in FONT_DIR.glob("*.ttf") if "Arabic" not in path.name)

WIDTH, HEIGHT = 1080, 280
NAVY, WHITE, MUTED = "#10263B", "#F3F7FC", "#B7C9DD"
COLORS = ["#77B5F1", "#57D1C1", "#B9A1F5", "#F3C66E", "#77B5F1"]
LABELS = ["Discover", "Apply", "Confirm", "Train", "Review"]
CAPTIONS = ["Opportunities", "Company decision", "One placement", "Tasks & feedback", "Completion checks"]
POINTS = [112, 326, 540, 754, 968]


def font(size):
    return ImageFont.truetype(str(FONT), size)


def centered(draw, x, y, text, size, fill):
    draw.text((x, y), text, font=font(size), fill=fill, anchor="mt")


def frame(stage, progress=0):
    canvas = Image.new("RGB", (WIDTH, HEIGHT), NAVY)
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle((1, 1, WIDTH - 2, HEIGHT - 2), radius=22, outline="#39516B", width=2)
    draw.text((36, 23), "UIMS / THE INTERNSHIP JOURNEY", font=font(14), fill=MUTED)
    draw.text((36, 50), "From opportunity to completion", font=font(30), fill=WHITE)
    draw.line((POINTS[0], 137, POINTS[-1], 137), fill="#39516B", width=3)
    if stage:
        draw.line((POINTS[0], 137, POINTS[stage], 137), fill=COLORS[stage], width=3)
    if stage < 4 and progress:
        x = POINTS[stage] + (POINTS[stage + 1] - POINTS[stage]) * progress
        draw.line((POINTS[stage], 137, x, 137), fill=COLORS[stage + 1], width=3)
        draw.ellipse((x - 4, 133, x + 4, 141), fill=WHITE)
    for i, x in enumerate(POINTS):
        active = i == stage
        draw.ellipse((x - 19, 118, x + 19, 156), fill=COLORS[i] if active else NAVY,
                     outline=COLORS[i], width=2)
        centered(draw, x, 123, str(i + 1), 17, NAVY if active else WHITE)
        centered(draw, x, 174, LABELS[i], 22, WHITE)
        centered(draw, x, 207, CAPTIONS[i], 13, MUTED)
    draw.text((36, 250), "Illustrative workflow / integration status documented below", font=font(12), fill=MUTED)
    return canvas


frames, durations = [], []
for stage in range(5):
    frames.append(frame(stage))
    durations.append(1400 if stage == 0 else 850)
    if stage < 4:
        for tick in range(1, 9):
            t = tick / 9
            frames.append(frame(stage, (1 - math.cos(math.pi * t)) / 2))
            durations.append(80)

# One palette prevents flicker; modest frame rate/delta encoding keeps the file small.
palette = frames[0].quantize(colors=96)
indexed = [im.quantize(palette=palette, dither=Image.Dither.NONE) for im in frames]
output = HERE / "uims-journey.gif"
indexed[0].save(output, save_all=True, append_images=indexed[1:], duration=durations,
                loop=0, optimize=True, disposal=1)
with Image.open(output) as saved:
    print(f"{output.name}: {output.stat().st_size:,} bytes, {saved.n_frames} encoded frames")
