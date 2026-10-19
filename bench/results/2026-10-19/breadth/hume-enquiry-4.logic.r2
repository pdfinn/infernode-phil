# the argument of hume-enquiry-4.md as claude-opus-5-5 read it: check that it says what the text says
atom	instinct	the opinion of external existence is rested on natural instinct
atom	reason_ref	the opinion of external existence is referred to reason
atom	contra_reason	the opinion of external existence is contrary to reason
atom	contra_instinct	the opinion of external existence is contrary to natural instinct
atom	no_evidence	the opinion of external existence carries no rational evidence with it to convince an impartial enquirer
atom	qualities_in_mind	it is a principle of reason that all sensible qualities are in the mind, not in the object
atom	bereft	matter is bereaved of all its intelligible qualities, both primary and secondary
atom	annihilated	matter is in a manner annihilated, leaving only a certain unknown, inexplicable something as the cause of our perceptions
atom	not_worth	the notion of matter is so imperfect that no sceptic will think it worth while to contend against it
P1	S1	(instinct → contra_reason) ∧ (reason_ref → contra_instinct) ∧ no_evidence
P2	S3	bereft → annihilated ∧ not_worth
# Hume argues just before this passage that if sensible qualities are in the mind, matter loses its qualities; the passage relies on it without stating it.
A1	-	qualities_in_mind → bereft
# Unsure: the link from the annihilation of matter to the opinion being contrary to reason is left implicit.
A2	-	annihilated → contra_reason
C	S2	qualities_in_mind → contra_reason	from P2 A1 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space
