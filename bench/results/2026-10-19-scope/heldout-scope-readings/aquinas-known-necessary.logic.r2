# reading 3 of aquinas-known-necessary.md by claude-opus-5-5
logic	s5
atom	known_by_god	the future contingent thing is known by God
atom	be	the future contingent thing is (comes to be)
atom	our_known_necessary	even what we ourselves know must necessarily be
atom	god_more_certain	the knowledge of God is much more certain than ours
# S2: "everything known by God must necessarily be" read as known_by_god -> []be (necessity of the consequent); it could be read as [](known_by_god -> be), necessity of the consequence, which would not yield the conclusion.
P1	S2	our_known_necessary
P2	S2	god_more_certain
P3	S2	our_known_necessary ∧ god_more_certain → (known_by_god → □be)
C1	S2	known_by_god → □be	from P1 P2 P3
# S3: being contingent, the future thing does not necessarily come to be.
P4	S3	¬□be
C	S4	¬known_by_god	from C1 P4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space
