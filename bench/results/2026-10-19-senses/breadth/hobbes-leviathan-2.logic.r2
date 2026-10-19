# the argument of hobbes-leviathan-2.md as claude-opus-5-5 read it: check that it says what the text says
atom	commentary_cavil	Commentaries are commonly more subject to cavil than the Text
atom	need_more_commentaries	Commentaries need other Commentaries
atom	endless_interpretation	There will be no end of such Interpretation
atom	commentator_interpreter	He that writeth a Commentary upon written Lawes is the Interpreter of them
atom	authorised_interpreter	There is an Interpreter authorised by the Soveraign, from which the subordinate Judges are not to recede
atom	judges_interpreter	The ordinary Judges are the Interpreter of written Lawes
atom	law_for_parties	The Judges' Sentences are to be taken by them that plead for Lawes in that particular case
atom	binds_other_judges	The Judges' Sentences bind other Judges in like cases to give like judgements
atom	judge_may_err	A Judge may erre in the Interpretation even of written Lawes
atom	error_changes_law	An errour of a subordinate Judge can change the Law, which is the generall Sentence of the Soveraigne
P1	S2	commentary_cavil	kind empirical
P2	S2	commentary_cavil → need_more_commentaries
P3	S2	need_more_commentaries → endless_interpretation
A1	-	endless_interpretation → ¬commentator_interpreter
C1	S1	¬commentator_interpreter	from P1 P2 P3 A1
# The text plainly treats the authorised interpreter, commentators and the ordinary Judges as the only candidates.
A2	-	authorised_interpreter ∨ commentator_interpreter ∨ judges_interpreter
C2	S3	¬authorised_interpreter → judges_interpreter	from C1 A2
P4	S3	law_for_parties
P5	S4	judge_may_err
P6	S4	¬error_changes_law
# "may erre" is read as a plain claim, not as a modal operator, since S4 uses it only to support the denial of binding force.
A3	-	binds_other_judges ∧ judge_may_err → error_changes_law
C3	S3	¬binds_other_judges	from P5 P6 A3
C	S3	(¬authorised_interpreter → judges_interpreter) ∧ law_for_parties ∧ ¬binds_other_judges	from C2 P4 C3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space
