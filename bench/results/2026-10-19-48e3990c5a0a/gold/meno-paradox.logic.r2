# the argument of meno-paradox.md as claude-opus-5-5 read it: check that it says what the text says
# The argument is Meno's, as Socrates reports it ("You argue that ..."); Socrates calls it a tiresome dispute but does not endorse it.
# The conclusion is drawn from Meno's reported premises; it is Meno's conclusion, not the text's own.
# The known case says only that he "has no need" to enquire, while the conclusion says he "cannot" enquire.
# No premise links the two, and none is added, since the text does not supply one.
atom	knows	the man knows that about which he is to enquire
atom	need_enquire	the man has need to enquire about it
atom	can_enquire	the man can enquire about it
P1	S2	knows → ¬need_enquire	says meno
P2	S2	¬knows → ¬can_enquire	says meno
P3	S2	knows ∨ ¬knows	says meno
C	S2	¬can_enquire	from P1 P2 P3
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space
