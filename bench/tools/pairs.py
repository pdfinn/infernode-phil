# pairs.py dir - the attribution pairs: for each, a corpus directory with
# the source's passages (one work) and the commentary that reports them
# (another), cut from Project Gutenberg texts in $PG, and a works file.
# Readings are made by bench/pairs.sh: the source first, then the
# commentary given the source's atoms, so that where it speaks of the
# source's claims the two readings share names, and align follows.
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pgtext import cut
PAIRS = {
    'berkeley-locke': [
        ('locke', 'primary', '1690', 'J. Locke, Essay concerning Human Understanding II.xi.10, III.iii.6, IV.vii.9', [
            (10615, 'If it may be doubted whether beasts compound', 'any other general signs.'),
            (10616, 'Words become general by being made the signs of general ideas', 'is (as we call it) of that sort.'),
            (10616, 'does it not require some pains and skill to form the general idea of a triangle', 'inconsistant ideas are put together.')]),
        ('berkeley', 'secondary', '1710', 'G. Berkeley, Principles of Human Knowledge, Introduction sect. 11', [
            (4723, 'I proceed to examine what can be alleged in DEFENCE', 'any one of which it indifferently suggests to the mind.')])],
    'mill-kant': [
        ('kant', 'primary', '1785', 'I. Kant, Fundamental Principles of the Metaphysic of Morals, sect. II, tr. T. K. Abbott', [
            (5682, 'Another finds himself forced by necessity to borrow money', 'ridicule all such statements as vain pretences.')]),
        ('mill', 'secondary', '1863', 'J. S. Mill, Utilitarianism, ch. 1', [
            (11224, 'I cannot help referring, for illustration', 'such as no one would choose to incur.')])],
    'sidgwick-mill': [
        ('mill', 'primary', '1863', 'J. S. Mill, Utilitarianism, ch. 4', [
            (11224, 'The only proof capable of being given that an object is visible', 'one of the criteria of morality.')]),
        ('sidgwick', 'secondary', '1907', 'H. Sidgwick, The Methods of Ethics, 7th ed., III.xiii.4', [
            (46743, 'Still, when I examine the', 'the intuition of Rational Benevolence.')])],
}
out = sys.argv[1]
for pair, works in PAIRS.items():
    d = os.path.join(out, pair)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, 'works'), 'w') as w:
        w.write('# id\tkey\tkind\tdate\tpath\trevision\ttitle\n')
        for wid, kind, date, title, spans in works:
            t = '\n\n'.join(cut(n, a, b) for n, a, b in spans)
            t = re.sub(r'\s*\[Note\.? ?\d+\]', '', t).replace('_', '')
            t = re.sub(r'\[\d+\]', '', t)
            open(os.path.join(d, wid + '.md'), 'w').write(t + '\n')
            srcs = ', '.join('ebook %d' % n for n in sorted({s[0] for s in spans}))
            w.write('%s\t-\t%s\t%s\t%s.md\t%s\t%s\n' % (wid, kind, date, wid, srcs.replace(' ', '-'), title))
            print('%-16s %-9s %4d words' % (pair, wid, len(t.split())))
