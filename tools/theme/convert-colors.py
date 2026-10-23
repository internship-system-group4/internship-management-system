"""Theme colour conversion for UIMS (Light / Dark).

Rewrites hard-coded colours in stylesheets, inline <style> blocks and style="" attributes as
var(--token, #original). Light never defines the generated --th-* tokens, so every Light colour renders exactly as
before. Dark values are written to the generated block in Assets/css/theme.css.

Role comes from the CSS property: background/fill -> background, color/stroke -> text, border/outline -> line.
Colours that equal an existing UIMS token use that token; the long tail gets --th-<role>-<hex>, whose dark value is
derived in OKLCH by role (light surfaces become dark surfaces in the same order, dark text becomes light text, light
lines become low-contrast dark lines), keeping each colour's hue.

Idempotent: colours already inside a var() fallback are skipped. Run from the repository root:
    python -I tools/theme/convert-colors.py            (rewrite files and regenerate the dark block)
    python -I tools/theme/convert-colors.py --check    (report only)
"""
import math, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'InternshipManagementSystem', 'InternshipManagementSystem')
THEME = os.path.join(ROOT, 'Assets', 'css', 'theme.css')
SKIP_CSS = {'ui-tokens.css', 'theme.css'}
CHECK = '--check' in sys.argv

BG_PROPS = {'background', 'background-color', 'background-image', 'fill'}
FG_PROPS = {'color', '-webkit-text-fill-color', 'caret-color', 'text-decoration-color', 'stroke', 'accent-color'}
LINE_PROPS_PREFIX = ('border', 'outline', 'column-rule')
SKIP_SELECTOR = re.compile(r'logo', re.I)  # official logo backings stay as they are

# Exact original values that already have a UIMS token (same value in Light, so nothing changes there).
SEMANTIC = {
 'bg': {'ffffff': '--ui-surface', 'f6f8ff': '--ui-canvas', 'e5efff': '--ui-primary-soft', 'f0f3f7': '--ui-neutral-soft',
        '264f73': '--ui-primary', '173f62': '--ui-primary-hover', 'f5f5f5': '--ui-nav', 'edf7f0': '--ui-success-soft',
        'fff5db': '--ui-warning-soft', 'fff0f1': '--ui-danger-soft', 'edf5fb': '--ui-info-soft'},
 'fg': {'133d61': '--ui-ink', '50657a': '--ui-muted', '42474b': '--ui-nav-text', '565f69': '--ui-nav-muted', '52616a': '--ui-neutral',
        '206044': '--ui-success', '76500b': '--ui-warning', 'a52c37': '--ui-danger', '245979': '--ui-info', 'c8a349': '--ui-accent',
        '264f73': '--ui-primary-text', '173f62': '--ui-primary-text'},
 'line': {'e4ebf4': '--ui-border', '7b8b9e': '--ui-control-border', '264f73': '--ui-primary'},
}
# Brand variables used as text need the light link blue in Dark (the same variables stay mid-navy for filled buttons).
BRAND_TEXT = [('var(--brand)', 'var(--brand-text,var(--brand))'), ('var(--brand-dark)', 'var(--brand-text,var(--brand-dark))'),
              ('var(--ui-primary)', 'var(--ui-primary-text,var(--ui-primary))'), ('var(--ui-primary-hover)', 'var(--ui-primary-text,var(--ui-primary-hover))')]

# ---------------------------------------------------------------------------------------------- OKLCH helpers
def _lin(c): return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
def _gam(c): return 12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055
def to_oklch(rgb):
    r, g, b = (_lin(x / 255) for x in rgb)
    l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ** (1 / 3)
    m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ** (1 / 3)
    s = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ** (1 / 3)
    L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
    a = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
    bb = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
    return L, math.hypot(a, bb), math.atan2(bb, a)
def from_oklch(L, C, h):
    for _ in range(40):  # reduce chroma until the colour is inside sRGB
        a, b = C * math.cos(h), C * math.sin(h)
        l = (L + 0.3963377774 * a + 0.2158037573 * b) ** 3
        m = (L - 0.1055613458 * a - 0.0638541728 * b) ** 3
        s = (L - 0.0894841775 * a - 1.2914855480 * b) ** 3
        rgb = (4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
               -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
               -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)
        if all(-1e-4 <= x <= 1.0001 for x in rgb):
            return tuple(max(0, min(255, round(_gam(max(0.0, min(1.0, x))) * 255))) for x in rgb)
        C *= 0.9
    return tuple(max(0, min(255, round(_gam(max(0.0, min(1.0, x))) * 255))) for x in rgb)
def clamp(x, lo, hi): return max(lo, min(hi, x))

NAVY_HUE = to_oklch((0x15, 0x23, 0x31))[2]  # hue of the Dark surface #152331

