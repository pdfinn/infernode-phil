# score.py gold results - how the readings in results (bench/run.sh's)
# fare against the gold set: for each passage, run by run, whether the
# known fault was located (a finding of a fault at the gold sentence),
# detected (the argument does not hold without what the text never
# states, or some fault is found elsewhere), or missed; for a valid
# passage, whether it was read as valid (a false alarm if not).  Then
# what each run's reading assumed or said was missing, beside the gold
# statement of the fault, for a person to judge whether it is the one.
import os, re, sys
FAULT = ('invalid', 'missing', 'assumed', 'begs', 'circular', 'equivocates', 'modal-ambiguous', 'quantifier', 'converse', 'unlinked', 'negation')
gold, res = sys.argv[1], sys.argv[2]
def gfile(g):
    d = {}
    for l in open(os.path.join(gold, g + '.gold')):
        k, _, v = l.rstrip('\n').partition('\t')
        d[k] = v
    return d
def findings(path):
    r = []
    for l in open(path, errors='replace'):
        m = re.match(r'\S+?: (argue/[a-z-]+): (.*)', l.rstrip('\n'))
        if not m:
            m = re.match(r'\S+?:\d+: (argue/[a-z-]+): (.*)', l.rstrip('\n'))
        if m:
            s = re.search(r'\(S(\d+)\)', m.group(2))
            r.append((m.group(1)[6:], int(s.group(1)) if s else None, m.group(2)))
    return r
rows, review = [], []
for f in sorted(os.listdir(gold)):
    if not f.endswith('.gold'):
        continue
    g = f[:-5]; d = gfile(g); cls = d['class']
    at = int(d['at'].split('\t')[0][1:]) if 'at' in d else None
    runs = []
    for i in (1, 2, 3):
        p = os.path.join(res, '%s.logic.r%d.out' % (g, i))
        if not os.path.exists(p):
            runs.append(None); continue
        fs = findings(p)
        v = re.findall(r'argue/valid (-?\d)', open(p, errors='replace').read())
        verdict = v[-1] if v else '?'
        located = at is not None and any(r in FAULT and s == at for r, s, _ in fs)
        detected = verdict == '0' or any(r in FAULT for r, s, _ in fs)
        said = [(r, s, m) for r, s, m in fs if r in ('assumed', 'missing', 'begs', 'equivocates', 'modal-ambiguous')]
        lp = os.path.join(res, '%s.logic.r%d' % (g, i))
        asm = [l.rstrip('\n') for l in open(lp, errors='replace') if re.match(r'A\d+\t', l)] if os.path.exists(lp) else []
        runs.append((verdict, located, detected, said, asm))
    rows.append((g, cls, at, runs))
    review.append((g, d, runs))
def cell(cls, r):
    if r is None: return 'not run'
    verdict, located, detected, _, _ = r
    if cls == 'valid':
        return 'valid' if verdict == '1' else ('false alarm' if verdict == '0' else 'undecided')
    return 'located' if located else ('detected' if detected else 'missed')
print('| Passage | Class | Gold sentence | Run 1 | Run 2 | Run 3 |')
print('|---|---|---|---|---|---|')
tot = {}
for g, cls, at, runs in rows:
    cs = [cell(cls, r) for r in runs]
    for c in cs:
        tot.setdefault(cls, {}).setdefault(c, 0)
        tot[cls][c] += 1
    print('| %s | %s | %s | %s |' % (g, cls, 'S%d' % at if at else '-', ' | '.join(cs)))
print()
for cls in ('inference', 'equivocation', 'valid'):
    if cls in tot:
        n = sum(tot[cls].values())
        print('%s: %s, of %d runs' % (cls, ', '.join('%s %d' % (k, v) for k, v in sorted(tot[cls].items())), n))
print()
for g, d, runs in review:
    if d['class'] == 'valid' and all(r is None or r[0] == '1' for r in runs):
        continue
    print('### %s\n' % g)
    print('Gold (%s): %s\n' % (d.get('at', '-').replace('\t', ': '), d['fault']))
    for i, r in enumerate(runs, 1):
        if r is None:
            continue
        verdict, located, detected, said, asm = r
        print('- Run %d, valid %s:' % (i, verdict))
        for a in asm:
            print('  - assumed `%s`' % a.split('\t', 2)[-1].replace('|', '\\|'))
        for rr, s, m in said:
            if rr != 'assumed':
                print('  - %s: %s' % (rr, m[:240].replace('|', '\\|')))
    print()
