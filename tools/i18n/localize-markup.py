"""Moves hard-coded interface text from Web Forms markup into the resource tables.

    python -I tools/i18n/localize-markup.py <Area> <file> [<file> ...]       (rewrite + append entries)
    python -I tools/i18n/localize-markup.py --check <Area> <file> ...        (report only)

- Plain HTML text nodes and attributes (placeholder, title, aria-label, alt and data-* messages) become
  <%: L.T("Area.Key") %>.
- Server-control properties (Text, ErrorMessage, HeaderText, ToolTip, EmptyDataText, placeholder, ...) become
  <%$ Resources:Area, Key %>, the form ASP.NET allows on server controls.
- Skipped and listed for manual work: <script>, <style>, comments, code blocks, and the content of controls that do not
  accept render blocks (Label, LinkButton, HyperLink, ListItem, Literal, Button...).
- Each new key is appended to tools/i18n/strings/<Area>.txt with its English text; Arabic comes from the translation
  memory (tools/i18n/memory.txt) when the same English text is already translated.
- Files keep their own encoding (UTF-8 with/without BOM, or Windows-1252).
"""
import html, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
CHECK = '--check' in sys.argv
args = [a for a in sys.argv[1:] if a != '--check']
AREA, FILES = args[0], args[1:]
STRINGS = os.path.join(HERE, 'strings', AREA + '.txt')

TEXT_ATTRS = ('placeholder', 'title', 'aria-label', 'alt', 'data-required-message', 'data-short-message', 'data-invalid-message',
              'data-portal-label', 'data-empty-message', 'data-confirm', 'data-confirm-message', 'data-loading-text', 'data-busy-text')
CONTROL_PROPS = ('Text', 'ErrorMessage', 'HeaderText', 'ToolTip', 'EmptyDataText', 'placeholder', 'Title', 'AlternateText',
                 'ValidationGroupText', 'FooterText', 'InitialValue_never')
NO_CONTENT_CONTROLS = re.compile(r'^(asp:(Label|LinkButton|HyperLink|ListItem|Literal|Button|Localize|TextBox|RequiredFieldValidator|RegularExpressionValidator|CompareValidator|CustomValidator|RangeValidator|ValidationSummary)|uims:)', re.I)

def load_existing():
    keys, by_text = set(), {}
    if os.path.exists(STRINGS):
        key = None
        for line in open(STRINGS, encoding='utf-8').read().splitlines():
            m = re.match(r'^\s*en:\s?(.*)$', line)
            if m and key: by_text.setdefault(m.group(1), key); continue
            if line.strip() and not re.match(r'^\s*(ar:|#)', line): key = line.strip(); keys.add(key)
    return keys, by_text

keys, by_text = load_existing()
new_entries = []

def slug(text, limit=6):
    words = re.findall(r"[A-Za-z0-9]+", text)
    return ''.join(w[:1].upper() + w[1:] for w in words[:limit]) or 'Text'

def key_for(page, text):
    text = text.strip()
    if text in by_text and by_text[text].startswith(page + '.'): return by_text[text]
    base = page + '.' + slug(text)
    k, n = base, 2
    while k in keys: k, n = '%s%d' % (base, n), n + 1
    keys.add(k); by_text[text] = k; new_entries.append((k, text))
    return k

def clean(text):
    return re.sub(r'\s+', ' ', html.unescape(text)).strip()

def worth(text):
    t = clean(text)
    return bool(re.search(r'[A-Za-z]{2}', t)) and not re.match(r'^(UIMS|GJU|PDF|CV|URL|ID|Zoom|GitHub|LinkedIn|https?://\S+|[\w.+-]+@[\w.-]+|\S+\.(aspx|pdf|png|jpg))$', t)

TOKEN = re.compile(r'<!DOCTYPE[^>]*>|<!\[CDATA\[.*?\]\]>|<%--.*?--%>|<%.*?%>|<script\b.*?</script>|<style\b.*?</style>|<!--.*?-->|<(/?)([A-Za-z][\w:.-]*)((?:<%.*?%>|[^>"\']|"[^"]*"|\'[^\']*\')*?)(/?)>', re.S | re.I)
ATTR = re.compile(r'(\s)([\w:.-]+)\s*=\s*"([^"]*)"')