def dark_of(role, hex6):
    rgb = tuple(int(hex6[i:i + 2], 16) for i in (0, 2, 4))
    L, C, h = to_oklch(rgb)
    neutral = C < 0.015
    if role == 'bg':
        if L >= 0.80:                                                                     # light surfaces and tints
            L2, C2 = 0.215 + (L - 0.80) / 0.20 * 0.05, min(C * 0.6, 0.045)
            if neutral: h, C2 = NAVY_HUE, 0.02                                            # greys join the navy surfaces
        elif L >= 0.55 and C > 0.06: return hex6                                          # vivid accents (pins, dots) keep their identity
        elif L >= 0.55: L2, C2 = 0.30 + (L - 0.55) / 0.25 * 0.08, C * 0.8                 # neutral mid tones
        elif C > 0.03:  L2, C2 = clamp(L + 0.07, 0.30, 0.58), C                           # brand fills: a step lighter
        else:           L2, C2 = max(L, 0.18), C                                          # near-black stays dark
    elif role == 'fg':
        if L > 0.70: return hex6                                                          # light text is already right
        L2 = 0.95 - (L - 0.20) * 0.45
        C2 = min(C, 0.14) if C > 0.08 else min(C * 0.7, 0.05)
        if C > 0.08: L2 = max(min(L2, 0.84), 0.78)                                        # status/brand text stays vivid
    else:
        if hex6 == 'ffffff': return hex6                                                  # white rings/outlines sit on colour or photos
        if L >= 0.70:                                                                     # quiet dividers
            L2, C2 = 0.34 + (L - 0.70) / 0.30 * 0.06, min(C * 0.6, 0.04)
            if neutral: h, C2 = NAVY_HUE, 0.02
        elif L >= 0.45: L2, C2 = 0.55, C * 0.8                                            # control borders
        else:           L2, C2 = clamp(L + 0.15, 0.50, 0.70), C                           # brand/strong lines
    return '%02x%02x%02x' % from_oklch(L2, C2, h)

# ----------------------------------------------------------------------------------------------- rewriting
HEX = re.compile(r'#([0-9a-fA-F]{8}|[0-9a-fA-F]{6}|[0-9a-fA-F]{3})(?![0-9a-zA-Z])')
DECL = re.compile(r'(?<![\w-])([a-zA-Z-]+)\s*:\s*([^;{}]*?)(?=\s*(?:!important)?\s*[;}]|\s*$)')
generated = {}
stats = {}

def norm(h):
    h = h.lower()
    return ''.join(c * 2 for c in h) if len(h) == 3 else h

def role_of(prop):
    p = prop.lower()
    if p in BG_PROPS: return 'bg'
    if p in FG_PROPS: return 'fg'
    if p.startswith(LINE_PROPS_PREFIX) and not p.endswith(('width', 'style', 'radius', 'collapse', 'spacing', 'image', 'offset')): return 'line'
    return None

def convert_value(role, value):
    if NAMED.search(value) and 'url(' not in value and 'var(' not in value:
        named = NAMED.sub(lambda m: NAMED_HEX[m.group(1).lower()], value)
        if named != value:
            new, n = convert_value(role, named)
            return (new, n) if n else (value, 0)
    out, pos, changed = [], 0, 0
    url_spans = [m.span() for m in re.finditer(r'url\([^)]*\)', value)]
    for m in HEX.finditer(value):
        start = m.start()
        if any(a <= start < b for a, b in url_spans): continue
        if re.search(r'var\(--[\w-]+,\s*$', value[:start]): continue  # already a fallback
        h = norm(m.group(1)); alpha = h[6:] if len(h) == 8 else ''; h6 = h[:6]
        token = SEMANTIC[role].get(h6) if not alpha else None
        if not token:
            dark = dark_of(role, h6)
            if dark == h6: continue
            token = '--th-%s-%s' % (role, h)
            generated[token] = '#' + dark + alpha
        out.append(value[pos:start]); out.append('var(%s,%s)' % (token, m.group(0))); pos = m.end(); changed += 1
    if role == 'fg':
        v = ''.join(out) + value[pos:]
        for a, b in BRAND_TEXT:
            v2 = re.sub(r'(?<!-text,)' + re.escape(a) + r'(?![\w-])', b, v)
            if v2 != v: changed += v2.count('-text,') - v.count('-text,'); v = v2
        # Page-level navy/blue variables used as text (e.g. --ex-navy, --cm-blue) get the light link blue in Dark.
        v2 = re.sub(r'(?<!-text,)var\(--((?![\w-]*-text)[\w-]*(?:navy|blue)[\w-]*)\)', r'var(--ui-primary-text,var(--\1))', v)
        if v2 != v: changed += v2.count('-text,') - v.count('-text,'); v = v2
        return v, changed
    return ''.join(out) + value[pos:], changed

