implement Skeleton;

#
# phil/skeleton [file] - a reading by rule, with no model: the shape of
# an argument from each sentence's dependencies, as wwb/parse writes
# them (file:line:, then a token to a line: number, word, Penn tag,
# head, relation; a blank line after the sentence):
#
#	wwb/parse x.md | phil/skeleton > x.skel.logic
#
# Each sentence is a premise, or the conclusion where it begins so,
# therefore, hence, thus, consequently or it follows that (the last such
# is C; if none is, the last sentence); a premise that is a conjunction
# is a statement a conjunct.  Within a sentence the connectives are
# read from the tree: an adverbial clause marked if (or when, whenever,
# or a conditional with had or were put first) is the antecedent of
# the main clause; only if turns it round; unless is if not; because,
# since or as gives the reason and its link to the main clause as
# premises, the main clause what they support; clauses
# joined by or are a disjunction, by and a conjunction; not, n't,
# never, no or nothing denies its clause; necessarily or must puts it
# under [], ought or should under ought.  What is left of each clause is
# an atom, its words its meaning; two clauses are one atom when they
# have the same content words, or the same main word and the content
# words of one (two at least) all among the other's, which has at most
# one more, each word taken without its ending; the atom is named for
# the first.  A subject quantified (every, each, all, any, whatever,
# whoever; a or an with the verb in the present; no, nothing, nobody;
# some, someone, something) makes the clause all x: or some x: over
# predicates of x, the subject's words the restriction; a subject that
# names one thing (a name, or the, this, that and a noun) makes it a
# predicate of a constant.
#
# It knows nothing of a quantifier that is not the subject's (an
# object's every or some stays inside a predicate), of pronouns, or of
# what a sentence takes for granted: it is a reader of
# another kind than a model, wrong in other ways, to set beside one.
# Its last line says what read it:
#
#	# rules tool=phil/skeleton date=2026-10-20
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "daytime.m";
	daytime: Daytime;

Skeleton: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

Tok: adt {
	word:	string;
	low:	string;
	tag:	string;
	head:	int;
	rel:	string;
};

Atom: adt {
	name:	string;
	text:	string;
	key:	list of string;
	arity:	int;
	head:	string;	# the clause's main word, without its ending
};

out: ref Iobuf;
atoms: list of ref Atom;	# newest first
names: list of string;

