"""Pixel comparison of the English interface: tests/artifacts/i18n/english-before (committed build) vs english-after.

Same algorithm as tools/theme/compare-light.py: per screenshot, the number of pixels that differ by more than 12 in any
channel and the bounding box of the differences.
    python -I tools/i18n/compare-english.py [name-filter ...]
"""
import importlib.util, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('compare_light', os.path.join(HERE, '..', 'theme', 'compare-light.py'))
BASE = os.path.join(HERE, '..', '..', 'tests', 'artifacts', 'i18n')
# compare-light.py runs its report on import; load only its PNG decoder.
source = open(spec.origin, encoding='utf-8').read().split('def compare(')[0]
helpers = {'__file__': spec.origin}; exec(compile(source, spec.origin, 'exec'), helpers)
decode = helpers['decode']

def compare(name):
    wa, ha, A = decode(os.path.join(BASE, 'english-before', name)); wb, hb, B = decode(os.path.join(BASE, 'english-after', name))
    w, h = min(wa, wb), min(ha, hb); n = 0; box = [w, h, -1, -1]
    for y in range(h):
        ra, rb = A[y], B[y]
        if ra[:w * 3] == rb[:w * 3]: continue
        for x in range(w):
            i = x * 3
            if abs(ra[i] - rb[i]) > 12 or abs(ra[i + 1] - rb[i + 1]) > 12 or abs(ra[i + 2] - rb[i + 2]) > 12:
                n += 1; box = [min(box[0], x), min(box[1], y), max(box[2], x), max(box[3], y)]
    return (wa, ha, wb, hb), n, (box if n else None)

only = sys.argv[1:]; identical = 0
names = sorted(f for f in os.listdir(os.path.join(BASE, 'english-before')) if f.endswith('.png') and (not only or any(o in f for o in only)))
for name in names:
    size, n, box = compare(name)
    if n == 0 and size[1] == size[3]: identical += 1; continue
    print('%-34s %sx%s -> %sx%s  changed %7d  box %s' % (name, size[0], size[1], size[2], size[3], n, box))
print('identical:', identical, 'of', len(names))
