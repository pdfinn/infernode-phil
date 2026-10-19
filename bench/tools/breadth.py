# breadth.py dir [per] - the breadth sample: per (default 4) argumentative
# paragraphs from each work below, drawn with a fixed seed from the
# paragraphs that look like argument (70 to 320 words, three sentences or
# more, ending a sentence, with a word of inference in them), past each
# book's front matter, and none in the gold set.  Written to dir as
# work-n.md, with SOURCES saying where each came from.
import os, random, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pgtext import flat
from gold import G
WORKS = [
    (1497, 'plato-republic', 'Plato, Republic, tr. B. Jowett'),
    (1672, 'plato-gorgias', 'Plato, Gorgias, tr. B. Jowett'),
    (1658, 'plato-phaedo', 'Plato, Phaedo, tr. B. Jowett'),
    (8438, 'aristotle-ethics', 'Aristotle, Nicomachean Ethics, tr. D. P. Chase'),
    (6762, 'aristotle-politics', 'Aristotle, Politics, tr. W. Ellis'),
    (10661, 'epictetus', 'Epictetus, Discourses (selection), tr. G. Long'),
    (14328, 'boethius', 'Boethius, Consolation of Philosophy, tr. H. R. James'),
    (3296, 'augustine', 'Augustine, Confessions, tr. E. B. Pusey'),
    (17611, 'aquinas-st-i', 'Thomas Aquinas, Summa Theologica I, tr. Dominican Fathers'),
    (17897, 'aquinas-st-i-ii', 'Thomas Aquinas, Summa Theologica I-II, tr. Dominican Fathers'),
    (59, 'descartes-discourse', 'R. Descartes, Discourse on Method, tr. J. Veitch'),
    (3207, 'hobbes-leviathan', 'T. Hobbes, Leviathan'),
    (7370, 'locke-treatise', 'J. Locke, Second Treatise of Government'),
    (3800, 'spinoza-ethics', 'B. de Spinoza, Ethics, tr. R. H. M. Elwes'),
    (4723, 'berkeley-principles', 'G. Berkeley, Principles of Human Knowledge'),
    (4705, 'hume-treatise', 'D. Hume, Treatise of Human Nature'),
    (9662, 'hume-enquiry', 'D. Hume, Enquiry concerning Human Understanding'),
    (4583, 'hume-dialogues', 'D. Hume, Dialogues concerning Natural Religion'),
    (5682, 'kant-groundwork', 'I. Kant, Fundamental Principles of the Metaphysic of Morals, tr. T. K. Abbott'),
    (5683, 'kant-practical', 'I. Kant, Critique of Practical Reason, tr. T. K. Abbott'),
    (11224, 'mill-utilitarianism', 'J. S. Mill, Utilitarianism'),
    (34901, 'mill-liberty', 'J. S. Mill, On Liberty'),
    (27083, 'mill-subjection', 'J. S. Mill, The Subjection of Women'),
    (46743, 'sidgwick-methods', 'H. Sidgwick, The Methods of Ethics'),
    (26659, 'james-will', 'W. James, The Will to Believe'),
]
INFER = re.compile(r'\b(therefore|hence|thus|consequently|it follows|follows that|must|wherefore|for this reason|so that|because)\b', re.I)
out = sys.argv[1]
per = int(sys.argv[2]) if len(sys.argv) > 2 else 4
os.makedirs(out, exist_ok=True)
gold = [re.sub(r'\W+', ' ', open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'gold', g[0] + '.md')).read()).lower()[:200] for g in G]
rng = random.Random(20261019)
src = open(os.path.join(out, 'SOURCES'), 'w')
src.write('# passage\tebook\twork\tparagraph\n')
for n, name, work in WORKS:
    paras = flat(n).split('\n\n')
    first = len(paras) // 25		# front matter: the first part of the book
    for i, p in enumerate(paras):
        if 'PERSONS OF THE DIALOGUE' in p:
            first = i + 1
    cand = []
    for i in range(first, len(paras)):
        p = paras[i]
        w = len(p.split())
        if not (70 <= w <= 320) or p.isupper() or p.startswith('['):
            continue
        if len(re.findall(r'[.?!]["\')]?(\s|$)', p)) < 3 or not re.search(r'[.?!]["\')]?$', p):
            continue
        if not INFER.search(p) or re.search(r'Project Gutenberg|footnote|\[\d+\]', p, re.I):
            continue
        key = re.sub(r'\W+', ' ', p).lower()
        if any(g[:120] in key or key[:120] in g for g in gold):
            continue
        cand.append(i)
    for k, i in enumerate(sorted(rng.sample(cand, min(per, len(cand)))), 1):
        pid = '%s-%d' % (name, k)
        open(os.path.join(out, pid + '.md'), 'w').write(paras[i].replace('_', '') + '\n')
        src.write('%s\t%d\t%s\t%d\n' % (pid, n, work, i))
    print('%-22s %4d candidates' % (name, len(cand)))
