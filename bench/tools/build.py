# build.py dir - the gold set's passages and gold files, cut from the
# Project Gutenberg texts in $PG (each ebook n as n.txt; fetch.sh gets
# them), into dir.  The passages are what tools/gold.py names: each from
# its start phrase to its end phrase, matched across line breaks.  A gold
# file's at line names the sentence the fault is at by its phrase; its
# number, as wwb/sentences numbers the passage, was added by hand after
# (S4 before the phrase), and score.py relies on it.
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pgtext import cut
from gold import G
out = sys.argv[1]
os.makedirs(out, exist_ok=True)
for (gid, n, src, start, end, cls, at, fault, ref) in G:
    t = cut(n, start, end).replace('_', '')     # Gutenberg's italics
    open(os.path.join(out, gid + '.md'), 'w').write(t + '\n')
    with open(os.path.join(out, gid + '.gold'), 'w') as f:
        f.write('source\t%s\n' % src)
        f.write('text\tProject Gutenberg ebook %d, https://www.gutenberg.org/ebooks/%d\n' % (n, n))
        f.write('class\t%s\n' % cls)
        if at:
            f.write('at\t%s\n' % at)
        f.write('fault\t%s\n' % fault)
        f.write('reference\t%s\n' % ref)
        f.write('known\tcanon\n')     # the fault is the literature's
    print('%-30s %5d words  %s' % (gid, len(t.split()), cls))
