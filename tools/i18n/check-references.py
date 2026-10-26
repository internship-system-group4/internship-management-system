"""Check static resource references, page titles and JavaScript dictionary keys.

Run after build-resources.py --check. Dynamic status/value keys are exercised by
the browser checks; concatenated key prefixes are not treated as complete keys.
"""
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

WEB = Path(__file__).resolve().parents[2] / 'InternshipManagementSystem/InternshipManagementSystem'
keys = {
    p.stem: {data.attrib['name'] for data in ET.parse(p).getroot().findall('data')}
    for p in (WEB / 'App_GlobalResources').glob('*.resx') if not p.stem.endswith('.ar')
}
problems = []
files = 0
for path in sorted(WEB.rglob('*')):
    if path.suffix not in ('.cs', '.aspx', '.ascx', '.master', '.js') or any(part in ('bin', 'obj', 'vendor') for part in path.parts):
        continue
    source = path.read_text(encoding='utf-8-sig')
    # Replace comments with whitespace so line numbers remain useful. URL literals
    # are left alone; // only starts a comment at a line's beginning here.
    source = re.sub(r'/\*.*?\*/|<%--.*?--%>|<!--.*?-->|(?m:^[ \t]*//[^\n]*)',
                    lambda m: re.sub(r'[^\n]', ' ', m[0]), source, flags=re.S)
    references = [(m[1], m[2], m.start()) for m in re.finditer(r'L\.(?:T|F|H|InEnglish)\(\s*"([A-Za-z]+)\.([A-Za-z0-9_.]+)"', source)]
    references += [(m[1], m[2], m.start()) for m in re.finditer(r'Resources:\s*(\w+),\s*([A-Za-z0-9_.]+)', source)]
    references += [('Shared', 'Js.' + m[1], m.start()) for m in re.finditer(r'\buimsT\(\s*[\'"]([A-Za-z0-9_.]+)[\'"]', source)]
    # Masters localize page.Title using this implicit resource key at runtime.
    if path.suffix == '.aspx' and re.search(r'<%@\s*Page\b[^%]*\bTitle="[^"]+"', source):
        title = 'Title.' + path.relative_to(WEB).with_suffix('').as_posix().replace('/', '.')
        references.append(('Shared', title, 0))
    for area, key, offset in references:
        if key.endswith('.'):
            continue
        if key not in keys.get(area, set()):
            problems.append(f'{path.relative_to(WEB)}:{source[:offset].count(chr(10)) + 1}: {area}.{key}')
    files += 1

for problem in problems:
    print('MISSING', problem)
print(f'{files} source files checked; {len(problems)} unresolved static references')
sys.exit(1 if problems else 0)
