implement Prove;

#
# prove - whether an argument's conclusion follows from its premises.
#
# The argument is a logic file, one statement to a line, its fields
# separated by tabs:
#
#	atom	rain	it rains
#	P1	S3	rain -> wet
#	P2	S4	rain
#	A1	-	wet -> slippery
#	C	S5	slippery
#
# An atom is a name and what it stands for.  A premise (P1, A1, ...)
# or the conclusion (C) is a name, the sentence it was taken from (S3,
# as wwb/sentences numbers them; - for one the text never states), and
# a formula: atoms joined by ! (not), & (and), | (or), -> (implies) and
# <-> (if and only if), with parentheses.  A model may write the file
# (phil/argue has one do it) or a person may; either way what follows
# from it is decided here, by trying every case, and not by anyone's
# say-so.
#
# Findings are addressed in the logic file, or, given the document the
# argument came from, at the sentence a statement was taken from, so
# that an agent can go to the words that need mending.
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
include "prose.m";
	prose: Prose;
	Sent: import prose;

Prove: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

Fatom, Fnot, Fand, For, Fimp, Fiff, Ftrue, Fall, Fsome, Fnec, Fpos: con iota;

# The logic an argument is read in (a line logic s5): classical; S5,
# necessity and possibility; or KD, the standard deontic logic, ought
# and permitted.
Mclassical, Ms5, Mkd, Mk, Mkt, Mmix: con iota;
modal := Mclassical;
modalnames := array[] of { "classical", "s5", "kd", "k", "kt", "s5kd" };

Form: adt {
	op:	int;
	atom:	int;
	l:	ref Form;
	r:	ref Form;
	dual:	ref Form;	# its denial, grounded apart (K, KT, KD), or nil
};

# A formula as written: an atom may have arguments, audited(web1),
# and all and some bind variables.  It is grounded into a Form by
# taking all and some over the individuals the argument names.
Q: adt {
	op:	int;
	name:	string;		# an atom's, or a quantifier's variable
	args:	list of string;
	l:	ref Q;
	r:	ref Q;
};

Stmt: adt {
	name:	string;
	sent:	int;		# S number; 0 for one the text never states
	f:	ref Form;
	q:	ref Q;
	line:	int;		# in the logic file
	text:	string;		# the formula as written
	from:	list of string;	# a step's: the statements it is drawn from
	against:	list of string;	# an objection's or reply's: what it attacks
	says:	string;	# a premise the work reports, not asserts: whose claim it is
	kind:	string;	# what kind of claim: empirical, normative or conceptual
};

# What kind a claim may be (a kind field): tested differently, and
# priced differently in a corpus's ledger.
Kinds := array[] of { "empirical", "normative", "conceptual" };

out: ref Iobuf;
atoms: array of string;
meanings: array of string;
natoms := 0;
logic: string;
doc: string;
sents: array of ref Sent;
errors := 0;

# Predicates: their parameters and what they mean (x was audited)
Pred: adt {
	name:	string;
	params:	list of string;
	meaning:	string;
	used:	int;
	line:	int;
	arity:	int;	# as first used, -1 before
};
preds: list of ref Pred;
consts: list of string;		# the individuals the argument names
nquant := 0;			# how many all and some it has
fresh: array of int;		# atoms about an individual the argument does not name

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	prose = load Prose Prose->PATH;
	if(prose == nil)
		fatal(sys->sprint("cannot load %s: %r", Prose->PATH));
	prose->init();
	arg := load Arg Arg->PATH;
	arg->init(args);
	arg->setusage("phil/prove [-APevx] logicfile [document]\n\tphil/prove -p logicfile [document]\n\tphil/prove [-Ax] -c [-a answers] [-d document] logicfile ...\n\tphil/prove -t logicfile\n\tphil/prove [-A] -f logicfile\n\tphil/prove [-A] -s n logicfile");
	cflag := 0;
	tflag := 0;
	docname: string;
	while((o := arg->opt()) != 0)
		case o {
		'x' =>	prose->exact(1);
		'v' =>	vflag = 1;
		'p' =>	pflag = 1;
		'e' =>	eflag = 1;
		'c' =>	cflag = 1;
		't' =>	tflag = 1;
		'd' =>	docname = arg->earg();
		'a' =>	answerfile = arg->earg();
		'A' =>	aflag = 1;
		'f' =>	fflag = 1;
		's' =>	scopek = int arg->earg();
		'P' =>	proofflag++;
		* =>	arg->usage();
		}
	args = arg->argv();
	if(args == nil || !cflag && len args > 2)
		arg->usage();
	logic = hd args;
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);
	if(!cflag && tl args != nil)
		docname = hd tl args;
	if(docname != nil){
		(name, lines, err) := prose->readtext(docname, Prose->Fauto);
		if(err != nil)
			fatal(err);
		doc = name;
		sents = prose->sentences(name, lines);
	}
	atoms = array[64] of string;
	meanings = array[64] of string;
	if(cflag){
		compare(args);
		out.flush();
		return;
	}
	if(fflag){
		reformat(logic);
		out.flush();
		return;
	}
	if(scopek > 0){
		scopes(logic, scopek);
		out.flush();
		return;
	}
	(prems, concl) := readlogic(logic);
	if(tflag){
		if(errors){
			out.flush();
			raise "fail:syntax";
		}
		tptp(prems, concl);
		out.flush();
		return;
	}
	if(pflag){
		if(errors){
			out.flush();
			raise "fail:syntax";
		}
		positions(prems);
		out.flush();
		return;
	}
	if(concl == nil){
		if(errors == 0)
			report(nil, "argue/no-conclusion", "the argument has no conclusion (a line C)");
		out.flush();
		raise "fail:findings";
	}
	if(errors){
		out.flush();
		raise "fail:syntax";
	}
	# a refuting case with as few individuals as can be: read again
	# with fewer others added, so the case shown is the plainest
	if(lastfresh > 1 && satisfiable(neg(concl.f) :: forms(prems))){
		full := lastfresh;
		for(m := 1; m < full; m++){
			reset();
			forcefresh = m;
			quiet = 1;
			(p2, c2) := readlogic(logic);
			quiet = 0;
			if(c2 != nil && satisfiable(neg(c2.f) :: forms(p2))){
				(prems, concl) = (p2, c2);
				break;
			}
		}
		if(m == full){
			reset();
			forcefresh = full;
			quiet = 1;
			(prems, concl) = readlogic(logic);
			quiet = 0;
		}
	}
	if(eflag)
		readback(appendlist(appendst(appendlist(prems, steps), concl), objections));
	if(steps != nil || concl.from != nil || objections != nil){
		structured(prems, concl);
		out.flush();
		return;
	}
	faithful(prems, concl);
	lint(prems, concl);
	# 1 valid, 0 invalid with a case to show it, -1 otherwise
	if(check(prems, concl) == 0)
		unlinked(prems, concl);
	out.flush();
}

#
# Arguments in steps: conclusions (C1, C2, ...) drawn from named
# statements (from P1 P2), which later steps and the argument's
# conclusion (C) rest on.  Each step is checked on its own, against what
# it says it rests on and nothing else, and reported at its sentence as
# a whole argument would be; the argument holds if every step its
# conclusion depends on does.  A conclusion with no from rests on every
# step before it, and every premise and assumption they do not draw on.
#

steps: list of ref Stmt;	# the conclusions on the way, in order
objections: list of ref Stmt;	# objections and replies, in order
everything: list of ref Stmt;	# every statement read
stepping := 0;		# checking a step: no measure of its own
inconsistentseen := 0;	# a step's premises were found to contradict each other

structured(prems: list of ref Stmt, concl: ref Stmt)
{
	all := appendlist(prems, steps);
	faithful(appendlist(all, objections), concl);
	lint(all, concl);
	order := appendst(steps, concl);
	# each step and what it rests on, once, by index
	n := len order;
	oa := array[n] of ref Stmt;
	i := 0;
	for(l := order; l != nil; l = tl l)
		oa[i++] = hd l;
	supp := array[n] of list of ref Stmt;
	edges := array[n] of list of int;
	for(i = 0; i < n; i++){
		supp[i] = support(oa[i], prems);
		if(oa[i].from == nil)
			continue;	# only earlier steps: no circle through it
		for(sl := supp[i]; sl != nil; sl = tl sl)
			if((j := index(oa, hd sl)) >= 0)
				edges[i] = j :: edges[i];
	}
	# steps that rest on each other: a depth-first search, a circle
	# wherever it comes back to a step still on its path
	color := array[n] of { * => 0 };	# 0 not seen, 1 on the path, 2 done
	incyc := array[n] of { * => 0 };
	path := array[n] of int;
	for(i = 0; i < n; i++)
		if(color[i] == 0)
			cycles(i, 0, oa, edges, color, incyc, path);
	# each step, against what it rests on
	verdicts: list of (ref Stmt, int);
	for(i = 0; i < n; i++){
		st := oa[i];
		if(incyc[i]){
			verdicts = (st, 0) :: verdicts;
			continue;
		}
		stepping = 1;
		v := check(supp[i], st);
		stepping = 0;
		# a step that names what it rests on and fails may only have
		# left something out: what else in the file it would follow from
		if(v == 0 && st.from != nil){
			others: list of ref Stmt;
			for(j := i-1; j >= 0; j--)
				if(!inlist(oa[j], supp[i]))
					others = oa[j] :: others;
			for(l = rev(prems); l != nil; l = tl l)
				if(!inlist(hd l, supp[i]))
					others = hd l :: others;
			if(others != nil && entails(forms(appendlist(supp[i], others)), st.f)){
				add := others;
				for(l = others; l != nil; l = tl l){
					trial := without(add, hd l);
					if(entails(forms(appendlist(supp[i], trial)), st.f))
						add = trial;
				}
				# statements that contradict each other give anything:
				# no reason to draw a step from them
				if(satisfiable(forms(appendlist(supp[i], add))))
					sreport(st, "argue/missing", sys->sprint("%s would follow if it were drawn from %s too: add %s to its from",
						st.name, names(add), plural(len add, "it", "them")));
			}
		}
		# circular or inconsistent: no argument, though it follows
		if(v < 0)
			v = lastvalid;
		if(v == 0)
			unlinked(supp[i], st);
		verdicts = (st, v) :: verdicts;
	}
	# the work's premises and assumptions read together: each step may
	# be consistent and the whole not, one part's claim denied by another
	# part's, or by an assumption made to join them
	if(prems != nil && !inconsistentseen && !satisfiable(forms(prems)) && (decided || refuted(stmtqs(prems)))){
		core := mincore(prems);
		sreport(hd core, "argue/inconsistent", sys->sprint("%s cannot all be true: read together, the work's premises and assumptions contradict each other",
			names(core)));
	}
	# the steps the conclusion depends on, and those nothing names
	reach := array[n] of { * => 0 };
	depends(n-1, oa, supp, reach);
	named := array[n] of { * => 0 };
	for(i = 0; i < n; i++)
		for(fl := oa[i].from; fl != nil; fl = tl fl)
			for(j := 0; j < n; j++)
				if(oa[j].name == hd fl)
					named[j] = 1;
	need: list of ref Stmt;
	for(i = 0; i < n-1; i++){
		if(reach[i])
			need = oa[i] :: need;
		else if(!named[i])
			sreport(oa[i], "argue/unused-step", sys->sprint("nothing rests on %s, and it is not the conclusion: a step that leads nowhere", oa[i].name));
	}
	# the argument holds if every step its conclusion depends on does
	r := 1;
	for(vl := verdicts; vl != nil; vl = tl vl){
		(st, v) := hd vl;
		if(st != concl && !inlist(st, need))
			continue;
		if(v == 0)
			r = 0;
		else if(v < 0 && r > 0)
			r = -1;
	}
	measure("argue/valid", r);
	if(objections != nil)
		dialectic(prems, concl, verdicts);
}

#
# Objections and replies.  An attack holds if the attacker contradicts
# what it is aimed at: alone, or else given the premises no objection
# disputes; one that does not is argue/misses.  Then what survives the
# attacks that hold, by Dung's grounded semantics (Dung 1995), with a
# step standing only while everything it rests on stands: a statement
# is in when every attacker is out (and, for a step, all it rests on is
# in), out when an attacker is in (or, for a step, something it rests
# on is out), and undecided where attacks go round.
#

Lin, Lout, Lundec: con iota;

Attack: adt {
	by:	ref Stmt;
	on:	ref Stmt;
};

dialectic(prems: list of ref Stmt, concl: ref Stmt, verdicts: list of (ref Stmt, int))
{
	nodes := appendlist(appendst(appendlist(prems, steps), concl), objections);
	# the premises no objection is aimed at
	disputed: list of ref Stmt;
	for(l := objections; l != nil; l = tl l)
		for(al := (hd l).against; al != nil; al = tl al)
			if((t := stmtnamed(hd al, everything)) != nil && !inlist(t, disputed))
				disputed = t :: disputed;
	settled: list of ref Form;
	for(l = prems; l != nil; l = tl l)
		if(!inlist(hd l, disputed))
			settled = (hd l).f :: settled;
	attacks: list of ref Attack;
	for(l = objections; l != nil; l = tl l){
		o := hd l;
		for(al = o.against; al != nil; al = tl al){
			t = stmtnamed(hd al, everything);
			if(t == nil)
				continue;
			if(satisfiable(o.f :: t.f :: nil) && satisfiable(o.f :: t.f :: settled)){
				sreport(o, "argue/misses", sys->sprint("%s does not contradict %s, even given the premises no one disputes: as written it leaves %s standing; is it aimed at something else?",
					o.name, t.name, t.name));
				continue;
			}
			attacks = ref Attack(o, t) :: attacks;
			# a reply that says only what the objection disputes
			if(o.name[0] == 'R' && t.name[0] == 'O')
				for(dl := t.against; dl != nil; dl = tl dl){
					x := stmtnamed(hd dl, everything);
					if(x != nil && x.name[0] != 'O' && x.name[0] != 'R' && equiv(o.f, x.f)){
						sreport(o, "argue/restates", sys->sprint("%s says no more than %s, which %s disputes: it answers the objection by repeating what is in question",
							o.name, x.name, t.name));
						break;
					}
				}
		}
	}
	# the grounded labelling, by rounds until nothing changes
	n := len nodes;
	na := array[n] of ref Stmt;
	lab := array[n] of { * => Lundec };
	i := 0;
	for(l = nodes; l != nil; l = tl l)
		na[i++] = hd l;
	# each statement's attackers and what it rests on, by index, once
	# (the labelling is the least that satisfies the rules, so the
	# order it is found in does not matter)
	attby := array[n] of list of int;
	for(at := attacks; at != nil; at = tl at)
		if((j := index(na, (hd at).on)) >= 0)
			attby[j] = index(na, (hd at).by) :: attby[j];
	supby := array[n] of list of int;
	for(i = 0; i < n; i++)
		if(isconcl(na[i].name))
			for(su := support(na[i], prems); su != nil; su = tl su)
				supby[i] = index(na, hd su) :: supby[i];
	# a step that does not follow from what it rests on cannot stand,
	# whatever the objections; one left undecided cannot be shown to
	invalid := array[n] of { * => 0 };
	for(vl := verdicts; vl != nil; vl = tl vl){
		(vs, v) := hd vl;
		if((k := index(na, vs)) < 0)
			continue;
		if(v == 0){
			invalid[k] = 1;
			lab[k] = Lout;
		}else if(v < 0)
			invalid[k] = -1;
	}
	for(changed := 1; changed; ){
		changed = 0;
		for(i = 0; i < n; i++){
			if(lab[i] != Lundec)
				continue;
			allout := 1;
			somein := 0;
			for(xl := attby[i]; xl != nil; xl = tl xl)
				case lab[hd xl] {
				Lin =>	somein = 1;
				Lundec =>	allout = 0;
				}
			supin := 1;
			supout := 0;
			for(yl := supby[i]; yl != nil; yl = tl yl)
				case lab[hd yl] {
				Lout =>	supout = 1;
				Lundec =>	supin = 0;
				}
			if(invalid[i] < 0)
				supin = 0;
			if(somein || supout){
				lab[i] = Lout;
				changed = 1;
			}else if(allout && supin){
				lab[i] = Lin;
				changed = 1;
			}
		}
	}
	# what falls, and why
	for(i = 0; i < n; i++){
		st := na[i];
		if(lab[i] != Lout)
			continue;
		if(invalid[i] > 0){
			sreport(st, "argue/defeated", sys->sprint("%s cannot stand: it does not follow from what it rests on, so no reply to the objections can save it", st.name));
			continue;
		}
		by: list of ref Stmt;
		for(ak := attacks; ak != nil; ak = tl ak)
			if((hd ak).on == st && lab[index(na, (hd ak).by)] == Lin)
				by = (hd ak).by :: by;
		if(by != nil){
			answered := "which nothing answers";
			for(bl := by; bl != nil; bl = tl bl)
				for(ak = attacks; ak != nil; ak = tl ak)
					if((hd ak).on == hd bl)
						answered = "whose replies fail";
			sreport(st, "argue/defeated", sys->sprint("%s falls to %s, %s", st.name, names(rev(by)), answered));
		}else if(isconcl(st.name)){
			fell: list of ref Stmt;
			for(sl := support(st, prems); sl != nil; sl = tl sl)
				if(lab[index(na, hd sl)] == Lout)
					fell = hd sl :: fell;
			sreport(st, "argue/defeated", sys->sprint("%s falls with %s, which it rests on", st.name, names(rev(fell))));
		}
	}
	for(i = 0; i < n; i++)
		if(lab[i] == Lundec && !isattack(na[i].name)){
			sreport(na[i], "argue/undecided", sys->sprint("%s neither stands nor falls: the objections to it and the replies to them go round, each defeating the other", na[i].name));
			break;
		}
	v := -1;
	case lab[index(na, concl)] {
	Lin =>	v = 1;
	Lout =>	v = 0;
	}
	measure("argue/survives", v);
}

index(a: array of ref Stmt, s: ref Stmt): int
{
	for(i := 0; i < len a; i++)
		if(a[i] == s)
			return i;
	return -1;
}

# The circles through the steps from u on: path holds the steps on the
# way to u, k of them.
cycles(u, k: int, oa: array of ref Stmt, edges: array of list of int, color, incyc, path: array of int)
{
	color[u] = 1;
	path[k] = u;
	for(el := edges[u]; el != nil; el = tl el){
		v := hd el;
		if(color[v] == 0)
			cycles(v, k+1, oa, edges, color, incyc, path);
		else if(color[v] == 1 && !incyc[v]){
			ring: list of ref Stmt;
			for(m := k; m >= 0; m--){
				ring = oa[path[m]] :: ring;
				incyc[path[m]] = 1;
				if(path[m] == v)
					break;
			}
			sreport(oa[v], "argue/cycle", sys->sprint("%s rest on each other: the argument goes round in a circle", names(ring)));
		}
	}
	color[u] = 2;
}

# Mark the steps u depends on, directly or through others.
depends(u: int, oa: array of ref Stmt, supp: array of list of ref Stmt, reach: array of int)
{
	for(sl := supp[u]; sl != nil; sl = tl sl)
		if((j := index(oa, hd sl)) >= 0 && !reach[j]){
			reach[j] = 1;
			depends(j, oa, supp, reach);
		}
}

# What a statement rests on: what its from names, or else every step
# before it and every premise and assumption none of them draws on.
support(st: ref Stmt, prems: list of ref Stmt): list of ref Stmt
{
	if(st.from != nil){
		r: list of ref Stmt;
		for(fl := st.from; fl != nil; fl = tl fl){
			s := stmtnamed(hd fl, everything);
			if(s != nil && s.says == nil && !inlist(s, r))
				r = s :: r;
		}
		return rev(r);
	}
	# the premises no earlier step draws on, and the steps
	r: list of ref Stmt;
	for(l := prems; l != nil; l = tl l){
		drawn := 0;
		for(sl := steps; sl != nil && hd sl != st; sl = tl sl)
			for(fl := (hd sl).from; fl != nil; fl = tl fl)
				if(hd fl == (hd l).name)
					drawn = 1;
		if(!drawn)
			r = appendst(r, hd l);
	}
	for(l = steps; l != nil && hd l != st; l = tl l)
		r = appendst(r, hd l);
	return r;
}







appendlist(a, b: list of ref Stmt): list of ref Stmt
{
	if(a == nil)
		return b;
	return hd a :: appendlist(tl a, b);
}

#
# Several readings of one text (phil/argue -k): logic files over the
# same atoms, compared sentence by sentence.  Two readings of a
# sentence agree if each entails the other; where they do not, a
# situation that one allows and the other does not says how they
# differ.  Then whether the verdicts agree, and for each file how
# many of its readings are the most common one, so the best supported
# reading can be kept.
#

Reading: adt {
	file:	string;
	prems:	list of ref Stmt;
	concl:	ref Stmt;
	valid:	int;
	support:	int;
	out:	int;	# ruled out by an answer
	mismatch:	int;	# its statements' mismatches with their sentences
};

# Where readings differ, a question: a situation the readings tell
# apart, and whether sentence k is true in it.  Answered, yes or no,
# in a file of lines "S1 yes" (-a), it rules out the readings that
# answer otherwise.
answerfile: string;
Ukey: con -100;	# the answer to assumption question Un is keyed Ukey-n
Mkey: con -99;	# the answer to M, which sentence is the main conclusion

readanswers(file: string): list of (int, int)
{
	l: list of (int, int);
	if(file == nil)
		return nil;
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil){
		report(nil, "argue/no-answers", sys->sprint("cannot open %s: %r", file));
		return nil;
	}
	while((s := b.gets('\n')) != nil){
		(n, w) := sys->tokenize(s, " \t\r\n");
		if(n < 2)
			continue;
		k := hd w;
		a := prose->lower(hd tl w);
		key := 0;
		if(k == "C")
			key = -1;
		else if(len k > 1 && k[0] == 'S' && alldigits(k[1:]))
			key = int k[1:];
		else if(len k > 1 && k[0] == 'U' && alldigits(k[1:]))
			key = Ukey - int k[1:];
		else if(k == "M")
			key = Mkey;
		else
			continue;
		if(len a >= 3 && a[0:3] == "yes")
			l = (key, 1) :: l;
		else if(len a >= 2 && a[0:2] == "no")
			l = (key, 0) :: l;
	}
	return l;
}

