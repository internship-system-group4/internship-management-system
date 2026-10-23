"""Second pass after localize-code.py: wraps remaining English UI sentences in C# with L.T("Area.Page.Key").

localize-code.py only looks at known sinks (ShowError(...), .Text = ...). This pass catches what those miss:
ternaries, multi-line calls, Notice = ..., new ListItem("Select ..."), return "..." in display helpers.
A literal qualifies when it starts with a capital letter and has at least two words. It is skipped on lines that
log, throw or test exception text, in comments, and in attribute/key positions.

    python -I tools/i18n/localize-literals.py [--check] <Area> <file.cs> [...]
"""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
CHECK = '--check' in sys.argv
args = [a for a in sys.argv[1:] if a != '--check']
AREA, FILES = args[0], args[1:]
STRINGS = os.path.join(HERE, 'strings', AREA + '.txt')
LIT = re.compile(r'(?<![@\w$])"((?:[^"\\]|\\.)*)"')
UI = re.compile(r'^[A-Z][a-z]+(?: [^ ]+)+$|^[A-Z][a-z]+ ?[.!…]?$')
SKIP_LINE = re.compile(r'Trace\.|Debug\.|throw\b|IndexOf\(|GetWhere\(|\[\s*"|Attributes\[|Request\.|Session\[|ViewState\[|Response\.|Redirect\(|ContentType|Header')
SINGLE_WORDS = {'Unknown', 'Pending', 'Approved', 'Rejected', 'Returned'}
# Text that is saved to Firebase (starter criteria, default university) or printed in the English-only PDF stays as is.
KEEP = {'Quality of work', 'Everything in the instructions is done.', 'On time', 'Submitted before the deadline.',
        'Correct, clean and well organised.', 'German Jordanian University', 'Internship Coordinator'}

keys, by_text, new = set(), {}, []
if os.path.exists(STRINGS):
    key = None
    for line in open(STRINGS, encoding='utf-8').read().splitlines():
        m = re.match(r'^en:\s?(.*)$', line)
        if m and key: by_text.setdefault(m.group(1), key)
        elif line.strip() and not line.startswith(('ar:', '#')): key = line.strip(); keys.add(key)

def slug(t):
    w = re.findall(r'[A-Za-z0-9]+', t)
    return ''.join(x[:1].upper() + x[1:] for x in w[:6]) or 'Text'

def key_for(page, t):
    if t in by_text and by_text[t].startswith(page + '.'): return by_text[t]
    base = page + '.' + slug(t); k, n = base, 2
    while k.lower() in (x.lower() for x in keys): k, n = '%s%d' % (base, n), n + 1
    keys.add(k); by_text[t] = k; new.append((k, t)); return k

for path in FILES:
    raw = open(path, 'rb').read(); bom = raw.startswith(b'\xef\xbb\xbf'); text = raw.decode('utf-8-sig')
    page = re.sub(r'(\.(aspx|ascx|master))?\.cs$', '', os.path.basename(path)).replace('.', '')
    out, pos, count = [], 0, 0
    for m in LIT.finditer(text):
        ls = text.rfind('\n', 0, m.start()) + 1; le = text.find('\n', m.end()); line = text[ls:le if le > 0 else None]
        before = text[ls:m.start()]
        if '//' in before or before.lstrip().startswith(('*', '///')) or SKIP_LINE.search(line): continue
        if re.search(r'L\.(T|F|Value)\(\s*$', before) or re.search(r'[=!]=\s*$', before): continue
        prev = text[max(0, ls - 200):ls]
        if re.search(r'(throw new \w+|Trace\.\w+)\([^;]*$', prev): continue
        t = m.group(1)
        if t in KEEP or '\\' in t or not (UI.match(t) and (' ' in t or t.rstrip('.!…') in SINGLE_WORDS)): continue
        if re.search(r'https?://|\.aspx|\{\d\}', t): continue
        out.append(text[pos:m.start()]); out.append('L.T("%s.%s")' % (AREA, key_for(page, t))); pos = m.end(); count += 1
        print('   %s: %s' % (page, t[:90]))
    out.append(text[pos:]); new_text = ''.join(out)
    if count and 'using InternshipManagementSystem.Common;' not in new_text and 'namespace InternshipManagementSystem.Common' not in new_text:
        new_text = re.sub(r'(using System;\r?\n)', r'\1using InternshipManagementSystem.Common;\n', new_text, count=1)
    if not CHECK and new_text != text: open(path, 'wb').write((b'\xef\xbb\xbf' if bom else b'') + new_text.encode('utf-8'))
    print('%-60s %3d' % (path, count))
if not CHECK and new:
    with open(STRINGS, 'a', encoding='utf-8', newline='\n') as f:
        for k, t in new: f.write('\n%s\nen: %s\n' % (k, t))
print(len(new), 'new entries')
