"""Web build of the animated Rocketbox student (Male_Adult_17_Animated.glb -> Male_Adult_17_Animated.web.glb).

Same avatar, skeleton and motion; smaller download and faster decode for the Login checkpoint and the Jisr homepage.
  - Drops the 'stop' clip (no page plays it; 'walk' and 'look' are kept).
  - Mesh: NORMAL -> normalized int8, TEXCOORD_0 -> normalized uint16 (only when all UVs lie in [0,1]),
    WEIGHTS_0 -> normalized uint8 (renormalized to sum 255), JOINTS_0 -> uint8. POSITION and indices are unchanged.
    Declares KHR_mesh_quantization, which three.js GLTFLoader reads natively (no decoder, no extra download).
  - Animation: rotation keyframes -> normalized int16 quaternions (allowed by core glTF 2.0).
  - Textures: colour and normal maps downscaled from 1024 to 512 px JPEG (quality 88) with Windows GDI+ bicubic
    resampling through PowerShell; the characters are under 400 device pixels tall at the Login camera.
  - Accessor min/max rounded to 6 significant digits.
Licence: Microsoft Rocketbox, MIT (Assets/models/people/LICENSE.md) applies unchanged to the derived file.

    python -I tools/rocketbox/optimize-animated.py [--size 512] [--quality 88]
"""
import json, math, os, struct, subprocess, sys, tempfile

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'InternshipManagementSystem', 'InternshipManagementSystem', 'Assets', 'models', 'people')
SOURCE, TARGET = os.path.join(ROOT, 'Male_Adult_17_Animated.glb'), os.path.join(ROOT, 'Male_Adult_17_Animated.web.glb')
args = sys.argv[1:]
SIZE = int(args[args.index('--size') + 1]) if '--size' in args else 512
QUALITY = int(args[args.index('--quality') + 1]) if '--quality' in args else 88
DROP = {'stop'}
FLOAT, BYTE, UBYTE, SHORT, USHORT, UINT = 5126, 5120, 5121, 5122, 5123, 5125
SIZES = {FLOAT: 4, BYTE: 1, UBYTE: 1, SHORT: 2, USHORT: 2, UINT: 4}
FMT = {FLOAT: 'f', BYTE: 'b', UBYTE: 'B', SHORT: 'h', USHORT: 'H', UINT: 'I'}
WIDTH = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4, 'MAT4': 16}

data = open(SOURCE, 'rb').read()
magic, version, length = struct.unpack('<III', data[:12]); assert magic == 0x46546C67 and version == 2
json_len = struct.unpack('<I', data[12:16])[0]; gltf = json.loads(data[20:20 + json_len])
bin_len = struct.unpack('<I', data[20 + json_len:24 + json_len])[0]; BIN = data[28 + json_len:28 + json_len + bin_len]

def read(index):
    a = gltf['accessors'][index]; v = gltf['bufferViews'][a['bufferView']]; n = WIDTH[a['type']]; size = SIZES[a['componentType']]
    stride = v.get('byteStride', n * size); start = v.get('byteOffset', 0) + a.get('byteOffset', 0); f = '<' + FMT[a['componentType']] * n
    return [struct.unpack_from(f, BIN, start + i * stride) for i in range(a['count'])]

out = bytearray(); views = []
def add_view(raw, stride=None, target=None):
    while len(out) % 4: out.append(0)
    view = {'buffer': 0, 'byteOffset': len(out), 'byteLength': len(raw)}
    if stride: view['byteStride'] = stride
    if target: view['target'] = target
    out.extend(raw); views.append(view); return len(views) - 1
def sig(x): return float('%.6g' % x)
accessors = []; remap = {}
def add_accessor(index, component=None, normalized=False, values=None, pad_to=None, target=None):
    """Copy an accessor (optionally re-encoding it) into the output; returns its new index."""
    a = dict(gltf['accessors'][index]); n = WIDTH[a['type']]
    if component is None:
        v = gltf['bufferViews'][a['bufferView']]; size = SIZES[a['componentType']]; stride = v.get('byteStride')
        start = v.get('byteOffset', 0) + a.get('byteOffset', 0); span = (stride or n * size) * (a['count'] - 1) + n * size
        a['bufferView'] = add_view(BIN[start:start + span], stride, v.get('target')); a.pop('byteOffset', None)
    else:
        size = SIZES[component]; elem = n * size; stride = pad_to if pad_to and pad_to > elem else None
        raw = bytearray()
        for row in values:
            raw += struct.pack('<' + FMT[component] * n, *row)
            if stride: raw += b'\0' * (stride - elem)
        a['bufferView'] = add_view(bytes(raw), stride, target); a.pop('byteOffset', None)
        a['componentType'] = component
        if normalized: a['normalized'] = True
        else: a.pop('normalized', None)
        if 'min' in a and component != FLOAT:
            a['min'] = [min(r[i] for r in values) for i in range(n)]; a['max'] = [max(r[i] for r in values) for i in range(n)]
    for key in ('min', 'max'):
        if key in a and a['componentType'] == FLOAT: a[key] = [sig(x) for x in a[key]]
    accessors.append(a); return len(accessors) - 1

def q(x, bits, signed=True):
    top = (1 << (bits - 1)) - 1 if signed else (1 << bits) - 1
    return int(round(max(-1.0 if signed else 0.0, min(1.0, x)) * top))