compare(files: list of string)
{
	rs: list of ref Reading;
	stmts: list of list of ref Stmt;
	kinds := 0;	# the modal logics the readings are in: 1 s5, 2 kd, 4 other
	for(l := files; l != nil; l = tl l){
		(p, c, st) := readstmts(hd l);
		case modal {
		Ms5 =>	kinds |= 1;
		Mkd =>	kinds |= 2;
		Mmix =>	kinds |= 3;
		Mk or Mkt =>	kinds |= 4;
		}
		if(c == nil)
			report(nil, "argue/no-conclusion", hd l + " has no conclusion (a line C)");
		rs = ref Reading(hd l, p, c, 0, 0, 0, 0) :: rs;
		stmts = st :: stmts;
	}
	if(errors){
		out.flush();
		raise "fail:syntax";
	}
	# one reading's necessity, another's ought: both in one logic
	case kinds {
	0 =>	modal = Mclassical;
	1 =>	modal = Ms5;
	2 =>	modal = Mkd;
	3 =>	modal = Mmix;
	}
	finish(stmts);
	n := len rs;
	ra := array[n] of ref Reading;
	for(i := n-1; i >= 0; i--){
		ra[i] = hd rs;
		rs = tl rs;
	}
	# the sentences any reading cites, in order; 0 for assumptions,
	# -1 for the conclusion
	keys: list of int;
	for(i = 0; i < n; i++)
		for(sl := ra[i].prems; sl != nil; sl = tl sl)
			keys = addkey((hd sl).sent, keys);
	keys = sortkeys(keys);
	keys = appendkey(keys, -1);
	agree := ndiffer := 0;
	answers := readanswers(answerfile);
	questions := "";
	asked: list of string;		# each question once: C's may be a premise's sentence
	fits := array[n] of { * => 0 };	# the answers each reading agrees with
	nanswered := 0;
	for(kl := keys; kl != nil; kl = tl kl){
		k := hd kl;
		fs := array[n] of ref Form;
		texts := array[n] of string;
		for(i = 0; i < n; i++)
			(fs[i], texts[i]) = readingof(ra[i], k);
		# group the readings: each joins the first it is equivalent to
		group := array[n] of int;
		ng := 0;
		for(i = 0; i < n; i++){
			group[i] = -1;
			for(j := 0; j < i; j++)
				if(equiv(fs[i], fs[j])){
					group[i] = group[j];
					break;
				}
			if(group[i] < 0)
				group[i] = ng++;
		}
		# the most common reading
		most := 0;
		bigsize := 0;
		for(g := 0; g < ng; g++){
			sz := 0;
			for(i = 0; i < n; i++)
				if(group[i] == g)
					sz++;
			if(sz > bigsize){
				most = g;
				bigsize = sz;
			}
		}
		for(i = 0; i < n; i++)
			if(group[i] == most)
				ra[i].support++;
		if(ng == 1){
			agree++;
			continue;
		}
		ndiffer++;
		msg := sys->sprint("%s is read %d ways:", keyname(k), ng);
		first := -1;
		for(g = 0; g < ng; g++){
			wl: list of string;
			rep := -1;
			for(i = 0; i < n; i++)
				if(group[i] == g){
					wl = ra[i].file :: wl;
					if(rep < 0)
						rep = i;
				}
			msg += sys->sprint(" %s %s %s;", listed(revs(wl)), plural(len wl, "has", "have"), texts[rep]);
			if(first < 0)
				first = rep;
			else if(g == 1)
				msg += " they differ " + differ(fs[first], fs[rep]) + ";";
		}
		msg = msg[0:len msg-1];
		creport(ra[0], k, "argue/readings", msg);
		if(k != 0)
			modalambiguous(ra, k);
		# the question that settles it, or its answer; the conclusion's,
		# when the readings put it at different sentences, is M below
		if(k == 0 || k < 0 && conclsdiffer(ra))
			continue;
		other := -1;
		for(i = 0; i < n; i++)
			if(group[i] != group[first]){
				other = i;
				break;
			}
		m := situation(fs[first], fs[other]);
		if(m == nil)
			continue;
		yes, no: list of string;
		for(i = n-1; i >= 0; i--)
			if(val(fs[i], m) == 1)
				yes = ra[i].file :: yes;
			else
				no = ra[i].file :: no;
		answered := -1;
		for(al := answers; al != nil; al = tl al){
			(ak, av) := hd al;
			if(ak == k)
				answered = av;
		}
		if(answered < 0){
			qt := question(k, m, fs, ra[first]);
			key := qt + spaced(yes);
			if(!member(key, asked)){
				asked = key :: asked;
				questions += sys->sprint("# question %s: %s\n# if yes: %s\n# if no: %s\n",
					keyname2(k), qt, spaced(yes), spaced(no));
			}
			continue;
		}
		nanswered++;
		kept: list of string;
		for(i = n-1; i >= 0; i--)
			if(val(fs[i], m) != answered)
				ra[i].out = 1;
			else{
				kept = ra[i].file :: kept;
				fits[i]++;
			}
		yn := "no";
		if(answered)
			yn = "yes";
		creport(ra[0], k, "argue/answered", sys->sprint("%s: answered %s, which keeps %s, to: %s", keyname(k),
			yn, listed(kept), question(k, m, fs, ra[first])));
	}
	# the readings' conclusions at different sentences: is the first
	# reading's the main one?
	cs := -1;
	for(i = 0; i < n && cs < 0; i++)
		if(ra[i].concl != nil)
			cs = ra[i].concl.sent;
	others: list of int;
	for(i = 0; i < n; i++)
		if(ra[i].concl != nil && ra[i].concl.sent != cs && !intmember(ra[i].concl.sent, others))
			others = ra[i].concl.sent :: others;
	if(cs > 0 && others != nil){
		yes, no: list of string;
		for(i = n-1; i >= 0; i--)
			if(ra[i].concl != nil && ra[i].concl.sent == cs)
				yes = ra[i].file :: yes;
			else
				no = ra[i].file :: no;
		ol := "";
		for(ml := others; ml != nil; ml = tl ml){
			if(ol != "")
				ol += " or ";
			ol += sentquote(hd ml);
		}
		report(nil, "argue/readings", sys->sprint("the main conclusion is read at %d sentences: %s %s it at %s; %s at %s",
			1 + len others, listed(yes), plural(len yes, "puts", "put"), sentquote(cs), listed(no), ol));
		qt := sys->sprint("Is the text's main conclusion %s, rather than %s?", sentquote(cs), ol);
		answered := -1;
		for(al := answers; al != nil; al = tl al){
			(ak, av) := hd al;
			if(ak == Mkey)
				answered = av;
		}
		if(answered < 0)
			questions += sys->sprint("# question M: %s\n# if yes: %s\n# if no: %s\n", qt, spaced(yes), spaced(no));
		else{
			nanswered++;
			kept: list of string;
			for(i = n-1; i >= 0; i--){
				at := ra[i].concl != nil && ra[i].concl.sent == cs;
				if(at != answered)
					ra[i].out = 1;
				else{
					kept = ra[i].file :: kept;
					fits[i]++;
				}
			}
			yn := "no";
			if(answered)
				yn = "yes";
			report(nil, "argue/answered", sys->sprint("M: answered %s, which keeps %s, to: %s", yn, listed(kept), qt));
		}
	}
	# what some readings take for granted and others do not: one
	# question for each such assumption, since the text says nothing
	# a question about a sentence could ask
	nu := 0;
	us: list of ref Stmt;
	affirmed: list of (ref Stmt, int);	# assumptions answered yes, and a reading that has them
	for(i = 0; i < n; i++)
		for(al0 := ra[i].prems; al0 != nil; al0 = tl al0){
			a := hd al0;
			if(a.sent != 0 || a.name == nil || a.name[0] != 'A')
				continue;
			dup := 0;
			for(ul := us; ul != nil; ul = tl ul)
				if(equiv(a.f, (hd ul).f))
					dup = 1;
			if(dup)
				continue;
			us = a :: us;
			# which readings have it, stated or assumed
			has := array[n] of int;
			nhas := 0;
			for(j := 0; j < n; j++){
				has[j] = entails(forms(ra[j].prems), a.f);
				nhas += has[j];
			}
			if(nhas == n)
				continue;
			nu++;
			key := Ukey - nu;
			yes, no: list of string;
			for(j = n-1; j >= 0; j--)
				if(has[j])
					yes = ra[j].file :: yes;
				else
					no = ra[j].file :: no;
			qt := sys->sprint("Does the text's argument take this for granted, whether or not it says so: \"%s\"? Answer yes if the author would accept it as part of the argument.", english(a.q));
			answered := -1;
			for(al := answers; al != nil; al = tl al){
				(ak, av) := hd al;
				if(ak == key)
					answered = av;
			}
			report(nil, "argue/readings", sys->sprint("U%d: %s take%s for granted \"%s\"; %s do%s not",
				nu, listed(yes), plural(len yes, "s", ""), english(a.q), listed(no), plural(len no, "es", "")));
			if(answered < 0){
				questions += sys->sprint("# question U%d: %s\n# if yes: %s\n# if no: %s\n",
					nu, qt, spaced(yes), spaced(no));
				continue;
			}
			nanswered++;
			if(answered)
				affirmed = (a, i) :: affirmed;
			kept: list of string;
			for(j = n-1; j >= 0; j--)
				if(has[j] != answered)
					ra[j].out = 1;
				else{
					kept = ra[j].file :: kept;
					fits[j]++;
				}
			yn := "no";
			if(answered)
				yn = "yes";
			report(nil, "argue/answered", sys->sprint("U%d: answered %s, which keeps %s, to: %s", nu, yn, listed(kept), qt));
		}
	# each reading read back beside the text: a misreading every
	# reading makes alike agrees with itself, but not with the words
	if(doc != nil)
		for(i = 0; i < n; i++){
			sprefix = ra[i].file + " ";
			ra[i].mismatch = faithful(ra[i].prems, ra[i].concl);
			sprefix = nil;
		}
	# the verdicts
	vs := "";
	nvalid := 0;
	for(i = 0; i < n; i++){
		r := ra[i];
		if(r.concl == nil)
			continue;
		r.valid = !satisfiable(neg(r.concl.f) :: forms(r.prems));
		nvalid += r.valid;
	}
	if(nvalid != 0 && nvalid != n){
		for(i = 0; i < n; i++)
			if(ra[i].valid){
				if(vs != "")
					vs += ", ";
				vs += ra[i].file;
			}
		report(nil, "argue/verdicts", sys->sprint("valid as %s read%s it, not as the others do: which reading is right decides the verdict",
			vs, plural(nvalid, "s", "")));
	}
	out.puts(sys->sprint("%s: argue/readings-agree %d\n", logic, agree));
	out.puts(sys->sprint("%s: argue/readings-differ %d\n", logic, ndiffer));
	vagree := 0;
	if(nvalid == 0 || nvalid == n)
		vagree = 1;
	out.puts(sys->sprint("%s: argue/verdicts-agree %d\n", logic, vagree));
	# the reading most of the others agree with, the first if tied,
	# among those no answer rules out
	nout := 0;
	for(i = 0; i < n; i++)
		nout += ra[i].out;
	split := 0;
	if(nout == n){
		split = nanswered > 1;
		# every reading is ruled out by some answer: each is partly
		# right, and the reading wanted takes from more than one
		if(nanswered > 1){
			fl := "";
			for(i = 0; i < n; i++){
				if(fl != "")
					fl += ", ";
				fl += sys->sprint("%s %d", ra[i].file, fits[i]);
			}
			report(nil, "argue/answers-split", sys->sprint("no reading agrees with all %d answers (%s of them): each is right somewhere, and the reading the answers want takes statements from more than one",
				nanswered, fl));
		}
		for(i = 0; i < n; i++)
			ra[i].out = 0;
	}
	# fewest mismatches with the words first: agreement among the
	# readings of one model is no proof that any of them is right
	best := -1;
	for(i = 0; i < n; i++){
		out.puts(sys->sprint("%s: argue/support %d\n", ra[i].file, ra[i].support));
		if(doc != nil)
			out.puts(sys->sprint("%s: argue/mismatches %d\n", ra[i].file, ra[i].mismatch));
		if(ra[i].out)
			continue;
		# where the answers split the readings, the one that agrees
		# with most of them
		if(split && best >= 0 && fits[i] != fits[best]){
			if(fits[i] > fits[best])
				best = i;
			continue;
		}
		if(best < 0 || ra[i].mismatch < ra[best].mismatch ||
		   ra[i].mismatch == ra[best].mismatch && ra[i].support > ra[best].support)
			best = i;
	}
	out.puts(questions);
	out.puts("# best reading: " + ra[best].file + "\n");
	# what the answers say the text takes for granted and the reading
	# kept does not have: to be added to it, at the step that rests on
	# it in a reading that has it, where the kept reading has its atoms
	bp: list of string;
	for(ks := appendst(ra[best].prems, ra[best].concl); ks != nil; ks = tl ks)
		bp = qpreds((hd ks).q, bp);
	for(al := rev2a(affirmed); al != nil; al = tl al){
		(a, ai) := hd al;
		if(entails(forms(ra[best].prems), a.f))
			continue;
		ok := 1;
		for(pl := qpreds(a.q, nil); pl != nil; pl = tl pl)
			if(!member(hd pl, bp))
				ok = 0;
		if(!ok){
			report(nil, "argue/assumption-left", sys->sprint("the answers say the text takes \"%s\" for granted, but %s has no atoms for it: add it by hand",
				english(a.q), ra[best].file));
			continue;
		}
		at := 0;
		for(ks = appendst(ra[ai].prems, ra[ai].concl); ks != nil; ks = tl ks)
			if(member(a.name, (hd ks).from))
				at = (hd ks).sent;
		if(at == 0 && ra[best].concl != nil)
			at = ra[best].concl.sent;
		out.puts(sys->sprint("# assume S%d: %s\n", at, qshow(a.q)));
	}
}

rev2a(l: list of (ref Stmt, int)): list of (ref Stmt, int)
{
	r: list of (ref Stmt, int);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

# The modalities a formula uses: 1 necessity or possibility, 2 ought or
# permitted.
modalsig(q: ref Q): int
{
	if(q == nil)
		return 0;
	m := modalsig(q.l) | modalsig(q.r);
	if(q.op == Fnec || q.op == Fpos){
		if(modal == Mkd || deontic(q))
			m |= 2;
		else
			m |= 1;
	}
	return m;
}

# The modality a reading gives sentence k.
readingsig(r: ref Reading, k: int): int
{
	if(k < 0){
		if(r.concl == nil)
			return 0;
		return modalsig(r.concl.q);
	}
	m := 0;
	for(l := r.prems; l != nil; l = tl l)
		if((hd l).sent == k)
			m |= modalsig((hd l).q);
	return m;
}

signame(m: int): string
{
	case m {
	0 =>	return "with no modality";
	1 =>	return "as what is necessary or possible";
	2 =>	return "as what ought to be or is permitted";
	}
	return "as both";
}

# The readings give a sentence different modalities: the text does not
# say which it means.  A fault of the text, whatever any answer keeps.
modalambiguous(ra: array of ref Reading, k: int)
{
	n := len ra;
	sig := array[n] of int;
	differ := 0;
	for(i := 0; i < n; i++){
		sig[i] = readingsig(ra[i], k);
		if(sig[i] != sig[0])
			differ = 1;
	}
	if(!differ)
		return;
	msg := "";
	for(m := 0; m < 4; m++){
		wl: list of string;
		for(i = n-1; i >= 0; i--)
			if(sig[i] == m)
				wl = ra[i].file :: wl;
		if(wl == nil)
			continue;
		if(msg != "")
			msg += "; ";
		msg += sys->sprint("%s %s", listed(wl), signame(m));
	}
	what := keyname(k);
	sn := k;
	if(k < 0 && ra[0].concl != nil)
		sn = ra[0].concl.sent;
	mw := "";
	if(doc != nil && sn > 0 && sn <= len sents)
		mw = modalwords(sents[sn-1]);
	if(mw != nil)
		mw = sys->sprint(": %s does not say which it means", mw);
	else
		mw = ": the text does not say which it means";
	creport(ra[0], k, "argue/modal-ambiguous", sys->sprint("%s is read %s%s", what, msg, mw));
}

# The modal words of a sentence that can mean either what must or may be
# and what must or may be done.
Modalwords := array[] of { "must", "may", "might", "can", "cannot", "can't", "could", "need", "needs", "should" };

modalwords(s: ref Sent): string
{
	found: list of string;
	for(i := 0; i < len s.words; i++)
		for(j := 0; j < len Modalwords; j++)
			if(s.words[i].lc == Modalwords[j] && !member(Modalwords[j], found))
				found = Modalwords[j] :: found;
	if(found == nil)
		return nil;
	t := "";
	for(l := revs(found); l != nil; l = tl l){
		if(t != "")
			t += " or ";
		t += "\"" + hd l + "\"";
	}
	return "its " + t;
}

# What a reading says of sentence k: its statements from it, together,
# and as written.
readingof(r: ref Reading, k: int): (ref Form, string)
{
	if(k < 0){
		if(r.concl == nil)
			return (ref Form(Ftrue, 0, nil, nil, nil), "no conclusion");
		return (r.concl.f, "\"" + qshow(r.concl.q) + "\"");
	}
	f: ref Form;
	t := "";
	for(l := r.prems; l != nil; l = tl l){
		st := hd l;
		if(st.sent != k)
			continue;
		if(f == nil)
			f = st.f;
		else
			f = ref Form(Fand, 0, f, st.f, nil);
		if(t != "")
			t += " and ";
		t += "\"" + qshow(st.q) + "\"";
	}
	if(f == nil)
		return (ref Form(Ftrue, 0, nil, nil, nil), "nothing from it");
	return (f, t);
}

equiv(a, b: ref Form): int
{
	return entails(a :: nil, b) && entails(b :: nil, a);
}

# How two readings differ: a situation one allows and the other not.
# A situation one of a and b allows and the other does not, every atom
# either names given a value: those left open, false.
situation(a, b: ref Form): array of int
{
	m := sat(a :: neg(b) :: nil);
	if(m == nil)
		m = sat(b :: neg(a) :: nil);
	if(m == nil)
		return nil;
	for(i := 0; i < natoms; i++)
		if(m[i] < 0)
			m[i] = 0;
	return m;
}

# The question, in words: the situation, and whether sentence k holds.
question(k: int, m: array of int, fs: array of ref Form, r: ref Reading): string
{
	used := array[natoms] of { * => 0 };
	for(i := 0; i < len fs; i++)
		mark(fs[i], used);
	t, f: list of string;
	for(i = 0; i < natoms; i++)
		if(used[i] && !isfresh(i)){
			if(m[i] == 1)
				t = sys->sprint("\"%s\"", told2(i)) :: t;
			else
				f = sys->sprint("\"%s\"", told2(i)) :: f;
		}
	q := "Suppose";
	if(t != nil)
		q += sys->sprint(" %s %s", listed(revs(t)), plural(len t, "is true", "are true"));
	if(t != nil && f != nil)
		q += " and";
	if(f != nil)
		q += sys->sprint(" %s %s", listed(revs(f)), plural(len f, "is false", "are false"));
	if(t == nil && f == nil)
		q += " nothing is true";
	what := keyname(k);
	sn := k;
	if(k < 0 && r.concl != nil)
		sn = r.concl.sent;
	if(doc != nil && sn > 0 && sn <= len sents)
		what += sys->sprint(", \"%s\",", sents[sn-1].s);
	return q + ". Is " + what + " true then?";
}

# Do the readings put their conclusions at different sentences?
conclsdiffer(ra: array of ref Reading): int
{
	cs := -1;
	for(i := 0; i < len ra; i++)
		if(ra[i].concl != nil){
			if(cs >= 0 && ra[i].concl.sent != cs)
				return 1;
			cs = ra[i].concl.sent;
		}
	return 0;
}

# S6, with its words when the document is known.
sentquote(k: int): string
{
	if(doc != nil && k > 0 && k <= len sents)
		return sys->sprint("S%d, \"%s\"", k, sents[k-1].s);
	return sys->sprint("S%d", k);
}

intmember(k: int, l: list of int): int
{
	for(; l != nil; l = tl l)
		if(hd l == k)
			return 1;
	return 0;
}

keyname2(k: int): string
{
	if(k < 0)
		return "C";
	return sys->sprint("S%d", k);
}

spaced(l: list of string): string
{
	s := "";
	for(; l != nil; l = tl l){
		if(s != "")
			s += " ";
		s += hd l;
	}
	return s;
}

differ(a, b: ref Form): string
{
	(m, which) := (sat(a :: neg(b) :: nil), "the first");
	if(m == nil)
		(m, which) = (sat(b :: neg(a) :: nil), "the second");
	if(m == nil)
		return "";
	used := array[natoms] of { * => 0 };
	mark(a, used);
	mark(b, used);
	t: list of string;
	for(i := 0; i < natoms; i++)
		if(used[i] && m[i] == 1 && (!isfresh(i)))
			t = sys->sprint("\"%s\"", told2(i)) :: t;
	if(t == nil)
		return sys->sprint("when nothing is true, which %s allows", which);
	return sys->sprint("when only %s %s, which %s allows", listed(revs(t)), plural(len t, "is true", "are true"), which);
}

told2(i: int): string
{
	if(meanings[i] != nil)
		return meanings[i];
	return atoms[i];
}

keyname(k: int): string
{
	if(k < 0)
		return "the conclusion";
	if(k == 0)
		return "what the text leaves unstated";
	return sys->sprint("S%d", k);
}

# A finding about sentence k: at the sentence when the document is
# known, otherwise in the first logic file.
creport(r: ref Reading, k: int, rule, msg: string)
{
	if(doc != nil && k > 0 && k <= len sents){
		st := sents[k-1];
		out.puts(prose->finding(doc, st.line, st.q0, st.q1, rule, msg));
		return;
	}
	if(doc != nil && k < 0 && r.concl != nil && r.concl.sent > 0 && r.concl.sent <= len sents){
		st := sents[r.concl.sent-1];
		out.puts(prose->finding(doc, st.line, st.q0, st.q1, rule, msg));
		return;
	}
	out.puts(sys->sprint("%s: %s: %s\n", logic, rule, msg));
}

addkey(k: int, l: list of int): list of int
{
	for(m := l; m != nil; m = tl m)
		if(hd m == k)
			return l;
	return k :: l;
}

appendkey(l: list of int, k: int): list of int
{
	if(l == nil)
		return k :: nil;
	return hd l :: appendkey(tl l, k);
}

sortkeys(l: list of int): list of int
{
	a := array[len l] of int;
	for(i := 0; l != nil; l = tl l)
		a[i++] = hd l;
	for(i = 1; i < len a; i++)
		for(j := i; j > 0 && a[j] < a[j-1]; j--)
			(a[j], a[j-1]) = (a[j-1], a[j]);
	r: list of int;
	for(i = len a - 1; i >= 0; i--)
		r = a[i] :: r;
	# assumptions after the sentences
	if(r != nil && hd r == 0)
		r = appendkey(tl r, 0);
	return r;
}

#
# The argument in TPTP's first-order form (fof), for E, Vampire or any
# prover that reads it: a check on this one.  Premises and assumptions
# are axioms, the conclusion the conjecture; atoms keep their names, a
# variable is put in capitals, and a name TPTP would not take as it
# stands is quoted.
#

tptp(prems: list of ref Stmt, c: ref Stmt)
{
	out.puts("% " + logic + ", for a first-order prover\n");
	if(modal != Mclassical){
		out.puts(sys->sprint("%% logic %s, by the standard translation: each atom holds at a world, w0 the actual one\n", modalnames[modal]));
		twld = "w0";
		if(modal == Mkd || modal == Mmix)
			out.puts("fof(serial, axiom, (! [X] : (? [Y] : r(X,Y)))).\n");
		if(modal == Mkt)
			out.puts("fof(reflexive, axiom, (! [X] : r(X,X))).\n");
	}
	for(pl := revpreds(preds); pl != nil; pl = tl pl){
		pr := hd pl;
		if(pr.used && pr.meaning != "")
			out.puts(sys->sprint("%% %s: %s\n", tname(pr.name), pr.meaning));
	}
	for(l := prems; l != nil; l = tl l){
		st := hd l;
		out.puts(sys->sprint("fof(%s, axiom, %s).\n", tname(lowerstr(st.name)), tform(st.q, nil)));
	}
	if(c != nil)
		out.puts(sys->sprint("fof(c, conjecture, %s).\n", tform(c.q, nil)));
}

# In modal logic, by the standard translation: each atom holds at a
# world, its last argument; [] is every world the one at hand sees
# (all of them, in S5), <> some, and w0 is the actual world.
twld := "";
tworlds := 0;

tform(q: ref Q, bound: list of string): string
{
	case q.op {
	Fatom =>
		s := tname(q.name);
		if(q.args != nil || twld != ""){
			s += "(";
			sep := "";
			for(a := q.args; a != nil; a = tl a){
				if(member(hd a, bound))
					s += sep + tvar(hd a);
				else
					s += sep + tname(hd a);
				sep = ",";
			}
			if(twld != "")
				s += sep + twld;
			s += ")";
		}
		return s;
	Fnec or Fpos =>
		w := twld;
		v := sys->sprint("W%d", ++tworlds);
		twld = v;
		body := tform(q.l, bound);
		twld = w;
		if(modal == Ms5 || modal == Mmix && !deontic(q)){
			if(q.op == Fnec)
				return "(! [" + v + "] : " + body + ")";
			return "(? [" + v + "] : " + body + ")";
		}
		if(q.op == Fnec)
			return "(! [" + v + "] : (r(" + w + "," + v + ") => " + body + "))";
		return "(? [" + v + "] : (r(" + w + "," + v + ") & " + body + "))";
	Ftrue =>
		return "$true";
	Fnot =>
		return "~ " + tform(q.l, bound);
	Fand =>
		return "(" + tform(q.l, bound) + " & " + tform(q.r, bound) + ")";
	For =>
		return "(" + tform(q.l, bound) + " | " + tform(q.r, bound) + ")";
	Fimp =>
		return "(" + tform(q.l, bound) + " => " + tform(q.r, bound) + ")";
	Fiff =>
		return "(" + tform(q.l, bound) + " <=> " + tform(q.r, bound) + ")";
	Fall =>
		return "(! [" + tvar(q.name) + "] : " + tform(q.l, q.name :: bound) + ")";
	Fsome =>
		return "(? [" + tvar(q.name) + "] : " + tform(q.l, q.name :: bound) + ")";
	}
	return "$false";
}

# A TPTP name: a lower-case word as it is, anything else quoted.
tname(n: string): string
{
	ok := len n > 0 && n[0] >= 'a' && n[0] <= 'z';
	for(i := 0; ok && i < len n; i++)
		if(!isword(n[i]))
			ok = 0;
	if(ok)
		return n;
	return "'" + n + "'";
}

tvar(v: string): string
{
	r := v;
	if(r[0] >= 'a' && r[0] <= 'z')
		r[0] += 'A' - 'a';
	else if(!(r[0] >= 'A' && r[0] <= 'Z'))
		r = "V" + r;
	return r;
}

lowerstr(s: string): string
{
	r := s;
	for(i := 0; i < len r; i++)
		if(r[i] >= 'A' && r[i] <= 'Z')
			r[i] += 'a' - 'A';
	return r;
}

revpreds(l: list of ref Pred): list of ref Pred
{
	r: list of ref Pred;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

#
# Checks on how the argument is written, which a verdict alone hides:
# a premise that says nothing or cannot be true; a conclusion about
# something no premise mentions; when it fails, premises about things
# nothing else mentions.  A model writing the argument down tends to
# leave a fact out or name one thing two ways, and these show where.
#

lint(prems: list of ref Stmt, c: ref Stmt)
{
	for(l := prems; l != nil; l = tl l){
		st := hd l;
		if(!satisfiable(neg(st.f) :: nil))
			sreport(st, "argue/empty", sys->sprint("%s is true whatever the case: it says nothing", st.name));
		else if(!satisfiable(st.f :: nil))
			sreport(st, "argue/impossible", sys->sprint("%s can never be true", st.name));
	}
	inprem: list of string;
	for(l = prems; l != nil; l = tl l)
		inprem = qpreds((hd l).q, inprem);
	for(cl := qpreds(c.q, nil); cl != nil; cl = tl cl)
		if(!member(hd cl, inprem))
			sreport(c, "argue/unlinked", sys->sprint("the conclusion speaks of %s, which no premise mentions: nothing links it to them", told(hd cl)));
}

unlinked(prems: list of ref Stmt, c: ref Stmt)
{
	inc := qpreds(c.q, nil);
	for(l := prems; l != nil; l = tl l){
		st := hd l;
		# the claims only this statement speaks of, in one finding
		alone: list of string;
		for(pl := qpreds(st.q, nil); pl != nil; pl = tl pl){
			n := hd pl;
			if(member(n, inc))
				continue;
			others := 0;
			for(m := prems; m != nil; m = tl m)
				if(hd m != st && member(n, qpreds((hd m).q, nil)))
					others = 1;
			if(!others)
				alone = told(n) :: alone;
		}
		if(alone != nil)
			sreport(st, "argue/unlinked", sys->sprint("%s is the only statement about %s: as written it cannot bear on the conclusion; was the same thing named two ways?", st.name, listed(alone)));
	}
}

# The names of the predicates a formula uses, added to l.
qpreds(q: ref Q, l: list of string): list of string
{
	if(q == nil)
		return l;
	if(q.op == Fatom && !member(q.name, l))
		l = q.name :: l;
	return qpreds(q.r, qpreds(q.l, l));
}

# A predicate as a reader knows it: "x is patched", or its name.
told(n: string): string
{
	p := predof(n);
	if(p.meaning != "")
		return sys->sprint("\"%s\"", p.meaning);
	return n;
}

#
# Reading
#

# The logic file as it is, but each statement's formula written as
# formulas are shown (in logic's symbols, or with -A in ASCII); a file
# with a line the prover cannot read is not rewritten.
reformat(file: string)
{
	stdout := out;
	out = bufio->fopen(sys->fildes(2), Bufio->OWRITE);
	(nil, nil, stmts) := readstmts(file);
	out.flush();
	out = stdout;
	if(errors)
		raise "fail:syntax";
	byline := array[Nhash] of list of ref Stmt;
	for(l := stmts; l != nil; l = tl l)
		byline[(hd l).line % Nhash] = hd l :: byline[(hd l).line % Nhash];
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil)
		fatal(sys->sprint("cannot open %s: %r", file));
	n := 0;
	while((s := b.gets('\n')) != nil){
		n++;
		nl := "";
		if(s[len s-1] == '\n'){
			s = s[0:len s-1];
			nl = "\n";
		}
		st: ref Stmt;
		for(sl := byline[n % Nhash]; sl != nil; sl = tl sl)
			if((hd sl).line == n)
				st = hd sl;
		if(st != nil){
			# name, sentence, formula and the rest, by tabs
			f := 0;
			for(i := 0; i < len s; i++)
				if(s[i] == '\t' && ++f == 2)
					break;
			if(i < len s){
				j := i+1;
				while(j < len s && s[j] != '\t')
					j++;
				s = s[0:i+1] + qshow(st.q) + s[j:];
			}
		}
		out.puts(s + nl);
	}
}

# The scope of a necessity or an ought in a conditional: "if p, then
# necessarily q" may put it on q alone, p → □q, or on the whole,
# □(p → q); and the same for ought.  The other reading of each premise
# or assumption read one way, in the formula or in one of the
# conjuncts it asserts, as a whole formula with what it says.
Flip: adt {
	q:	ref Q;
	how:	string;	# where the reading put it: "consequent" or "whole"
	what:	string;	# "necessity" or "obligation"
};

flips(q: ref Q): list of ref Flip
{
	r: list of ref Flip;
	if(q == nil)
		return nil;
	what := "necessity";
	if(q.op == Fimp && q.r != nil && q.r.op == Fnec){
		if(deontic(q.r))
			what = "obligation";
		r = ref Flip(ref Q(Fnec, q.r.name, nil, ref Q(Fimp, nil, nil, q.l, q.r.l), nil), "consequent", what) :: r;
	}
	if(q.op == Fnec && q.l != nil && q.l.op == Fimp){
		if(deontic(q))
			what = "obligation";
		r = ref Flip(ref Q(Fimp, nil, nil, q.l.l, ref Q(Fnec, q.name, nil, q.l.r, nil)), "whole", what) :: r;
	}
	if(q.op == Fand){
		for(l := flips(q.l); l != nil; l = tl l)
			r = ref Flip(ref Q(Fand, nil, nil, (hd l).q, q.r), (hd l).how, (hd l).what) :: r;
		for(l = flips(q.r); l != nil; l = tl l)
			r = ref Flip(ref Q(Fand, nil, nil, q.l, (hd l).q), (hd l).how, (hd l).what) :: r;
	}
	return r;
}

# The logic file with the nth such scope turned over, the line it is on
# said first, as a comment:
#	# scope<TAB>P1<TAB>S2<TAB>consequent<TAB>necessity<TAB>as read<TAB>turned over
# and nothing if the file has fewer.
scopes(file: string, k: int)
{
	stdout := out;
	out = bufio->fopen(sys->fildes(2), Bufio->OWRITE);
	(nil, nil, stmts) := readstmts(file);
	out.flush();
	out = stdout;
	if(errors)
		raise "fail:syntax";
	n := 0;
	at: ref Stmt;
	flip: ref Flip;
	for(l := stmts; l != nil && at == nil; l = tl l){
		st := hd l;
		if(st.name == nil || st.name[0] != 'P' && st.name[0] != 'A')
			continue;
		for(fl := rev2f(flips(st.q)); fl != nil; fl = tl fl)
			if(++n == k){
				at = st;
				flip = hd fl;
				break;
			}
	}
	if(at == nil)
		return;
	sent := "-";
	if(at.sent > 0)
		sent = "S" + string at.sent;
	out.puts("# scope\t" + at.name + "\t" + sent + "\t" + flip.how + "\t" + flip.what + "\t" + qshow(at.q) + "\t" + qshow(flip.q) + "\n");
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil)
		fatal(sys->sprint("cannot open %s: %r", file));
	line := 0;
	while((s := b.gets('\n')) != nil){
		line++;
		if(line == at.line){
			nl := "";
			if(s[len s-1] == '\n'){
				s = s[0:len s-1];
				nl = "\n";
			}
			f := 0;
			for(i := 0; i < len s; i++)
				if(s[i] == '\t' && ++f == 2)
					break;
			if(i < len s){
				j := i+1;
				while(j < len s && s[j] != '\t')
					j++;
				s = s[0:i+1] + qshow(flip.q) + s[j:];
			}
			s += nl;
		}
		out.puts(s);
	}
}

