# reading 3 of republic-function.md by claude-opus-5-5
# S10's "necessarily" is not rendered as a modal; quantified atoms are used instead.
atom	just(x)	x (the soul or the man) is just
atom	excellent(x)	x's soul has its own excellence
atom	fulfils(x)	x's soul fulfils its own ends (superintends, commands, deliberates, lives) well, as a good ruler and superintendent
atom	liveswell(x)	x lives well
atom	happy(x)	x is blessed and happy
atom	profits(x)	x's condition is profitable to x
P1	S8	∀x (¬excellent(x) → ¬fulfils(x))
P2	S10	∀x (excellent(x) → fulfils(x))
P3	S4	∀x (fulfils(x) ↔ liveswell(x))
P4	S12	∀x (just(x) ↔ excellent(x))	kind conceptual
C1	S14	∀x ((just(x) → liveswell(x)) ∧ (¬just(x) → ¬liveswell(x)))	from P1 P2 P3 P4
P5	S16	∀x ((liveswell(x) → happy(x)) ∧ (¬liveswell(x) → ¬happy(x)))
C2	S18	∀x ((just(x) → happy(x)) ∧ (¬just(x) → ¬happy(x)))	from C1 P5
P6	S20	∀x ((happy(x) → profits(x)) ∧ (¬happy(x) → ¬profits(x)))
C	S22	∀x ((just(x) → profits(x)) ∧ (¬just(x) → ¬profits(x)))	from C2 P6
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space
