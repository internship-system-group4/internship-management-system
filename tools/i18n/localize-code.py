"""Moves user-visible English messages in C# code-behind into the resource tables.

    python -I tools/i18n/localize-code.py <Area> <file.cs> [...]          (rewrite + append entries)
    python -I tools/i18n/localize-code.py --check <Area> <file.cs> ...    (report only)

A literal is localized when it is passed to a UI sink:
    Show*(...) / Set*Message(...)            ShowError("..."), ShowMessage("...", true)
    <name>Error = "..." / .Text = "..." / ErrorMessage = "..." / Message = "..." / ToolTip = "..." / EmptyDataText = "..."
    return "..." inside methods whose name contains Message, Friendly, Label or Describe
    the "fallback message" argument of AuthService.Call(...) / Post(...)
Adjacent literals joined with + become one entry. Literals combined with variables are reported, not changed:
those need a format string written by hand (L.F("Area.Key", value)). Technical strings (exceptions, logs, URLs,
keys) are never touched.
"""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
CHECK = '--check' in sys.argv
args = [a for a in sys.argv[1:] if a != '--check']
AREA, FILES = args[0], args[1:]
STRINGS = os.path.join(HERE, 'strings', AREA + '.txt')

LIT = r'@?"(?:[^"\\]|\\.)*"'
CHAIN = LIT + r'(?:\s*\+\s*' + LIT + r')*'
SINKS = [
    re.compile(r'(\b(?:Show\w*|Set\w*Message|Fail|Notify\w*)\s*\(\s*)(' + CHAIN + r')(?=\s*[,)])'),
    re.compile(r'(\b(?:\w+Error|\w*\.Text|Text|ErrorMessage|\w*Message|ToolTip|EmptyDataText|HeaderText)\s*=\s*)(' + CHAIN + r')(?=\s*[;,}])'),
    re.compile(r'(\b(?:Call|Post)\s*\([^;]*?,\s*)(' + CHAIN + r')(?=\s*[,)])'),
]
RETURN_IN = re.compile(r'(?:Message|Friendly|Label|Describe|Text)\w*\s*\(')

keys, by_text, new_entries, manual = set(), {}, [], []
if os.path.exists(STRINGS):
    key = None
    for line in open(STRINGS, encoding='utf-8').read().splitlines():
        m = re.match(r'^\s*en:\s?(.*)$', line)
        if m and key: by_text.setdefault(m.group(1), key); continue
        if line.strip() and not re.match(r'^\s*(ar:|#)', line): key = line.strip(); keys.add(key)

def unquote(lit):
    if lit.startswith('@'): return lit[2:-1].replace('""', '"')
    return bytes(lit[1:-1], 'utf-8').decode('unicode_escape').encode('latin-1').decode('utf-8') if '\\u' not in lit else lit[1:-1].encode().decode('unicode_escape')

def text_of(chain):
    return ''.join(unquote(l) for l in re.findall(LIT, chain))

def worth(t):
    return bool(re.search(r'[A-Za-z]{3,}', t)) and ' ' in t.strip() and not re.search(r'(https?://|\.aspx|\.json|Firebase\.|docs/|\{[0-9]\}|^[\w.]+$|^[a-z-]+/[\w.+-]+)', t) or t.strip() in ('Saved', 'Done')

def slug(t):
    w = re.findall(r'[A-Za-z0-9]+', t)
    return ''.join(x[:1].upper() + x[1:] for x in w[:6]) or 'Message'

def key_for(page, t):
    if t in by_text and by_text[t].startswith(page + '.'): return by_text[t]
    base = page + '.' + slug(t); k, n = base, 2
    while k in keys: k, n = '%s%d' % (base, n), n + 1
    keys.add(k); by_text[t] = k; new_entries.append((k, t)); return k

def process(text, page):
    count = 0
    def repl(m):
        nonlocal count
        chain = m.group(2); t = text_of(chain)
        if not worth(t): return m.group(0)
        count += 1
        return m.group(1) + 'L.T("%s.%s")' % (AREA, key_for(page, t))
    for sink in SINKS: text = sink.sub(repl, text)
    # return "..." inside message-describing methods
    out, pos = [], 0
    for m in re.finditer(r'\breturn\s+(' + CHAIN + r')\s*;', text):
        head = text[:m.start()]
        method = head[head.rfind('\n    ', 0, max(0, head.rfind('{'))):]
        sig = re.findall(r'\b\w+\s*\([^)]*\)\s*\{', head[-3000:])
        t = text_of(m.group(1))
        if sig and RETURN_IN.search(sig[-1]) and worth(t):
            out.append(text[pos:m.start(1)]); out.append('L.T("%s.%s")' % (AREA, key_for(page, t))); pos = m.end(1); count += 1
    out.append(text[pos:]); text = ''.join(out)
    # Report literals mixed with variables in sinks.
    for m in re.finditer(r'\b(?:Show\w*\s*\(|\.Text\s*=|\w+Error\s*=)\s*([^;\n]*"[A-Za-z][^"]{3,}"[^;\n]*\+\s*[A-Za-z_][^;\n]*)', text):
        if 'L.T(' not in m.group(1): manual.append('%s: %s' % (page, m.group(0)[:110]))
    return text, count

for path in FILES:
    raw = open(path, 'rb').read(); bom = raw.startswith(b'\xef\xbb\xbf')
    text = raw.decode('utf-8-sig')
    page = re.sub(r'(\.(aspx|ascx|master))?\.cs$', '', os.path.basename(path)).replace('.', '')
    new, n = process(text, page)
    if n and 'using InternshipManagementSystem.Common;' not in new and 'namespace InternshipManagementSystem.Common' not in new:
        new = re.sub(r'(using System;\r?\n)', r'\1using InternshipManagementSystem.Common;\n', new, count=1)
    print('%-60s %3d messages' % (path, n))
    if not CHECK and new != text: open(path, 'wb').write((b'\xef\xbb\xbf' if bom else b'') + new.encode('utf-8'))
for item in manual: print('   manual:', item)
if not CHECK and new_entries:
    with open(STRINGS, 'a', encoding='utf-8', newline='\n') as f:
        for k, t in new_entries: f.write('\n%s\nen: %s\n' % (k, t.replace('\n', '\\n')))
print('%d new entries, %d need a hand-written format string' % (len(new_entries), len(manual)))