rev2f(l: list of ref Flip): list of ref Flip
{
	r: list of ref Flip;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

readlogic(file: string): (list of ref Stmt, ref Stmt)
{
	(prems, concl, stmts) := readstmts(file);
	finish(stmts :: nil);
	return (prems, concl);
}

# A logic file's statements, parsed but not yet grounded: all and some
# are taken over the individuals every file being read names.
readstmts(file: string): (list of ref Stmt, ref Stmt, list of ref Stmt)
{
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil)
		fatal(sys->sprint("cannot open %s: %r", file));
	prems: list of ref Stmt;
	concl: ref Stmt;
	stmts: list of ref Stmt;
	byname := array[Nhash] of list of ref Stmt;	# by name's hash
	steps = nil;
	objections = nil;
	rivals = nil;
	modal = Mclassical;
	n := 0;
	while((s := b.gets('\n')) != nil){
		n++;
		if(s[len s-1] == '\n')
			s = s[0:len s-1];
		(nf, fl) := sys->tokenize(s, "\t");
		if(nf == 0 || (hd fl)[0] == '#')
			continue;
		name := hd fl;
		if(name == "atom"){
			if(nf < 2){
				lreport(n, "argue/syntax", "an atom needs a name");
				continue;
			}
			(pn, params, derr) := atomdecl(hd tl fl);
			if(derr != nil){
				lreport(n, "argue/syntax", derr);
				continue;
			}
			m := "";
			if(nf > 2)
				m = hd tl tl fl;
			pr := predof(pn);
			pr.params = params;
			pr.meaning = m;
			pr.line = n;
			# a plain atom takes its place now, in the order declared
			if(params == nil){
				i := atomof(pn);
				meanings[i] = m;
			}
			continue;
		}
		if(name == "logic"){
			m := -1;
			if(nf > 1)
				for(k := 0; k < len modalnames; k++)
					if(hd tl fl == modalnames[k])
						m = k;
			if(m < 0){
				lreport(n, "argue/syntax", "logic is classical, s5 (necessity and possibility), kd (ought and permitted), k or kt");
				continue;
			}
			if(stmts != nil)
				lreport(n, "argue/syntax", "the logic line comes before the statements");
			modal = m;
			continue;
		}
		if(name == "rivals"){
			# rival premises: positions (-p) leaves out any set with both
			(nil, ws) := sys->tokenize(s, " \t,");
			if(len ws != 3){
				lreport(n, "argue/syntax", "rivals names two premises or assumptions: rivals P10 P11");
				continue;
			}
			rivals = (n, hd tl ws, hd tl tl ws) :: rivals;
			continue;
		}
		if(name == "domain"){
			for(l := tl fl; l != nil; l = tl l){
				(nil, ws) := sys->tokenize(hd l, " ,");
				for(; ws != nil; ws = tl ws)
					addconst(hd ws);
			}
			continue;
		}
		if(nf < 3){
			lreport(n, "argue/syntax", "a statement is a name, a sentence (S3, or - if none) and a formula");
			continue;
		}
		where := hd tl fl;
		sn := 0;
		if(where != "-"){
			if(len where < 2 || where[0] != 'S' || !alldigits(where[1:])){
				lreport(n, "argue/syntax", sys->sprint("\"%s\" is not a sentence: S and its number, or -", where));
				continue;
			}
			sn = int where[1:];
			if(sents != nil && (sn < 1 || sn > len sents)){
				lreport(n, "argue/no-sentence", sys->sprint("%s cites %s, but the document has %d sentences", name, where, len sents));
				continue;
			}
		}
		text := hd tl tl fl;
		(q, err) := parse(text);
		if(err != nil){
			lreport(n, "argue/syntax", sys->sprint("%s: %s", name, err));
			continue;
		}
		st := ref Stmt(name, sn, nil, q, n, text, nil, nil, nil, nil);
		# fields after the formula, each a word and what follows it:
		# what a conclusion is drawn from, what an objection is
		# against, whose claim a premise reports, what kind a claim is
		bad := 0;
		for(xl := tl tl tl fl; xl != nil && !bad; xl = tl xl){
			(nil, ws) := sys->tokenize(hd xl, " ,");
			if(ws != nil && (hd ws == "says" || hd ws == "kind")){
				if(tl ws == nil){
					what := "a kind: empirical, normative or conceptual";
					if(hd ws == "says")
						what = "whose claim it is (says schmitt)";
					lreport(n, "argue/syntax", sys->sprint("%s: %s names %s", name, hd ws, what));
					bad = 1;
				}else if(hd ws == "says"){
					if(name == nil || name[0] != 'P'){
						lreport(n, "argue/syntax", sys->sprint("%s: only a premise (P1, ...) reports what another says", name));
						bad = 1;
					}
					st.says = words(tl ws);
				}else{
					st.kind = hd tl ws;
					if(tl tl ws != nil || !member(st.kind, kindlist())){
						lreport(n, "argue/syntax", sys->sprint("%s: a kind is empirical, normative or conceptual", name));
						bad = 1;
					}
				}
				continue;
			}
			if(ws == nil || (hd ws != "from" && hd ws != "against") || tl ws == nil){
				lreport(n, "argue/syntax", sys->sprint("%s: a fourth field is from and the statements it rests on (from P1 P2), or against and what it attacks (against P1)", name));
				bad = 1;
			}else if(hd ws == "from" && !isconcl(name)){
				lreport(n, "argue/syntax", sys->sprint("%s: only a conclusion (C, C1, C2, ...) is drawn from others", name));
				bad = 1;
			}else if(hd ws == "against" && !isattack(name)){
				lreport(n, "argue/syntax", sys->sprint("%s: only an objection (O1, ...) or a reply (R1, ...) is against something", name));
				bad = 1;
			}else if(hd ws == "from")
				st.from = tl ws;
			else
				st.against = tl ws;
		}
		if(bad)
			continue;
		h := hashstr(name) % Nhash;
		for(l := byname[h]; l != nil; l = tl l)
			if((hd l).name == name)
				lreport(n, "argue/duplicate", sys->sprint("%s is named twice, here and at line %d", name, (hd l).line));
		byname[h] = st :: byname[h];
		stmts = st :: stmts;
		if(name == "C"){
			if(concl != nil)
				lreport(n, "argue/duplicate", "an argument has one conclusion");
			concl = st;
		}else if(isconcl(name))
			steps = st :: steps;
		else if(isattack(name)){
			if(st.against == nil)
				lreport(n, "argue/syntax", sys->sprint("%s: an objection or reply says what it is against (against P1)", name));
			objections = st :: objections;
		}else if(st.says == nil)
			prems = st :: prems;
		# a premise that reports another's claim is the work's
		# account of it, not a premise of its argument
	}
	steps = rev(steps);
	objections = rev(objections);
	everything = stmts;
	# what a step is drawn from must be in the file
	for(l := stmts; l != nil; l = tl l)
		for(fl := (hd l).from; fl != nil; fl = tl fl)
			if(stmtnamed(hd fl, stmts) == nil)
				lreport((hd l).line, "argue/syntax", sys->sprint("%s is drawn from %s, which is not in the file", (hd l).name, hd fl));
	for(l = stmts; l != nil; l = tl l)
		for(al := (hd l).against; al != nil; al = tl al)
			if(stmtnamed(hd al, stmts) == nil)
				lreport((hd l).line, "argue/syntax", sys->sprint("%s is against %s, which is not in the file", (hd l).name, hd al));
	# a step drawn from what the work only reports
	if(!quiet)
		for(l = stmts; l != nil; l = tl l)
			for(rl := (hd l).from; rl != nil; rl = tl rl)
				if((t := stmtnamed(hd rl, stmts)) != nil && t.says != nil)
					sreport(hd l, "argue/reported-as-premise", sys->sprint("%s rests on %s, which reports what %s says: a work's account of another's claim is not its premise; if the work holds it, it says so on a line of its own", (hd l).name, t.name, t.says));
	return (rev(prems), concl, stmts);
}

# The kinds a claim may be, as a list.
kindlist(): list of string
{
	l: list of string;
	for(i := len Kinds - 1; i >= 0; i--)
		l = Kinds[i] :: l;
	return l;
}

# Words joined by blanks.
words(l: list of string): string
{
	s := "";
	for(; l != nil; l = tl l){
		if(s != nil)
			s += " ";
		s += hd l;
	}
	return s;
}

# An objection's name (O1, O2, ...) or a reply's (R1, ...).
isattack(n: string): int
{
	return len n > 1 && (n[0] == 'O' || n[0] == 'R') && n[1] >= '0' && n[1] <= '9';
}

# A conclusion's name: C, the argument's, or C1, C2, ..., a step on
# the way to it.
isconcl(n: string): int
{
	return n == "C" || len n > 1 && n[0] == 'C' && n[1] >= '0' && n[1] <= '9';
}

Nhash: con 4093;
atomhash: array of list of int;	# by name's hash: the atoms

hashstr(s: string): int
{
	h := 0;
	for(i := 0; i < len s; i++)
		h = (h*31 + s[i]) & 16r7fffffff;
	return h;
}

stmtnamed(n: string, l: list of ref Stmt): ref Stmt
{
	for(; l != nil; l = tl l)
		if((hd l).name == n)
			return hd l;
	return nil;
}

decided := 1;	# whether trying the cases decides validity exactly
forcefresh := -1;	# individuals to add, when looking for a smaller case
lastfresh := 0;
quiet := 0;	# looking, not reporting
MAXFRESH: con 16;

# How many individuals beyond those named the cases need, and whether
# with that many trying them decides the argument (Börger, Grädel and
# Gurevich, The Classical Decision Problem):
#	no all or some: nothing to add, decided;
#	only one-place predicates: 2^k for k of them (Löwenheim 1915);
#	no some within an all, once the conclusion is denied (the
#	Bernays-Schönfinkel class): one for each some;
#	otherwise up to three, and a verdict of valid is not certain.
classify(all: list of list of ref Stmt): (int, int)
{
	if(nquant == 0)
		return (1, 0);
	monadic := 1;
	k := 0;
	for(pl := preds; pl != nil; pl = tl pl){
		pr := hd pl;
		if(!pr.used)
			continue;
		a := pr.arity;
		if(pr.line != 0)
			a = len pr.params;
		if(a > 1)
			monadic = 0;
		if(a == 1)
			k++;
	}
	epr := 1;
	e := 0;
	for(; all != nil; all = tl all)
		for(l := hd all; l != nil; l = tl l){
			st := hd l;
			pol := 1;
			if(st.name == "C")
				pol = -1;
			(ee, ok) := quants(st.q, pol, 0);
			e += ee;
			if(!ok)
				epr = 0;
		}
	c := len consts;
	best := -1;
	if(monadic && k < 5)
		best = 1 << k;
	if(epr && (best < 0 || e < best))
		best = e;
	if(best < 0 || best > MAXFRESH)
		return (0, min(nquant, 3));
	if(c + best == 0)
		best = 1;	# something must exist
	return (1, best);
}

# Counting the somes of a formula (a some, or an all denied) and
# whether none lies within an all; pol is 1 where the formula is
# asserted, -1 where denied, 0 both (inside if and only if).
quants(q: ref Q, pol, underall: int): (int, int)
{
	if(q == nil)
		return (0, 1);
	case q.op {
	Fatom or Ftrue =>
		return (0, 1);
	Fnot =>
		return quants(q.l, -pol, underall);
	Fimp =>
		(a, ok1) := quants(q.l, -pol, underall);
		(b, ok2) := quants(q.r, pol, underall);
		return (a+b, ok1 && ok2);
	Fiff =>
		(a, ok1) := quants(q.l, 0, underall);
		(b, ok2) := quants(q.r, 0, underall);
		return (a+b, ok1 && ok2);
	Fall or Fsome =>
		some := q.op == Fsome && pol >= 0 || q.op == Fall && pol <= 0;
		every := q.op == Fall && pol >= 0 || q.op == Fsome && pol <= 0;
		n := 0;
		ok := 1;
		if(some){
			n = 1;
			if(underall)
				ok = 0;
		}
		u := underall;
		if(every)
			u = 1;
		(b, ok2) := quants(q.l, pol, u);
		return (n+b, ok && ok2);
	* =>
		(a, ok1) := quants(q.l, pol, underall);
		(b, ok2) := quants(q.r, pol, underall);
		return (a+b, ok1 && ok2);
	}
}

#
# Possible worlds.  The premises hold, and the conclusion is to hold, in
# the actual world, w0; [] is true at a world if what follows is true at
# every world it sees, <> at some.  Enough worlds that an argument with
# a refuting case has one among them: in S5, where every world sees
# every other, one for each modal operator and the actual one (S5's
# small models: Ladner 1977); in KD, a tree as deep as the operators
# are nested, each world seeing one more for each operator, and those
# at the bottom themselves, so that every world sees some world (D).
#

MAXWORLDS: con 2048;
curworld := 0;
worldkids: array of list of int;
worldatom: array of int;	# K, KT: the atom saying a world is there
framecut: string;	# why the worlds tried are not enough, if they are not

# S5's necessities and possibilities, each an atom, true at every world
# or at none, with what defines it: so that nesting them does not
# multiply the formula by the worlds at each level.
s5atoms: list of (ref Q, int);
modaldefs: list of ref Form;

s5atom(q: ref Q, env: list of (string, string)): ref Form
{
	for(l := s5atoms; l != nil; l = tl l)
		if((hd l).t0 == q)
			return ref Form(Fatom, (hd l).t1, nil, nil, nil);
	i := atomof(sys->sprint("modal%d", len s5atoms + 1));
	meanings[i] = english(q);
	s5atoms = (q, i) :: s5atoms;
	f: ref Form;
	w := curworld;
	for(kl := worldkids[w]; kl != nil; kl = tl kl){
		curworld = hd kl;
		g := ground(q.l, env);
		if(f == nil)
			f = g;
		else if(q.op == Fnec)
			f = ref Form(Fand, 0, f, g, nil);
		else
			f = ref Form(For, 0, f, g, nil);
	}
	curworld = w;
	a := ref Form(Fatom, i, nil, nil, nil);
	modaldefs = ref Form(Fiff, 0, a, f, nil) :: modaldefs;
	return a;
}

framed := 0;	# the argument is read over worlds

frame(all: list of list of ref Stmt)
{
	framed = 0;
	worldkids = array[1] of { * => 0 :: nil };
	worldatom = nil;
	framecut = nil;
	s5atoms = nil;
	modaldefs = nil;
	nqueue = qhead0 = nmodal = 0;
	if(modal == Mclassical)
		return;
	n := 0;
	d := 0;
	for(a := all; a != nil; a = tl a)
		for(l := hd a; l != nil; l = tl l){
			n += modalops((hd l).q);
			if((k := modaldepth((hd l).q)) > d)
				d = k;
		}
	if(n == 0)
		return;
	framed = 1;
	if(modal == Ms5){
		nw := min(n + 1, MAXWORLDS);
		ws: list of int;
		for(i := nw-1; i >= 0; i--)
			ws = i :: ws;
		worldkids = array[nw] of { * => ws };
		return;
	}
	# K, KT, KD: worlds are made as the formulas ask for them
	nworlds = 1;
	wdepth = array[16] of { * => 0 };
	dmax = d + 1;
	relaxed = 0;
	wkids = array[16] of list of int;
	wexist = array[16] of { * => -1 };
	wnodes = array[16] of list of (ref Q, int, int);
	wserial = array[16] of { * => 0 };
	queue = array[16] of ref Entry;
	nqueue = qhead0 = 0;
}

#
# Worlds made as needed (K, KT, KD), after Sebastiani and Vescovi's
# Km2SAT.  A possibility or necessity met at a world, in a polarity
# (asserted or denied), is an atom of its own there, bound one way only,
# as that polarity needs: a possibility asserted, or a necessity
# denied, by a world of its own below that is there and where the body
# holds (or fails); a necessity asserted, or a possibility denied, by
# every world below that is there (and in KT the world itself).  A
# statement is grounded twice, asserted and denied (its dual), so that
# each question puts each the right way.  Once every formula met at a
# world is known, and so every world it sees, its atoms are bound;
# worlds are taken a level at a time, so that a world's are all made
# before then.  In KD a world that must see something sees a world that
# is there.
#

Entry: adt {
	w:	int;
	q:	ref Q;
	a:	int;
	pol:	int;
	child:	int;	# its own world below, if it is a witness; -1 if none
	own:	ref Form;	# KT: what it says of the world itself
	univ:	int;	# s5kd: a necessity held at every world there is
	bound:	int;	# the worlds it has been held at so far
	acc:	ref Form;	# what it says of them
};

nworlds := 0;
wdepth: array of int;	# s5kd: how many oughts below a world it is
dmax := 0;	# s5kd: worlds deeper than this are left free
relaxed := 0;	# s5kd: a world was left free, so a case found may not be one
wkids: array of list of int;
wexist: array of int;
wnodes: array of list of (ref Q, int, int);
wserial: array of int;
queue: array of ref Entry;
nqueue := 0;
qhead0 := 0;
nmodal := 0;

kentry(q: ref Q, nil: list of (string, string)): ref Form
{
	w := curworld;
	# s5kd's necessity and possibility are the same at every world: one
	# atom for each, kept with the actual world's
	alethic := modal == Mmix && !deontic(q);
	if(alethic)
		w = 0;
	pol := gpol;
	for(l := wnodes[w]; l != nil; l = tl l)
		if((hd l).t0 == q && (hd l).t1 == pol)
			return ref Form(Fatom, (hd l).t2, nil, nil, nil);
	a := atomof(sys->sprint("modal%d", ++nmodal));
	if(w == 0)
		meanings[a] = english(q);
	else
		meanings[a] = sys->sprint("in w%d, %s", w, english(q));
	wnodes[w] = (q, pol, a) :: wnodes[w];
	if(modal == Mmix && !alethic && wdepth[w] >= dmax){
		# s5kd: necessities held at every world reach the worlds an
		# ought makes, and make more: below dmax an ought is left free.
		# No case even so proves validity; a case found may need it
		relaxed = 1;
		return ref Form(Fatom, a, nil, nil, nil);
	}
	e := ref Entry(w, q, a, pol, -1, nil, 0, 0, nil);
	witness := q.op == Fpos && pol > 0 || q.op == Fnec && pol < 0;
	if(alethic){
		# a possibility's world is any world, seen from every one; a
		# necessity holds at every world, those made later too
		if(witness)
			e.child = newworld(-1);
		else
			e.univ = 1;
	}else if(witness)
		e.child = newworld(w);
	else if((modal == Mkd || modal == Mmix) && !wserial[w]){
		# a world that must see something sees a world
		wserial[w] = 1;
		newworld(w);
	}
	if(modal == Mkt)
		e.own = bodyat(e, w);
	if(nqueue == len queue){
		nq := array[2*len queue] of ref Entry;
		nq[0:] = queue;
		queue = nq;
	}
	queue[nqueue++] = e;
	return ref Form(Fatom, a, nil, nil, nil);
}

