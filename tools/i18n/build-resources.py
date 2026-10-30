"""Builds the ASP.NET resource files for the Arabic / English interface.

Source of truth: tools/i18n/strings/<Area>.txt, UTF-8, one entry per block:

    Key.Name
    en: English text
    ar: النص العربي

Use \u0020 for a significant trailing space and \n for a line break.

(blank line between entries; lines starting with # are comments). Output:
    App_GlobalResources/<Area>.resx      English (neutral, the fallback)
    App_GlobalResources/<Area>.ar.resx   Arabic
and the matching <Content> entries in the project file. Entries without "ar:" are reported as gaps; at runtime they fall
back to English and are recorded by L.T().

    python -I tools/i18n/build-resources.py          (write)
    python -I tools/i18n/build-resources.py --check  (report only)
"""
import os, re, sys
import xml.etree.ElementTree as ET
from xml.sax.saxutils import escape

HERE = os.path.dirname(os.path.abspath(__file__))
WEB = os.path.join(HERE, '..', '..', 'InternshipManagementSystem', 'InternshipManagementSystem')
OUT = os.path.join(WEB, 'App_GlobalResources')
CHECK = '--check' in sys.argv

HEADER = '''<?xml version="1.0" encoding="utf-8"?>
<root>
  <resheader name="resmimetype"><value>text/microsoft-resx</value></resheader>
  <resheader name="version"><value>2.0</value></resheader>
  <resheader name="reader"><value>System.Resources.ResXResourceReader, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value></resheader>
  <resheader name="writer"><value>System.Resources.ResXResourceWriter, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value></resheader>
'''

def parse(path):
    entries, key, current, errors = {}, None, {}, []
    def flush():
        if key is None: return
        if 'en' not in current: errors.append('%s: no English text' % key)
        if key.lower() in (k.lower() for k in entries): errors.append('%s: duplicate key (resource keys ignore case)' % key)
        entries[key] = dict(current)
    for raw in open(path, encoding='utf-8').read().splitlines():
        line = raw  # values keep edge spaces: "Current decision: " + label
        if not line.strip() or line.lstrip().startswith('#'): continue
        m = re.match(r'^\s*(en|ar):\s?(.*)$', line)
        if m and key is not None:
            current[m.group(1)] = m.group(2).replace('\\n', '\n').replace('\\u0020', ' '); continue
        flush(); key = line.strip(); current = {}
        if not re.match(r'^[A-Za-z][A-Za-z0-9_.]*$', key): errors.append('bad key: ' + key)
    flush()
    return entries, errors

def resx(entries, lang):
    body = HEADER
    for key in sorted(entries):
        text = entries[key].get(lang)
        if text is None: continue
        body += '  <data name="%s" xml:space="preserve"><value>%s</value></data>\n' % (escape(key, {'"': '&quot;'}), escape(text))
    return body + '</root>\n'

# Translation memory: the same English text gets the same Arabic everywhere unless an entry gives its own "ar:".
MEMORY = {}
mp = os.path.join(HERE, 'memory.txt')
if os.path.exists(mp):
    en = None
    for line in open(mp, encoding='utf-8').read().splitlines():
        if line.startswith('en: '): en = line[4:]
        elif line.startswith('ar: ') and en is not None: MEMORY[en] = line[4:]; en = None

areas, gaps, problems, total, resources = [], [], [], 0, {}
for name in sorted(os.listdir(os.path.join(HERE, 'strings'))):
    if not name.endswith('.txt'): continue
    area = name[:-4]; areas.append(area)
    entries, errors = parse(os.path.join(HERE, 'strings', name))
    problems += ['%s: %s' % (area, e) for e in errors]
    total += len(entries)
    for v in entries.values():
        if 'ar' not in v and v.get('en') in MEMORY: v['ar'] = MEMORY[v['en']]
    gaps += ['%s.%s' % (area, k) for k, v in entries.items() if 'ar' not in v]
    resources[area] = entries
    # Older changes added keys directly to .resx. Refuse to erase those keys
    # when source tables have fallen behind, before writing ANY resource file.
    for lang, suffix in (('en', '.resx'), ('ar', '.ar.resx')):
        path = os.path.join(OUT, area + suffix)
        if not os.path.exists(path):
            if CHECK: problems.append('%s: generated file is missing' % (area + suffix))
            continue
        existing = {d.attrib['name']: d.findtext('value', '') for d in ET.parse(path).getroot().findall('data')}
        expected = {key: v[lang] for key, v in entries.items() if lang in v}
        removed = sorted(set(existing) - set(expected))
        if removed:
            problems.append('%s: refusing to remove %d keys absent from the source tables: %s. Sync strings first.' %
                            (area + suffix, len(removed), ', '.join(removed[:8])))
        elif CHECK and existing != expected:
            problems.append('%s: generated translations are out of date; run build-resources.py' % (area + suffix))

for area, entries in resources.items():
    for key, values in entries.items():
        # A dropped argument can silently turn a factual count into the wrong message.
        en_args = set(re.findall(r'(?<!\{)\{(\d+)(?:[,}:])', values.get('en', '')))
        ar_args = set(re.findall(r'(?<!\{)\{(\d+)(?:[,}:])', values.get('ar', '')))
        if en_args != ar_args:
            problems.append('%s.%s: English and Arabic format arguments differ' % (area, key))

if not CHECK and not problems and not gaps:
    os.makedirs(OUT, exist_ok=True)
    for area, entries in resources.items():
        open(os.path.join(OUT, area + '.resx'), 'w', encoding='utf-8', newline='\r\n').write(resx(entries, 'en'))
        open(os.path.join(OUT, area + '.ar.resx'), 'w', encoding='utf-8', newline='\r\n').write(resx(entries, 'ar'))

if not CHECK and not problems and not gaps:
    proj = os.path.join(WEB, 'InternshipManagementSystem.csproj')
    s = open(proj, 'rb').read().decode('utf-8-sig')
    for area in areas:
        for suffix in ('.resx', '.ar.resx'):
            item = '    <Content Include="App_GlobalResources\\%s%s" />\r\n' % (area, suffix)
            if item.strip() not in s:
                anchor = '    <Content Include="Global.asax" />'
                s = s.replace(anchor, anchor + '\r\n' + item.rstrip('\r\n'), 1) if anchor in s else s
    open(proj, 'wb').write(b'\xef\xbb\xbf' + s.encode('utf-8') if open(proj, 'rb').read().startswith(b'\xef\xbb\xbf') else s.encode('utf-8'))

for p in problems: print('PROBLEM', p)
print('%d entries in %d areas; %d without Arabic%s' % (total, len(areas), len(gaps), (': ' + ', '.join(gaps[:20])) if gaps else ''))
sys.exit(1 if problems or gaps else 0)
