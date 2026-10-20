# aligncmp.py out res - how phil/align did on three readings of each
# passage (bench/align.sh's out, the readings in res): of the first
# reading's atoms, how many were aligned by form and how many by words
# alone; how often form and words agree (words >= 0.5); and whether the
# alignments hold together: where r1's x is r2's y and r2's y is r3's z,
# whether r1's x is r3's z.  Then the alignments by form whose words
# disagree, for a person to judge.
import os, re, sys
out, res = sys.argv[1], sys.argv[2]
def atoms(p):
    a = []
    for l in open(p, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if f[0] == 'atom' and len(f) > 2:
            a.append(re.sub(r'\(.*', '', f[1]))
    return a
def aligns(p):
    d = {}
    if not os.path.exists(p):
        return d
    for l in open(p):
        f = l.rstrip('\n').split('\t')
        if len(f) < 4 or f[0] != 'same':
            continue
        a, b = f[1].split(':', 1)[1], f[2].split(':', 1)[1]
        attrs = dict(x.split('=', 1) for x in f[3].split() if '=' in x)
        d[a] = (b, attrs)
    return d
tot = shape = words = 0
agree = shapen = 0
tri = trin = 0
low = []
names = sorted(set(f.split('.r')[0] for f in os.listdir(out) if f.endswith('.align')))
for n in names:
    a12 = aligns(os.path.join(out, n + '.r1-r2.align'))
    a13 = aligns(os.path.join(out, n + '.r1-r3.align'))
    a23 = aligns(os.path.join(out, n + '.r2-r3.align'))
    r1 = atoms(os.path.join(res, n + '.logic.r1'))
    for x in r1:
        for al in (a12, a13):
            tot += 1
            if x in al:
                b, at = al[x]
                if at.get('rule') == 'shape':
                    shape += 1
                    shapen += 1
                    w = float(at.get('words', '0'))
                    agree += w >= 0.5
                    if w < 0.5:
                        low.append((n, x, b, at.get('words'), at.get('sentences')))
                else:
                    words += 1
        if x in a12 and x in a13 and a12[x][0] in a23:
            trin += 1
            tri += a23[a12[x][0]][0] == a13[x][0]
pct = lambda a, b: '%d of %d (%d%%)' % (a, b, 100 * a // b) if b else '0 of 0'
print('passages: %d' % len(names))
print('first reading\'s atoms aligned by form: %s' % pct(shape, tot))
print('aligned by words alone: %s' % pct(words, tot))
print('by form, the words agreeing (>= 0.5): %s' % pct(agree, shapen))
print('holding together (r1-r2-r3 the same as r1-r3): %s' % pct(tri, trin))
print()
print('| Passage | r1 | r2 or r3 | Words | Sentences |')
print('|---|---|---|---|---|')
for n, x, b, w, s in low:
    print('| %s | %s | %s | %s | %s |' % (n, x, b, w, s))