def custom_role(name):
    n = name.lower()
    if re.search(r'border|line|divider', n): return 'line'
    if re.search(r'-bg|background', n): return 'bg'
    if re.search(r'muted|ink|text|-color$', n): return 'fg'
    return None

NAMED = re.compile(r'(?<![\w#-])(white|black)(?![\w-])', re.I)
NAMED_HEX = {'white': '#ffffff', 'black': '#000000'}

def convert_css(text, page=False):
    total = 0
    def repl(m):
        nonlocal total
        prop, value = m.group(1), m.group(2)
        if prop.startswith('--'):
            # Page <style> blocks: colour variables named for their role. Stylesheet variables are themed by hand.
            role = custom_role(prop) if page else None
            if not role: return m.group(0)
            new, n = convert_value(role, value); total += n
            return m.group(0).replace(value, new, 1) if n else m.group(0)
        role = role_of(prop)
        if not role: return m.group(0)
        head = text[:m.start()]
        selector = head[max(head.rfind('}'), head.rfind(';')) + 1:]
        if '{' in selector and SKIP_SELECTOR.search(selector[:selector.rfind('{')]): return m.group(0)
        if SKIP_SELECTOR.search(selector.split('{')[0]) and '{' in selector: return m.group(0)
        new, n = convert_value(role, value)
        total += n
        return m.group(0).replace(value, new, 1) if n else m.group(0)
    return DECL.sub(repl, text), total

def convert_markup(text):
    total = 0
    def style_block(m):
        nonlocal total
        new, n = convert_css(m.group(2), page=True); total += n
        return m.group(1) + new + m.group(3)
    text = re.sub(r'(<style[^>]*>)(.*?)(</style>)', style_block, text, flags=re.S | re.I)
    def style_attr(m):
        nonlocal total
        new, n = convert_css(m.group(2) + ';'); total += n
        return m.group(1) + new[:-1] + m.group(3)
    text = re.sub(r'(\sstyle=")([^"]*)(")', style_attr, text)
    return text, total

def process(path, fn):
    raw = open(path, 'rb').read()
    bom = raw.startswith(b'\xef\xbb\xbf')
    # Keep each file's own encoding: a few team pages are Windows-1252, not UTF-8.
    try: text, encoding = raw.decode('utf-8-sig'), 'utf-8'
    except UnicodeDecodeError: text, encoding = raw.decode('cp1252'), 'cp1252'
    new, n = fn(text)
    if n:
        stats[os.path.relpath(path, ROOT) + ('' if encoding == 'utf-8' else ' [cp1252]')] = n
        if not CHECK: open(path, 'wb').write((b'\xef\xbb\xbf' if bom else b'') + new.encode(encoding))

for name in sorted(os.listdir(os.path.join(ROOT, 'Assets', 'css'))):
    if name.endswith('.css') and name not in SKIP_CSS:
        process(os.path.join(ROOT, 'Assets', 'css', name), convert_css)
for folder, _, files in os.walk(ROOT):
    if any(part in folder for part in ('\\bin', '/bin', '\\obj', '/obj', 'vendor', 'node_modules')): continue
    for name in files:
        if name.endswith(('.aspx', '.master', '.ascx')):
            process(os.path.join(folder, name), convert_markup)

# Every token in use is recomputed from its name (role + original hex), so palette rules can be tuned and rerun.
existing = {}
theme = open(THEME, 'rb').read().decode('utf-8')
for m in re.finditer(r'(--th-(bg|fg|line)-([0-9a-f]{6})([0-9a-f]{2})?):#[0-9a-f]{6,8}', theme):
    existing[m.group(1)] = '#' + dark_of(m.group(2), m.group(3)) + (m.group(4) or '')
existing.update(generated)
existing = {k: v for k, v in existing.items() if v[1:7] != k.split('-')[-1][:6]}
block = '/* ===== generated:start (tools/theme/convert-colors.py) — do not edit by hand ===== */\n:root[data-theme="dark"] {\n'
items = sorted(existing.items())
for i in range(0, len(items), 6):
    block += ' ' + ' '.join('%s:%s;' % kv for kv in items[i:i + 6]) + '\n'
block += '}\n/* ===== generated:end ===== */'
theme = re.sub(r'/\* ===== generated:start.*?generated:end ===== \*/', lambda m: block, theme, flags=re.S)
if not CHECK: open(THEME, 'wb').write(theme.encode('utf-8'))
for k, v in sorted(stats.items(), key=lambda kv: -kv[1]): print('%4d  %s' % (v, k))
print('converted', sum(stats.values()), 'colours in', len(stats), 'files;', len(existing), 'generated dark tokens')