# Mesh attributes.
for mesh in gltf['meshes']:
    for prim in mesh['primitives']:
        attrs = prim['attributes']
        for name, index in list(attrs.items()):
            if index in remap: attrs[name] = remap[index]; continue
            rows = read(index); new = None
            if name == 'NORMAL':
                new = add_accessor(index, BYTE, True, [tuple(q(c / (math.sqrt(sum(v * v for v in r)) or 1), 8) for c in r) for r in rows], pad_to=4, target=34962)
            elif name.startswith('TEXCOORD') and all(0 <= c <= 1 for r in rows for c in r):
                new = add_accessor(index, USHORT, True, [tuple(q(c, 16, False) for c in r) for r in rows], target=34962)
            elif name.startswith('WEIGHTS'):
                packed = []
                for r in rows:
                    total = sum(r) or 1; w = [int(round(c / total * 255)) for c in r]; w[w.index(max(w))] += 255 - sum(w); packed.append(tuple(w))
                new = add_accessor(index, UBYTE, True, packed, target=34962)
            elif name.startswith('JOINTS') and max(max(r) for r in rows) < 256:
                new = add_accessor(index, UBYTE, False, [tuple(int(c) for c in r) for r in rows], target=34962)
            else:
                new = add_accessor(index)
            remap[index] = attrs[name] = new
        if 'indices' in prim:
            if prim['indices'] not in remap: remap[prim['indices']] = add_accessor(prim['indices'])
            prim['indices'] = remap[prim['indices']]
for skin in gltf.get('skins', []):
    if 'inverseBindMatrices' in skin:
        old = skin['inverseBindMatrices']
        if old not in remap: remap[old] = add_accessor(old)
        skin['inverseBindMatrices'] = remap[old]

# Animations: drop unused clips; quantize rotation outputs.
kept = []
for anim in gltf['animations']:
    if anim['name'] in DROP: continue
    local = {}
    for channel in anim['channels']:
        sampler = anim['samplers'][channel['sampler']]
        for key in ('input', 'output'):
            old = sampler[key]
            if (old, key) in local: continue
            if key == 'output' and channel['target']['path'] == 'rotation' and gltf['accessors'][old]['componentType'] == FLOAT:
                rows = read(old); new = add_accessor(old, SHORT, True, [tuple(q(c / (math.sqrt(sum(v * v for v in r)) or 1), 16) for c in r) for r in rows])
            else:
                new = remap[old] if old in remap else add_accessor(old)
            remap[old] = new; local[(old, key)] = new
    for sampler in anim['samplers']:
        sampler['input'] = remap[sampler['input']]; sampler['output'] = remap[sampler['output']]
    kept.append(anim)
gltf['animations'] = kept

# Images: downscale with GDI+ (PowerShell), keep JPEG.
work = tempfile.mkdtemp(prefix='rocketbox-')
for i, image in enumerate(gltf['images']):
    v = gltf['bufferViews'][image['bufferView']]; src = os.path.join(work, 'in%d.jpg' % i); dst = os.path.join(work, 'out%d.jpg' % i)
    open(src, 'wb').write(BIN[v.get('byteOffset', 0):v.get('byteOffset', 0) + v['byteLength']])
    script = ("Add-Type -AssemblyName System.Drawing; $s=[Drawing.Image]::FromFile('%s'); $b=New-Object Drawing.Bitmap %d,%d; "
              "$g=[Drawing.Graphics]::FromImage($b); $g.InterpolationMode='HighQualityBicubic'; $g.PixelOffsetMode='HighQuality'; $g.DrawImage($s,0,0,%d,%d); "
              "$e=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|?{$_.MimeType -eq 'image/jpeg'}; $p=New-Object Drawing.Imaging.EncoderParameters 1; "
              "$p.Param[0]=New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality),([long]%d); $b.Save('%s',$e,$p); $g.Dispose(); $b.Dispose(); $s.Dispose()") % (src, SIZE, SIZE, SIZE, SIZE, QUALITY, dst)
    subprocess.run(['powershell', '-NoProfile', '-Command', script], check=True)
    image['bufferView'] = add_view(open(dst, 'rb').read()); image['mimeType'] = 'image/jpeg'

gltf['bufferViews'] = views; gltf['accessors'] = accessors; gltf['buffers'] = [{'byteLength': len(out)}]
for key in ('extensionsUsed', 'extensionsRequired'):
    gltf[key] = sorted(set(gltf.get(key, [])) | {'KHR_mesh_quantization'})
gltf.setdefault('asset', {})['generator'] = 'UIMS tools/rocketbox/optimize-animated.py'
text = json.dumps(gltf, separators=(',', ':')).encode('utf-8')
while len(text) % 4: text += b' '
while len(out) % 4: out.append(0)
glb = struct.pack('<III', 0x46546C67, 2, 28 + len(text) + len(out)) + struct.pack('<II', len(text), 0x4E4F534A) + text + struct.pack('<II', len(out), 0x004E4942) + bytes(out)
open(TARGET, 'wb').write(glb)
print('%s: %d -> %d bytes (json %d -> %d, binary %d -> %d)' % (os.path.basename(TARGET), len(data), len(glb), json_len, len(text), bin_len, len(out)))