# What an entry needs of world x: its body, held or failed, by its
# polarity.
bodyat(e: ref Entry, x: int): ref Form
{
	(cw, gp) := (curworld, gpol);
	(curworld, gpol) = (x, e.pol);
	g := ground(e.q.l, nil);
	(curworld, gpol) = (cw, gp);
	if(e.pol < 0)
		g = ref Form(Fnot, 0, g, nil, nil);
	return g;
}

newworld(parent: int): int
{
	if(nworlds >= MAXWORLDS){
		# a case found among fewer worlds still refutes; but no
		# case found among them proves nothing
		framecut = sys->sprint("it needs more than %d worlds", MAXWORLDS);
		decided = 0;
		return -1;
	}
	if(nworlds == len wkids){
		n := 2*len wkids;
		nk := array[n] of list of int;
		nk[0:] = wkids;
		wkids = nk;
		ne := array[n] of { * => -1 };
		ne[0:] = wexist[0:nworlds];
		wexist = ne;
		nn := array[n] of list of (ref Q, int, int);
		nn[0:] = wnodes;
		wnodes = nn;
		ns := array[n] of { * => 0 };
		ns[0:] = wserial[0:nworlds];
		wserial = ns;
		nd := array[n] of { * => 0 };
		nd[0:] = wdepth[0:nworlds];
		wdepth = nd;
	}
	w := nworlds++;
	if(parent >= 0)
		wdepth[w] = wdepth[parent] + 1;
	wexist[w] = atomof(sys->sprint("world%d", w));
	meanings[wexist[w]] = sys->sprint("there is a world w%d", w);
	if(parent >= 0)
		wkids[parent] = w :: wkids[parent];
	return w;
}

# World x is there: the actual world always.
there(x: int): ref Form
{
	if(x == 0)
		return ref Form(Ftrue, 0, nil, nil, nil);
	return ref Form(Fatom, wexist[x], nil, nil, nil);
}

# Bind each world's possibilities and necessities, a level at a time.
modalclose()
{
	if(!kfamily())
		return;
	univ: list of ref Entry;
	for(;;){
		closequeue();
		for(i := 0; i < nqueue; i++)
			if(queue[i].univ && queue[i].bound == 0 && queue[i].acc == nil && !univmember(queue[i], univ))
				univ = queue[i] :: univ;
		more := 0;
		for(ul := univ; ul != nil; ul = tl ul){
			e := hd ul;
			while(e.bound < nworlds){
				x := e.bound++;
				g := ref Form(Fimp, 0, there(x), bodyat(e, x), nil);
				if(e.acc == nil)
					e.acc = g;
				else
					e.acc = ref Form(Fand, 0, e.acc, g, nil);
				more = 1;
			}
		}
		if(!more && qhead0 >= nqueue)
			break;
	}
	for(ul := univ; ul != nil; ul = tl ul){
		e := hd ul;
		a := ref Form(Fatom, e.a, nil, nil, nil);
		if(e.pol < 0)
			a = ref Form(Fnot, 0, a, nil, nil);
		f := e.acc;
		if(f == nil)
			f = ref Form(Ftrue, 0, nil, nil, nil);
		modaldefs = ref Form(Fimp, 0, a, f, nil) :: modaldefs;
	}
	curworld = 0;
	# KD: every world that sees any sees one that is there
	if(modal == Mkd || modal == Mmix)
		for(w := 0; w < nworlds; w++){
			d: ref Form;
			for(kl := wkids[w]; kl != nil; kl = tl kl){
				there := ref Form(Fatom, wexist[hd kl], nil, nil, nil);
				if(d == nil)
					d = there;
				else
					d = ref Form(For, 0, d, there, nil);
			}
			if(d != nil)
				modaldefs = d :: modaldefs;
		}
}

univmember(e: ref Entry, l: list of ref Entry): int
{
	for(; l != nil; l = tl l)
		if(hd l == e)
			return 1;
	return 0;
}

# Bind the entries met so far, a level at a time; s5kd's necessities are
# bound apart, at every world, once no more are made.
closequeue()
{
	for(; qhead0 < nqueue; qhead0++){
		e := queue[qhead0];
		if(e.univ)
			continue;
		f: ref Form;
		if(e.child >= 0 || e.q.op == Fpos && e.pol > 0 || e.q.op == Fnec && e.pol < 0){
			# a witness: its own world, there, where the body holds
			if(e.child >= 0)
				f = ref Form(Fand, 0, ref Form(Fatom, wexist[e.child], nil, nil, nil), bodyat(e, e.child), nil);
			if(e.own != nil){
				if(f == nil)
					f = e.own;
				else
					f = ref Form(For, 0, f, e.own, nil);
			}
			if(f == nil)
				f = neg(ref Form(Ftrue, 0, nil, nil, nil));
		}else{
			# every world below that is there
			f = e.own;
			for(kl := wkids[e.w]; kl != nil; kl = tl kl){
				g := ref Form(Fimp, 0, ref Form(Fatom, wexist[hd kl], nil, nil, nil), bodyat(e, hd kl), nil);
				if(f == nil)
					f = g;
				else
					f = ref Form(Fand, 0, f, g, nil);
			}
			if(f == nil)
				f = ref Form(Ftrue, 0, nil, nil, nil);
		}
		a := ref Form(Fatom, e.a, nil, nil, nil);
		if(e.pol < 0)
			a = ref Form(Fnot, 0, a, nil, nil);
		modaldefs = ref Form(Fimp, 0, a, f, nil) :: modaldefs;
	}
}

modalops(q: ref Q): int
{
	if(q == nil)
		return 0;
	n := 0;
	if(q.op == Fnec || q.op == Fpos)
		n = 1;
	return n + modalops(q.l) + modalops(q.r);
}

modaldepth(q: ref Q): int
{
	if(q == nil)
		return 0;
	a := modaldepth(q.l);
	if((b := modaldepth(q.r)) > a)
		a = b;
	if(q.op == Fnec || q.op == Fpos)
		a++;
	return a;
}

worldname(w: int): string
{
	case modal {
	Mkd =>	return sys->sprint(" in w%d, a world as it ought to be", w);
	Ms5 =>	return sys->sprint(" in w%d, another possible world", w);
	Mmix =>	return sys->sprint(" in w%d, another world", w);
	}
	return sys->sprint(" in w%d", w);
}

# Forget a reading, to read the file again.
reset()
{
	atoms = array[64] of string;
	meanings = array[64] of string;
	natoms = 0;
	preds = nil;
	consts = nil;
	nquant = 0;
	fresh = nil;
	decided = 1;
}

min(a, b: int): int
{
	if(a < b)
		return a;
	return b;
}

finish(all: list of list of ref Stmt)
{
	# all and some range over the individuals named and others enough
	# that, where the logic allows it, a case with no more individuals
	# than that refutes any argument that can be refuted at all
	(dec, nfresh) := classify(all);
	decided = dec;
	if(forcefresh >= 0)
		nfresh = forcefresh;
	lastfresh = nfresh;
	for(k := 1; k <= nfresh; k++){
		if(k == 1)
			addconst("another");
		else
			addconst("another" + string k);
	}
	consts = revs(consts);
	frame(all);
	curworld = 0;
	for(; all != nil; all = tl all)
		for(l := rev(hd all); l != nil; l = tl l){
			gpol = 1;
			f := ground((hd l).q, nil);
			if(kfamily()){
				# denied, grounded apart: possibilities and
				# necessities bound the other way
				gpol = -1;
				d := ref Form(Fnot, 0, ground((hd l).q, nil), nil, f);
				gpol = 1;
				f.dual = d;
			}
			(hd l).f = f;
		}
	modalclose();
	# atoms used and never said what they stand for
	for(pl := preds; pl != nil; pl = tl pl){
		pr := hd pl;
		if(pr.used && pr.line == 0){
			d := pr.name;
			if(pr.params != nil)
				d += "(x)";
			report(nil, "argue/undefined", sys->sprint("atom %s is used but not given a meaning (atom\t%s\t...)", pr.name, d));
		}
	}
}

isname(s: string): int
{
	if(s == nil)
		return 0;
	for(i := 0; i < len s; i++){
		c := s[i];
		if(!(c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c == '_' || i > 0 && c >= '0' && c <= '9'))
			return 0;
	}
	return 1;
}

alldigits(s: string): int
{
	if(s == nil)
		return 0;
	for(i := 0; i < len s; i++)
		if(s[i] < '0' || s[i] > '9')
			return 0;
	return 1;
}

atomof(a: string): int
{
	if(natoms == 0)
		atomhash = array[Nhash] of list of int;
	h := hashstr(a) % Nhash;
	for(l := atomhash[h]; l != nil; l = tl l)
		if(atoms[hd l] == a)
			return hd l;
	atomhash[h] = natoms :: atomhash[h];
	if(natoms == len atoms){
		na := array[2*len atoms] of string;
		na[0:] = atoms;
		atoms = na;
		nm := array[2*len meanings] of string;
		nm[0:] = meanings;
		meanings = nm;
	}
	atoms[natoms] = a;
	return natoms++;
}

#
# Formulas: iff := imp {<-> imp}; imp := or [-> imp];
# or := and {| and}; and := un {& un}; un := ! un | atom | ( iff )
#

ptext: string;
ppos: int;
perr: string;
bound: list of string;

parse(s: string): (ref Q, string)
{
	ptext = s;
	ppos = 0;
	perr = nil;
	bound = nil;
	f := piff();
	skip();
	if(perr == nil && ppos < len ptext)
		perr = sys->sprint("unexpected \"%s\"", ptext[ppos:]);
	if(perr != nil)
		return (nil, perr);
	return (f, nil);
}

skip()
{
	while(ppos < len ptext && (ptext[ppos] == ' ' || ptext[ppos] == '\t'))
		ppos++;
}

looking(t: string): int
{
	skip();
	if(ppos + len t <= len ptext && ptext[ppos:ppos+len t] == t){
		ppos += len t;
		return 1;
	}
	return 0;
}

piff(): ref Q
{
	f := pimp();
	while(perr == nil && (looking("<->") || looking("<=>") || looking("↔") || lookword("iff")))
		f = ref Q(Fiff, nil, nil, f, pimp());
	return f;
}

pimp(): ref Q
{
	f := por();
	if(perr == nil && (looking("->") || looking("=>") || looking("→") || lookword("implies")))
		f = ref Q(Fimp, nil, nil, f, pimp());
	return f;
}

por(): ref Q
{
	f := pand();
	while(perr == nil && (looking("||") || looking("|") || looking("∨") || lookword("or")))
		f = ref Q(For, nil, nil, f, pand());
	return f;
}

pand(): ref Q
{
	f := pun();
	while(perr == nil && (looking("&&") || looking("&") || looking("∧") || lookword("and")))
		f = ref Q(Fand, nil, nil, f, pun());
	return f;
}

# A quantifier written with its symbol: the variable, then : or .
# or nothing before the body.
quant(op: int): ref Q
{
	v := word();
	if(v == ""){
		perr = "a quantifier wants its variable";
		return nil;
	}
	if(!looking(":"))
		looking(".");
	return quantbody(op, v);
}

quantbody(op: int, v: string): ref Q
{
	if(modal != Mclassical){
		perr = "all and some are not decided in modal logic here: its arguments are propositional";
		return nil;
	}
	nquant++;
	ob := bound;
	bound = v :: bound;
	body := piff();
	bound = ob;
	return ref Q(op, v, nil, body, nil);
}

# A word as an operator (and, or, not, implies, iff): only whole.
lookword(w: string): int
{
	skip();
	e := ppos + len w;
	if(e > len ptext || ptext[ppos:e] != w || e < len ptext && isword(ptext[e]))
		return 0;
	ppos = e;
	return 1;
}

word(): string
{
	skip();
	s := ppos;
	while(ppos < len ptext){
		c := ptext[ppos];
		if(!(c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c == '_' || c >= '0' && c <= '9'))
			break;
		ppos++;
	}
	return ptext[s:ppos];
}

pun(): ref Q
{
	if(perr != nil)
		return nil;
	if(looking("!") || looking("~") || looking("¬") || lookword("not"))
		return ref Q(Fnot, nil, nil, pun(), nil);
	# necessarily, possibly; in deontic logic ought, permitted; in
	# s5kd both, ought and permitted marked deontic ("d")
	deon := modal == Mkd || modal == Mmix;
	# O and P as logicians write them: in these logics they are not atoms
	ought := deon && (lookword("ought") || lookword("O"));
	nec := ought || looking("[]") || looking("□") || lookword("nec") || lookword("necessarily");
	perm := !nec && deon && (lookword("permitted") || lookword("P"));
	if(nec || perm || looking("<>") || looking("◇") || lookword("pos") || lookword("possibly")){
		if(modal == Mclassical){
			perr = "necessity and possibility need a line logic s5, ought and permitted logic kd, both logic s5kd";
			return nil;
		}
		op := Fpos;
		if(nec)
			op = Fnec;
		kind: string;
		if(modal == Mkd || ought || perm)
			kind = "d";
		return ref Q(op, kind, nil, pun(), nil);
	}
	# ∀x: ..., ∃x. ...
	if(looking("∀"))
		return quant(Fall);
	if(looking("∃"))
		return quant(Fsome);
	if(looking("(")){
		f := piff();
		if(perr == nil && !looking(")"))
			perr = "a ( is not closed";
		return f;
	}
	s := ppos;
	a := word();
	if(a == ""){
		if(ppos >= len ptext)
			perr = "the formula ends too soon";
		else
			perr = sys->sprint("unexpected \"%s\"", ptext[ppos:]);
		return nil;
	}
	# all x: ..., some x: ...; the body runs as far as it can
	if(a == "all" || a == "some" || a == "every" || a == "each" || a == "forall" || a == "exists"){
		save := ppos;
		v := word();
		if(v != "" && (looking(":") || looking("."))){
			op := Fall;
			if(a == "some" || a == "exists")
				op = Fsome;
			return quantbody(op, v);
		}
		ppos = save;
	}
	if(a == "true" || a == "T")
		return ref Q(Ftrue, nil, nil, nil, nil);
	# an atom, perhaps of individuals: audited(web1), trusts(x, y)
	args: list of string;
	if(looking("(")){
		for(;;){
			t := word();
			if(t == ""){
				perr = sys->sprint("%s( wants the names of individuals, separated by commas", a);
				return nil;
			}
			if(!member(t, bound))
				addconst(t);
			args = t :: args;
			if(looking(")"))
				break;
			if(!looking(",")){
				perr = sys->sprint("%s(: a , or ) was wanted", a);
				return nil;
			}
		}
		args = revs(args);
	}
	pr := predof(a);
	pr.used = 1;
	# the same name with different numbers of individuals is two
	# predicates the argument confuses
	if(pr.line == 0 && pr.arity >= 0 && pr.arity != len args){
		perr = sys->sprint("%s is used with %s and with %d", a, individuals(pr.arity), len args);
		ppos = s;
		return nil;
	}
	pr.arity = len args;
	if(pr.line != 0 && len pr.params != len args){
		perr = sys->sprint("%s takes %s, not %d", a, individuals(len pr.params), len args);
		ppos = s;
		return nil;
	}
	return ref Q(Fatom, a, args, nil, nil);
}

reserved := array[] of { "true", "T", "not", "and", "or", "implies", "iff" };

# atom audited(x): the predicate's name and its parameters
atomdecl(d: string): (string, list of string, string)
{
	ptext = d;
	ppos = 0;
	n := word();
	if(n == "" || !isname(n))
		return (nil, nil, sys->sprint("\"%s\" cannot be an atom's name: letters, digits and _ only", d));
	# a word of the notation would be read as that, not as the atom
	for(r := 0; r < len reserved; r++)
		if(n == reserved[r])
			return (nil, nil, sys->sprint("\"%s\" cannot be an atom's name: it is a word of the notation", n));
	params: list of string;
	if(looking("(")){
		for(;;){
			t := word();
			if(t == "")
				return (nil, nil, sys->sprint("%s: the parameters are names, separated by commas", d));
			params = t :: params;
			if(looking(")"))
				break;
			if(!looking(","))
				return (nil, nil, sys->sprint("%s: a , or ) was wanted", d));
		}
	}
	skip();
	if(ppos < len ptext)
		return (nil, nil, sys->sprint("unexpected \"%s\" in %s", ptext[ppos:], d));
	return (n, revs(params), nil);
}

individuals(n: int): string
{
	if(n == 1)
		return "1 individual";
	return sys->sprint("%d individuals", n);
}

predof(n: string): ref Pred
{
	if(preds == nil)
		predhash = array[Nhash] of list of ref Pred;
	h := hashstr(n) % Nhash;
	for(l := predhash[h]; l != nil; l = tl l)
		if((hd l).name == n)
			return hd l;
	p := ref Pred(n, nil, "", 0, 0, -1);
	preds = p :: preds;
	predhash[h] = p :: predhash[h];
	return p;
}

predhash: array of list of ref Pred;	# by name's hash: preds

addconst(c: string)
{
	if(!member(c, consts))
		consts = c :: consts;
}