CONCL := array[] of {"so", "therefore", "hence", "thus", "consequently", "accordingly"};
NEG := array[] of {"not", "n't", "never", "no", "nothing", "none", "neither", "nor"};
STOP := array[] of {
	"a", "an", "the", "this", "that", "these", "those", "it", "its", "he", "she", "they", "them",
	"his", "her", "their", "we", "us", "our", "i", "me", "my", "you", "your", "one",
	"be", "is", "are", "was", "were", "been", "being", "am", "'s",
	"have", "has", "had", "having", "do", "does", "did",
	"will", "would", "shall", "should", "must", "may", "might", "can", "could", "ought",
	"who", "whom", "which", "what", "whose", "there", "then", "also", "very", "only",
	"to", "of", "in", "on", "at", "by", "for", "with", "from", "as", "into", "upon",
	"if", "unless", "when", "whenever", "so", "therefore", "hence", "thus", "and", "or", "but",
	"either", "neither", "nor", "not", "n't", "never", "no", "nothing", "none",
	"necessarily", "consequently", "accordingly", "however", "all", "every", "each", "some", "any",
};

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	daytime = load Daytime Daytime->PATH;
	if(bufio == nil || daytime == nil)
		fatal(sys->sprint("cannot load: %r"));
	args = tl args;
	in: ref Iobuf;
	if(args == nil)
		in = bufio->fopen(sys->fildes(0), Bufio->OREAD);
	else
		in = bufio->open(hd args, Bufio->OREAD);
	if(in == nil)
		fatal(sys->sprint("cannot open %s: %r", hd args));
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);

	# the statements, written after the atoms they use
	stmts: list of string;
	doc := "";
	n := 0;
	toks: list of ref Tok;
	conc := -1;
	for(;;) {
		# a blank line is "", which is nil: the end is told apart by eof
		s := in.gets('\n');
		eof := s == nil;
		if(!eof && s[len s - 1] == '\n')
			s = s[0:len s - 1];
		if(s == nil) {
			if(toks != nil) {
				n++;
				t := rev(toks);
				(f, isconc) := sentence(t);
				if(f != nil) {
					if(isconc)
						conc = n;
					stmts = sys->sprint("%d\t%s", n, f) :: stmts;
				}
				toks = nil;
			}
			if(eof)
				break;
			continue;
		}
		(nf, fl) := sys->tokenize(s, "\t");
		if(nf < 5) {
			# the sentence's address
			if(doc == "" && len s > 1) {
				for(i := 0; i < len s && s[i] != ':'; i++)
					;
				doc = s[0:i];
			}
			continue;
		}
		fl = tl fl;
		w := hd fl; fl = tl fl;
		tag := hd fl; fl = tl fl;
		h := int hd fl; fl = tl fl;
		toks = ref Tok(w, lower(w), tag, h, hd fl) :: toks;
	}

	out.puts(sys->sprint("# the argument of %s by rule (phil/skeleton): connectives from the parse, an atom to each clause\n", doc));
	# the logic the operators need
	nec := deon := 0;
	for(sl0 := stmts; sl0 != nil; sl0 = tl sl0) {
		if(contains(hd sl0, "[]"))
			nec = 1;
		if(contains(hd sl0, "ought "))
			deon = 1;
	}
	if(nec && deon)
		out.puts("logic\ts5kd\n");
	else if(nec)
		out.puts("logic\ts5\n");
	else if(deon)
		out.puts("logic\ts5kd\n");
	for(al := rev2(atoms); al != nil; al = tl al) {
		a := hd al;
		if(a.arity)
			out.puts(sys->sprint("atom\t%s(x)\tx: %s\n", a.name, a.text));
		else
			out.puts(sys->sprint("atom\t%s\t%s\n", a.name, a.text));
	}
	# a conclusion marked last is C; one marked earlier, a step; if
	# none is marked, the last sentence is C
	if(conc < 0)
		conc = n;
	p := 0;
	for(sl := revs(stmts); sl != nil; sl = tl sl) {
		(nil, fl) := sys->tokenize(hd sl, "\t");
		k := int hd fl;
		f := hd tl fl;
		parts := conjuncts(f);
		if(k == conc) {
			# the last conjunct is what is concluded; those before it,
			# a reason and its link, premises at the same sentence
			for(; tl parts != nil; parts = tl parts) {
				p++;
				out.puts(sys->sprint("P%d\tS%d\t%s\n", p, k, hd parts));
			}
			out.puts(sys->sprint("C\tS%d\t%s\n", k, hd parts));
		} else
			for(; parts != nil; parts = tl parts) {
				p++;
				out.puts(sys->sprint("P%d\tS%d\t%s\n", p, k, hd parts));
			}
	}
	out.puts("# rules tool=phil/skeleton date=" + today() + "\n");
	out.flush();
}

# the conjuncts of f, if it is a conjunction in parentheses: one
# statement each, as a reader writes them
conjuncts(f: string): list of string
{
	if(len f < 2 || f[0] != '(' || f[len f - 1] != ')')
		return f :: nil;
	g := f[1:len f - 1];
	parts: list of string;
	d := 0;
	b := 0;
	for(i := 0; i < len g; i++) {
		case g[i] {
		'(' =>	d++;
		')' =>
			d--;
			if(d < 0)
				return f :: nil;
		'&' =>
			if(d == 0) {
				parts = trim(g[b:i]) :: parts;
				b = i + 1;
			}
		'|' or '-' =>
			# a disjunction or a conditional at the top: not a conjunction
			if(d == 0 && (g[i] == '|' || (i + 1 < len g && g[i+1] == '>')))
				return f :: nil;
		}
	}
	if(parts == nil)
		return f :: nil;
	parts = trim(g[b:]) :: parts;
	return rev1s(parts);
}

trim(s: string): string
{
	while(s != nil && s[0] == ' ')
		s = s[1:];
	while(s != nil && s[len s - 1] == ' ')
		s = s[0:len s - 1];
	return s;
}

