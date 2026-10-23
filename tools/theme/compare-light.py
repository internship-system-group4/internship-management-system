"""Pixel comparison of the Light theme: tests/artifacts/theme/light-before vs light-after (same file names).

Reports, per screenshot, whether the size matches, how many pixels differ by more than 12 in any channel, and the
bounding box of the differences. Pure standard library (zlib PNG decoding for 8-bit RGB/RGBA, non-interlaced).
    python -I tools/theme/compare-light.py
"""
import os, struct, sys, zlib

BASE = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'tests', 'artifacts', 'theme')

def decode(path):
    data = open(path, 'rb').read()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    pos, idat, width = 8, b'', 0
    while pos < len(data):
        length, kind = struct.unpack('>I4s', data[pos:pos + 8]); chunk = data[pos + 8:pos + 8 + length]; pos += 12 + length
        if kind == b'IHDR':
            width, height, depth, color, _, _, interlace = struct.unpack('>IIBBBBB', chunk)
            assert depth == 8 and color in (2, 6) and not interlace, (path, depth, color, interlace)
            bpp = 3 if color == 2 else 4
        elif kind == b'IDAT': idat += chunk
        elif kind == b'IEND': break
    raw = zlib.decompress(idat); stride = width * bpp
    rows, prev = [], bytearray(stride)
    for y in range(height):
        f = raw[y * (stride + 1)]; line = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        for i in range(stride):
            a = line[i - bpp] if i >= bpp else 0; b = prev[i]; c = prev[i - bpp] if i >= bpp else 0
            if f == 1: line[i] = (line[i] + a) & 255
            elif f == 2: line[i] = (line[i] + b) & 255
            elif f == 3: line[i] = (line[i] + ((a + b) >> 1)) & 255
            elif f == 4:
                p = a + b - c; pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append(bytes(line) if bpp == 3 else bytes(line[j] for j in range(stride) if j % 4 != 3))
        prev = line
    return width, height, rows

def compare(name):
    wa, ha, A = decode(os.path.join(BASE, 'light-before', name)); wb, hb, B = decode(os.path.join(BASE, 'light-after', name))
    w, h = min(wa, wb), min(ha, hb); n = 0; box = [w, h, -1, -1]
    for y in range(h):
        ra, rb = A[y], B[y]
        if ra[:w * 3] == rb[:w * 3]: continue
        for x in range(w):
            i = x * 3
            if abs(ra[i] - rb[i]) > 12 or abs(ra[i + 1] - rb[i + 1]) > 12 or abs(ra[i + 2] - rb[i + 2]) > 12:
                n += 1; box = [min(box[0], x), min(box[1], y), max(box[2], x), max(box[3], y)]
    return (wa, ha, wb, hb), n, (box if n else None)

names = sorted(f for f in os.listdir(os.path.join(BASE, 'light-before')) if f.endswith('.png'))
only = sys.argv[1:]
identical = 0
for name in names:
    if only and not any(o in name for o in only): continue
    size, n, box = compare(name)
    if n == 0 and size[1] == size[3]: identical += 1; continue
    print('%-70s size %sx%s -> %sx%s  changed %d  box %s' % (name, size[0], size[1], size[2], size[3], n, box))
print('identical:', identical, 'of', len(names) if not only else 'selection')
