# sayscmp.py saysdir readings - phil/says (by rule) against the says
# fields of argue's readings (by a model), sentence by sentence: where
# both mark a report, where only one does, and whom each names.
import os,re,sys,glob
says_dir, res = sys.argv[1], sys.argv[2]
rule = {}; model = {}
for f in glob.glob(os.path.join(says_dir,'*.says')):
    p = os.path.basename(f)[:-5]
    for l in open(f):
        m = re.search(r'says/report: S(\d+): (\S+) \((.*)\)', l)
        if m: rule.setdefault(p,set()).add((int(m.group(1)), m.group(2), m.group(3)))
for f in glob.glob(os.path.join(res,'*.logic.r[0-9]')):
    p = os.path.basename(f).split('.logic')[0]
    for l in open(f, errors='replace'):
        m = re.match(r'[PACOR]\d*\tS(\d+)\t.*\tsays (\S+)', l)
        if m: model.setdefault(p,set()).add((int(m.group(1)), m.group(2)))
both=ronly=monly=0; out=[]
for p in sorted(set(rule)|set(model)):
    rs = {(s,w) for s,w,c in rule.get(p,())}
    ms = model.get(p,set())
    rsent = {s for s,w in rs}; msent={s for s,w in ms}
    for s in sorted(rsent|msent):
        rw = {w for x,w in rs if x==s}; mw={w for x,w in ms if x==s}
        if s in rsent and s in msent: both+=1; tag='both'
        elif s in rsent: ronly+=1; tag='rule only'
        else: monly+=1; tag='model only'
        cue = [c for x,w,c in rule.get(p,()) if x==s]
        out.append('%s S%d %s: rule %s %s | model %s' % (p, s, tag, sorted(rw), cue, sorted(mw)))
print('sentences reported: both', both, 'rule only', ronly, 'model only', monly)
print('\n'.join(out))
