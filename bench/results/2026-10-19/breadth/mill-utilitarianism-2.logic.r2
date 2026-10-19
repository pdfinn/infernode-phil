# the argument of mill-utilitarianism-2.md as claude-opus-5-5 read it: check that it says what the text says
# "Nothing desired except happiness" (S1) is read as: whatever is desired is desired either as a means to happiness or as a part of it.
# S3 and S4 apply S2 to virtue. Desiring virtue "for its own sake" is read as desired(virtue) & !means(virtue).
# The text never states that pleasure or pain in virtue makes virtue a part of happiness, so no line links them.
atom	desired(x)	x is desired
atom	means(x)	x is desired as a means to some end beyond itself, and ultimately to happiness
atom	part(x)	x is desired as itself a part of happiness
atom	virtue_pleasure	the consciousness of virtue is a pleasure to the person who desires it
atom	virtue_pain	the consciousness of being without virtue is a pain to the person who desires it
P1	S2	∀x (desired(x) ∧ ¬means(x) → part(x))
P2	S3	desired(virtue) ∧ ¬means(virtue) → virtue_pleasure ∨ virtue_pain
P3	S4	¬virtue_pleasure ∧ ¬virtue_pain → ¬(desired(virtue) ∧ ¬means(virtue))
C	S1	∀x (desired(x) → means(x) ∨ part(x))	from P1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space
