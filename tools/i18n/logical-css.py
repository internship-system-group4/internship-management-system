"""Converts physical left/right CSS to logical properties so layouts follow dir="rtl" (Arabic) automatically.

In LTR every logical property resolves to the physical one it replaces, so English renders exactly as before.
    margin/padding/border-left|right(-color|-width|-style)  -> *-inline-start|end
    left:/right: (offsets)                                  -> inset-inline-start|end
    text-align:left|right                                   -> start|end
    float:left|right                                        -> inline-start|inline-end
    border-top-left-radius etc.                             -> border-start-start-radius etc.
Not converted (they stay physical on purpose): centring with left:50% / right:50%, rules that already target
[dir="rtl"] or [dir="ltr"], and anything inside @keyframes. Transforms (translateX, transform-origin) are reviewed by
hand in Assets/css/i18n.css.

    python -I tools/i18n/logical-css.py [--check]
Processes Assets/css/*.css and <style> blocks / style="" attributes in .aspx/.master/.ascx files.
"""
import os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'InternshipManagementSystem', 'InternshipManagementSystem')
CHECK = '--check' in sys.argv
SKIP = {'i18n.css', 'theme.css', 'ui-tokens.css'}

SIDES = {'left': 'inline-start', 'right': 'inline-end'}
MAP = {}
for box in ('margin', 'padding'):
    for side, logical in SIDES.items(): MAP['%s-%s' % (box, side)] = '%s-%s' % (box, logical)
for side, logical in SIDES.items():
    MAP['border-' + side] = 'border-' + logical
    for part in ('color', 'width', 'style'): MAP['border-%s-%s' % (side, part)] = 'border-%s-%s' % (logical, part)
MAP.update({'border-top-left-radius': 'border-start-start-radius', 'border-top-right-radius': 'border-start-end-radius',
            'border-bottom-left-radius': 'border-end-start-radius', 'border-bottom-right-radius': 'border-end-end-radius'})
DECL = re.compile(r'(?<![\w-])([a-z-]+)(\s*:\s*)([^;{}]*)')
stats = {}

def convert_block(css):
    changed = 0
    def rule(m):
        nonlocal changed
        before = css[:m.start()]
        open_brace, close_brace = before.rfind('{'), before.rfind('}')
        selector = before[close_brace + 1:open_brace] if open_brace > close_brace else ''
        if re.search(r'\[dir\s*=|:dir\(', selector): return m.group(0)
        prop, sep, value = m.group(1), m.group(2), m.group(3)
        new, nv = MAP.get(prop, prop), value
        if prop in ('left', 'right') and not re.match(r'^\s*50%', value):
            new = 'inset-inline-start' if prop == 'left' else 'inset-inline-end'
        if prop == 'text-align': nv = re.sub(r'^(\s*)left\b', r'\1start', re.sub(r'^(\s*)right\b', r'\1end', value))
        if prop == 'float': nv = re.sub(r'^(\s*)left\b', r'\1inline-start', re.sub(r'^(\s*)right\b', r'\1inline-end', value))
        if new == prop and nv == value: return m.group(0)
        changed += 1
        return new + sep + nv
    # Keyframes stay physical.
    parts = re.split(r'(@keyframes[^{]*\{(?:[^{}]*\{[^{}]*\})*[^{}]*\})', css)
    out = ''.join(p if p.startswith('@keyframes') else DECL.sub(rule, p) for p in parts)
    return out, changed

def process(path, markup):
    raw = open(path, 'rb').read(); bom = raw.startswith(b'\xef\xbb\xbf')
    try: text, enc = raw.decode('utf-8-sig'), 'utf-8'
    except UnicodeDecodeError: text, enc = raw.decode('cp1252'), 'cp1252'
    total = 0
    if markup:
        def block(m):
            nonlocal total; new, n = convert_block(m.group(2)); total += n; return m.group(1) + new + m.group(3)
        new = re.sub(r'(<style[^>]*>)(.*?)(</style>)', block, text, flags=re.S | re.I)
        def attr(m):
            nonlocal total; v, n = convert_block(m.group(2) + ';'); total += n; return m.group(1) + v[:-1] + m.group(3)
        new = re.sub(r'(\sstyle=")([^"<]*)(")', attr, new)
    else:
        new, total = convert_block(text)
    if total:
        stats[os.path.relpath(path, ROOT)] = total
        if not CHECK: open(path, 'wb').write((b'\xef\xbb\xbf' if bom else b'') + new.encode(enc))

for name in sorted(os.listdir(os.path.join(ROOT, 'Assets', 'css'))):
    if name.endswith('.css') and name not in SKIP: process(os.path.join(ROOT, 'Assets', 'css', name), False)
for folder, _, files in os.walk(ROOT):
    if any(x in folder for x in ('bin', 'obj', 'vendor')): continue
    for f in files:
        if f.endswith(('.aspx', '.master', '.ascx')): process(os.path.join(folder, f), True)
for k, v in sorted(stats.items(), key=lambda kv: -kv[1]): print('%4d  %s' % (v, k))
print('converted', sum(stats.values()), 'declarations in', len(stats), 'files')