member(s: string, l: list of string): int
{
	for(; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

revs(l: list of string): list of string
{
	r: list of string;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

# The formula with all and some taken over the individuals: a
# conjunction or a disjunction of the body, once for each.
# The polarity of what is being grounded: 1 where it is asserted, -1
# where denied.  It matters only to K, KT and KD, whose possibilities
# and necessities are bound one way, as their polarity needs.
gpol := 1;

kfamily(): int
{
	return modal == Mk || modal == Mkt || modal == Mkd || modal == Mmix;
}

# Is q ought or permitted, not necessarily or possibly?
deontic(q: ref Q): int
{
	return q.name == "d";
}

ground(q: ref Q, env: list of (string, string)): ref Form
{
	if(kfamily())
		case q.op {
		Fnot =>
			gpol = -gpol;
			g := ground(q.l, env);
			gpol = -gpol;
			return ref Form(Fnot, 0, g, nil, nil);
		Fimp =>
			gpol = -gpol;
			a := ground(q.l, env);
			gpol = -gpol;
			return ref Form(Fimp, 0, a, ground(q.r, env), nil);
		Fiff =>
			if(modalops(q) > 0){
				# each side both ways: (a -> b) & (b -> a)
				gpol = -gpol;
				a1 := ground(q.l, env);
				b2 := ground(q.r, env);
				gpol = -gpol;
				b1 := ground(q.r, env);
				a2 := ground(q.l, env);
				return ref Form(Fand, 0, ref Form(Fimp, 0, a1, b1, nil), ref Form(Fimp, 0, b2, a2, nil), nil);
			}
		}
	case q.op {
	Fatom =>
		key := q.name;
		vals: list of string;
		if(q.args != nil){
			key += "(";
			sep := "";
			for(a := q.args; a != nil; a = tl a){
				v := inst(hd a, env);
				vals = v :: vals;
				key += sep + v;
				sep = ",";
			}
			key += ")";
			vals = revs(vals);
		}
		if(curworld > 0)
			key += sys->sprint("@w%d", curworld);
		i := atomof(key);
		if(meanings[i] == nil){
			meanings[i] = meaningof(predof(q.name), vals, key);
			if(curworld > 0)
				meanings[i] += worldname(curworld);
		}
		for(vl := vals; vl != nil; vl = tl vl)
			if(isanother(hd vl))
				markfresh(i);
		return ref Form(Fatom, i, nil, nil, nil);
	Ftrue =>
		return ref Form(Ftrue, 0, nil, nil, nil);
	Fnot =>
		return ref Form(Fnot, 0, ground(q.l, env), nil, nil);
	Fnec or Fpos =>
		# in S5 the same at every world: an atom of its own, defined once
		if(modal == Ms5)
			return s5atom(q, env);
		# K, KT, KD: an atom for it at this world, defined once the
		# worlds this one sees are all made
		return kentry(q, env);
	Fall or Fsome =>
		f: ref Form;
		for(c := consts; c != nil; c = tl c){
			g := ground(q.l, (q.name, hd c) :: env);
			if(f == nil)
				f = g;
			else if(q.op == Fall)
				f = ref Form(Fand, 0, f, g, nil);
			else
				f = ref Form(For, 0, f, g, nil);
		}
		if(f == nil){
			f = ref Form(Ftrue, 0, nil, nil, nil);
			if(q.op == Fsome)
				f = neg(f);
		}
		return f;
	* =>
		r: ref Form;
		if(q.r != nil)
			r = ground(q.r, env);
		return ref Form(q.op, 0, ground(q.l, env), r, nil);
	}
}

namedcount(): int
{
	n := 0;
	for(l := consts; l != nil; l = tl l)
		if(!isanother(hd l))
			n++;
	return n;
}

isanother(v: string): int
{
	if(len v < 7 || v[0:7] != "another")
		return 0;
	for(i := 7; i < len v; i++)
		if(v[i] < '0' || v[i] > '9')
			return 0;
	return 1;
}

markfresh(i: int)
{
	if(fresh == nil || i >= len fresh){
		n := array[len atoms] of { * => 0 };
		if(fresh != nil)
			n[0:] = fresh;
		fresh = n;
	}
	fresh[i] = 1;
}

isfresh(i: int): int
{
	return fresh != nil && i < len fresh && fresh[i];
}

anyfresh(f: ref Form): int
{
	if(f == nil)
		return 0;
	if(f.op == Fatom)
		return isfresh(f.atom);
	return anyfresh(f.l) || anyfresh(f.r);
}

lookup(v: string, env: list of (string, string)): string
{
	for(; env != nil; env = tl env){
		(n, c) := hd env;
		if(n == v)
			return c;
	}
	return v;
}

# What a ground atom means: the predicate's meaning with its
# parameters replaced by the individuals (x was audited: web1 was
# audited).
meaningof(p: ref Pred, vals: list of string, key: string): string
{
	if(p.line == 0)
		return nil;
	m := p.meaning;
	if(m == "")
		return key;
	for(ps := p.params; ps != nil && vals != nil; ps = tl ps){
		m = subst(m, hd ps, hd vals);
		vals = tl vals;
	}
	return m;
}

subst(s, w, by: string): string
{
	r := "";
	i := 0;
	while(i < len s){
		if(i + len w <= len s && s[i:i+len w] == w &&
		   (i == 0 || !isword(s[i-1])) && (i+len w == len s || !isword(s[i+len w]))){
			r += by;
			i += len w;
		}else
			r[len r] = s[i++];
	}
	return r;
}

isword(c: int): int
{
	return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == '_';
}

fstring(f: ref Form): string
{
	case f.op {
	Fatom =>	return atoms[f.atom];
	Ftrue =>	return sym("⊤", "true");
	Fnot =>	return sym("¬", "!") + fstring(f.l);
	Fand =>	return "(" + fstring(f.l) + sym(" ∧ ", " & ") + fstring(f.r) + ")";
	For =>	return "(" + fstring(f.l) + sym(" ∨ ", " | ") + fstring(f.r) + ")";
	Fimp =>	return "(" + fstring(f.l) + sym(" → ", " -> ") + fstring(f.r) + ")";
	Fiff =>	return "(" + fstring(f.l) + sym(" ↔ ", " <-> ") + fstring(f.r) + ")";
	}
	return "?";
}

#
# A formula as it is shown: in logic's own symbols, ¬ ∧ ∨ → ↔ ∀ ∃,
# necessity and possibility □ ◇, obligation and permission O and P,
# whatever the logic, so that a formula never depends on its file's
# logic line to be read; with -A, as a logic file may write it, in
# ASCII, the deontic operators as ought and permitted.  Brackets only
# where the operators' binding needs them.
#

sym(u, a: string): string
{
	if(aflag)
		return a;
	return u;
}

qshow(q: ref Q): string
{
	if(q == nil)
		return "";
	case q.op {
	Fatom =>
		s := q.name;
		if(q.args != nil){
			s += "(";
			for(a := q.args; a != nil; a = tl a){
				s += hd a;
				if(tl a != nil)
					s += ", ";
			}
			s += ")";
		}
		return s;
	Ftrue =>
		return sym("⊤", "true");
	Fnot =>
		return sym("¬", "!") + qarg(q.l);
	Fnec or Fpos =>
		# O and P are letters: a space keeps them off an atom's name
		if(deontic(q)){
			o := sym("O", "ought ");
			if(q.op == Fpos)
				o = sym("P", "permitted ");
			if(!aflag && !qbinary(q.l))
				o += " ";
			return o + qarg(q.l);
		}
		if(q.op == Fnec)
			return sym("□", "[]") + qarg(q.l);
		return sym("◇", "<>") + qarg(q.l);
	Fall =>
		return sym("∀" + q.name + " ", "all " + q.name + ": ") + qarg(q.l);
	Fsome =>
		return sym("∃" + q.name + " ", "some " + q.name + ": ") + qarg(q.l);
	Fand =>
		return qside(q.l, q.op) + sym(" ∧ ", " & ") + qside(q.r, q.op);
	For =>
		return qside(q.l, q.op) + sym(" ∨ ", " | ") + qside(q.r, q.op);
	Fimp =>
		return qside(q.l, q.op) + sym(" → ", " -> ") + qside(q.r, q.op);
	Fiff =>
		return qside(q.l, q.op) + sym(" ↔ ", " <-> ") + qside(q.r, q.op);
	}
	return "?";
}

# What an operator of one place applies to: bracketed if it has two.
qarg(q: ref Q): string
{
	if(qbinary(q))
		return "(" + qshow(q) + ")";
	return qshow(q);
}

# A side of a connective: bracketed unless it binds tighter, or is
# the same ∧ or ∨, whose grouping does not matter.
qside(q: ref Q, op: int): string
{
	if(!qbinary(q) || qbind(q.op) > qbind(op) || q.op == op && (op == Fand || op == For))
		return qshow(q);
	return "(" + qshow(q) + ")";
}

qbinary(q: ref Q): int
{
	return q.op == Fand || q.op == For || q.op == Fimp || q.op == Fiff;
}

qbind(op: int): int
{
	case op {
	Fand =>	return 4;
	For =>	return 3;
	Fimp =>	return 2;
	Fiff =>	return 1;
	}
	return 5;
}

#
# Deciding: a formula's value under a partial assignment (-1 unset)
# is 0, 1, or U while it depends on what is unset.  The search sets
# one atom at a time, abandoning a branch the moment a formula is
# false in it, so arguments of a few dozen atoms take no time.
#

U: con 2;

val(f: ref Form, a: array of int): int
{
	case f.op {
	Fatom =>
		if(a[f.atom] < 0)
			return U;
		return a[f.atom];
	Ftrue =>
		return 1;
	Fnot =>
		v := val(f.l, a);
		if(v == U)
			return U;
		return !v;
	Fand =>
		l := val(f.l, a);
		if(l == 0)
			return 0;
		r := val(f.r, a);
		if(r == 0)
			return 0;
		if(l == U || r == U)
			return U;
		return 1;
	For =>
		l := val(f.l, a);
		if(l == 1)
			return 1;
		r := val(f.r, a);
		if(r == 1)
			return 1;
		if(l == U || r == U)
			return U;
		return 0;
	Fimp =>
		l := val(f.l, a);
		if(l == 0)
			return 1;
		r := val(f.r, a);
		if(r == 1)
			return 1;
		if(l == U || r == U)
			return U;
		return 0;
	Fiff =>
		l := val(f.l, a);
		if(l == U)
			return U;
		r := val(f.r, a);
		if(r == U)
			return U;
		return l == r;
	}
	return U;
}

# An assignment making every formula true, or nil if there is none.
# A case in which every formula is true, or nil if there is none: the
# first, trying the atoms in order and each true before false, and set
# only as far as it takes to make every formula true, the rest left
# open (-1); "nothing else is true", a case reads.  Found by a CDCL
# search (Marques-Silva and Sakallah's GRASP, as in MiniSat) over the
# formulas in clauses (Tseitin), which keeps to that order (decisions
# atom by atom, true first, no restarts) so that the case is the one a
# plain search would find; past Budget conflicts it gives that up for
# speed (activity and restarts), on searches no plain one would finish.
sat(fs: list of ref Form): array of int
{
	if(!satisfiable(fs))
		return nil;
	return found();
}

# Whether there is a case in which every formula is true.
satisfiable(fs: list of ref Form): int
{
	all := appendforms(fs, modaldefs);
	# the atoms the formulas use, in order, as the first variables:
	# the search over them is the one over every atom (an atom no
	# clause holds is only ever decided true, at a level of its own
	# that nothing follows from), and its cost is the formulas', not
	# the vocabulary's
	ua := usedatoms(all);
	k := len ua;
	for(i := 0; i < k; i++)
		cmap[ua[i]] = i;
	satinit(all, k);
	for(l := modaldefs; l != nil && !unsat; l = tl l)
		top(hd l);
	for(l = fs; l != nil && !unsat; l = tl l)
		top(hd l);
	r := !unsat && solve();
	compact = 0;
	(sfs, sua) = (fs, ua);
	return r;
}

sfs: list of ref Form;	# what satisfiable last found a case for
sua: array of int;	# and the atoms they use, in order

# The case satisfiable found, set as far as it takes to make every
# formula true, atom by atom: an atom no formula uses is true, as the
# search left it.
found(): array of int
{
	return found1(sfs);
}

# A case made as small as it will go: each atom, a world's being there
# among them, false wherever every formula still holds, the latest first.
smallest(a: array of int, fs: list of ref Form): array of int
{
	for(i := 0; i < len a; i++)
		if(a[i] < 0)
			a[i] = 0;
	for(changed := 1; changed; ){
		changed = 0;
		for(i = len a - 1; i >= 0; i--){
			if(a[i] != 1)
				continue;
			a[i] = 0;
			if(allhold(fs, a))
				changed = 1;
			else
				a[i] = 1;
		}
	}
	return a;
}

# The same, set far enough to make what binds the worlds true as well.
foundall(): array of int
{
	return found1(appendforms(sfs, modaldefs));
}

found1(fs: list of ref Form): array of int
{
	(ua, k) := (sua, len sua);
	i: int;
	a := array[natoms] of { * => -1 };
	for(i = 0; ; i++){
		if(allhold(fs, a))
			break;
		if(i >= k){
			for(j := 0; j < natoms; j++)
				if(a[j] < 0)
					a[j] = 1;
			break;
		}
		for(j := 0; j < ua[i]; j++)
			if(a[j] < 0)
				a[j] = 1;
		a[ua[i]] = asg[i];
	}
	return a;
}

# The atoms the formulas use, in order.
usedatoms(all: list of ref Form): array of int
{
	if(len ustamp < natoms){
		ustamp = array[len atoms] of { * => 0 };
		cmap = array[len atoms] of int;
		ucur = 0;
	}
	ucur++;
	used: list of int;
	k := 0;
	for(l := all; l != nil; l = tl l)
		(used, k) = useatoms(hd l, used, k, 1);
	ua := array[k] of int;
	i := 0;
	if(16*k < natoms){
		for(i = k-1; used != nil; used = tl used)
			ua[i--] = hd used;
		for(i = 1; i < k; i++)
			for(j := i; j > 0 && ua[j] < ua[j-1]; j--)
				(ua[j], ua[j-1]) = (ua[j-1], ua[j]);
	}else{
		i = 0;
		for(j := 0; j < natoms; j++)
			if(ustamp[j] == ucur)
				ua[i++] = j;
	}
	return ua;
}

ustamp: array of int;		# by atom: ucur if the formulas use it
ucur := 0;
cmap: array of int;		# by atom: its variable, while compact
compact := 0;

# A denial put into clauses may be a statement's dual (neg), so its
# atoms are counted too; one counted that no clause holds is harmless,
# being decided true as one not counted would be.
useatoms(f: ref Form, l: list of int, k, duals: int): (list of int, int)
{
	for(; f != nil; f = f.r){
		if(f.op == Fatom && ustamp[f.atom] != ucur){
			ustamp[f.atom] = ucur;
			l = f.atom :: l;
			k++;
		}
		if(duals && f.dual != nil)
			(l, k) = useatoms(f.dual, l, k, 0);
		(l, k) = useatoms(f.l, l, k, duals);
	}
	return (l, k);
}

# An atom's literal.
atomlit(a: int): int
{
	case compact {
	1 =>
		return 2*cmap[a];
	2 =>
		# an asker's atoms, by halves
		(lo, hi) := (0, len cua);
		while(lo < hi){
			m := (lo+hi)/2;
			if(cua[m] < a)
				lo = m+1;
			else
				hi = m;
		}
		if(lo == len cua || cua[lo] != a)
			fatal("internal error: an atom the asker was not given");
		return 2*lo;
	}
	return 2*a;
}

cua: array of int;		# an asker's atoms, in order

#
appendforms(a, b: list of ref Form): list of ref Form
{
	if(a == nil)
		return b;
	return hd a :: appendforms(tl a, b);
}

# The CDCL search.  A literal is 2v for variable v, 2v+1 for its
# denial; variables 0 to natoms-1 are the atoms, the rest stand for
# the formulas' parts.
#

Budget: con 10000;

clauses: array of array of int;
nclauses := 0;
watches: array of array of int;	# by literal: the clauses watching it
nwatch: array of int;
asg: array of int;		# by variable: 1, 0, or -1 unset
vlevel: array of int;
reason: array of int;		# the clause that set it, -1 if decided
phase: array of int;
activity: array of real;
actinc := 1.0;
trail: array of int;
ntrail := 0;
qhead := 0;
lim: array of int;		# by level: where it starts on the trail
dlevel := 0;
nvars := 0;
unsat := 0;
heur := 0;
seen: array of int;
truelit := -1;
vnext := 0;		# every variable before it is set

satinit(fs: list of ref Form, nat: int)
{
	n := nat + 1;
	for(l := fs; l != nil; l = tl l)
		n += nodes(hd l);
	asg = array[n] of { * => -1 };
	vlevel = array[n] of { * => 0 };
	reason = array[n] of { * => -1 };
	phase = array[n] of { * => 1 };
	activity = array[n] of { * => 0.0 };
	seen = array[n] of { * => 0 };
	trail = array[n] of int;
	lim = array[n+1] of { * => 0 };
	watches = array[2*n] of array of int;
	nwatch = array[2*n] of { * => 0 };
	clauses = array[4*n+16] of array of int;
	nclauses = 0;
	nvars = nat;
	compact = nat != natoms;
	ntrail = qhead = dlevel = vnext = 0;
	unsat = heur = 0;
	actinc = 1.0;
	truelit = -1;
}

nodes(f: ref Form): int
{
	if(f == nil)
		return 0;
	return 1 + nodes(f.l) + nodes(f.r);
}

newvar(): int
{
	return nvars++;
}

# A formula that must hold: a conjunction as its parts, a disjunction
# of literals as one clause, anything else as the literal for it.
top(f: ref Form)
{
	if(f.op == Fand){
		top(f.l);
		top(f.r);
		return;
	}
	(ok, lits) := clauseof(f, nil);
	if(ok){
		addclause(lits, 0);
		return;
	}
	addclause(tseitin(f) :: nil, 0);
}

clauseof(f: ref Form, l: list of int): (int, list of int)
{
	case f.op {
	Fatom =>
		return (1, atomlit(f.atom) :: l);
	Fnot =>
		if(f.l.op == Fatom)
			return (1, atomlit(f.l.atom)+1 :: l);
	For =>
		(ok, l2) := clauseof(f.l, l);
		if(ok)
			return clauseof(f.r, l2);
	Fimp =>
		(ok, l2) := clauseof(neg(f.l), l);
		if(ok)
			return clauseof(f.r, l2);
	}
	return (0, nil);
}

# The literal for a formula, its meaning fixed by clauses.
tseitin(f: ref Form): int
{
	case f.op {
	Fatom =>
		return atomlit(f.atom);
	Ftrue =>
		if(truelit < 0){
			truelit = 2*newvar();
			addclause(truelit :: nil, 0);
		}
		return truelit;
	Fnot =>
		return tseitin(f.l) ^ 1;
	}
	a := tseitin(f.l);
	b := tseitin(f.r);
	x := 2*newvar();
	case f.op {
	Fand =>
		addclause(x^1 :: a :: nil, 0);
		addclause(x^1 :: b :: nil, 0);
		addclause(x :: a^1 :: b^1 :: nil, 0);
	For or Fimp =>
		if(f.op == Fimp)
			a ^= 1;
		addclause(x^1 :: a :: b :: nil, 0);
		addclause(x :: a^1 :: nil, 0);
		addclause(x :: b^1 :: nil, 0);
	Fiff =>
		addclause(x^1 :: a^1 :: b :: nil, 0);
		addclause(x^1 :: a :: b^1 :: nil, 0);
		addclause(x :: a :: b :: nil, 0);
		addclause(x :: a^1 :: b^1 :: nil, 0);
	}
	return x;
}

litval(l: int): int
{
	v := asg[l>>1];
	if(v < 0)
		return -1;
	return v ^ (l & 1);
}

# A clause of the problem (learnt 0), at level 0; or a learnt one,
# whose first literal is to be set by it.  The index, -1 if none kept.
addclause(lits: list of int, learnt: int): int
{
	if(unsat)
		return -1;
	c: array of int;
	if(learnt){
		c = array[len lits] of int;
		for(i := 0; lits != nil; lits = tl lits)
			c[i++] = hd lits;
	}else{
		# the literals not yet false, and none twice; a clause with
		# both a literal and its denial always holds
		keep: list of int;
		for(; lits != nil; lits = tl lits){
			x := hd lits;
			if(litval(x) == 1 || inints(x^1, keep))
				return -1;
			if(litval(x) == 0 || inints(x, keep))
				continue;
			keep = x :: keep;
		}
		if(keep == nil){
			unsat = 1;
			return -1;
		}
		if(tl keep == nil){
			enqueue(hd keep, -1);
			if(propagate() >= 0)
				unsat = 1;
			return -1;
		}
		c = array[len keep] of int;
		for(i := 0; keep != nil; keep = tl keep)
			c[i++] = hd keep;
	}
	if(nclauses == len clauses){
		nc := array[2*len clauses] of array of int;
		nc[0:] = clauses;
		clauses = nc;
	}
	ci := nclauses++;
	clauses[ci] = c;
	if(len c >= 2){
		watch(c[0], ci);
		watch(c[1], ci);
	}
	return ci;
}

inints(x: int, l: list of int): int
{
	for(; l != nil; l = tl l)
		if(hd l == x)
			return 1;
	return 0;
}

watch(lit, ci: int)
{
	w := watches[lit];
	n := nwatch[lit];
	if(w == nil || n == len w){
		nw := array[2*n+4] of int;
		if(n > 0)
			nw[0:] = w[0:n];
		watches[lit] = w = nw;
	}
	w[n] = ci;
	nwatch[lit] = n+1;
}

enqueue(lit, why: int)
{
	v := lit >> 1;
	asg[v] = (lit & 1) ^ 1;
	vlevel[v] = dlevel;
	reason[v] = why;
	trail[ntrail++] = lit;
}

# Set what the clauses force; the index of a clause made false, or -1.
propagate(): int
{
	while(qhead < ntrail){
		fl := trail[qhead++] ^ 1;	# the literal now false
		ws := watches[fl];
		n := nwatch[fl];
		j := 0;
		for(i := 0; i < n; i++){
			ci := ws[i];
			c := clauses[ci];
			if(c[0] == fl){
				c[0] = c[1];
				c[1] = fl;
			}
			if(litval(c[0]) == 1){
				ws[j++] = ci;
				continue;
			}
			moved := 0;
			for(k := 2; k < len c; k++)
				if(litval(c[k]) != 0){
					c[1] = c[k];
					c[k] = fl;
					watch(c[1], ci);
					moved = 1;
					break;
				}
			if(moved)
				continue;
			ws[j++] = ci;
			if(litval(c[0]) == 0){
				for(i++; i < n; i++)
					ws[j++] = ws[i];
				nwatch[fl] = j;
				qhead = ntrail;
				return ci;
			}
			enqueue(c[0], ci);
		}
		nwatch[fl] = j;
	}
	return -1;
}

# The clause a conflict teaches (its first literal to be set) and the
# level to go back to: the first unique implication point.
analyze(confl: int): (list of int, int)
{
	learnt: list of int;
	pathc := 0;
	p := -1;
	idx := ntrail - 1;
	bt := 0;
	for(;;){
		c := clauses[confl];
		for(i := 0; i < len c; i++){
			q := c[i];
			v := q >> 1;
			if(p >= 0 && v == p >> 1)
				continue;
			if(seen[v] || vlevel[v] == 0)
				continue;
			seen[v] = 1;
			bump(v);
			if(vlevel[v] == dlevel)
				pathc++;
			else{
				learnt = q :: learnt;
				if(vlevel[v] > bt)
					bt = vlevel[v];
			}
		}
		while(!seen[trail[idx] >> 1])
			idx--;
		p = trail[idx--];
		seen[p >> 1] = 0;
		pathc--;
		if(pathc <= 0)
			break;
		confl = reason[p >> 1];
	}
	for(l := learnt; l != nil; l = tl l)
		seen[hd l >> 1] = 0;
	# the literal at the level gone back to second, to be watched
	second: list of int;
	rest: list of int;
	for(l = learnt; l != nil; l = tl l)
		if(second == nil && vlevel[hd l >> 1] == bt)
			second = hd l :: nil;
		else
			rest = hd l :: rest;
	if(second != nil)
		rest = hd second :: rest;
	return ((p ^ 1) :: rest, bt);
}

bump(v: int)
{
	activity[v] += actinc;
	if(activity[v] > 1e100){
		for(i := 0; i < nvars; i++)
			activity[i] *= 1e-100;
		actinc *= 1e-100;
	}
}

backtrack(level: int)
{
	if(dlevel <= level)
		return;
	for(i := ntrail - 1; i >= lim[level+1]; i--){
		v := trail[i] >> 1;
		phase[v] = asg[v];
		asg[v] = -1;
		reason[v] = -1;
		if(v < vnext)
			vnext = v;
	}
	ntrail = qhead = lim[level+1];
	dlevel = level;
}

# The next variable to decide: in order, or once that has been given
# up, the most active.
choose(): int
{
	if(!heur){
		for(v := vnext; v < nvars; v++)
			if(asg[v] < 0){
				vnext = v;
				return v;
			}
		vnext = nvars;
		return -1;
	}
	best := -1;
	for(v := 0; v < nvars; v++)
		if(asg[v] < 0 && (best < 0 || activity[v] > activity[best]))
			best = v;
	return best;
}

solve(): int
{
	conflicts := 0;
	restart := 100;
	if(propagate() >= 0)
		return 0;
	for(;;){
		confl := propagate();
		if(confl >= 0){
			conflicts++;
			if(dlevel == 0)
				return 0;
			(learnt, bt) := analyze(confl);
			backtrack(bt);
			if(tl learnt == nil)
				enqueue(hd learnt, -1);
			else
				enqueue(hd learnt, addclause(learnt, 1));
			actinc *= 1.05;
			if(!heur && conflicts > Budget)
				heur = 1;
			if(heur && conflicts >= restart){
				backtrack(0);
				restart += restart/2 + 100;
			}
			continue;
		}
		v := choose();
		if(v < 0)
			return 1;
		dlevel++;
		lim[dlevel] = ntrail;
		lit := 2*v;
		if(heur && phase[v] == 0)
			lit++;
		enqueue(lit, -1);
	}
}

# A formula's denial: its own, where the modal logic grounds denials
# apart (a statement's dual); through and, or and not to those; else
# not and the formula.
neg(f: ref Form): ref Form
{
	if(f.dual != nil)
		return f.dual;
	if(hasdual(f))
		case f.op {
		Fand =>	return ref Form(For, 0, neg(f.l), neg(f.r), nil);
		For =>	return ref Form(Fand, 0, neg(f.l), neg(f.r), nil);
		Fnot =>	return f.l;
		}
	return ref Form(Fnot, 0, f, nil, nil);
}

hasdual(f: ref Form): int
{
	if(f == nil)
		return 0;
	return f.dual != nil || hasdual(f.l) || hasdual(f.r);
}

forms(l: list of ref Stmt): list of ref Form
{
	r: list of ref Form;
	for(; l != nil; l = tl l)
		r = (hd l).f :: r;
	return r;
}

# Whether fs entail c: no case where all of fs hold and c fails.
entails(fs: list of ref Form, c: ref Form): int
{
	return !satisfiable(neg(c) :: fs);
}

# Questions put many times over to one set of formulas, each time to
# some of them: can they all be true together?  Each formula holds
# where its guard, a variable of its own, does; a question assumes the
# guards of the formulas it is about and searches (MiniSat's
# assumptions), so the formulas go into clauses once and what one
# question learns serves the rest.  It answers only yes or no, which is
# a fact of logic and so the same as sat's; the case sat gives, the
# plainest, is sat's alone.  The solver's state is kept here between
# questions, and sat may run between them.
Asker: adt {
	clauses: array of array of int;
	nclauses: int;
	watches: array of array of int;
	nwatch: array of int;
	asg, vlevel, reason, phase, seen, trail, lim: array of int;
	activity: array of real;
	actinc: real;
	ntrail, qhead, dlevel, nvars, unsat, heur, truelit, vnext: int;
	ua: array of int;	# the atoms of the formulas it may be given
};

# An asker for formulas over the atoms of fs (and none other).
asker(fs: list of ref Form): ref Asker
{
	ua := usedatoms(appendforms(fs, modaldefs));
	satinit(nil, len ua);
	(compact, cua) = (2, ua);
	for(l := modaldefs; l != nil && !unsat; l = tl l){
		grow(nodes(hd l));
		top(hd l);
	}
	s := ref Asker;
	s.ua = ua;
	stash(s);
	return s;
}

stash(s: ref Asker)
{
	(s.clauses, s.nclauses, s.watches, s.nwatch) = (clauses, nclauses, watches, nwatch);
	(s.asg, s.vlevel, s.reason, s.phase, s.seen, s.trail, s.lim) = (asg, vlevel, reason, phase, seen, trail, lim);
	(s.activity, s.actinc) = (activity, actinc);
	(s.ntrail, s.qhead, s.dlevel, s.nvars, s.unsat, s.heur, s.truelit, s.vnext) = (ntrail, qhead, dlevel, nvars, unsat, heur, truelit, vnext);
	compact = 0;
}

unstash(s: ref Asker)
{
	(clauses, nclauses, watches, nwatch) = (s.clauses, s.nclauses, s.watches, s.nwatch);
	(asg, vlevel, reason, phase, seen, trail, lim) = (s.asg, s.vlevel, s.reason, s.phase, s.seen, s.trail, s.lim);
	(activity, actinc) = (s.activity, s.actinc);
	(ntrail, qhead, dlevel, nvars, unsat, heur, truelit, vnext) = (s.ntrail, s.qhead, s.dlevel, s.nvars, s.unsat, s.heur, s.truelit, s.vnext);
	(compact, cua) = (2, s.ua);
}

# A new guard.
askguard(s: ref Asker): int
{
	unstash(s);
	grow(1);
	g := 2*newvar();
	stash(s);
	return g;
}

# f, to hold where guard g does; a new guard if g < 0.  The guard.
askadd(s: ref Asker, f: ref Form, g: int): int
{
	unstash(s);
	grow(nodes(f) + 1);
	if(g < 0)
		g = 2*newvar();
	gtop(f, g);
	stash(s);
	return g;
}

gtop(f: ref Form, g: int)
{
	if(f.op == Fand){
		gtop(f.l, g);
		gtop(f.r, g);
		return;
	}
	(ok, lits) := clauseof(f, nil);
	if(!ok)
		lits = tseitin(f) :: nil;
	addclause((g^1) :: lits, 0);
}

# A guard settled for every question to come: on (g) or off (g^1).
askfix(s: ref Asker, lit: int)
{
	unstash(s);
	addclause(lit :: nil, 0);
	stash(s);
}

# Whether the formulas whose guards are on can all be true.
ask(s: ref Asker, on: list of int): int
{
	unstash(s);
	a := array[len on] of int;
	for(i := 0; on != nil; on = tl on)
		a[i++] = hd on;
	r := !unsat && solveunder(a);
	backtrack(0);
	stash(s);
	return r;
}

# solve, the assumptions decided first, one to a level.
solveunder(assume: array of int): int
{
	conflicts := 0;
	restart := 100;
	for(;;){
		confl := propagate();
		if(confl >= 0){
			conflicts++;
			if(dlevel == 0){
				unsat = 1;
				return 0;
			}
			(learnt, bt) := analyze(confl);
			backtrack(bt);
			if(tl learnt == nil)
				enqueue(hd learnt, -1);
			else
				enqueue(hd learnt, addclause(learnt, 1));
			actinc *= 1.05;
			if(!heur && conflicts > Budget)
				heur = 1;
			if(heur && conflicts >= restart){
				backtrack(0);
				restart += restart/2 + 100;
			}
			continue;
		}
		lit: int;
		if(dlevel < len assume){
			lit = assume[dlevel];
			case litval(lit) {
			0 =>
				return 0;
			1 =>
				dlevel++;
				lim[dlevel] = ntrail;
				continue;
			}
		}else{
			v := choose();
			if(v < 0)
				return 1;
			lit = 2*v;
			if(heur && phase[v] == 0)
				lit++;
		}
		dlevel++;
		lim[dlevel] = ntrail;
		enqueue(lit, -1);
	}
}

# Room for k more variables.
grow(k: int)
{
	n := nvars + k;
	if(n <= len asg)
		return;
	m := 2*n;
	asg = growi(asg, m, -1);
	vlevel = growi(vlevel, m, 0);
	reason = growi(reason, m, -1);
	phase = growi(phase, m, 1);
	seen = growi(seen, m, 0);
	trail = growi(trail, m, 0);
	lim = growi(lim, m+1, 0);
	nwatch = growi(nwatch, 2*m, 0);
	na := array[m] of { * => 0.0 };
	na[0:] = activity;
	activity = na;
	nw := array[2*m] of array of int;
	nw[0:] = watches;
	watches = nw;
}

growi(a: array of int, m, z: int): array of int
{
	na := array[m] of { * => z };
	na[0:] = a;
	return na;
}

#
# Checking
#

check(prems: list of ref Stmt, c: ref Stmt): int
{
	pf := forms(prems);
	# trying cases decides only some arguments; for the rest a
	# contradiction among the cases tried is shown again by a proof
	if(!satisfiable(neg(c.f) :: nil) && (decided || refuted(qnot(c.q) :: nil))){
		sreport(c, "argue/trivial", "the conclusion is true whatever the case, so it needs no argument");
		measure("argue/valid", 1);
		return 1;
	}
	if(prems != nil && !satisfiable(pf) && !decided && !refuted(stmtqs(prems))){
		if(framecut != nil)
			sreport(c, "argue/undecided", "no case among the worlds tried makes every premise true, but " + framecut + ": whether more would is left open");
		else
		sreport(c, "argue/undecided", sys->sprint("no case with the individuals named and %s makes every premise true, but whether a larger one does cannot be decided by trying cases",
			plural(len consts - namedcount(), "one other", sys->sprint("%d others", len consts - namedcount()))));
		measure("argue/valid", -1);
		return -1;
	}
	if(prems != nil && !satisfiable(pf)){
		inconsistentseen = 1;
		core := mincore(prems);
		if(tl core == nil)
			sreport(hd core, "argue/inconsistent", sys->sprint("with %s among the premises anything at all would follow", (hd core).name));
		else
			sreport(hd core, "argue/inconsistent", sys->sprint("%s contradict each other, so anything at all would follow from them",
				names(core)));
		measure("argue/valid", 0);
		return -1;
	}
	# a conclusion that restates a premise or assumption only assumes
	# it; one that restates a step argued elsewhere (a thesis stated in
	# the abstract and argued in a chapter) is proved by that step
	for(l := prems; l != nil; l = tl l)
		if(!isconcl((hd l).name) && entails((hd l).f :: nil, c.f) && entails(c.f :: nil, (hd l).f)){
			sreport(c, "argue/circular", sys->sprint("the conclusion only restates %s: it is assumed, not argued", (hd l).name));
			measure("argue/valid", 0);
			return -1;
		}
	cx := sat(neg(c.f) :: pf);
	# the whole case, the worlds' atoms with the rest, for the model
	cxall: array of int;
	if(cx != nil)
		cxall = smallest(foundall(), appendforms(neg(c.f) :: pf, modaldefs));
	if(cx == nil && !decided && refuted(qnot(c.q) :: stmtqs(prems))){
		sreport(c, "argue/proved", sys->sprint("valid whatever the individuals, not only in the cases tried: the premises, applied to the individuals named and %s they say exist, leave no case in which the conclusion fails",
			plural(hfound, "one", string hfound)));
		measure("argue/valid", 1);
		return 1;
	}
	if(cx == nil && !decided){
		if(framecut != nil)
			sreport(c, "argue/undecided", "no case among the worlds tried refutes it, but " + framecut + ": it is left open");
		else
		sreport(c, "argue/undecided", sys->sprint("no case with the individuals named and %s refutes it, and no proof turned up: its logic (some within all, over relations) cannot be decided in general, so it is left open",
			plural(len consts - namedcount(), "one other", sys->sprint("%d others", len consts - namedcount()))));
		measure("argue/valid", -1);
		return -1;
	}
	if(cx != nil && relaxed){
		sreport(c, "argue/undecided", sys->sprint("a case refutes it among the worlds tried, but only with what ought to be left open in worlds more than %d deep, so it may not be a case: it is left open", dmax));
		measure("argue/valid", -1);
		return -1;
	}
	if(cx == nil){
		need := minsupport(prems, c.f);
		for(l = prems; l != nil; l = tl l)
			if(!inlist(hd l, need))
				sreport(hd l, "argue/unused", sys->sprint("%s is not needed: the conclusion follows from %s without it", (hd l).name, names(need)));
		assumed: list of ref Stmt;
		# what the text never states: an assumption, not a step drawn
		# at no sentence of its own
		for(l = need; l != nil; l = tl l)
			if((hd l).sent == 0 && !isconcl((hd l).name))
				assumed = hd l :: assumed;
		if(assumed != nil && len assumed == len need){
			assumed = rev2(assumed);
			sreport(c, "argue/begs", sys->sprint("follows from %s alone, which the text never states: the text's own premises do no work", names(assumed)));
		}else if(assumed != nil){
			assumed = rev2(assumed);
			sreport(c, "argue/assumed", sys->sprint("follows only by %s, which the text never states: state it, or argue for it", names(assumed)));
		}
		# a premise read from the conclusion's own sentence may be the
		# conclusion read twice: a reading that makes its sentence
		# assert what it concludes proves nothing
		own: list of ref Stmt;
		for(l = need; l != nil; l = tl l)
			if(c.sent != 0 && (hd l).sent == c.sent && !isconcl((hd l).name))
				own = hd l :: own;
		if(own != nil && len own == len need)
			sreport(c, "argue/own-sentence", sys->sprint("follows from %s alone, read from the conclusion's own sentence: unless S%d gives %s as its reason, the reading has it assert what it concludes",
				names(rev2(own)), c.sent, plural(len own, "it", "them")));
		else if(own != nil)
			sreport(c, "argue/own-sentence", sys->sprint("needs %s, read from the conclusion's own sentence: check that S%d gives %s as its reason and does not conclude %s",
				names(rev2(own)), c.sent, plural(len own, "it", "them"), plural(len own, "it", "them")));
		if(vflag && decided)
			why(c, need);
		if(proofflag)
			tableau(c, need);
		measure("argue/valid", 1);
		return 1;
	}
	# the model first: what follows may ask other questions of other worlds
	used: list of string;
	for(ul := c :: prems; ul != nil; ul = tl ul)
		used = qpreds((hd ul).q, used);
	model := countermodel(cxall, used);
	msg := "does not follow: " + caseof(cx, pf, c.f);
	fall := fallacy(prems, c.f);
	if(fall == nil)
		fall = qfallacy(prems, c, cx);
	if(fall != nil)
		msg += "; this is " + fall;
	sreport(c, "argue/invalid", msg);
	if(model != nil)
		sreport(c, "argue/countermodel", model);
	if(proofflag > 1)
		tableau(c, prems);
	bridges: string;
	if(modal == Mclassical)
		bridges = missing(prems, c.f);
	if(bridges != nil)
		sreport(c, "argue/missing", "it would follow given " + bridges);
	measure("argue/valid", 0);
	return 0;
}

#
# Positions (-p): the premises and assumptions taken as a family of
# claims, each subset of them put to the solver, smallest first, as
# itertools' combinations would list them; every minimal set that
# cannot all be true (an impossibility result) and every maximal set
# that can (a coherent position, told as what it gives up, with the
# plainest case in which the rest hold).  Exhaustive by design, so that
# the result is easy to audit; a superset of a set that cannot all be
# true is known not to without asking.
#

Maxpositions: con 16;

rivals: list of (int, string, string);	# line, and the two names

positions(prems: list of ref Stmt)
{
	n := len prems;
	if(n == 0){
		report(nil, "positions/none", "no premises or assumptions to take positions on");
		return;
	}
	if(n > Maxpositions){
		report(nil, "positions/too-many", sys->sprint("%d premises and assumptions: %d subsets; positions are worked out for at most %d (split the family, or drop some)",
			n, 1<<n, Maxpositions));
		return;
	}
	pa := array[n] of ref Stmt;
	i := 0;
	for(l := prems; l != nil; l = tl l)
		pa[i++] = hd l;
	s := asker(forms(prems));
	g := array[n] of int;
	for(i = 0; i < n; i++)
		g[i] = askadd(s, pa[i].f, -1);
	# a set with both of a pair of rivals is left out
	rmasks: list of int;
	for(rl := rivals; rl != nil; rl = tl rl){
		(line, a, b) := hd rl;
		(ia, ib) := (-1, -1);
		for(i = 0; i < n; i++)
			if(pa[i].name == a)
				ia = i;
			else if(pa[i].name == b)
				ib = i;
		if(ia < 0 || ib < 0){
			lreport(line, "argue/syntax", sys->sprint("rivals %s %s: both must be premises or assumptions", a, b));
			continue;
		}
		rmasks = (1<<ia | 1<<ib) :: rmasks;
	}
	ok := array[1<<n] of { * => byte 0 };
	order := combos(n);
	checked := 0;
	impossible: list of int;
	for(ol := order; ol != nil; ol = tl ol){
		m := hd ol;
		if(!admissible(m, rmasks))
			continue;
		checked++;
		if(m == 0){
			ok[m] = byte ask(s, nil);
			continue;
		}
		# every smaller set has been settled: 0, cannot all be true
		known := 0;
		for(i = 0; i < n; i++)
			if(m & (1<<i) && ok[m & ~(1<<i)] == byte 0)
				known = 1;
		if(known)
			continue;	# a smaller set already cannot
		on: list of int;
		for(i = n-1; i >= 0; i--)
			if(m & (1<<i))
				on = g[i] :: on;
			else
				on = (g[i]^1) :: on;
		if(ask(s, on))
			ok[m] = byte 1;
		else
			impossible = m :: impossible;
	}
	for(il := revints(impossible); il != nil; il = tl il){
		set := members(pa, hd il);
		if(tl set == nil)
			sreport(hd set, "positions/impossible", sys->sprint("%s can never be true", (hd set).name));
		else
			sreport(hd set, "positions/impossible", sys->sprint("%s cannot all be true", names(set)));
	}
	# the coherent positions, largest first, each in the order listed
	coherent: list of int;
	for(k := n; k >= 0; k--)
		for(ol = order; ol != nil; ol = tl ol){
			m := hd ol;
			if(bits(m) != k || ok[m] == byte 0)
				continue;
			maximal := 1;
			for(i = 0; i < n; i++)
				if(!(m & (1<<i)) && admissible(m | (1<<i), rmasks) && ok[m | (1<<i)] != byte 0)
					maximal = 0;
			if(maximal)
				coherent = m :: coherent;
		}
	coherent = revints(coherent);
	for(cl := coherent; cl != nil; cl = tl cl){
		m := hd cl;
		kept := members(pa, m);
		dropped := members(pa, ((1<<n)-1) & ~m);
		what: string;
		if(dropped == nil)
			what = "all can be true together";
		else
			what = "give up " + names(dropped);
		a := sat(forms(kept));
		if(a != nil)
			what += ": " + plaincase(a, forms(kept));
		report(nil, "positions/coherent", what);
	}
	if(!decided)
		report(nil, "positions/undecided", "these are over the individuals named and those added; a larger domain could make more sets possible");
	measure("positions/checked", checked);
	measure("positions/impossible", len impossible);
	measure("positions/coherent", len coherent);
}

admissible(m: int, rmasks: list of int): int
{
	for(; rmasks != nil; rmasks = tl rmasks)
		if((m & hd rmasks) == hd rmasks)
			return 0;
	return 1;
}

# Every subset of n, as masks, smallest first and, within a size, in
# the order itertools' combinations gives.
combos(n: int): list of int
{
	r: list of int;
	for(k := n; k >= 0; k--)
		r = appendints(choosek(n, k, 0, 0), r);
	return r;
}

choosek(n, k, from, m: int): list of int
{
	if(k == 0)
		return m :: nil;
	r: list of int;
	for(i := n-k; i >= from; i--)
		r = appendints(choosek(n, k-1, i+1, m | (1<<i)), r);
	return r;
}

appendints(a, b: list of int): list of int
{
	if(a == nil)
		return b;
	return hd a :: appendints(tl a, b);
}

revints(l: list of int): list of int
{
	r: list of int;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

bits(m: int): int
{
	n := 0;
	for(; m; m &= m-1)
		n++;
	return n;
}

members(pa: array of ref Stmt, m: int): list of ref Stmt
{
	r: list of ref Stmt;
	for(i := len pa - 1; i >= 0; i--)
		if(m & (1<<i))
			r = pa[i] :: r;
	return r;
}

# The plainest case in which every formula holds: whatever can be
# false is, told as what is true.
plaincase(a: array of int, fs: list of ref Form): string
{
	used := array[natoms] of { * => 0 };
	for(l := fs; l != nil; l = tl l)
		mark(hd l, used);
	for(i := 0; i < natoms; i++)
		if(a[i] < 0)
			a[i] = 0;
	for(changed := 1; changed; ){
		changed = 0;
		for(i = 0; i < natoms; i++){
			if(!used[i] || a[i] != 1)
				continue;
			a[i] = 0;
			if(!allhold(fs, a))
				a[i] = 1;
			else
				changed = 1;
		}
	}
	trues: list of string;
	for(i = 0; i < natoms; i++)
		if(used[i] && a[i] == 1 && !isfresh(i)){
			m := meanings[i];
			if(m == nil)
				m = atoms[i];
			trues = sys->sprint("\"%s\"", m) :: trues;
		}
	if(trues == nil)
		return "as when nothing is true";
	return "as when only " + listed(revs(trues)) + plural(len trues, " is true", " are true");
}

# Why a valid conclusion follows: what it follows from, and for each
# of those, the case in which the conclusion fails without it.
why(c: ref Stmt, need: list of ref Stmt)
{
	if(need == nil){
		sreport(c, "argue/follows", sys->sprint("%s follows from nothing: it is true whatever the case", c.name));
		return;
	}
	sreport(c, "argue/follows", sys->sprint("%s follows from %s: there is no case in which %s and %s fails",
		c.name, names(need), plural(len need, "it holds", "they all hold"), c.name));
	for(l := need; l != nil; l = tl l){
		rest := without(need, hd l);
		cx := sat(neg(c.f) :: forms(rest));
		if(cx == nil)
			continue;
		m := caseof(cx, forms(rest), c.f);
		for(e := 0; e < len m; e++)
			if(m[e:] == ", every premise holds and the conclusion fails"){
				m = m[0:e] + ", the other premises hold and " + c.name + " fails";
				break;
			}else if(m[e:] == ", the conclusion fails, and there are no premises"){
				m = m[0:e] + ", " + c.name + " fails";
				break;
			}
		sreport(hd l, "argue/needed", sys->sprint("%s is needed: without it %s could fail: %s", (hd l).name, c.name, m));
	}
}

# A case that refutes the argument, in the atoms' own meanings.
caseof(a: array of int, pf: list of ref Form, c: ref Form): string
{
	used := array[natoms] of { * => 0 };
	for(l := c :: pf; l != nil; l = tl l)
		mark(hd l, used);
	# the plainest case: whatever can be false is
	for(i := 0; i < natoms; i++)
		if(a[i] < 0)
			a[i] = 0;
	for(changed := 1; changed; ){
		changed = 0;
		for(i = 0; i < natoms; i++){
			if(!used[i] || a[i] != 1)
				continue;
			a[i] = 0;
			if(val(c, a) != 0 || !allhold(pf, a))
				a[i] = 1;
			else
				changed = 1;
		}
	}
	# told as what is true, what of the conclusion is false, and that
	# nothing else is true; an individual the argument does not name
	# only where the conclusion is about it
	inc := array[natoms] of { * => 0 };
	mark(c, inc);
	trues: list of string;
	falses: list of string;
	others := 0;
	for(i = 0; i < natoms; i++){
		# a true one is always told: "nothing else" must be so
		if(!used[i] || isfresh(i) && !inc[i] && a[i] != 1)
			continue;
		m := meanings[i];
		if(m == nil)
			m = atoms[i];
		if(a[i] == 1)
			trues = sys->sprint("\"%s\"", m) :: trues;
		else if(inc[i])
			falses = sys->sprint("\"%s\"", m) :: falses;
		else
			others++;
	}
	s: string;
	if(trues == nil)
		s = "when nothing is true";
	else if(falses == nil && others)
		s = "when only " + listed(revs(trues)) + plural(len trues, " is true", " are true");
	else{
		s = "when " + listed(revs(trues)) + plural(len trues, " is true", " are true");
		if(falses != nil && len falses <= 3)
			s += ", " + listed(revs(falses)) + plural(len falses, " is false", " are false");
		else if(falses != nil)
			others++;
		if(others)
			s += ", and nothing else is true";
	}
	if(pf == nil)
		return s + ", the conclusion fails, and there are no premises";
	return s + ", every premise holds and the conclusion fails";
}

#
# The case as a logician writes a model: each claim's truth value (T or
# F), each predicate's extension over the domain D, and in a modal
# logic the worlds W, what each sees (R) and what holds at each.  In S5
# every world sees every one; in KD a world that sees none of those
# shown sees itself, which changes nothing, since nothing modal is
# asked of it; in s5kd □ ranges over every world and O over R.
#

countermodel(a: array of int, used: list of string): string
{
	nw := 1;
	if(framed && modal == Ms5)
		nw = len worldkids;
	else if(framed)
		nw = nworlds;
	there := array[nw] of { * => 0 };
	there[0] = 1;
	for(w := 1; w < nw; w++)
		there[w] = modal == Ms5 || wexist != nil && w < len wexist && wexist[w] >= 0 && a[wexist[w]] == 1;
	# each world's claims, and each predicate's extension in it
	vals := array[nw] of list of string;
	exts := array[nw] of list of (string, list of string);
	dom: list of string;
	for(i := natoms - 1; i >= 0; i--){
		n := atoms[i];
		if(internal(n))
			continue;
		w = 0;
		for(j := len n - 1; j > 0; j--)
			if(n[j] == '@'){
				w = int n[j+2:];
				n = n[0:j];
				break;
			}
		if(w >= nw || !there[w])
			continue;
		(pn, args) := splitatom(n);
		if(!member(pn, used))
			continue;
		for(l := args; l != nil; l = tl l)
			if(!member(hd l, dom))
				dom = hd l :: dom;
		if(args == nil){
			v := "F";
			if(a[i] == 1)
				v = "T";
			vals[w] = n + " = " + v :: vals[w];
			continue;
		}
		t := hd args;
		if(tl args != nil){
			t = "(";
			for(l = args; l != nil; l = tl l){
				t += hd l;
				if(tl l != nil)
					t += ", ";
			}
			t += ")";
		}
		el: list of (string, list of string);
		found := 0;
		for(el = exts[w]; el != nil; el = tl el)
			if((hd el).t0 == pn)
				found = 1;
		if(!found)
			exts[w] = (pn, nil) :: exts[w];
		if(a[i] != 1)
			continue;
		nl: list of (string, list of string);
		for(el = exts[w]; el != nil; el = tl el)
			if((hd el).t0 == pn)
				nl = (pn, t :: (hd el).t1) :: nl;
			else
				nl = hd el :: nl;
		exts[w] = revext(nl);
	}
	for(cl := consts; cl != nil; cl = tl cl)
		if(!member(hd cl, dom))
			dom = hd cl :: dom;
	s := "";
	if(dom != nil)
		s = "D = " + set(sortstr(dom)) + "; ";
	ws: list of int;
	for(w = nw - 1; w >= 0; w--)
		if(there[w])
			ws = w :: ws;
	if(framed){
		wl: list of string;
		for(l := ws; l != nil; l = tl l)
			wl = sys->sprint("w%d", hd l) :: wl;
		s += "W = " + set(revs(wl)) + "; ";
		s += accessibility(ws);
	}
	for(l := ws; l != nil; l = tl l){
		w = hd l;
		t := "";
		for(vl := sortstr(vals[w]); vl != nil; vl = tl vl){
			if(t != "")
				t += ", ";
			t += hd vl;
		}
		el: list of string;
		for(xl := exts[w]; xl != nil; xl = tl xl)
			el = (hd xl).t0 + " = " + set(sortstr((hd xl).t1)) :: el;
		for(el = sortstr(el); el != nil; el = tl el){
			if(t != "")
				t += ", ";
			t += hd el;
		}
		if(framed)
			t = sys->sprint("w%d: ", w) + t;
		if(l != ws)
			s += "; ";
		s += t;
	}
	return s;
}

# R as the case has it: see countermodel.
accessibility(ws: list of int): string
{
	if(modal == Ms5)
		return "R = W" + sym(" × ", " x ") + "W; ";
	pairs: list of string;
	for(l := ws; l != nil; l = tl l){
		w := hd l;
		sees := 0;
		if(modal == Mkt){
			pairs = sys->sprint("(w%d, w%d)", w, w) :: pairs;
			sees = 1;
		}
		for(kl := wkids[w]; kl != nil; kl = tl kl)
			if(member(string hd kl, intstrs(ws))){
				pairs = sys->sprint("(w%d, w%d)", w, hd kl) :: pairs;
				sees = 1;
			}
		if(!sees && (modal == Mkd || modal == Mmix))
			pairs = sys->sprint("(w%d, w%d)", w, w) :: pairs;
	}
	r := "R = " + set(sortstr(pairs)) + "; ";
	if(modal == Mmix)
		r = sym("□", "[]") + " over W, O over R: " + r;
	return r;
}

intstrs(l: list of int): list of string
{
	r: list of string;
	for(; l != nil; l = tl l)
		r = string hd l :: r;
	return r;
}

# The prover's own atoms, which are no claim of the argument's.
internal(n: string): int
{
	for(pl := "modal" :: "world" :: nil; pl != nil; pl = tl pl){
		p := hd pl;
		if(len n > len p && n[0:len p] == p && alldigits(n[len p:]))
			return 1;
	}
	return 0;
}

# An atom's predicate and its individuals: trusts(a,b) is trusts, a b.
splitatom(n: string): (string, list of string)
{
	for(i := 0; i < len n; i++)
		if(n[i] == '('){
			(nil, args) := sys->tokenize(n[i+1:len n-1], ",");
			return (n[0:i], args);
		}
	return (n, nil);
}

set(l: list of string): string
{
	if(l == nil)
		return sym("∅", "{}");
	s := "{";
	for(; l != nil; l = tl l){
		s += hd l;
		if(tl l != nil)
			s += ", ";
	}
	return s + "}";
}

revext(l: list of (string, list of string)): list of (string, list of string)
{
	r: list of (string, list of string);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

sortstr(l: list of string): list of string
{
	a := array[len l] of string;
	for(i := 0; l != nil; l = tl l)
		a[i++] = hd l;
	for(i = 1; i < len a; i++)
		for(j := i; j > 0 && a[j] < a[j-1]; j--)
			(a[j], a[j-1]) = (a[j-1], a[j]);
	r: list of string;
	for(i = len a - 1; i >= 0; i--)
		r = a[i] :: r;
	return r;
}

listed(l: list of string): string
{
	s := "";
	for(; l != nil; l = tl l){
		if(s != ""){
			if(tl l == nil)
				s += " and ";
			else
				s += ", ";
		}
		s += hd l;
	}
	return s;
}

plural(n: int, one, many: string): string
{
	if(n == 1)
		return one;
	return many;
}

allhold(fs: list of ref Form, a: array of int): int
{
	for(; fs != nil; fs = tl fs)
		if(val(hd fs, a) != 1)
			return 0;
	return 1;
}

mark(f: ref Form, used: array of int)
{
	if(f == nil)
		return;
	if(f.op == Fatom)
		used[f.atom] = 1;
	mark(f.l, used);
	mark(f.r, used);
}

# The two invalid forms with names.
fallacy(prems: list of ref Stmt, c: ref Form): string
{
	for(l := prems; l != nil; l = tl l){
		f := (hd l).f;
		if(f.op != Fimp)
			continue;
		for(m := prems; m != nil; m = tl m){
			g := (hd m).f;
			if(same(g, f.r) && same(c, f.l))
				return sys->sprint("affirming the consequent (%s and %s)", (hd l).name, (hd m).name);
			if(g.op == Fnot && same(g.l, f.l) && c.op == Fnot && same(c.l, f.r))
				return sys->sprint("denying the antecedent (%s and %s)", (hd l).name, (hd m).name);
		}
	}
	return nil;
}

# The invalid forms with all: from all A are B and this is B, that
# it is A; and from what is true of the cases named, that it is true
# of every case.
qfallacy(prems: list of ref Stmt, c: ref Stmt, cx: array of int): string
{
	cq := c.q;
	if(cq.op == Fatom)
		for(l := prems; l != nil; l = tl l){
			q := (hd l).q;
			if(q.op != Fall || q.l.op != Fimp || q.l.l.op != Fatom || q.l.r.op != Fatom)
				continue;
			(a, b) := (q.l.l, q.l.r);
			if(a.name != cq.name || len a.args != 1 || len cq.args != 1 || hd a.args != q.name)
				continue;
			for(m := prems; m != nil; m = tl m){
				g := (hd m).q;
				if(g.op == Fatom && g.name == b.name && len g.args == 1 && hd g.args == hd cq.args)
					return sys->sprint("affirming the consequent (%s and %s)", (hd l).name, (hd m).name);
			}
		}
	if(cq.op == Fall){
		for(i := 0; i < natoms; i++)
			if(isfresh(i) && cx[i] >= 0)
				return "a generalization: what holds of the cases named need not hold of every case";
	}
	return nil;
}

same(a, b: ref Form): int
{
	return fstring(a) == fstring(b);
}

# The premises the argument needs least: one by one, each premise is
# dropped if the conclusion follows without it.
minsupport(prems: list of ref Stmt, c: ref Form): list of ref Stmt
{
	nc := neg(c);
	s := asker(nc :: forms(prems));
	return dropping(s, prems, askadd(s, nc, -1) :: nil);
}

# A smallest set of premises that cannot all be true together.
mincore(prems: list of ref Stmt): list of ref Stmt
{
	return dropping(asker(forms(prems)), prems, nil);
}

# prems, each dropped in turn if the rest, with what always is on,
# still cannot all be true.  A premise looked at is settled for the
# questions after (kept or dropped for good), so each question assumes
# only those not yet looked at.
dropping(s: ref Asker, prems: list of ref Stmt, always: list of int): list of ref Stmt
{
	n := len prems;
	pa := array[n] of ref Stmt;
	g := array[n] of int;
	i := 0;
	for(l := prems; l != nil; l = tl l){
		pa[i] = hd l;
		g[i++] = askadd(s, (hd l).f, -1);
	}
	for(al := always; al != nil; al = tl al)
		askfix(s, hd al);
	kept := array[n] of { * => 1 };
	for(i = 0; i < n; i++){
		on: list of int;
		for(j := n-1; j > i; j--)
			on = g[j] :: on;
		if(!ask(s, g[i]^1 :: on)){
			kept[i] = 0;
			askfix(s, g[i]^1);
		}else
			askfix(s, g[i]);
	}
	keep: list of ref Stmt;
	for(i = n-1; i >= 0; i--)
		if(kept[i])
			keep = pa[i] :: keep;
	return keep;
}

# What one more premise would make the conclusion follow: a premise
# of the form x -> y, between the atoms (or their negations), that is
# consistent with the others and does not prove the conclusion alone.
# The first three found, those leading from the premises' atoms to the
# conclusion's first.
missing(prems: list of ref Stmt, c: ref Form): string
{
	inp := array[natoms] of { * => 0 };
	inc := array[natoms] of { * => 0 };
	for(l := prems; l != nil; l = tl l)
		mark((hd l).f, inp);
	mark(c, inc);
	lits: list of ref Form;
	for(i := natoms-1; i >= 0; i--)
		if(inp[i] || inc[i]){
			a := ref Form(Fatom, i, nil, nil, nil);
			lits = a :: neg(a) :: lits;
		}
	# the premises under one guard, the conclusion's denial under
	# another, and each bridge tried under its own
	nc := neg(c);
	s := asker(nc :: forms(prems));
	gp := askguard(s);
	for(l = prems; l != nil; l = tl l)
		askadd(s, (hd l).f, gp);
	gn := askadd(s, nc, -1);
	found := "";
	n := 0;
	got: list of ref Form;
	# first a claim the premises speak of, taken as true or false: the
	# premise that went missing, named in its own words
	for(x := lits; x != nil && n < 3; x = tl x){
		b := hd x;
		xa := b;
		if(xa.op == Fnot)
			xa = xa.l;
		if(!inp[xa.atom] || inc[xa.atom] || isfresh(xa.atom))
			continue;
		gb := askadd(s, b, -1);
		no := !ask(s, gb :: gn :: gp^1 :: nil) || ask(s, gb :: gp :: gn :: nil) || !ask(s, gb :: gp :: gn^1 :: nil);
		askfix(s, gb^1);
		if(no)
			continue;
		got = b :: got;
		if(found != "")
			found += ", or ";
		m := meanings[xa.atom];
		if(m == nil)
			m = atoms[xa.atom];
		if(b.op == Fnot)
			m = "it is not so that " + m;
		found += sys->sprint("\"%s\" (%s)", bare(fstring(b)), m);
		n++;
	}
	for(pass := 0; pass < 2 && n < 3; pass++)
		for(x = lits; x != nil && n < 3; x = tl x){
			xa := hd x;
			if(xa.op == Fnot)
				xa = xa.l;
			if(pass == 0 && !inp[xa.atom])
				continue;
			for(y := lits; y != nil && n < 3; y = tl y){
				ya := hd y;
				if(ya.op == Fnot)
					ya = ya.l;
				if(xa.atom == ya.atom)
					continue;
				if(pass == 0 && !inc[ya.atom] || pass == 1 && inp[xa.atom] && inc[ya.atom])
					continue;
				b := ref Form(Fimp, 0, hd x, hd y, nil);
				if(anyfresh(b))
					continue;
				gb := askadd(s, b, -1);
				no := !ask(s, gb :: gn :: gp^1 :: nil) || ask(s, gb :: gp :: gn :: nil) || !ask(s, gb :: gp :: gn^1 :: nil);
				askfix(s, gb^1);
				if(no)
					continue;
				# not one already found in other words: x -> y
				# and its contrapositive !y -> !x are the same
				dup := 0;
				for(g := got; g != nil; g = tl g)
					if(entails(b :: nil, hd g) && entails(hd g :: nil, b))
						dup = 1;
				if(dup)
					continue;
				got = b :: got;
				if(found != "")
					found += ", or ";
				found += sys->sprint("\"%s\"", bare(fstring(b)));
				n++;
			}
		}
	return found;
}

bare(s: string): string
{
	if(len s > 1 && s[0] == '(' && s[len s-1] == ')')
		return s[1:len s-1];
	return s;
}


#
# A proof, where trying cases cannot decide: Herbrand's theorem.  The
# premises and the conclusion's denial are put in negation normal form
# and every some is replaced by a name for what it says exists (a
# Skolem term: sk1, or sk2(x) for one that depends on x); then all is
# taken over the individuals named, the constants those names give,
# and the names applied to them, a level at a time.  If at some level
# the instances contradict each other, no case at all, of any size,
# refutes the argument: it is valid.  If none does by the last level,
# nothing is shown either way.
#

HMAX: con 16;		# individuals at most, at the last level
HATOMS: con 800;	# and ground atoms
HLEVELS: con 4;

nvar := 0;
nsk := 0;
skfuns: list of (string, int);	# the Skolem functions, with their arities
hfound := 0;			# individuals the proof needed beyond those named

qnot(q: ref Q): ref Q
{
	return ref Q(Fnot, "", nil, q, nil);
}

qbin(op: int, l, r: ref Q): ref Q
{
	return ref Q(op, "", nil, l, r);
}

nnf(q: ref Q, pos: int): ref Q
{
	case q.op {
	Fatom or Ftrue =>
		if(pos)
			return q;
		return qnot(q);
	Fnot =>
		return nnf(q.l, !pos);
	Fand =>
		if(pos)
			return qbin(Fand, nnf(q.l, 1), nnf(q.r, 1));
		return qbin(For, nnf(q.l, 0), nnf(q.r, 0));
	For =>
		if(pos)
			return qbin(For, nnf(q.l, 1), nnf(q.r, 1));
		return qbin(Fand, nnf(q.l, 0), nnf(q.r, 0));
	Fimp =>
		if(pos)
			return qbin(For, nnf(q.l, 0), nnf(q.r, 1));
		return qbin(Fand, nnf(q.l, 1), nnf(q.r, 0));
	Fiff =>
		if(pos)
			return qbin(Fand, qbin(For, nnf(q.l, 0), nnf(q.r, 1)), qbin(For, nnf(q.l, 1), nnf(q.r, 0)));
		return qbin(For, qbin(Fand, nnf(q.l, 1), nnf(q.r, 0)), qbin(Fand, nnf(q.l, 0), nnf(q.r, 1)));
	Fall or Fsome =>
		op := q.op;
		if(!pos){
			if(op == Fall)
				op = Fsome;
			else
				op = Fall;
		}
		return ref Q(op, q.name, nil, nnf(q.l, pos), nil);
	}
	return q;
}

# Every some replaced by its Skolem term; every all's variable renamed
# apart (_v1, _v2, ...), so that substituting into terms cannot capture.
skolem(q: ref Q, env: list of (string, string), univ: list of string): ref Q
{
	case q.op {
	Fatom =>
		args: list of string;
		for(a := q.args; a != nil; a = tl a)
			args = lookup(hd a, env) :: args;
		return ref Q(Fatom, q.name, revs(args), nil, nil);
	Ftrue =>
		return q;
	Fnot =>
		return qnot(skolem(q.l, env, univ));
	Fand or For =>
		return qbin(q.op, skolem(q.l, env, univ), skolem(q.r, env, univ));
	Fall =>
		v := "_v" + string ++nvar;
		return ref Q(Fall, v, nil, skolem(q.l, (q.name, v) :: env, v :: univ), nil);
	Fsome =>
		f := "sk" + string ++nsk;
		t := f;
		if(univ != nil){
			t += "(";
			sep := "";
			for(u := revs(univ); u != nil; u = tl u){
				t += sep + hd u;
				sep = ",";
			}
			t += ")";
		}
		skfuns = (f, len univ) :: skfuns;
		return skolem(q.l, (q.name, t) :: env, univ);
	}
	return q;
}

# A term with its variables replaced by the individuals env gives them.
inst(t: string, env: list of (string, string)): string
{
	for(i := 0; i < len t; i++)
		if(t[i] == '(')
			break;
	if(i == len t)
		return lookup(t, env);
	for(; env != nil; env = tl env){
		(n, c) := hd env;
		t = subst(t, n, c);
	}
	return t;
}

# Whether the formulas together are contradictory, shown by a Herbrand
# proof; 1 if so.
refuted(qs: list of ref Q): int
{
	# a proof is sought in first-order logic, not modal
	if(modal != Mclassical)
		return 0;
	nvar = nsk = 0;
	skfuns = nil;
	sq: list of ref Q;
	for(; qs != nil; qs = tl qs)
		sq = skolem(nnf(hd qs, 1), nil, nil) :: sq;
	saved := consts;
	h: list of string;
	for(c := consts; c != nil; c = tl c)
		if(!isanother(hd c))
			h = hd c :: h;
	nnamed := len h;
	for(f := skfuns; f != nil; f = tl f){
		(fname, n) := hd f;
		if(n == 0)
			h = fname :: h;
	}
	if(h == nil)
		h = "another" :: nil;
	h = revs(h);
	proved := 0;
	for(level := 0; level < HLEVELS && len h <= HMAX; level++){
		consts = h;
		fs: list of ref Form;
		for(l := sq; l != nil; l = tl l)
			fs = ground(hd l, nil) :: fs;
		if(natoms > HATOMS)
			break;
		if(!satisfiable(fs)){
			proved = 1;
			hfound = len h - nnamed;
			break;
		}
		# the next level: each function applied to what there is
		nh := h;
		for(f = skfuns; f != nil; f = tl f){
			(fname, n) := hd f;
			if(n == 0)
				continue;
			for(tp := tuples(h, n); tp != nil; tp = tl tp){
				t := fname + "(" + hd tp + ")";
				if(!member(t, nh))
					nh = appendstr(nh, t);
			}
		}
		if(len nh == len h)
			break;	# nothing new: the instances are all there are
		h = nh;
	}
	consts = saved;
	return proved;
}

# Every n-tuple of the individuals, written a,b.
tuples(h: list of string, n: int): list of string
{
	if(n == 0)
		return "" :: nil;
	r: list of string;
	for(rest := tuples(h, n-1); rest != nil; rest = tl rest)
		for(l := h; l != nil; l = tl l){
			if(hd rest == "")
				r = hd l :: r;
			else
				r = hd rest + "," + hd l :: r;
		}
	return revs(r);
}

appendstr(l: list of string, s: string): list of string
{
	return revs(s :: revs(l));
}

stmtqs(l: list of ref Stmt): list of ref Q
{
	r: list of ref Q;
	for(; l != nil; l = tl l)
		r = (hd l).q :: r;
	return r;
}

#
# Reporting
#

lastvalid := 0;	# the last verdict, as the measure gives it

measure(name: string, v: int)
{
	if(name == "argue/valid")
		lastvalid = v;
	if(stepping)
		return;
	out.puts(sys->sprint("%s: %s %d\n", logic, name, v));
}

lreport(line: int, rule, msg: string)
{
	out.puts(prose->finding(logic, line, -1, -1, rule, msg));
	errors++;
}

report(nil: ref Stmt, rule, msg: string)
{
	if(quiet)
		return;
	out.puts(sys->sprint("%s: %s: %s\n", logic, rule, msg));
}

# A finding about a statement: at the sentence it came from when the
# document is known, otherwise at its line in the logic file.
sprefix: string;	# the reading a finding is about, when comparing

sreport(st: ref Stmt, rule, msg: string)
{
	what := sprefix + st.name;
	if(st.sent > 0)
		what += sys->sprint(" (S%d)", st.sent);
	msg = what + ": " + msg;
	if(doc != nil && st.sent > 0){
		s := sents[st.sent-1];
		out.puts(prose->finding(doc, s.line, s.q0, s.q1, rule, msg));
	}else
		out.puts(prose->finding(logic, st.line, -1, -1, rule, msg));
}

names(l: list of ref Stmt): string
{
	s := "";
	for(; l != nil; l = tl l){
		if(s != ""){
			if(tl l == nil)
				s += " and ";
			else
				s += ", ";
		}
		s += (hd l).name;
	}
	return s;
}

inlist(s: ref Stmt, l: list of ref Stmt): int
{
	for(; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

without(l: list of ref Stmt, s: ref Stmt): list of ref Stmt
{
	r: list of ref Stmt;
	for(; l != nil; l = tl l)
		if(hd l != s)
			r = hd l :: r;
	return rev2(r);
}

rev(l: list of ref Stmt): list of ref Stmt
{
	return rev2(l);
}

rev2(l: list of ref Stmt): list of ref Stmt
{
	r: list of ref Stmt;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

fatal(s: string)
{
	sys->fprint(sys->fildes(2), "phil/prove: %s\n", s);
	raise "fail:error";
}

#
# Faithfulness: whether a statement says what its sentence says,
# judged from the words, not by a model.  A model that misreads a
# sentence the same way every time agrees with itself across readings
# and answers its own questions the same way, so phil/argue -k cannot
# catch it; but the formula can be read back into English from the
# atoms' meanings and set beside the sentence.  Four mismatches are
# found so:
#	the sentence shares no word with an atom's meaning (argue/unfaithful);
#	it puts a condition (if, when; all and every on a subject) on
#	one side and the formula puts it on the other (argue/converse);
#	it says not, never, no about something the formula does not
#	deny, or states plainly what the formula denies (argue/negation);
#	it says most or some and the formula all, or every and the
#	formula some (argue/quantifier).
# Each is a reason to look, with the formula read back so that a
# person can judge; a paraphrase the words cannot show is not one.
#

eflag := 0;	# -e: every statement read back
vflag := 0;	# -v: why a valid conclusion follows
proofflag := 0;	# -P: a valid step's proof, as a tableau; -PP tries invalid ones too (a test)
fflag := 0;	# -f: the logic file again, its formulas in logic's symbols
scopek := 0;	# -s n: the logic file with its nth scope turned over
aflag := 0;	# -A: formulas shown in ASCII, as a logic file may write them
pflag := 0;	# -p: every impossible set and coherent position

# Each statement in English, from its atoms' meanings (argue/says), at
# its sentence if it has one: for a person to compare, and for phil/map
# to show an assumption the text never states.
readback(l: list of ref Stmt)
{
	for(; l != nil; l = tl l)
		if((hd l).q != nil)
			sreport(hd l, "argue/says", sys->sprint("reads \"%s\"", english((hd l).q)));
}

nfaith := 0;	# mismatches found

freport(st: ref Stmt, rule, msg: string)
{
	nfaith++;
	sreport(st, rule, msg);
}

# The mismatches between an argument's statements and their sentences,
# reported, and how many.
faithful(prems: list of ref Stmt, c: ref Stmt): int
{
	nfaith = 0;
	if(doc == nil || sents == nil)
		return 0;
	all := prems;
	if(c != nil)
		all = appendst(all, c);
	for(l := all; l != nil; l = tl l){
		st := hd l;
		if(st.sent <= 0 || st.q == nil)
			continue;
		s := sents[st.sent-1];
		(ok, toks, nil, nil, heads, labels) := prose->tree(s);
		words: array of string;
		if(ok && toks != nil){
			words = array[len toks] of string;
			for(i := 0; i < len toks; i++)
				words[i] = prose->lower(toks[i]);
		}else{
			words = array[len s.words] of string;
			for(i := 0; i < len s.words; i++)
				words[i] = s.words[i].lc;
			heads = nil;
		}
		ps := qpreds(st.q, nil);
		for(pl := ps; pl != nil; pl = tl pl){
			cw := content(hd pl);
			if(cw != nil && !anymatch(cw, words))
				freport(st, "argue/unfaithful", sys->sprint("the sentence has no word of %s: is it the sentence %s came from?", told(hd pl), st.name));
		}
		if(heads != nil && len heads == len words)
			converse(st, words, heads, labels, ps);
		negation(st, words, ps);
		quantity(st, words);
		disjunction(st, words);
	}
	equivocation(all);
	return nfaith;
}

# One modal word read in two senses: "must" as necessity at one sentence
# and as obligation at another, where each statement is of one sense
# and its sentence has that one modal word.  An argument that moves
# between them moves between what is so and what ought to be.
equivocation(all: list of ref Stmt)
{
	seen: list of (string, int, ref Stmt);
	said: list of string;	# each word's equivocation once, where it first shows
	for(l := all; l != nil; l = tl l){
		st := hd l;
		if(st.sent <= 0 || st.q == nil)
			continue;
		m := modalsig(st.q);
		if(m != 1 && m != 2)
			continue;
		s := sents[st.sent-1];
		w := "";
		nw := 0;
		for(i := 0; i < len s.words; i++)
			for(j := 0; j < len Modalwords; j++)
				if(s.words[i].lc == Modalwords[j] && s.words[i].lc != w){
					w = Modalwords[j];
					nw++;
				}
		if(nw != 1)
			continue;
		for(sl := seen; sl != nil; sl = tl sl){
			(sw, sm, sst) := hd sl;
			if(sw == w && sm != m && sst.sent != st.sent){
				if(member(w, said))
					break;
				said = w :: said;
				freport(st, "argue/equivocates", sys->sprint("\"%s\" is read %s here and %s at S%d (%s): one word in two senses, so the argument may move from one to the other; say which each means",
					w, signame(m), signame(sm), sst.sent, sst.name));
				break;
			}
			if(sm != m && sst.sent == st.sent){
				freport(st, "argue/equivocates", sys->sprint("its \"%s\" is read %s by %s and %s by %s: one sentence in two senses; say which it means",
					w, signame(m), st.name, signame(sm), sst.name));
				break;
			}
		}
		seen = (w, m, st) :: seen;
	}
}

# Either ... or read as allowing both, or a plain or read as ruling
# both out: which the text means is the writer's to say, and the
# formula should say the same.
# Is a disjunction asserted: the statement, or one of its conjuncts?
assertsor(q: ref Q): int
{
	if(q == nil)
		return 0;
	if(q.op == For)
		return 1;
	if(q.op == Fand)
		return assertsor(q.l) || assertsor(q.r);
	return 0;
}

disjunction(st: ref Stmt, words: array of string)
{
	either := orw := notboth := 0;
	for(i := 0; i < len words; i++){
		w := words[i];
		if(w == "either")
			either = 1;
		else if(w == "or")
			orw = 1;
		else if(w == "both" && i > 0 && isneg(words[i-1]) || w == "exactly" || w == "neither")
			notboth = 1;
	}
	if(!orw || notboth)
		return;
	x := hasxor(st.q);
	# the exclusive "either ... or" is asked about only where the
	# disjunction is asserted: inside a condition ("permitted when
	# either war or invasion") or what one implies, both is the natural
	# reading
	if(either && !x && assertsor(st.q))
		freport(st, "argue/or", sys->sprint("the sentence says \"either ... or\", which often means one and not both, but %s allows both: it reads \"%s\"; if not both, say so with & !(... & ...)",
			st.name, english(st.q)));
	else if(!either && x)
		freport(st, "argue/or", sys->sprint("the sentence's plain \"or\" allows both, but %s rules both out: it reads \"%s\"",
			st.name, english(st.q)));
}

# Whether a formula has one and not both: !(a <-> b), or
# (a | b) & !(a & b).
hasxor(q: ref Q): int
{
	if(q == nil)
		return 0;
	if(q.op == Fnot && q.l != nil && q.l.op == Fiff)
		return 1;
	if(q.op == Fand && (q.l.op == For && notand(q.r) || q.r.op == For && notand(q.l)))
		return 1;
	return hasxor(q.l) || hasxor(q.r);
}

notand(q: ref Q): int
{
	return q.op == Fnot && q.l != nil && q.l.op == Fand;
}

appendst(l: list of ref Stmt, s: ref Stmt): list of ref Stmt
{
	if(l == nil)
		return s :: nil;
	return hd l :: appendst(tl l, s);
}

# A condition the sentence states one way round and the formula the
# other: "If A, B" (and "B when A") or "Every A is B" read as B -> A;
# "A only if B" and "Only As are B" read as B -> A are the reverse.
converse(st: ref Stmt, words: array of string, heads: array of int, labels: array of string, ps: list of string)
{
	n := len words;
	cond := -1;	# the head of the condition's words
	rev := 0;
	how := "";
	for(i := 0; i < n && cond < 0; i++){
		w := words[i];
		if(heads[i] > 0 && (labels[i] == "mark" && (w == "if" || w == "when" || w == "whenever" || w == "provided") ||
		   labels[i] == "advmod" && (w == "when" || w == "whenever") && labels[heads[i]-1] == "advcl")){
			if(i > 0 && words[i-1] == "even")
				return;		# even if
			if(i > 0 && words[i-1] == "and")
				continue;	# the second if of if and only if
			if(i+2 < n && words[i+1] == "and" && words[i+2] == "only"){
				cond = heads[i]-1;
				how = "iff";
				break;
			}
			cond = heads[i]-1;
			if(i > 0 && words[i-1] == "only"){
				rev = 1;
				how = "only if";
			}else
				how = w;
		}else if(labels[i] == "det" && (w == "all" || w == "every" || w == "each" || w == "no" || w == "only") && heads[i] > 0){
			h := heads[i]-1;
			if(labels[h] == "nsubj" || labels[h] == "nsubj:pass"){
				cond = h;
				how = w;
				rev = w == "only";
			}
		}else if(w == "only" && labels[i] == "advmod" && heads[i] > 0){
			h := heads[i]-1;
			if(labels[h] == "nsubj" || labels[h] == "nsubj:pass"){
				cond = h;
				how = w;
				rev = 1;
			}
		}
	}
	if(cond < 0)
		return;
	in := array[n] of { * => 0 };
	if(how == "iff"){
		if(!hasop(st.q, Fiff))
			freport(st, "argue/converse", sys->sprint("the sentence says \"if and only if\", but %s goes one way only: it reads \"%s\"",
				st.name, english(st.q)));
		return;
	}
	for(i = 0; i < n; i++)
		for(j := i; j >= 0; j = heads[j]-1)
			if(j == cond){
				in[i] = 1;
				break;
			}
	q := st.q;
	while(q != nil && q.op == Fall)
		q = q.l;
	if(q == nil || q.op != Fimp)
		return;
	left := qpreds(q.l, nil);
	right := qpreds(q.r, nil);
	cw := array[n] of string;
	rest := array[n] of string;
	for(i = 0; i < n; i++)
		if(in[i])
			cw[i] = words[i];
		else
			rest[i] = words[i];
	# where the sentence puts each atom, by the words of its meaning
	# that no other atom of the formula shares: 1 in the condition,
	# 2 outside it, 0 if the words do not say
	placed := 0;
	wrong := 0;
	sides := 0;
	for(k := 0; k < 2; k++){
		l := left;
		if(k == 1)
			l = right;
		any := 0;
		for(; l != nil; l = tl l){
			dw := distinct(hd l, ps);
			a := anymatch(dw, cw);
			b := anymatch(dw, rest);
			if(a == b)
				continue;
			placed++;
			any = 1;
			# the condition belongs on the left, or with only on the right
			if((k == 0) != (a != rev))
				wrong++;
		}
		sides += any;
	}
	if(sides < 2 || wrong != placed)
		return;
	if(rev)
		freport(st, "argue/converse", sys->sprint("\"%s\" makes what follows it necessary, not sufficient, but %s has it the other way round: it reads \"%s\"",
			how, st.name, english(st.q)));
	else
		freport(st, "argue/converse", sys->sprint("the sentence makes the words after \"%s\" the condition, but %s has them follow from it: it reads \"%s\"",
			how, st.name, english(st.q)));
}

NEGS: con "not n't never no none nothing nobody neither nor cannot without";

# A denial in the sentence the formula leaves out, or one in the
# formula of what the sentence states plainly.
negation(st: ref Stmt, words: array of string, ps: list of string)
{
	n := len words;
	negs := negated(st.q, 0, nil);
	cue := 0;
	for(i := 0; i < n; i++){
		w := words[i];
		# unpatched: a denial of what patched means, unless an atom
		# means it as it stands
		if((r := unneg(w)) != w && !stopword(w)){
			if(aboutexact(w, ps) != nil)
				continue;
			m := aboutexact(r, ps);
			if(m == nil)
				continue;	# information, not a denial of formation
			cue = 1;
			for(; m != nil; m = tl m)
				if(member(hd m, negs))
					break;
			if(m == nil){
				report1(st, w);
				return;
			}
			continue;
		}
		if(!isneg(w))
			continue;
		# "not just X but Y", "not only", "not least": a contrast,
		# which denies nothing
		if(w == "not" && i+1 < n && (words[i+1] == "just" || words[i+1] == "only" ||
		   words[i+1] == "merely" || words[i+1] == "simply" || words[i+1] == "solely" || words[i+1] == "least"))
			continue;
		cue = 1;
		# no, none, neither deny what is said of the thing they
		# name: anything denied in the formula will do.  Only where
		# the formula speaks of the next word of substance: a long
		# sentence read as several statements has its denial in one
		if(w == "no" || w == "none" || w == "nothing" || w == "nobody" || w == "neither" || w == "nor"){
			if(negs != nil || negmeaning(ps))
				continue;
			for(j := i+1; j < n && j <= i+3; j++){
				if(stopword(words[j]) || isneg(words[j]))
					continue;
				if(about(words[j], ps) != nil){
					report1(st, w);
					return;
				}
				break;
			}
			if(j >= n || j > i+3)
				{
				report1(st, w);
				return;
			}
			continue;
		}
		# not, never: the next word of substance, and the atoms
		# that speak of it; one of them is to be denied
		for(j := i+1; j < n && j <= i+3; j++){
			if(stopword(words[j]))
				continue;
			m := about(words[j], ps);
			if(m == nil)
				break;
			for(; m != nil; m = tl m)
				if(member(hd m, negs) || negmeaning(hd m :: nil))
					break;
			if(m == nil)
				{
				report1(st, w);
				return;
			}
			break;
		}
	}
	if(cue)
		return;
	# no denial in the sentence: an atom the formula denies whose
	# every word the sentence has is stated, not denied
	q := st.q;
	while(q != nil && (q.op == Fall || q.op == Fsome))
		q = q.l;
	if(q == nil || !onlyand(q))
		return;
	for(l := negs; l != nil; l = tl l){
		cw := content(hd l);
		if(cw == nil || negmeaning(hd l :: nil))
			continue;
		for(c := cw; c != nil; c = tl c)
			if(!anymatch(hd c :: nil, words))
				break;
		if(c == nil){
			freport(st, "argue/negation", sys->sprint("the sentence states %s, with no word of denial, but %s denies it: it reads \"%s\"",
				told(hd l), st.name, english(st.q)));
			return;
		}
	}
}

report1(st: ref Stmt, w: string)
{
	freport(st, "argue/negation", sys->sprint("the sentence says \"%s\", but %s denies nothing it speaks of: it reads \"%s\"",
		w, st.name, english(st.q)));
}

isneg(w: string): int
{
	if(len w > 3 && w[len w-3:] == "n't")
		return 1;
	return member(w, wordlist(NEGS));
}

hasop(q: ref Q, op: int): int
{
	if(q == nil)
		return 0;
	return q.op == op || hasop(q.l, op) || hasop(q.r, op);
}

# Whether a formula is literals joined by & alone.
onlyand(q: ref Q): int
{
	case q.op {
	Fatom or Ftrue =>	return 1;
	Fnot =>	return q.l.op == Fatom;
	Fand =>	return onlyand(q.l) && onlyand(q.r);
	}
	return 0;
}

# The predicates a formula denies (an odd number of ! above them).
negated(q: ref Q, odd: int, l: list of string): list of string
{
	if(q == nil)
		return l;
	case q.op {
	Fatom =>
		if(odd && !member(q.name, l))
			l = q.name :: l;
		return l;
	Fnot =>
		return negated(q.l, !odd, l);
	}
	return negated(q.r, odd, negated(q.l, odd, l));
}

# Whether one of the predicates' meanings is itself a denial (x is
# not patched), which the formula need not repeat.
negmeaning(ps: list of string): int
{
	for(; ps != nil; ps = tl ps){
		(nil, ws) := sys->tokenize(prose->lower(predof(hd ps).meaning), " \t,;:.");
		for(; ws != nil; ws = tl ws)
			if(isneg(hd ws))
				return 1;
	}
	return 0;
}

# The predicates whose meanings have word w.
about(w: string, ps: list of string): list of string
{
	r: list of string;
	for(; ps != nil; ps = tl ps)
		if(anymatch(content(hd ps), array[] of {w}))
			r = hd ps :: r;
	return r;
}

# The predicates whose meanings have word w as it stands.
aboutexact(w: string, ps: list of string): list of string
{
	r: list of string;
	x := stem(w);
	for(; ps != nil; ps = tl ps)
		for(cw := content(hd ps); cw != nil; cw = tl cw)
			if(likeword(x, stem(hd cw))){
				r = hd ps :: r;
				break;
			}
	return r;
}

FEW: con "most many several some few";
ALL: con "every each all always";

# Most, many or some made all; every made some.
quantity(st: ref Stmt, words: array of string)
{
	(hasall, hassome) := qkinds(st.q, 0);
	for(i := 0; i < len words; i++){
		w := words[i];
		if(member(w, wordlist(FEW)) && hasall && !hassome){
			freport(st, "argue/quantifier", sys->sprint("the sentence says \"%s\", but %s says all: it reads \"%s\"", w, st.name, english(st.q)));
			return;
		}
		# not every: some are not
		if(member(w, wordlist(ALL)) && i > 0 && isneg(words[i-1])){
			if(hasall && !hassome){
				freport(st, "argue/quantifier", sys->sprint("the sentence says \"%s %s\", but %s says it of every one: it reads \"%s\"", words[i-1], w, st.name, english(st.q)));
				return;
			}
			continue;
		}
		if(member(w, wordlist(ALL)) && hassome && !hasall){
			freport(st, "argue/quantifier", sys->sprint("the sentence says \"%s\", but %s says only some: it reads \"%s\"", w, st.name, english(st.q)));
			return;
		}
	}
}

# Whether a formula has an all and a some that are not denied.
qkinds(q: ref Q, odd: int): (int, int)
{
	if(q == nil)
		return (0, 0);
	case q.op {
	Fnot =>
		return qkinds(q.l, !odd);
	Fall or Fsome =>
		(a, s) := qkinds(q.l, odd);
		if((q.op == Fall) != odd)
			a = 1;
		else
			s = 1;
		return (a, s);
	}
	(a1, s1) := qkinds(q.l, odd);
	(a2, s2) := qkinds(q.r, odd);
	return (a1 || a2, s1 || s2);
}

# The words of substance in a predicate's meaning, its parameters left out.
content(p: string): list of string
{
	pr := predof(p);
	m := pr.meaning;
	if(m == "")
		return nil;
	(nil, ws) := sys->tokenize(prose->lower(m), " \t,;:.()\"'");
	r: list of string;
	for(; ws != nil; ws = tl ws){
		w := hd ws;
		if(stopword(w) || member(w, pr.params))
			continue;
		r = w :: r;
	}
	return r;
}

# Those of p's words no other predicate in ps has.
distinct(p: string, ps: list of string): list of string
{
	r: list of string;
	for(cw := content(p); cw != nil; cw = tl cw){
		shared := 0;
		for(l := ps; l != nil; l = tl l)
			if(hd l != p && anymatch(hd cw :: nil, l2a(content(hd l))))
				shared = 1;
		if(!shared)
			r = hd cw :: r;
	}
	return r;
}

stopwords: list of string;
STOP: con "a an the this that these those it its they them their there here is are was were be been being am has have had having do does did done will would shall should can could may might must not no nor never if then than so as of to in on at by for with from into onto over under about and or but because since unless when whenever while whether which who whom whose what where why how all some every each any none only also too very just one ones i we you he she his her our your us me my case";

stopword(w: string): int
{
	if(stopwords == nil)
		stopwords = wordlist(STOP);
	return len w < 2 || member(w, stopwords);
}

wordlist(s: string): list of string
{
	(nil, l) := sys->tokenize(s, " ");
	return l;
}

l2a(l: list of string): array of string
{
	a := array[len l] of string;
	for(i := 0; l != nil; l = tl l)
		a[i++] = hd l;
	return a;
}

# Whether any of the words is one of a's (nil entries skipped), by
# their stems.
anymatch(l: list of string, a: array of string): int
{
	for(; l != nil; l = tl l){
		x := stem(hd l);
		for(i := 0; i < len a; i++)
			if(a[i] != nil && (likeword(x, stem(a[i])) || likeword(x, stem(unneg(a[i])))))
				return 1;
	}
	return 0;
}

# A word without a prefix that denies it: unpatched, nonzero, disabled.
unneg(w: string): string
{
	for(l := wordlist("un non dis in im ir il"); l != nil; l = tl l){
		p := hd l;
		if(len w > len p + 3 && w[0:len p] == p)
			return w[len p:];
	}
	return w;
}

# A word without its endings: patched, patches, patching: patch.
stem(w: string): string
{
	w = prose->lower(w);
	n := len w;
	if(n > 2 && (w[n-2:] == "'s" || w[n-2:] == "’s"))
		w = w[0:n-2];
	n = len w;
	if(n > 4 && w[n-3:] == "ies")
		return w[0:n-3] + "y";
	if(n > 5 && w[n-3:] == "ing")
		return w[0:n-3];
	if(n > 4 && w[n-2:] == "ed")
		return w[0:n-2];
	if(n > 4 && (w[n-4:] == "ches" || w[n-4:] == "shes" || w[n-3:] == "xes" || w[n-4:] == "sses"))
		return w[0:n-2];
	if(n > 3 && w[n-1] == 's' && w[n-2] != 's')
		return w[0:n-1];
	return w;
}

# Stems alike: the same, or one the other with an ending left on
# (secur, secure), at four letters or more, or one the start of the
# other (mov, move) at three.
likeword(a, b: string): int
{
	if(a == b)
		return 1;
	p := 0;
	while(p < len a && p < len b && a[p] == b[p])
		p++;
	# or one the other cut short by the stemming (mov, move), at three
	return p >= 4 && p >= min(len a, len b) - 1 || p >= 3 && p == min(len a, len b);
}

# A formula read back into English from its atoms' meanings.
english(q: ref Q): string
{
	if(q == nil)
		return "";
	case q.op {
	Fatom =>
		pr := predof(q.name);
		m := meaningof(pr, q.args, q.name);
		if(m == nil)
			m = q.name;
		return m;
	Ftrue =>
		return "true";
	Fnot =>
		return "it is not so that " + eng1(q.l, Fnot);
	Fnec =>
		if(modal == Mkd || deontic(q))
			return "it ought to be that " + eng1(q.l, Fnot);
		return "necessarily, " + eng1(q.l, Fnot);
	Fpos =>
		if(modal == Mkd || deontic(q))
			return "it is permitted that " + eng1(q.l, Fnot);
		return "possibly, " + eng1(q.l, Fnot);
	Fand =>
		return eng1(q.l, Fand) + " and " + eng1(q.r, Fand);
	For =>
		return "either " + eng1(q.l, For) + " or " + eng1(q.r, For);
	Fimp =>
		return "if " + eng1(q.l, Fimp) + ", then " + eng1(q.r, Fimp);
	Fiff =>
		return eng1(q.l, Fiff) + " if and only if " + eng1(q.r, Fiff);
	Fall =>
		return "for every " + q.name + ", " + english(q.l);
	Fsome =>
		return "for some " + q.name + ", " + english(q.l);
	}
	return "?";
}

# A part of a compound, bracketed when it is a compound of another kind.
eng1(q: ref Q, op: int): string
{
	s := english(q);
	if(q.op == Fatom || q.op == Ftrue || (q.op == Fnot || q.op == Fnec || q.op == Fpos) && q.l.op == Fatom || q.op == op && op != Fimp)
		return s;
	return "(" + s + ")";
}

#
# A proof of a valid step, as a logician checks one: an analytic
# tableau (a truth tree), after Smullyan and, for the modal logics,
# Priest.  The premises the step needs are set down at the actual world
# w0 with the conclusion denied, and the rules take each formula apart:
# a conjunction into both its sides on the branch, a disjunction into
# two branches; ◇A at a world into A at a new world it sees (w0 R w1),
# □A into A at every world it sees.  In S5, and for □ and ◇ in s5kd,
# every world sees every one, so no R is written; for O and P (KD) a
# world with an obligation and no world it sees is given one (D); in
# KT each world sees itself.  ∃x A gives A of a new individual, ∀x A
# gives A of each one on the branch.  A branch closes (×) when a
# formula and its denial stand at one world, and every branch closing
# is the proof.  Each line says what it came from.  Too large a tree is
# not shown.
#

TN: adt {
	n:	int;	# its line
	q:	ref Q;	# nil for a line w R v
	w:	int;
	v:	int;	# w R v
	why:	string;
	s:	string;	# the formula shown, to match a denial
};

Br: adt {
	nodes:	list of ref TN;	# on the branch, latest first
	done:	list of int;	# lines taken apart
	used:	list of string;	# □ and ∀ instances made: line@world, line#individual
	worlds:	list of int;
	inds:	list of string;
};

tline := 0;
tworld := 0;
tgrown := 0;
Tmaxlines: con 400;
Tmaxworlds: con 12;
Tmaxinds: con 8;

tableau(c: ref Stmt, need: list of ref Stmt)
{
	tline = tworld = tgrown = 0;
	what := c.name;
	if(c.sent > 0)
		what = sys->sprint("%s (S%d)", c.name, c.sent);
	b := ref Br(nil, nil, nil, 0 :: nil, nil);
	for(nl := need; nl != nil; nl = tl nl)
		b.inds = qinds((hd nl).q, nil, b.inds);
	b.inds = qinds(c.q, nil, b.inds);
	acc: list of string;
	shut: string;
	l: list of ref Stmt;
	for(l = need; l != nil && shut == nil; l = tl l){
		x := tnode((hd l).q, 0, (hd l).name);
		acc = tshow(x) :: acc;
		shut = tpush(b, x);
	}
	if(shut == nil){
		x := tnode(ref Q(Fnot, nil, nil, c.q, nil), 0, c.name + " denied");
		acc = tshow(x) :: acc;
		shut = tpush(b, x);
	}
	closed := 1;
	if(shut != nil)
		acc = "× " + shut :: acc;
	else{
		rest: list of string;
		(closed, rest) = texpand(b, "");
		for(; rest != nil; rest = tl rest)
			acc = hd rest :: acc;
	}
	if(!closed){
		out.puts(sys->sprint("# no tableau shown for %s: the tree grows past %d lines, %d worlds or %d individuals\n", what, Tmaxlines, Tmaxworlds, Tmaxinds));
		return;
	}
	out.puts(sys->sprint("# %s, proved by a tableau: every branch closes (×)\n", what));
	# what each line came from, in a column of its own
	col := 0;
	ol: list of string;
	for(; acc != nil; acc = tl acc){
		ol = hd acc :: ol;
		for(i := 0; i < len hd acc; i++)
			if((hd acc)[i] == '\t' && i > col)
				col = i;
	}
	for(; ol != nil; ol = tl ol){
		t := hd ol;
		for(i := 0; i < len t; i++)
			if(t[i] == '\t'){
				w := t[0:i];
				while(len w < col + 3)
					w[len w] = ' ';
				t = w + t[i+1:];
				break;
			}
		out.puts("#\t" + t + "\n");
	}
}

tnode(q: ref Q, w: int, why: string): ref TN
{
	s: string;
	if(q != nil)
		s = qshow(q);
	return ref TN(++tline, q, w, 0, why, s);
}

# A line of the tree.
tshow(x: ref TN): string
{
	f := x.s;
	if(x.q == nil)
		f = sys->sprint("w%d R w%d", x.w, x.v);
	s := sys->sprint("%d. %s", x.n, f);
	if(framed && x.q != nil)
		s += sys->sprint(", w%d", x.w);
	return s + "\t" + x.why;
}

# Put a line on the branch: what closes it, if it does.
tpush(b: ref Br, x: ref TN): string
{
	b.nodes = x :: b.nodes;
	if(x.q == nil)
		return nil;
	if(x.q.op == Fnot && x.q.l.op == Ftrue)
		return string x.n;
	for(l := tl b.nodes; l != nil; l = tl l){
		y := hd l;
		if(y.q == nil || y.w != x.w)
			continue;
		if(x.q.op == Fnot && qshow(x.q.l) == y.s || y.q.op == Fnot && qshow(y.q.l) == x.s)
			return sys->sprint("%d, %d", y.n, x.n);
	}
	return nil;
}

# The branch taken apart, each line it adds prefixed by pre (the tree's
# lines to its left): 1 if every branch below closes.
texpand(b: ref Br, pre: string): (int, list of string)
{
	acc: list of string;
	for(;;){
		if(tline > Tmaxlines || tworld > Tmaxworlds || len b.inds > Tmaxinds)
			return (0, nil);
		# what does not branch, first
		adds := tstep(b);
		if(adds != nil){
			for(; adds != nil; adds = tl adds){
				acc = pre + tshow(hd adds) :: acc;
				if((m := tpush(b, hd adds)) != nil)
					return (1, revs(pre + "× " + m :: acc));
			}
			continue;
		}
		x := tbeta(b);
		if(x == nil)
			return (0, nil);	# an open branch: no proof here
		b.done = x.n :: b.done;
		for(sl := tsides(x.q); sl != nil; sl = tl sl){
			nb := ref Br(b.nodes, b.done, b.used, b.worlds, b.inds);
			(lead, more) := ("├─ ", "│  ");
			if(tl sl == nil)
				(lead, more) = ("└─ ", "   ");
			shut: string;
			first := 1;
			for(fl := hd sl; fl != nil && shut == nil; fl = tl fl){
				y := tnode(hd fl, x.w, sys->sprint("%d %s", x.n, rulename(x.q)));
				if(first)
					acc = pre + lead + tshow(y) :: acc;
				else
					acc = pre + more + tshow(y) :: acc;
				first = 0;
				shut = tpush(nb, y);
			}
			if(shut != nil){
				acc = pre + more + "× " + shut :: acc;
				continue;
			}
			(closed, sub) := texpand(nb, pre + more);
			if(!closed)
				return (0, nil);
			for(; sub != nil; sub = tl sub)
				acc = hd sub :: acc;
		}
		return (1, revs(acc));
	}
}

# Whether □ or ◇ ranges over every world (S5, and s5kd's alethic ones).
tuniv(q: ref Q): int
{
	return modal == Ms5 || modal == Mmix && !deontic(q);
}

# The worlds w sees on the branch, for a □ or ◇ like q.
tsees(b: ref Br, q: ref Q, w: int): list of int
{
	if(tuniv(q))
		return revint(b.worlds);
	r: list of int;
	if(modal == Mkt)
		r = w :: r;
	for(l := b.nodes; l != nil; l = tl l)
		if((hd l).q == nil && (hd l).w == w)
			r = (hd l).v :: r;
	return r;	# oldest first
}

# The next lines that do not branch: a line taken apart, a new world or
# individual, an instance of □ or ∀; nil if none is left.
tstep(b: ref Br): list of ref TN
{
	old := rev2tn(b.nodes);
	for(l := old; l != nil; l = tl l){
		x := hd l;
		if(x.q == nil || intin(x.n, b.done))
			continue;
		q := x.q;
		why := sys->sprint("%d %s", x.n, rulename(q));
		case q.op {
		Fand =>
			b.done = x.n :: b.done;
			return tnode(q.l, x.w, why) :: tnode(q.r, x.w, why) :: nil;
		Fpos =>
			b.done = x.n :: b.done;
			v := ++tworld;
			b.worlds = v :: b.worlds;
			if(tuniv(q))
				return tnode(q.l, v, why) :: nil;
			r := ref TN(++tline, nil, x.w, v, why, nil);
			return r :: tnode(q.l, v, why) :: nil;
		Fsome =>
			b.done = x.n :: b.done;
			i := newind(b.inds);
			b.inds = i :: b.inds;
			return tnode(qsubst(q.l, q.name, i), x.w, why) :: nil;
		Fnot =>
			p := q.l;
			case p.op {
			Fnot =>
				b.done = x.n :: b.done;
				return tnode(p.l, x.w, why) :: nil;
			For =>
				b.done = x.n :: b.done;
				return tnode(qnot(p.l), x.w, why) :: tnode(qnot(p.r), x.w, why) :: nil;
			Fimp =>
				b.done = x.n :: b.done;
				return tnode(p.l, x.w, why) :: tnode(qnot(p.r), x.w, why) :: nil;
			Fnec =>
				b.done = x.n :: b.done;
				return tnode(ref Q(Fpos, p.name, nil, qnot(p.l), nil), x.w, why) :: nil;
			Fpos =>
				b.done = x.n :: b.done;
				return tnode(ref Q(Fnec, p.name, nil, qnot(p.l), nil), x.w, why) :: nil;
			Fall =>
				b.done = x.n :: b.done;
				return tnode(ref Q(Fsome, p.name, nil, qnot(p.l), nil), x.w, why) :: nil;
			Fsome =>
				b.done = x.n :: b.done;
				return tnode(ref Q(Fall, p.name, nil, qnot(p.l), nil), x.w, why) :: nil;
			}
		}
	}
	# □ at each world seen, ∀ of each individual, as they come
	for(l = old; l != nil; l = tl l){
		x := hd l;
		if(x.q == nil)
			continue;
		q := x.q;
		why := sys->sprint("%d %s", x.n, rulename(q));
		case q.op {
		Fnec =>
			for(vl := tsees(b, q, x.w); vl != nil; vl = tl vl){
				k := sys->sprint("%d@%d", x.n, hd vl);
				if(!member(k, b.used)){
					b.used = k :: b.used;
					# KT: the world sees itself
					if(modal == Mkt && hd vl == x.w)
						why += ", T";
					return tnode(q.l, hd vl, why) :: nil;
				}
			}
		Fall =>
			if(b.inds == nil)
				b.inds = newind(nil) :: nil;
			for(il := revs(b.inds); il != nil; il = tl il){
				k := sys->sprint("%d#%s", x.n, hd il);
				if(!member(k, b.used)){
					b.used = k :: b.used;
					return tnode(qsubst(q.l, q.name, hd il), x.w, why) :: nil;
				}
			}
		}
	}
	# D: a world with an obligation sees a world
	if(modal == Mkd || modal == Mmix)
		for(l = old; l != nil; l = tl l){
			x := hd l;
			if(x.q == nil || x.q.op != Fnec || tuniv(x.q) || tsees(b, x.q, x.w) != nil)
				continue;
			v := ++tworld;
			b.worlds = v :: b.worlds;
			return ref TN(++tline, nil, x.w, v, "D", nil) :: nil;
		}
	return nil;
}

# A branching line not yet taken apart: the one with a side that closes
# at once, if there is one, else the first.
tbeta(b: ref Br): ref TN
{
	first: ref TN;
	for(l := rev2tn(b.nodes); l != nil; l = tl l){
		x := hd l;
		if(x.q == nil || intin(x.n, b.done) || tsides(x.q) == nil)
			continue;
		if(first == nil)
			first = x;
		for(sl := tsides(x.q); sl != nil; sl = tl sl){
			if(len hd sl != 1)
				continue;
			f := hd hd sl;
			for(nl := b.nodes; nl != nil; nl = tl nl){
				y := hd nl;
				if(y.q != nil && y.w == x.w && (f.op == Fnot && qshow(f.l) == y.s || y.q.op == Fnot && qshow(y.q.l) == qshow(f)))
					return x;
			}
		}
	}
	return first;
}

# What a branching formula branches into, each side a list; nil if it
# does not branch.
tsides(q: ref Q): list of list of ref Q
{
	case q.op {
	For =>
		return (q.l :: nil) :: (q.r :: nil) :: nil;
	Fimp =>
		return (qnot(q.l) :: nil) :: (q.r :: nil) :: nil;
	Fiff =>
		return (q.l :: q.r :: nil) :: (qnot(q.l) :: qnot(q.r) :: nil) :: nil;
	Fnot =>
		p := q.l;
		case p.op {
		Fand =>
			return (qnot(p.l) :: nil) :: (qnot(p.r) :: nil) :: nil;
		Fiff =>
			return (p.l :: qnot(p.r) :: nil) :: (qnot(p.l) :: p.r :: nil) :: nil;
		}
	}
	return nil;
}

# The rule a line is taken apart by, by its main operator.
rulename(q: ref Q): string
{
	case q.op {
	Fnot =>
		return sym("¬", "!") + rulename(q.l);
	Fand =>	return sym("∧", "&");
	For =>	return sym("∨", "|");
	Fimp =>	return sym("→", "->");
	Fiff =>	return sym("↔", "<->");
	Fall =>	return sym("∀", "all");
	Fsome =>	return sym("∃", "some");
	Fnec =>
		if(deontic(q))
			return sym("O", "ought");
		return sym("□", "[]");
	Fpos =>
		if(deontic(q))
			return sym("P", "permitted");
		return sym("◇", "<>");
	}
	return "";
}

# q with the individual c for the variable v, where v is free.
qsubst(q: ref Q, v, c: string): ref Q
{
	if(q == nil)
		return nil;
	case q.op {
	Fatom =>
		args: list of string;
		for(a := q.args; a != nil; a = tl a)
			if(hd a == v)
				args = c :: args;
			else
				args = hd a :: args;
		return ref Q(Fatom, q.name, revs(args), nil, nil);
	Fall or Fsome =>
		if(q.name == v)
			return q;
	}
	return ref Q(q.op, q.name, q.args, qsubst(q.l, v, c), qsubst(q.r, v, c));
}

# The individuals q names, beside those in l.
qinds(q: ref Q, bound, l: list of string): list of string
{
	if(q == nil)
		return l;
	case q.op {
	Fatom =>
		for(a := q.args; a != nil; a = tl a)
			if(!member(hd a, bound) && !member(hd a, l))
				l = hd a :: l;
		return l;
	Fall or Fsome =>
		return qinds(q.l, q.name :: bound, l);
	}
	return qinds(q.r, bound, qinds(q.l, bound, l));
}

# A name for an individual the branch has not met: a, b, c, ...
newind(have: list of string): string
{
	for(i := 0; i < 26; i++){
		n := "";
		n[0] = 'a' + i;
		if(!member(n, have))
			return n;
	}
	for(i = 1; ; i++)
		if(!member(sys->sprint("d%d", i), have))
			return sys->sprint("d%d", i);
}

revint(l: list of int): list of int
{
	r: list of int;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

intin(n: int, l: list of int): int
{
	for(; l != nil; l = tl l)
		if(hd l == n)
			return 1;
	return 0;
}

rev2tn(l: list of ref TN): list of ref TN
{
	r: list of ref TN;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}
