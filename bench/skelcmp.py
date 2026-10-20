# skelcmp.py skel ref [suffix] - the reading by rule (bench/skeleton.sh's
# name.skel.shape in skel) set beside another reading of each passage,
# sentence by sentence, by the form of each statement (phil/shape's
# lines): a key (bench/planted's name.key.logic, suffix .key.shape) or a
# model's kept reading (suffix .shape, made by phil/shape from a run's
# name.logic).  For each sentence with a statement in both, whether
# their main connectives (-> | & ! [] ought ...) agree; the measures:
# of the sentences where the other reading has a connective, how many
# the rule has (recall), and of those where the rule has one, how many
# the other has (precision); and whether both conclude at one sentence.
# Then each disagreement, for a person to say which is right.
import os, sys
skel, ref = sys.argv[1], sys.argv[2]
suffix = sys.argv[3] if len(sys.argv) > 3 else '.shape'
def shapes(path):
    d = {}
    conc = None
    if not os.path.exists(path):
        return None, None
    for l in open(path, errors='replace'):
        f = l.rstrip('\n').split('\t')
        if len(f) < 5:
            continue
        stmt, sent, main, form = f[1], f[2], f[3], f[4]
        if stmt.startswith('C') and stmt[1:] == '':
            conc = sent
        if sent.startswith('S'):
            d.setdefault(sent, []).append((stmt, main, form))
    return d, conc
n = rec = recn = prec = precn = concagree = concn = 0
dis = []
for f in sorted(os.listdir(skel)):
    if not f.endswith('.skel.shape'):
        continue
    name = f[:-len('.skel.shape')]
    s, sc = shapes(os.path.join(skel, f))
    r, rc = shapes(os.path.join(ref, name + suffix))
    if r is None:
        continue
    n += 1
    if rc is not None and sc is not None:
        concn += 1
        concagree += rc == sc
        if rc != sc:
            dis.append((name, '-', 'conclusion at %s' % sc, 'conclusion at %s' % rc))
    for sent in sorted(set(s) & set(r), key=lambda x: int(x[1:])):
        sm = set(m for _, m, _ in s[sent])
        rm = set(m for _, m, _ in r[sent])
        rconn = rm - {'atom'}
        sconn = sm - {'atom'}
        if rconn:
            recn += 1
            rec += bool(rconn & sconn)
        if sconn:
            precn += 1
            prec += bool(sconn & rm)
        if sconn != rconn:
            dis.append((name, sent, '; '.join(fm for _, _, fm in s[sent]), '; '.join(fm for _, _, fm in r[sent])))
pct = lambda a, b: '%d of %d (%d%%)' % (a, b, 100 * a // b) if b else '0 of 0'
print('passages: %d' % n)
print('a connective in the other reading found by rule: %s' % pct(rec, recn))
print('a connective by rule that the other reading has: %s' % pct(prec, precn))
print('the same sentence concluded: %s' % pct(concagree, concn))
print()
print('| Passage | Sentence | By rule | The other reading |')
print('|---|---|---|---|')
for name, sent, a, b in dis:
    print('| %s | %s | `%s` | `%s` |' % (name, sent, a.replace('|', '\\|'), b.replace('|', '\\|')))
