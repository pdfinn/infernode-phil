# the argument of plato-phaedo-2.md as claude-opus-5-5 read it: check that it says what the text says
# S2 and S3 (Endymion, Anaxagoras) only illustrate the principle and are left out; S6 is a cross-reference.
# The "must" in S5 is read as plain inference rather than modal necessity.
atom	no_return	all things which partook of life, having died, remain in the form of death and do not come to life again
atom	spring_other	the living spring from other things than the dead
atom	others_die	those other things too die
atom	all_die	all things would at last die and be swallowed up in death, and nothing would be alive
P1	S5	spring_other ∧ others_die → all_die
A1	-	no_return → spring_other
A2	-	others_die
C	S4	no_return → all_die	from P1 A1 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space