# a sentence's formula, and whether it is marked a conclusion
sentence(t: array of ref Tok): (string, int)
{
	root := 0;
	for(i := 0; i < len t; i++)
		if(t[i].head == 0) {
			root = i + 1;
			break;
		}
	if(root == 0)
		return (nil, 0);
	isconc := 0;
	skip := array[len t + 1] of {* => 0};
	# so, therefore ...: a marker at the head of the sentence
	for(i = 0; i < len t && i < 3; i++) {
		if(member(t[i].low, CONCL) && (t[i].rel == "advmod" || t[i].rel == "cc" || t[i].rel == "mark" || t[i].rel == "discourse")) {
			isconc = 1;
			skip[i+1] = 1;
			break;
		}
	}
	# it follows that
	for(i = 0; i + 2 < len t; i++)
		if(t[i].low == "it" && (t[i+1].low == "follows" || t[i+1].low == "follow") && t[i+2].low == "that") {
			isconc = 1;
			skip[i+1] = skip[i+2] = skip[i+3] = 1;
			# the clause after that is what is concluded
			for(j := 0; j < len t; j++)
				if(t[j].head == i + 2 && (t[j].rel == "ccomp" || t[j].rel == "csubj"))
					return (clause(t, j + 1, skip), 1);
		}
	return (clause(t, root, skip), isconc);
}

# the formula of the clause headed by h (numbered from 1), the words
# skip marks left out
clause(t: array of ref Tok, h: int, skip: array of int): string
{
	sk := array[len skip] of int;
	sk[0:] = skip;

	# necessarily, put before a conditional or a conjunction, over the
	# whole of it: necessarily, if p then q
	for(i := 0; i < len t; i++) {
		if(t[i].head != h || sk[i+1] || t[i].low != "necessarily")
			continue;
		for(j := i + 1; j < len t; j++)
			if(t[j].head == h && !sk[j+1] && (t[j].rel == "advcl" || t[j].rel == "conj")) {
				w := array[len skip] of int;
				w[0:] = sk;
				w[i+1] = 1;
				return "[]" + clause(t, h, w);
			}
	}

	# conjoined clauses: verbs (or predicates) joined by and, or
	conjs: list of int;
	op := "";
	# the words of the clauses themselves: skip and the joining words
	own := array[len skip] of int;
	own[0:] = skip;
	for(i = 0; i < len t; i++)
		if(t[i].head == h && t[i].rel == "conj" && !sk[i+1] && isclause(t, i + 1)) {
			conjs = (i + 1) :: conjs;
			for(j := 0; j < len t; j++)
				if(t[j].head == i + 1 && t[j].rel == "cc") {
					if(t[j].low == "or" || t[j].low == "nor")
						op = " | ";
					else if(op == "")
						op = " & ";
					own[j+1] = 1;
				}
		}
	if(conjs != nil) {
		if(op == "")
			op = " & ";
		# either ... or
		for(i = 0; i < len t; i++)
			if(t[i].low == "either" && (t[i].rel == "cc:preconj" || t[i].rel == "preconj"))
				own[i+1] = 1;
		sk[0:] = own;
		for(l := conjs; l != nil; l = tl l)
			mark(t, hd l, sk);
		f := clause(t, h, sk);
		for(l = rev1(conjs); l != nil; l = tl l)
			f += op + clause(t, hd l, own);
		return "(" + f + ")";
	}

	# a conditional: an adverbial clause marked if, when, unless, or
	# put first with had or were
	for(i = 0; i < len t; i++) {
		if(t[i].head != h || t[i].rel != "advcl" || sk[i+1])
			continue;
		c := i + 1;
		kind := "";
		only := 0;
		# the conditional's own words, skipped from both clauses
		cw := array[len skip] of int;
		cw[0:] = sk;
		for(j := 0; j < len t; j++)
			if(t[j].head == c && t[j].rel == "mark") {
				case t[j].low {
				"if" or "when" or "whenever" or "provided" =>
					kind = "if";
				"unless" =>
					kind = "unless";
				"because" or "since" or "as" =>
					kind = "because";
				}
				if(j > 0 && t[j-1].low == "only") {
					only = 1;
					cw[j] = 1;
				}
				cw[j+1] = 1;
			}
		if(kind == "" && c < h)
			for(j = 0; j < c && j < len t; j++)
				if(t[j].head == c && t[j].rel == "aux" && (t[j].low == "had" || t[j].low == "were") && j < 2) {
					kind = "if";
					cw[j+1] = 1;
				}
		if(kind == "")
			continue;
		a := clause(t, c, cw);
		mark(t, c, cw);
		b := clause(t, h, cw);
		if(kind == "unless")
			return "(!" + a + " -> " + b + ")";
		# b because a: a is asserted, and a is why b; the reason and the
		# link are premises, b what they support (sentence() splits them)
		if(kind == "because")
			return "(" + a + " & (" + a + " -> " + b + ") & " + b + ")";
		if(only)
			return "(" + b + " -> " + a + ")";
		return "(" + a + " -> " + b + ")";
	}

	# a quantified subject: every, each, all, any, whatever, whoever
	# (and a generic a or an, the verb in the present); no, nothing,
	# nobody; some, someone, something
	subj := 0;
	for(i = 0; i < len t; i++)
		if(t[i].head == h && !sk[i+1] && (t[i].rel == "nsubj" || t[i].rel == "nsubj:pass")) {
			subj = i + 1;
			break;
		}
	if(subj > 0) {
		(q, qw) := quant(t, subj, h);
		if(q != "") {
			# the scope: the clause without its subject
			sc := array[len skip] of int;
			sc[0:] = sk;
			mark(t, subj, sc);
			body := modalised(t, h, sc, 1, "x");
			# the restrictor: the subject's own words, less the quantifier
			r := array[len skip] of {* => 1};
			unmark(t, subj, sk, r);
			r[qw] = 1;
			rp := atom(t, subj, r, 1);
			if(q == "none")
				body = "!" + body;
			if(q == "some") {
				if(rp != "true")
					return "(some x: " + rp + "(x) & " + body + ")";
				return "(some x: " + body + ")";
			}
			if(rp != "true")
				return "(all x: " + rp + "(x) -> " + body + ")";
			return "(all x: " + body + ")";
		}
		# a subject that names one thing: a name, or the, this, that
		# and a noun; what is said of it, a predicate of it
		if(named(t, subj)) {
			sc := array[len skip] of int;
			sc[0:] = sk;
			mark(t, subj, sc);
			c := constant(t, subj, sk);
			if(c != "") {
				f := modalised(t, h, sc, 1, c);
				if(f != "true(" + c + ")")
					return f;
			}
		}
	}
	return modalised(t, h, sk, 0, nil);
}

