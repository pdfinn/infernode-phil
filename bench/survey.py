# survey.py sources results - the breadth sample's readings (bench/run.sh
# with -n 2), measured where there is no gold: for each passage, each
# run's verdict, whether the runs agree, how far its readings agreed,
# what it marked as reported (says) and of what kind; by work and in all;
# and every says line, for a person to check against the text.
import os, re, sys, collections
sources, res = sys.argv[1], sys.argv[2]
work = {}
for l in open(sources):
    if l.startswith('#'): continue
    pid, n, w, _ = l.rstrip('\n').split('\t')
    work[pid] = w
rows = []
says_all = []
kinds = collections.Counter()
rules = collections.Counter()
for pid in sorted(work):
    runs = []
    for i in (1, 2, 3):
        o = os.path.join(res, '%s.logic.r%d.out' % (pid, i))
        if not os.path.exists(o): continue
        t = open(o, errors='replace').read()
        v = re.findall(r'argue/valid (-?\d)', t)
        unread = 'could not read' in t and not v
        ra = re.findall(r'argue/readings-agree (\d+)', t); rd = re.findall(r'argue/readings-differ (\d+)', t)
        for r in re.findall(r': argue/([a-z-]+):', t): rules[r] += 1
        lg = os.path.join(res, '%s.logic.r%d' % (pid, i))
        lines = open(lg, errors='replace').read().split('\n') if os.path.exists(lg) else []
        st = [l for l in lines if re.match(r'(P|A|C|O|R)\d*\t', l)]
        sy = [l for l in st if re.search(r'\tsays ', l)]
        for l in st:
            m = re.search(r'\tkind (\w+)', l)
            if m: kinds[m.group(1)] += 1
        for l in sy:
            says_all.append((pid, i, l))
        runs.append(dict(v=v[-1] if v else ('unreadable' if unread else '?'), agree=(int(ra[-1]) if ra else None, int(rd[-1]) if rd else None), n=len(st), says=len(sy)))
    rows.append((pid, runs))
n = len(rows)
done = [r for r in rows if r[1]]
verd = collections.Counter(x['v'] for _, rs in done for x in rs)
same = sum(1 for _, rs in done if len(rs) > 1 and len({x['v'] for x in rs}) == 1)
multi = sum(1 for _, rs in done if len(rs) > 1)
ag = [x['agree'] for _, rs in done for x in rs if x['agree'][0] is not None]
agree_frac = sum(a / (a + d) for a, d in ag if a + d) / max(1, len([1 for a, d in ag if a + d]))
print('Passages %d, read %d.' % (n, len(done)))
print()
print('| Measure | Value |')
print('|---|---|')
print('| Runs, by verdict | %s |' % ', '.join('%s: %d' % (k, v) for k, v in sorted(verd.items())))
print('| Passages whose runs agree on the verdict | %d of %d |' % (same, multi))
print('| Statements the three readings of a run agree on, on average | %.0f%% |' % (100 * agree_frac))
print('| Statements per reading, median | %d |' % sorted(x['n'] for _, rs in done for x in rs)[len([1 for _, rs in done for x in rs]) // 2])
print('| Readings with a says line | %d of %d |' % (sum(1 for _, rs in done for x in rs if x['says']), sum(len(rs) for _, rs in done)))
print('| kind fields | %s |' % ', '.join('%s %d' % kv for kv in kinds.most_common()))
print()
print('Findings, most common: ' + ', '.join('%s %d' % kv for kv in rules.most_common(14)))
print()
print('| Work | Passages | Verdicts (run 1, run 2) | Runs agree |')
print('|---|---|---|---|')
byw = collections.OrderedDict()
for pid, rs in rows:
    byw.setdefault(work[pid], []).append(rs)
for w, rss in byw.items():
    vs = '; '.join(','.join(x['v'] for x in rs) or 'not run' for rs in rss)
    ag = sum(1 for rs in rss if len(rs) > 1 and len({x['v'] for x in rs}) == 1)
    print('| %s | %d | %s | %d |' % (w, len(rss), vs, ag))
print()
print('Every says line, for review:')
print()
for pid, i, l in says_all:
    f = l.split('\t')
    print('- %s run %d, %s %s: `%s` %s' % (pid, i, f[0], f[1], f[2].replace('|', '\\|'), ' '.join(f[3:])))
