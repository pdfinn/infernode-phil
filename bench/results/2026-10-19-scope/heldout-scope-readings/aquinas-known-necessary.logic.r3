# the argument of aquinas-known-necessary.md as claude-opus-5-5 read it: check that it says what the text says
# Aquinas, Obj. 3. "Must necessarily be" is written as a predicate necbe(x) rather than
# with [], because the argument quantifies over things and modal arguments here take no all/some.
atom	knownbygod(x)	x is known by God
atom	knownbyus(x)	x is known by us (what we ourselves know)
atom	necbe(x)	x must necessarily be
atom	futcont(x)	x is a future contingent thing
atom	godmorecertain	the knowledge of God is much more certain than ours
P1	S2	∀x (knownbyus(x) → necbe(x))
P2	S2	godmorecertain
# The a fortiori step from our knowledge to God's is plainly relied on ("because ... much more certain").
A1	-	∀x (knownbyus(x) → necbe(x)) ∧ godmorecertain → ∀x (knownbygod(x) → necbe(x))
C1	S2	∀x (knownbygod(x) → necbe(x))	from P1 P2 A1
P3	S3	∀x (futcont(x) → ¬necbe(x))
C	S4	∀x (futcont(x) → ¬knownbygod(x))	from C1 P3
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space
