# heldout.py dir - the held-out equivocations: arguments that move
# between two senses of one word, where the literature names the word,
# cut as build.py cuts the gold set (PG names the texts' directory)
# into dir.  None of them was read while phil/senses or its prompt was
# written, and none is in the gold set; they test whether the tools find
# a shift of sense in passages they were not shaped on.  Each gold
# file's at line names the sentence of the second sense by its phrase;
# its number, as wwb/sentences numbers the passage, was added after.
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pgtext import cut

H = [
    ('euthydemus-learn', 1598, 'Plato, Euthydemus 275d-276c, tr. B. Jowett',
     'Euthydemus proceeded: There are some whom you would call teachers',
     'your last answer to Euthydemus was wrong.',
     'equivocation', 'learn',
     '"learn" is acquiring knowledge one lacks in the first argument (so the unlearned learn) and understanding what one is told in the second (so the wise learn): each conclusion holds only in its own sense, and they do not contradict each other',
     'Plato, Euthydemus 277e-278b (Socrates names the two senses); Aristotle, Sophistical Refutations 4, 165b32'),
    ('euthydemus-perish', 1598, 'Plato, Euthydemus 283c-d, tr. B. Jowett',
     'Well, said he, and so you say that you wish Cleinias to become wise?',
     'who want their favourite not to be, or to perish!',
     'equivocation', 'be',
     '"no longer to be what he is" is ceasing to be ignorant, a thing he is in some respect; "not to be" is ceasing to exist',
     'Aristotle, Sophistical Refutations 5, 166b37-167a20 (what is said simply and in some respect)'),
    ('euthydemus-knowing', 1598, 'Plato, Euthydemus 293b-d, tr. B. Jowett',
     'And did you not say that you knew something?',
     'and in reference to the same things.',
     'equivocation', 'knowing',
     '"knowing" is knowing some thing in "if you know, you are knowing" and knowing without qualification in "you are not knowing", so that being knowing and not knowing are not contraries',
     'Plato, Euthydemus 293c-d (Socrates\' "of the knowledge which I have"); Aristotle, Sophistical Refutations 5, 166b37-167a20'),
    ('republic-overreach', 1497, 'Plato, Republic I 349b-350c, tr. B. Jowett',
     'We may put the matter thus, I said',
     'That is the inference.',
     'equivocation', 'more',
     '"to desire more than" (pleonektein) is to try to get the better of another, to take a larger share, in the just and unjust man; and to try to go beyond another\'s performance of an art, in the musician and physician: the likeness of the just to the wise holds only on one sense throughout',
     'J. Annas, An Introduction to Plato\'s Republic (1981), ch. 2; R. C. Cross and A. D. Woozley, Plato\'s Republic (1964), ch. 2'),
    ('gorgias-polus', 1672, 'Plato, Gorgias 474c-475c, tr. B. Jowett',
     'SOCRATES: Let me ask a question of you: When you speak of beautiful things',
     'And that is now discovered to be more evil?',
     'equivocation', 'evil',
     'what is fine is measured by its pleasure or benefit to those who see or meet it, so what is more disgraceful exceeds in pain or harm to someone; that it is the greater evil for the one who does it is another sense of "evil"',
     'G. Vlastos, "Was Polus Refuted?", American Journal of Philology 88 (1967)'),
]

if __name__ == '__main__':
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for (hid, n, src, start, end, cls, word, fault, ref) in H:
        t = cut(n, start, end).replace('_', '')
        open(os.path.join(out, hid + '.md'), 'w').write(t + '\n')
        with open(os.path.join(out, hid + '.gold'), 'w') as f:
            f.write('source\t%s\n' % src)
            f.write('text\tProject Gutenberg ebook %d, https://www.gutenberg.org/ebooks/%d\n' % (n, n))
            f.write('class\t%s\n' % cls)
            f.write('word\t%s\n' % word)
            f.write('fault\t%s\n' % fault)
            f.write('reference\t%s\n' % ref)
        print('%-22s %5d words  %s' % (hid, len(t.split()), word))
