# nlicmp.py results [model] - tools/nli/answer.py's answers beside a
# language model's, on the questions phil/settle asked in a run (the
# argue/answered lines in results/*.out), by kind: situations (an NLI
# pair), whether an argument takes a claim for granted, and the rest
# (which it does not read).  For each kind: how many, how often the two
# agree, the agreement of always giving the commoner answer (what to
# beat), and Cohen's kappa.  Needs torch and transformers.
import glob, os, re, subprocess, sys
res = sys.argv[1]
model = sys.argv[2] if len(sys.argv) > 2 else 'cross-encoder/nli-deberta-v3-small'
here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(here, '..', 'tools', 'nli'))
qs = {}
for p in sorted(glob.glob(os.path.join(res, '*.out'))):
    for l in open(p, errors='replace'):
        m = re.search(r'argue/answered: .*?: answered (yes|no), which .*?, to: (.*?)( \[in \d+ of \d+ runs\])?$', l.rstrip('\n'))
        if m:
            qs[m.group(2)] = (m.group(1), os.path.basename(p).split('.')[0])
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import answer
tok = AutoTokenizer.from_pretrained(model)
nli = AutoModelForSequenceClassification.from_pretrained(model)
labels = {v.lower(): k for k, v in nli.config.id2label.items()}
def probs(p, h):
    x = tok(p, h, return_tensors='pt', truncation=True, max_length=512)
    with torch.no_grad():
        return torch.softmax(nli(**x).logits[0], -1).tolist()
def passage(name):
    p = os.path.join(res, name + '.md')
    return open(p, errors='replace').read() if os.path.exists(p) else ''
rows = []
for q, (want, name) in qs.items():
    s = answer.parse_situation(q)
    if s is not None:
        true, false, hyp = s
        prem = ' '.join(answer.sentence(t) for t in true) + ' ' + ' '.join('It is not the case that ' + answer.sentence(f) for f in false)
        pr = probs(prem.strip(), answer.sentence(hyp))
        got = 'yes' if pr[labels['entailment']] == max(pr) else 'no'
        rows.append(('situation', want, got))
        continue
    m = re.search(r'take this for granted, whether or not it says so: "(.*)"\?', q, re.S)
    if m:
        pr = probs(passage(name)[-2000:], answer.sentence(m.group(1)))
        got = 'no' if pr[labels['contradiction']] == max(pr) else 'yes'
        rows.append(('granted', want, got))
        continue
    rows.append(('other', want, None))
def kappa(pairs):
    n = len(pairs)
    if n == 0:
        return 0.0
    po = sum(a == b for a, b in pairs) / n
    pe = sum((sum(a == k for a, _ in pairs) / n) * (sum(b == k for _, b in pairs) / n) for k in ('yes', 'no'))
    return (po - pe) / (1 - pe) if pe < 1 else 0.0
print('model: %s' % model)
print('| Kind | Questions | Agree | Always the commoner | Kappa | Yes by the model, yes here | No by the model, no here |')
print('|---|---|---|---|---|---|---|')
for k in ('situation', 'granted', 'other'):
    r = [(w, g) for kk, w, g in rows if kk == k]
    if not r:
        continue
    if k == 'other':
        print('| %s | %d | not read | | | | |' % (k, len(r)))
        continue
    agree = sum(w == g for w, g in r)
    yes = sum(w == 'yes' for w, _ in r)
    base = max(yes, len(r) - yes)
    yy = sum(w == 'yes' and g == 'yes' for w, g in r)
    nn = sum(w == 'no' and g == 'no' for w, g in r)
    print('| %s | %d | %d (%d%%) | %d (%d%%) | %.2f | %d of %d | %d of %d |' % (k, len(r), agree, 100 * agree // len(r), base, 100 * base // len(r), kappa(r), yy, yes, nn, len(r) - yes))
