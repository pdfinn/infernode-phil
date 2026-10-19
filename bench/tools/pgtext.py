# pgtext.py - Project Gutenberg texts as paragraphs, and passages cut from them by
# phrases matched whatever the line breaks and blanks
import os, re, sys
PG = os.environ.get('PG', 'pg')	# the directory of ebooks, n.txt
def body(n):
    t = open('%s/%s.txt' % (PG, n), encoding='utf-8', errors='replace').read().replace('\r', '')
    a = re.search(r'\*\*\* ?START OF (THE|THIS) PROJECT GUTENBERG EBOOK.*?\*\*\*', t)
    b = re.search(r'\*\*\* ?END OF (THE|THIS) PROJECT GUTENBERG EBOOK', t)
    return t[a.end() if a else 0: b.start() if b else len(t)]
def flat(n):
    # paragraphs joined into lines, blanks squeezed; paragraphs kept apart
    paras = re.split(r'\n\s*\n', body(n))
    return '\n\n'.join(re.sub(r'\s+', ' ', p).strip() for p in paras if p.strip())
def pat(phrase):
    return re.compile(r'\s+'.join(re.escape(w) for w in phrase.split()), re.I)
def find(n, phrase, width=1600):
    t = flat(n); m = pat(phrase).search(t)
    return None if m is None else t[m.start(): m.start() + width]
def cut(n, start, end):
    t = flat(n); a = pat(start).search(t)
    if a is None: raise SystemExit('%s: no start: %s' % (n, start))
    b = pat(end).search(t, a.start())
    if b is None: raise SystemExit('%s: no end: %s' % (n, end))
    return t[a.start(): b.end()]
if __name__ == '__main__':
    print(find(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 1600))