# the clause headed by h, under its modal words and its denial, as an
# atom (arity 0) or a predicate of arg (arity 1)
modalised(t: array of ref Tok, h: int, sk: array of int, arity: int, arg: string): string
{
	neg := 0;
	modal := "";
	for(i := 0; i < len t; i++) {
		if(sk[i+1])
			continue;
		owner := t[i].head;
		if(owner != h) {
			# no, nothing as the subject's or object's determiner
			if(owner > 0 && t[owner-1].head == h && (t[i].low == "no" || t[i].low == "none") && t[i].rel == "det") {
				neg = !neg;
				sk[i+1] = 1;
			}
			continue;
		}
		# not only ... but: no denial
		if(t[i].low == "not" && i + 1 < len t && t[i+1].low == "only")
			continue;
		if(member(t[i].low, NEG) && (t[i].rel == "advmod" || t[i].rel == "neg" || t[i].rel == "obj" || t[i].rel == "nsubj" || t[i].rel == "cc:preconj")) {
			neg = !neg;
			sk[i+1] = 1;
		} else if(t[i].low == "necessarily" && t[i].rel == "advmod") {
			modal = "[]";
			sk[i+1] = 1;
		} else if(t[i].rel == "aux" && t[i].low == "must") {
			modal = "[]";
			sk[i+1] = 1;
		} else if(t[i].rel == "aux" && (t[i].low == "ought" || t[i].low == "should")) {
			modal = "ought ";
			sk[i+1] = 1;
		}
	}
	f := atom(t, h, sk, arity);
	if(arity && f != "true")
		f += "(" + arg + ")";
	else if(arity)
		f = "true(" + arg + ")";
	if(neg)
		f = "!" + f;
	if(modal != "")
		f = modal + f;
	return f;
}

UNIV := array[] of {"every", "each", "all", "any"};
UNIVW := array[] of {"whatever", "whoever", "everything", "everyone", "everybody", "anything", "anyone"};
NONEW := array[] of {"nothing", "nobody", "noone"};
SOMEW := array[] of {"something", "someone", "somebody"};

# the subject's quantifier, all, none, some or none at all, and the
# token that says it
quant(t: array of ref Tok, s: int, h: int): (string, int)
{
	w := t[s-1].low;
	if(member(w, UNIVW))
		return ("all", s);
	if(member(w, NONEW))
		return ("none", s);
	if(member(w, SOMEW))
		return ("some", s);
	for(j := 0; j < len t; j++) {
		if(t[j].head != s || t[j].rel != "det")
			continue;
		d := t[j].low;
		if(member(d, UNIV))
			return ("all", j + 1);
		if(d == "no")
			return ("none", j + 1);
		if(d == "some")
			return ("some", j + 1);
		# a generic: a man is mortal, a promise binds
		if((d == "a" || d == "an") && present(t, h))
			return ("all", j + 1);
	}
	return ("", 0);
}