def process_text(text, page):
    out, pos = [], 0
    manual = []
    stack = []  # (tagname, is_server, blocks_render)
    for m in TOKEN.finditer(text):
        chunk = text[pos:m.start()]
        out.append(rewrite_text(chunk, page, stack, manual))
        tok = m.group(0)
        if m.group(2):  # a tag
            closing, name, attrs, selfclose = m.group(1), m.group(2), m.group(3), m.group(4)
            if closing:
                for i in range(len(stack) - 1, -1, -1):
                    if stack[i][0].lower() == name.lower(): del stack[i:]; break
            else:
                server = ':' in name or re.search(r'runat\s*=\s*"server"', attrs or '', re.I) is not None
                tok = rewrite_attrs(tok, name, attrs, server, page, manual)
                void = name.lower() in ('br', 'img', 'input', 'meta', 'link', 'hr', 'source', 'track', 'col', 'area', 'wbr', 'param')
                if not selfclose and not void:
                    stack.append((name, server, bool(NO_CONTENT_CONTROLS.match(name)) or (server and not re.match(r'^(asp:(Content|ContentPlaceHolder|PlaceHolder|Panel|Repeater|GridView|ListView|DataList|FormView|DetailsView|TemplateField|MultiView|View|UpdatePanel)|form|head|ItemTemplate|HeaderTemplate|FooterTemplate|EmptyDataTemplate|AlternatingItemTemplate|SeparatorTemplate|LayoutTemplate|Columns|ContentTemplate|EditItemTemplate|InsertItemTemplate|Fields)$', name, re.I) and not name.lower() in ('a', 'div', 'span', 'section', 'p', 'li', 'ul', 'td', 'th', 'tr', 'table', 'tbody', 'thead', 'button', 'label', 'h1', 'h2', 'h3', 'h4', 'small', 'strong', 'nav', 'header', 'footer', 'main', 'article', 'aside', 'figure', 'figcaption', 'details', 'summary', 'dl', 'dt', 'dd', 'em', 'i', 'b', 'option', 'select', 'textarea', 'body', 'html'))))
        out.append(tok); pos = m.end()
    out.append(rewrite_text(text[pos:], page, stack, manual))
    return ''.join(out), manual

def rewrite_text(chunk, page, stack, manual):
    if not worth(chunk): return chunk
    if any(s[2] for s in stack):
        manual.append('content of <%s>: %s' % ([s[0] for s in stack if s[2]][-1], clean(chunk)[:70])); return chunk
    if any(s[0].lower() in ('textarea', 'option') for s in stack):
        manual.append('content of <%s>: %s' % (stack[-1][0], clean(chunk)[:70])); return chunk
    lead = re.match(r'^\s*', chunk).group(0); trail = re.search(r'\s*$', chunk).group(0)
    k = key_for(page, clean(chunk))
    return '%s<%%: L.T("%s.%s") %%>%s' % (lead, AREA, k, trail)

def rewrite_attrs(tok, name, attrs, server, page, manual):
    def repl(m):
        attr, value = m.group(2), m.group(3)
        if '<%' in value or not worth(value): return m.group(0)
        if server and attr in CONTROL_PROPS:
            k = key_for(page, clean(value)); return '%s%s="<%%$ Resources:%s, %s %%>"' % (m.group(1), attr, AREA, k)
        if server and attr.lower() in TEXT_ATTRS:
            k = key_for(page, clean(value)); return '%s%s="<%%$ Resources:%s, %s %%>"' % (m.group(1), attr, AREA, k)
        if not server and attr.lower() in TEXT_ATTRS:
            k = key_for(page, clean(value)); return '%s%s="<%%: L.T("%s.%s") %%>"' % (m.group(1), attr, AREA, k)
        if not server and name.lower() == 'input' and attr.lower() == 'value' and re.search(r'type\s*=\s*"(button|submit|reset)"', attrs, re.I):
            k = key_for(page, clean(value)); return '%s%s="<%%: L.T("%s.%s") %%>"' % (m.group(1), attr, AREA, k)
        return m.group(0)
    return ATTR.sub(repl, tok)

total_manual = 0
for path in FILES:
    raw = open(path, 'rb').read()
    bom = raw.startswith(b'\xef\xbb\xbf')
    try: text, enc = raw.decode('utf-8-sig'), 'utf-8'
    except UnicodeDecodeError: text, enc = raw.decode('cp1252'), 'cp1252'
    page = re.sub(r'\.(aspx|master|ascx)$', '', os.path.basename(path)).replace('.', '')
    # Page directive: keep (its Title is handled by L.PageTitle in the masters).
    head = re.match(r'\s*<%@[^%]*%>', text)
    before = len(new_entries)
    new, manual = process_text(text, page)
    total_manual += len(manual)
    print('%-55s %3d new keys, %2d manual  [%s%s]' % (path, len(new_entries) - before, len(manual), enc, '+bom' if bom else ''))
    for item in manual: print('      manual:', item)
    if not CHECK and new != text:
        open(path, 'wb').write((b'\xef\xbb\xbf' if bom else b'') + new.encode(enc))

if not CHECK and new_entries:
    memory = {}
    mp = os.path.join(HERE, 'memory.txt')
    if os.path.exists(mp):
        en = None
        for line in open(mp, encoding='utf-8').read().splitlines():
            if line.startswith('en: '): en = line[4:]
            elif line.startswith('ar: ') and en is not None: memory[en] = line[4:]; en = None
    with open(STRINGS, 'a', encoding='utf-8', newline='\n') as f:
        for k, t in new_entries:
            f.write('\n%s\nen: %s\n' % (k, t))
            if t in memory: f.write('ar: %s\n' % memory[t])
print('%d new entries, %d items need manual work' % (len(new_entries), total_manual))
