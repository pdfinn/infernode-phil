# canon.py out - lib/phil/canon, the canonical works phil/canon reads
# citations of, built from PerseusDL's canonical-greekLit (CC BY-SA 4.0):
# for each work of Plato (tlg0059) and Aristotle (tlg0086) its English
# title from the catalogue (__cts__.xml), its CTS URN, and the first and
# last passage its Greek edition marks (Stephanus section, or Bekker page,
# column and line), with the abbreviations scholars use beside the title.
# The commit read is named in the file's head.  Kant and Aquinas, whose
# citations are by edition volume and page or by part, question and
# article, are given by hand at the end, with what bounds them.
import re, sys, urllib.request
BASE = 'https://raw.githubusercontent.com/PerseusDL/canonical-greekLit/%s/data/'
REF = 'master'
def get(path):
    with urllib.request.urlopen((BASE % REF) + path) as r:
        return r.read().decode('utf-8', 'replace')
ABBR = {
    'Republic': ['Rep.', 'Resp.'], 'Phaedo': ['Phd.'], 'Apology': ['Ap.', 'Apol.'], 'Meno': ['Men.'],
    'Symposium': ['Symp.'], 'Phaedrus': ['Phdr.'], 'Theaetetus': ['Tht.'], 'Gorgias': ['Grg.', 'Gorg.'],
    'Euthyphro': ['Euthphr.'], 'Crito': ['Cri.'], 'Protagoras': ['Prt.', 'Prot.'], 'Timaeus': ['Ti.', 'Tim.'],
    'Laws': ['Leg.'], 'Sophist': ['Sph.', 'Soph.'], 'Statesman': ['Plt.'], 'Parmenides': ['Prm.', 'Parm.'],
    'Philebus': ['Phlb.', 'Phil.'], 'Euthydemus': ['Euthd.'], 'Cratylus': ['Cra.', 'Crat.'],
    'Metaphysics': ['Met.', 'Metaph.'], 'Nicomachean Ethics': ['NE', 'EN', 'Eth. Nic.', 'Nic. Eth.'],
    'Physics': ['Phys.'], 'Politics': ['Pol.'], 'Categories': ['Cat.'], 'De Anima': ['DA', 'De An.', 'On the Soul'],
    'Posterior Analytics': ['APo.', 'An. Post.'], 'Prior Analytics': ['APr.', 'An. Pr.'], 'Topics': ['Top.'],
    'Sophistical Refutations': ['SE', 'Soph. El.'], 'Rhetoric': ['Rhet.'], 'Poetics': ['Poet.'],
    'On Interpretation': ['De Int.', 'Int.'], 'Eudemian Ethics': ['EE', 'Eth. Eud.'],
}
def work(auth, n):
    cts = get('%s/tlg%03d/__cts__.xml' % (auth, n))
    t = re.search(r'<ti:title xml:lang="eng">([^<]*)', cts) or re.search(r'<ti:title[^>]*>([^<]*)', cts)
    eds = re.findall(r'urn="(urn:cts:greekLit:%s\.tlg%03d\.perseus-grc\d)"' % (auth, n), cts)
    if not t or not eds:
        return None
    title = re.sub(r'\s+', ' ', t.group(1)).strip()
    ed = eds[-1]
    xml = get('%s/tlg%03d/%s.xml' % (auth, n, ed.split(':')[-1]))
    if auth == 'tlg0059':
        s = re.findall(r'unit="section" resp="Stephanus" n="(\d+[a-e])"', xml) or re.findall(r'resp="Stephanus" unit="section" n="(\d+[a-e])"', xml)
        if not s:
            return None
        return title, 'urn:cts:greekLit:%s.tlg%03d' % (auth, n), 'stephanus', s[0], s[-1]
    # Bekker: a page (980a) and the lines on it
    first = last = None
    page = None
    for m in re.finditer(r'<milestone[^>]*>', xml):
        tag = m.group(0)
        if 'Bekker' not in tag:
            continue
        v = re.search(r'n="([^"]*)"', tag)
        if not v:
            continue
        if 'unit="page"' in tag:
            page = v.group(1)
            if first is None:
                first = page
            last = page
        elif 'unit="line"' in tag and page:
            if first == page and not re.search(r'\d+[ab]\d', first):
                first = page + v.group(1)
            last = page + v.group(1)
    if not first:
        return None
    return title, 'urn:cts:greekLit:%s.tlg%03d' % (auth, n), 'bekker', first, last
out = open(sys.argv[1], 'w')
out.write('# phil/canon\'s works: name, urn, system, first, last, author, title; a tab between.\n')
out.write('# Plato and Aristotle from PerseusDL canonical-greekLit (CC BY-SA 4.0), %s, by bench/tools/canon.py;\n' % REF)
out.write('# first and last are the first and last passage the Greek edition marks.\n')
for auth, who, rng in (('tlg0059', 'Plato', range(1, 37)), ('tlg0086', 'Aristotle', range(1, 60))):
    for n in rng:
        try:
            w = work(auth, n)
        except Exception as e:
            continue
        if not w:
            continue
        title, urn, sysname, f, l = w
        for name in [title] + ABBR.get(title, []):
            out.write('\t'.join((name, urn, sysname, f, l, who, title)) + '\n')
        sys.stderr.write('%s %s %s %s-%s\n' % (who, title, sysname, f, l))
out.write("""Critique of Pure Reason	-	krv	A1/B1	A856/B884	Kant	Critique of Pure Reason
KrV	-	krv	A1/B1	A856/B884	Kant	Critique of Pure Reason
CPR	-	krv	A1/B1	A856/B884	Kant	Critique of Pure Reason
AA	-	aa	1:1	29:1	Kant	Gesammelte Schriften (Akademie-Ausgabe)
Ak	-	aa	1:1	29:1	Kant	Gesammelte Schriften (Akademie-Ausgabe)
Ak.	-	aa	1:1	29:1	Kant	Gesammelte Schriften (Akademie-Ausgabe)
Groundwork	-	aa	4:385	4:463	Kant	Groundwork of the Metaphysics of Morals
GMS	-	aa	4:385	4:463	Kant	Groundwork of the Metaphysics of Morals
Summa Theologica	-	summa	I q.1	III q.90	Aquinas	Summa Theologiae
Summa Theologiae	-	summa	I q.1	III q.90	Aquinas	Summa Theologiae
ST	-	summa	I q.1	III q.90	Aquinas	Summa Theologiae
DK	-	dk	1	90	Diels-Kranz	Die Fragmente der Vorsokratiker
""")