# whether the clause's verb is in the present (or under a modal)
present(t: array of ref Tok, h: int): int
{
	tg := t[h-1].tag;
	if(tg == "VBZ" || tg == "VBP")
		return 1;
	for(j := 0; j < len t; j++)
		if(t[j].head == h && (t[j].rel == "aux" || t[j].rel == "cop" || t[j].rel == "aux:pass")) {
			if(t[j].tag == "VBZ" || t[j].tag == "VBP" || (t[j].tag == "MD" && t[j].low != "would" && t[j].low != "could"))
				return 1;
		}
	return 0;
}

# whether the subject names one thing: a proper name, or a noun with
# the, this or that
named(t: array of ref Tok, s: int): int
{
	tg := t[s-1].tag;
	if(tg == "NNP" || tg == "NNPS")
		return 1;
	if(tg != "NN")
		return 0;
	for(j := 0; j < len t; j++)
		if(t[j].head == s && t[j].rel == "det" && (t[j].low == "the" || t[j].low == "this" || t[j].low == "that"))
			return 1;
	return 0;
}

# the constant for the subject: its content words, named as an atom is
constant(t: array of ref Tok, s: int, sk: array of int): string
{
	in := array[len t + 1] of {* => 0};
	keep(t, s, sk, in);
	key: list of string;
	for(i := 1; i <= len t; i++)
		if(in[i] && !member(t[i-1].low, STOP) && (t[i-1].tag[0] == 'N' || t[i-1].tag[0] == 'J' || t[i-1].tag == "CD"))
			key = t[i-1].low :: key;
	if(key == nil)
		return "";
	n := "";
	k := 0;
	for(l := rev1s(key); l != nil && k < 3; l = tl l) {
		w := "";
		for(x := hd l; x != nil; x = x[1:])
			if((x[0] >= 'a' && x[0] <= 'z') || (x[0] >= '0' && x[0] <= '9'))
				w[len w] = x[0];
		if(w == "")
			continue;
		if(n != "")
			n += "_";
		n += w;
		k++;
	}
	if(n == "" || !(n[0] >= 'a' && n[0] <= 'z'))
		return "";
	return n;
}

# unmark into r the subtree of c that sk does not skip
unmark(t: array of ref Tok, c: int, sk: array of int, r: array of int)
{
	if(sk[c])
		return;
	r[c] = 0;
	for(j := 0; j < len t; j++)
		if(t[j].head == c)
			unmark(t, j + 1, sk, r);
}

# whether token c heads a clause: a verb, or a word with a subject or copula
isclause(t: array of ref Tok, c: int): int
{
	if(len t[c-1].tag >= 2 && t[c-1].tag[0:2] == "VB")
		return 1;
	for(j := 0; j < len t; j++)
		if(t[j].head == c && (t[j].rel == "nsubj" || t[j].rel == "cop" || t[j].rel == "nsubj:pass"))
			return 1;
	return 0;
}

# mark the subtree of c to be skipped
mark(t: array of ref Tok, c: int, sk: array of int)
{
	sk[c] = 1;
	for(j := 0; j < len t; j++)
		if(t[j].head == c && !sk[j+1])
			mark(t, j + 1, sk);
}

# the atom for the words of h's subtree that are not skipped: a
# proposition (arity 0) or a predicate of one thing (arity 1)
atom(t: array of ref Tok, h: int, sk: array of int, arity: int): string
{
	in := array[len t + 1] of {* => 0};
	keep(t, h, sk, in);
	text := "";
	key: list of string;
	for(i := 1; i <= len t; i++) {
		if(!in[i])
			continue;
		w := t[i-1].word;
		r := t[i-1].rel;
		if(r == "punct" && (w == "," || w == ":" || w == ";" || w == "."))
			continue;
		if(text != "" && w != "'s" && w != "n't" && w != "," )
			text += " ";
		text += w;
		lw := t[i-1].low;
		tg := t[i-1].tag;
		if(!member(lw, STOP) && tg != "." && tg != "," && tg != ":" && (tg[0] == 'N' || tg[0] == 'V' || tg[0] == 'J' || tg == "CD" || tg == "RB"))
			key = stem(lw) :: key;
	}
	if(text == "")
		return "true";
	text = lower1(text);
	if(key == nil)
		return "true";
	hw := stem(t[h-1].low);
	# one atom for clauses with the same content words, or, where their
	# main word is the same, one of whose content words (two at least)
	# are all the other's, the other having at most one more
	for(al := atoms; al != nil; al = tl al) {
		a := hd al;
		if(a.arity != arity)
			continue;
		if(within(key, a.key) && within(a.key, key))
			return a.name;
		if(len key >= 2 && len a.key >= 2 && a.head == hw && (within(key, a.key) || within(a.key, key)) && diff(len key, len a.key) <= 1)
			return a.name;
	}
	name := mkname(rev1s(key));
	atoms = ref Atom(name, text, key, arity, hw) :: atoms;
	return name;
}

keep(t: array of ref Tok, c: int, sk: array of int, in: array of int)
{
	if(sk[c])
		return;
	in[c] = 1;
	for(j := 0; j < len t; j++)
		if(t[j].head == c)
			keep(t, j + 1, sk, in);
}

# the name: the first content words, as a logic file's name may be
mkname(key: list of string): string
{
	n := "";
	k := 0;
	for(; key != nil && k < 3; key = tl key) {
		w := "";
		for(s := hd key; s != nil; s = s[1:])
			if((s[0] >= 'a' && s[0] <= 'z') || (s[0] >= '0' && s[0] <= '9'))
				w[len w] = s[0];
		if(w == "")
			continue;
		if(n != "")
			n += "_";
		n += w;
		k++;
	}
	if(n == "" || !(n[0] >= 'a' && n[0] <= 'z'))
		n = "c" + n;
	base := n;
	for(i := 2; has(names, n); i++)
		n = base + "_" + string i;
	names = n :: names;
	return n;
}

# a word without its ending, so that records and recorded are one
stem(w: string): string
{
	for(;;) {
		n := len w;
		if(n > 5 && w[n-3:] == "ing")
			w = w[0:n-3];
		else if(n > 4 && w[n-2:] == "ed")
			w = w[0:n-2];
		else if(n > 4 && w[n-2:] == "es")
			w = w[0:n-2];
		else if(n > 3 && w[n-1] == 's' && w[n-2] != 's')
			w = w[0:n-1];
		else
			break;
	}
	return w;
}

contains(s, t: string): int
{
	for(i := 0; i + len t <= len s; i++)
		if(s[i:i+len t] == t)
			return 1;
	return 0;
}

diff(a, b: int): int
{
	if(a > b)
		return a - b;
	return b - a;
}

within(a, b: list of string): int
{
	for(; a != nil; a = tl a)
		if(!has(b, hd a))
			return 0;
	return 1;
}

has(l: list of string, s: string): int
{
	for(; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

member(s: string, a: array of string): int
{
	for(i := 0; i < len a; i++)
		if(a[i] == s)
			return 1;
	return 0;
}

lower(s: string): string
{
	r := "";
	for(i := 0; i < len s; i++) {
		c := s[i];
		if(c >= 'A' && c <= 'Z')
			c += 'a' - 'A';
		r[len r] = c;
	}
	return r;
}

# a clause's first letter lower case, unless it is a name's
lower1(s: string): string
{
	if(len s > 1 && s[0] >= 'A' && s[0] <= 'Z' && s[1] >= 'a' && s[1] <= 'z') {
		sp := 0;
		for(; sp < len s && s[sp] != ' '; sp++)
			;
		w := lower(s[0:sp]);
		if(member(w, STOP))
			return w + s[sp:];
	}
	return s;
}

rev(l: list of ref Tok): array of ref Tok
{
	n := len l;
	a := array[n] of ref Tok;
	for(; l != nil; l = tl l)
		a[--n] = hd l;
	return a;
}

rev1(l: list of int): list of int
{
	r: list of int;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

rev1s(l: list of string): list of string
{
	r: list of string;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

revs(l: list of string): list of string
{
	return rev1s(l);
}

rev2(l: list of ref Atom): list of ref Atom
{
	r: list of ref Atom;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

today(): string
{
	tm := daytime->local(daytime->now());
	return sys->sprint("%d-%.2d-%.2d", tm.year + 1900, tm.mon + 1, tm.mday);
}

fatal(s: string)
{
	sys->fprint(sys->fildes(2), "phil/skeleton: %s\n", s);
	raise "fail:error";
}
