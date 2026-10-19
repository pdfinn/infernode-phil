implement Corpus;

#
# phil/corpus [-x] dir - a field's works read as one, by rule.  dir holds
# works (one to a line: id, bibliography key, kind, date, path, revision,
# title), atoms (the vocabulary the works share), align (which of a
# work's atoms is which shared one: same, negates), and readings/id/logic,
# each work's argument as a logic file, read by phil/argue or by hand.
# It writes, from them and nothing else:
#
#	readings/id/shared.logic	the work over the shared atoms: an atom
#		aligned same is the shared one, negates its denial, any other
#		the work's own, named id_atom
#	claims	each claim and every work that asserts, denies, assumes or
#		reports it
#	ids	every statement's id: k and eight hexadecimal digits of the
#		SHA-1 of its work, its kind of statement and its formula over
#		the shared atoms, so that a statement read again the same keeps
#		its id however it is numbered
#
# and reports, each at the reporting work's sentence:
#
#	claims/contradicts-source	a work says another in the corpus holds
#		a claim, and what that other holds, as read, entails its denial
#	claims/misattributed	what the other holds, as read, entails neither
#		the claim nor its denial
#	claims/attributed-unread	the claim is given as the view of a work
#		not in the corpus, which cannot be checked
#	claims/reported-only	no work in the corpus holds the claim (none
#		whose own commitments entail it); it is only reported
#
# Each check is decided by phil/prove: whether the other work's premises,
# assumptions and conclusions entail the claim, or its denial.  Measures
# follow, for gate.  -x gives findings their characters, as wwb's do.
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
include "sh.m";
	sh: Sh;
include "keyring.m";
	kr: Keyring;
include "prose.m";
	prose: Prose;

Corpus: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

St: adt {
	name:	string;
	sent:	int;		# S number; 0 for one the text never states
	formula:	string;	# as the work's reading writes it
	rest:	list of string;	# the fields after the formula
	line:	int;		# in the reading
	says:	string;	# whose claim it reports, if it reports one
	shared:	string;	# the formula over the shared atoms
	canon:	string;	# the same, as prove writes it in ASCII, unspaced
	id:	string;
};

Work: adt {
	id, key, kind, date, path, rev, title:	string;
	line:	int;		# in works
	logic:	string;	# its logic line, if it has one
	domains:	list of string;
	atoms:	list of (string, string, string);	# name, its parameters, what it means
	stmts:	list of ref St;	# in the order of the reading
	rename:	list of (string, string);	# an atom's name, and what it becomes
	readable:	int;	# whether prove reads its shared form
	doc:	string;	# its text, for addresses, when it can be read
	sents:	array of ref Prose->Sent;
};

dir: string;
works: list of ref Work;
shared: list of (string, string);	# the shared atoms: name, its whole atom line
errors := 0;
stderr: ref Sys->FD;
out: ref Iobuf;
ntmp := 0;

# the measures
nmis, ncontra, nunread, nonly, nheld, nclaims: int;

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	stderr = sys->fildes(2);
	bufio = load Bufio Bufio->PATH;
	sh = load Sh Sh->PATH;
	if(sh == nil)
		fatal(sys->sprint("cannot load %s: %r", Sh->PATH));
	sh->initialise();
	kr = load Keyring Keyring->PATH;
	prose = load Prose Prose->PATH;
	if(prose == nil)
		fatal(sys->sprint("cannot load %s: %r", Prose->PATH));
	prose->init();
	arg := load Arg Arg->PATH;
	arg->init(args);
	arg->setusage("phil/corpus [-x] dir");
	while((o := arg->opt()) != 0)
		case o {
		'x' =>	prose->exact(1);
		* =>	arg->usage();
		}
	args = arg->argv();
	if(len args != 1)
		arg->usage();
	dir = hd args;
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);
	readworks();
	readshared();
	for(wl := works; wl != nil; wl = tl wl)
		readwork(hd wl);
	readalign();
	if(errors){
		out.flush();
		raise "fail:corpus";
	}
	for(wl = works; wl != nil; wl = tl wl)
		writeshared(hd wl);
	writeids();
	writeclaims();
	attributions();
	measures();
	out.flush();
}

#
# Reading the corpus
#

readworks()
{
	n := 0;
	for(l := lines(dir + "/works"); l != nil; l = tl l){
		n++;
		s := hd l;
		if(s == nil || s[0] == '#')
			continue;
		(nf, f) := sys->tokenize(s, "\t");
		if(nf < 7){
			ferror(dir + "/works", n, "corpus/syntax", "a work is an id, a key, a kind, a date, a path, a revision and a title, separated by tabs; - for one not known");
			continue;
		}
		a := array[7] of string;
		for(i := 0; i < 7; i++){
			a[i] = hd f;
			f = tl f;
		}
		w := ref Work(a[0], a[1], a[2], a[3], a[4], a[5], a[6], n, nil, nil, nil, nil, nil, 0, nil, nil);
		if(!isname(w.id))
			ferror(dir + "/works", n, "corpus/syntax", sys->sprint("\"%s\" is not an id: letters, digits and _", w.id));
		if(w.kind != "primary" && w.kind != "secondary")
			ferror(dir + "/works", n, "corpus/syntax", sys->sprint("%s: a kind is primary or secondary", w.id));
		if(workof(w.id) != nil)
			ferror(dir + "/works", n, "corpus/duplicate", sys->sprint("%s is in works twice", w.id));
		works = rev(w :: rev(works));
	}
	if(works == nil)
		ferror(dir + "/works", 0, "corpus/empty", "the corpus has no works");
}

readshared()
{
	n := 0;
	for(l := lines(dir + "/atoms"); l != nil; l = tl l){
		n++;
		s := hd l;
		if(s == nil || s[0] == '#')
			continue;
		(nf, f) := sys->tokenize(s, "\t");
		if(nf < 3 || hd f != "atom"){
			ferror(dir + "/atoms", n, "corpus/syntax", "a shared atom is atom, its name and what it means, separated by tabs");
			continue;
		}
		(name, nil) := atomname(hd tl f);
		shared = (name, s) :: shared;
	}
	shared = revpairs(shared);
}

readwork(w: ref Work)
{
	file := dir + "/readings/" + w.id + "/logic";
	n := 0;
	ls := lines(file);
	if(ls == nil){
		ferror(file, 0, "corpus/unread", sys->sprint("%s has no reading: read it with phil/argue -w, or write one, at %s", w.id, file));
		return;
	}
	for(; ls != nil; ls = tl ls){
		n++;
		s := hd ls;
		if(s == nil || s[0] == '#')
			continue;
		(nf, f) := sys->tokenize(s, "\t");
		case hd f {
		"atom" =>
			if(nf < 2)
				continue;
			(name, params) := atomname(hd tl f);
			m := "";
			if(nf > 2)
				m = hd tl tl f;
			w.atoms = (name, params, m) :: w.atoms;
			continue;
		"logic" =>
			w.logic = s;
			continue;
		"domain" =>
			w.domains = s :: w.domains;
			continue;
		"rivals" =>
			continue;
		}
		if(nf < 3)
			continue;
		st := ref St(hd f, 0, hd tl tl f, tl tl tl f, n, nil, nil, nil, nil);
		where := hd tl f;
		if(len where > 1 && where[0] == 'S')
			st.sent = int where[1:];
		for(rl := st.rest; rl != nil; rl = tl rl){
			(nil, ws) := sys->tokenize(hd rl, " ");
			if(ws != nil && hd ws == "says" && tl ws != nil)
				st.says = hd tl ws;
		}
		w.stmts = st :: w.stmts;
	}
	w.atoms = rev3(w.atoms);
	w.stmts = revst(w.stmts);
	w.domains = revs(w.domains);
	# its text, for the sentences findings are addressed at
	if(w.path != "-"){
		(name, lns, err) := prose->readtext(dir + "/" + w.path, Prose->Fauto);
		if(err == nil){
			w.doc = name;
			w.sents = prose->sentences(name, lns);
		}
	}
}

readalign()
{
	file := dir + "/align";
	n := 0;
	for(l := lines(file); l != nil; l = tl l){
		n++;
		s := hd l;
		if(s == nil || s[0] == '#')
			continue;
		(nf, f) := sys->tokenize(s, "\t");
		how := hd f;
		case how {
		"same" or "negates" =>
			if(nf < 3){
				ferror(file, n, "corpus/syntax", how + " names a work's atom (id:atom) and a shared atom");
				continue;
			}
			(w, a) := workatom(hd tl f, file, n);
			if(w == nil)
				continue;
			sa := hd tl tl f;
			if(sharedline(sa) == nil){
				ferror(file, n, "corpus/align", sys->sprint("%s is not a shared atom: declare it in atoms", sa));
				continue;
			}
			if(lookup(a, w.rename) != nil){
				ferror(file, n, "corpus/align", sys->sprint("%s:%s is aligned twice", w.id, a));
				continue;
			}
			dest := sa;
			if(how == "negates")
				dest = "!" + sa;
			w.rename = (a, dest) :: w.rename;
		"distinct" or "rival" =>
			# decisions kept for later: a proposal not to make again,
			# alternatives for positions
			if(nf < 3)
				ferror(file, n, "corpus/syntax", how + " names two works' atoms (id:atom id:atom)");
		* =>
			ferror(file, n, "corpus/syntax", "an alignment is same, negates, distinct or rival");
		}
	}
	# an atom aligned to nothing is the work's own, under its id
	for(wl := works; wl != nil; wl = tl wl){
		w := hd wl;
		for(al := w.atoms; al != nil; al = tl al){
			(name, nil, nil) := hd al;
			if(lookup(name, w.rename) == nil)
				w.rename = (name, w.id + "_" + name) :: w.rename;
		}
	}
}

# id:atom, checked against works and the work's atoms
workatom(s: string, file: string, n: int): (ref Work, string)
{
	for(i := 0; i < len s && s[i] != ':'; i++)
		;
	if(i == len s){
		ferror(file, n, "corpus/syntax", sys->sprint("\"%s\" is not id:atom", s));
		return (nil, nil);
	}
	w := workof(s[0:i]);
	a := s[i+1:];
	if(w == nil){
		ferror(file, n, "corpus/align", sys->sprint("%s is not in works", s[0:i]));
		return (nil, nil);
	}
	for(al := w.atoms; al != nil; al = tl al){
		(name, nil, nil) := hd al;
		if(name == a)
			return (w, a);
	}
	ferror(file, n, "corpus/align", sys->sprint("%s's reading declares no atom %s", w.id, a));
	return (nil, nil);
}

#
# The works over the shared atoms
#

writeshared(w: ref Work)
{
	file := dir + "/readings/" + w.id + "/shared.logic";
	b := bufio->create(file, Bufio->OWRITE, 8r666);
	if(b == nil)
		fatal(sys->sprint("cannot create %s: %r", file));
	b.puts(sys->sprint("# %s over the corpus's shared atoms, written by phil/corpus from readings/%s/logic: not to be edited\n", w.id, w.id));
	if(w.logic != nil)
		b.puts(w.logic + "\n");
	for(dl := w.domains; dl != nil; dl = tl dl)
		b.puts(hd dl + "\n");
	for(al := atomlines(w, nil); al != nil; al = tl al)
		b.puts(hd al + "\n");
	for(sl := w.stmts; sl != nil; sl = tl sl){
		st := hd sl;
		st.shared = rewrite(st.formula, w.rename);
		s := st.name + "\t" + sentname(st.sent) + "\t" + st.shared;
		for(rl := st.rest; rl != nil; rl = tl rl)
			s += "\t" + hd rl;
		b.puts(s + "\n");
	}
	b.close();
	# each formula as prove writes it, in ASCII: the same claim written
	# two ways is one
	t := tmpname();
	err := run("phil/prove -A -f " + quote(file) + " > " + quote(t) + " >[2] /dev/null");
	w.readable = err == nil;
	if(!w.readable)
		ferror(file, 0, "corpus/unreadable", sys->sprint("the prover cannot read %s's reading over the shared atoms: phil/prove %s", w.id, file));
	byname: list of (string, string);
	if(w.readable)
		for(l := lines(t); l != nil; l = tl l){
			(nf, f) := sys->tokenize(hd l, "\t");
			if(nf >= 3 && stmtname(hd f))
				byname = (hd f, hd tl tl f) :: byname;
		}
	sys->remove(t);
	for(sl = w.stmts; sl != nil; sl = tl sl){
		st := hd sl;
		c := lookup(st.name, byname);
		if(c == nil)
			c = st.shared;
		st.canon = unspace(c);
	}
}

# The atom lines a work's shared form needs: the shared atoms it uses,
# and its own, renamed; with also, another work's own atoms too.
atomlines(w: ref Work, also: ref Work): list of string
{
	r: list of string;
	seen: list of string;
	for(ws := w :: also :: nil; ws != nil; ws = tl ws){
		x := hd ws;
		if(x == nil)
			continue;
		for(al := x.atoms; al != nil; al = tl al){
			(name, params, m) := hd al;
			dest := lookup(name, x.rename);
			if(dest != nil && dest[0] == '!')
				dest = dest[1:];
			if(dest == nil || member(dest, seen))
				continue;
			seen = dest :: seen;
			if((sl := sharedline(dest)) != nil)
				r = sl :: r;
			else
				r = "atom\t" + dest + params + "\t" + m :: r;
		}
	}
	return revs(r);
}

# A formula with each atom the work declares renamed: to a shared atom,
# its denial, or the work's own name.  A name inside an atom's
# arguments is a term, not an atom, and is left as it is.
rewrite(f: string, ren: list of (string, string)): string
{
	r := "";
	args := 0;		# how deep in an atom's arguments
	opens: list of int;	# for each ( open, whether it began arguments
	after := 0;		# the last thing read was an atom's name
	for(i := 0; i < len f; ){
		c := f[i];
		if(isidstart(c)){
			j := i;
			while(j < len f && isidchar(f[j]))
				j++;
			id := f[i:j];
			dest: string;
			if(args == 0)
				dest = lookup(id, ren);
			if(dest != nil)
				r += dest;
			else
				r += id;
			after = 1;
			i = j;
			continue;
		}
		if(c == '('){
			a := after || args > 0;
			opens = a :: opens;
			if(a)
				args++;
		}else if(c == ')'){
			if(opens != nil){
				if(hd opens)
					args--;
				opens = tl opens;
			}
		}
		if(c != ' ' && c != '\t')
			after = 0;
		r[len r] = c;
		i++;
	}
	return r;
}

#
# Ids
#

writeids()
{
	b := bufio->create(dir + "/ids", Bufio->OWRITE, 8r666);
	if(b == nil)
		fatal(sys->sprint("cannot create %s/ids: %r", dir));
	b.puts("# every statement's id, written by phil/corpus: work, id, name, sentence, formula over the shared atoms\n");
	for(wl := works; wl != nil; wl = tl wl){
		w := hd wl;
		used: list of string;
		for(sl := w.stmts; sl != nil; sl = tl sl){
			st := hd sl;
			kind := st.name[0:1];
			if(st.says != nil)
				kind += "says " + st.says;
			base := "k" + hex(w.id + "\t" + kind + "\t" + st.canon, 4);
			id := base;
			for(k := 2; member(id, used); k++)
				id = base + "." + string k;
			used = id :: used;
			st.id = id;
			b.puts(sys->sprint("id\t%s\t%s\t%s\t%s\t%s\n", w.id, id, st.name, sentname(st.sent), st.canon));
		}
	}
	b.close();
}

#
# Claims
#

Claim: adt {
	key:	string;
	rels:	list of (string, ref Work, ref St);	# how, by whom, where
};
claims: list of ref Claim;	# in the order first met

writeclaims()
{
	for(wl := works; wl != nil; wl = tl wl){
		w := hd wl;
		for(sl := w.stmts; sl != nil; sl = tl sl){
			st := hd sl;
			c := st.name[0];
			if(c == 'O' || c == 'R')
				continue;	# a move in an exchange, not a commitment
			(key, neg) := polarity(st.canon);
			how: string;
			if(st.says != nil)
				how = "reports";
			else if(c == 'A')
				how = "assumes";
			else
				how = "asserts";
			if(neg)
				case how {
				"reports" =>	how = "reports-not";
				"assumes" =>	how = "assumes-not";
				* =>	how = "denies";
				}
			cl := claimof(key);
			cl.rels = (how, w, st) :: cl.rels;
		}
	}
	b := bufio->create(dir + "/claims", Bufio->OWRITE, 8r666);
	if(b == nil)
		fatal(sys->sprint("cannot create %s/claims: %r", dir));
	b.puts("# each claim and the works that assert, deny, assume or report it, written by phil/corpus\n");
	for(cl := revc(claims); cl != nil; cl = tl cl){
		c := hd cl;
		s := "claim\t" + c.key;
		for(rl := revrel(c.rels); rl != nil; rl = tl rl){
			(how, w, st) := hd rl;
			s += "\t" + how + " " + w.id + ":" + st.name;
			if(st.says != nil)
				s += " " + st.says;
		}
		b.puts(s + "\n");
		nclaims++;
	}
	b.close();
}

claimof(key: string): ref Claim
{
	for(l := claims; l != nil; l = tl l)
		if((hd l).key == key)
			return hd l;
	c := ref Claim(key, nil);
	claims = c :: claims;
	return c;
}

# A claim and whether the formula denies it: an even number of ! before
# an atom or a bracketed formula is none.
polarity(f: string): (string, int)
{
	neg := 0;
	for(;;){
		if(len f > 1 && f[0] == '!' && (isidstart(f[1]) || f[1] == '(' || f[1] == '!') && whole(f[1:])){
			neg = !neg;
			f = f[1:];
			continue;
		}
		if(len f > 2 && f[0] == '(' && f[len f-1] == ')' && closes(f, 0) == len f-1){
			f = f[1:len f-1];
			continue;
		}
		break;
	}
	return (f, neg);
}

# Whether f is one atom (with its arguments), or one bracketed formula,
# or another denial of one: what ! before it denies all of.
whole(f: string): int
{
	if(f[0] == '!')
		return len f > 1 && whole(f[1:]);
	if(f[0] == '(')
		return closes(f, 0) == len f-1;
	j := 0;
	while(j < len f && isidchar(f[j]))
		j++;
	if(j == len f)
		return 1;
	return f[j] == '(' && closes(f, j) == len f-1;
}

# Where the bracket opened at i closes, or -1.
closes(f: string, i: int): int
{
	d := 0;
	for(; i < len f; i++)
		if(f[i] == '(')
			d++;
		else if(f[i] == ')' && --d == 0)
			return i;
	return -1;
}

#
# Who says what
#

attributions()
{
	for(wl := works; wl != nil; wl = tl wl){
		w := hd wl;
		for(sl := w.stmts; sl != nil; sl = tl sl){
			st := hd sl;
			if(st.says == nil)
				continue;
			x := workof(st.says);
			if(x == nil)
				x = workbykey(st.says);
			if(x == nil){
				nunread++;
				sfind(w, st, "claims/attributed-unread", sys->sprint("%s gives %s as the view of %s, which is not in the corpus: add it to check", st.name, show(st), st.says));
				continue;
			}
			if(x == w || !x.readable || !w.readable)
				continue;
			v := entails(x, w, st.shared);
			if(v == 1){
				nheld++;
				continue;
			}
			if(v < 0){
				sfind(w, st, "claims/unchecked", sys->sprint("%s gives %s as %s's, but what %s holds, as read, cannot be decided against it", st.name, show(st), x.id, x.id));
				continue;
			}
			if(entails(x, w, "!(" + st.shared + ")") == 1){
				ncontra++;
				sfind(w, st, "claims/contradicts-source", sys->sprint("%s gives %s as %s's, but what %s holds, as read (readings/%s/logic), entails its denial", st.name, show(st), x.id, x.id, x.id));
			}else{
				nmis++;
				sfind(w, st, "claims/misattributed", sys->sprint("%s gives %s as %s's, but nothing %s holds, as read (readings/%s/logic), entails it, nor its denial", st.name, show(st), x.id, x.id, x.id));
			}
		}
	}
	# a claim no work holds: none whose own commitments entail it, as
	# reported (its denial is another claim), the reporting work's own
	# included; decided by prove, so that a claim held in other words
	# is held
	for(wl = works; wl != nil; wl = tl wl){
		w := hd wl;
		for(sl := w.stmts; sl != nil; sl = tl sl){
			st := hd sl;
			if(st.says == nil || !w.readable)
				continue;
			held := 0;
			for(yl := works; yl != nil && !held; yl = tl yl)
				if((hd yl).readable && entails(hd yl, w, st.shared) == 1)
					held = 1;
			if(held)
				continue;
			nonly++;
			sfind(w, st, "claims/reported-only", sys->sprint("%s gives %s as %s's, and no work in the corpus holds it: it is only reported", st.name, show(st), st.says));
		}
	}
}

# Whether what x holds (its premises, assumptions and conclusions, but
# not what it reports) entails f, a formula over the shared atoms that
# w states: 1 if it does, 0 if a case refutes it, -1 if prove cannot
# say.  Prove decides, over the shared atoms, with both works' own.
entails(x, w: ref Work, f: string): int
{
	t := tmpname();
	b := bufio->create(t, Bufio->OWRITE, 8r666);
	if(b == nil)
		fatal(sys->sprint("cannot create %s: %r", t));
	if(x.logic != nil)
		b.puts(x.logic + "\n");
	else if(w.logic != nil)
		b.puts(w.logic + "\n");
	for(dl := x.domains; dl != nil; dl = tl dl)
		b.puts(hd dl + "\n");
	for(dl = w.domains; dl != nil; dl = tl dl)
		b.puts(hd dl + "\n");
	for(al := atomlines(x, w); al != nil; al = tl al)
		b.puts(hd al + "\n");
	k := 0;
	for(sl := x.stmts; sl != nil; sl = tl sl){
		st := hd sl;
		c := st.name[0];
		if(st.says != nil || c == 'O' || c == 'R')
			continue;
		b.puts(sys->sprint("P%d\t-\t%s\n", ++k, st.shared));
	}
	b.puts("C\t-\t" + f + "\n");
	b.close();
	o := tmpname();
	run("phil/prove " + quote(t) + " > " + quote(o) + " >[2=1]");
	# a claim the other work states outright is one it holds, though
	# prove calls an argument to it circular; one true in every case,
	# trivially; and premises that contradict each other or a claim
	# prove cannot decide settle nothing
	v := -1;
	held := 0;
	moot := 0;
	for(l := lines(o); l != nil; l = tl l){
		s := hd l;
		if(suffix(s, "argue/valid 1"))
			v = 1;
		else if(suffix(s, "argue/valid 0"))
			v = 0;
		if(contains(s, ": argue/circular: ") || contains(s, ": argue/trivial: "))
			held = 1;
		if(contains(s, ": argue/inconsistent: ") || contains(s, ": argue/syntax: ") || contains(s, ": argue/undecided: "))
			moot = 1;
	}
	sys->remove(t);
	sys->remove(o);
	if(moot)
		return -1;
	if(held)
		return 1;
	return v;
}

measures()
{
	out.puts(sys->sprint("%s: corpus/works %d\n", dir, len works));
	out.puts(sys->sprint("%s: corpus/claims %d\n", dir, nclaims));
	out.puts(sys->sprint("%s: claims/attributed %d\n", dir, nheld));
	out.puts(sys->sprint("%s: claims/misattributed %d\n", dir, nmis));
	out.puts(sys->sprint("%s: claims/contradicts-source %d\n", dir, ncontra));
	out.puts(sys->sprint("%s: claims/attributed-unread %d\n", dir, nunread));
	out.puts(sys->sprint("%s: claims/reported-only %d\n", dir, nonly));
}

#
# Findings
#

# A finding about a work's statement: at its sentence in the work's
# text, when there is one, or else at its line in the reading.
sfind(w: ref Work, st: ref St, rule, msg: string)
{
	msg = w.id + " " + msg;
	if(w.doc != nil && st.sent > 0 && st.sent <= len w.sents){
		s := w.sents[st.sent-1];
		out.puts(prose->finding(w.doc, s.line, s.q0, s.q1, rule, msg));
	}else
		out.puts(prose->finding(dir + "/readings/" + w.id + "/logic", st.line, -1, -1, rule, msg));
}

ferror(file: string, line: int, rule, msg: string)
{
	if(line > 0)
		out.puts(sys->sprint("%s:%d: %s: %s\n", file, line, rule, msg));
	else
		out.puts(sys->sprint("%s: %s: %s\n", file, rule, msg));
	errors++;
}

# A claim as a finding gives it: its formula over the shared atoms, and
# what its atom means where it is one.
show(st: ref St): string
{
	(key, neg) := polarity(st.canon);
	m := meaning(key);
	s := "\"" + st.canon + "\"";
	if(m != nil){
		if(neg)
			m = "not: " + m;
		s += " (" + m + ")";
	}
	return s;
}

meaning(a: string): string
{
	for(l := shared; l != nil; l = tl l){
		(name, line) := hd l;
		if(name == a){
			(nf, f) := sys->tokenize(line, "\t");
			if(nf >= 3)
				return hd tl tl f;
		}
	}
	for(wl := works; wl != nil; wl = tl wl){
		w := hd wl;
		for(al := w.atoms; al != nil; al = tl al){
			(name, nil, m) := hd al;
			if(w.id + "_" + name == a)
				return m;
		}
	}
	return nil;
}

#
# Little things
#

fatal(s: string)
{
	sys->fprint(stderr, "phil/corpus: %s\n", s);
	raise "fail:error";
}

lines(file: string): list of string
{
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil)
		return nil;
	r: list of string;
	while((s := b.gets('\n')) != nil){
		if(s[len s-1] == '\n')
			s = s[0:len s-1];
		r = s :: r;
	}
	return revs(r);
}

run(cmd: string): string
{
	return sh->system(nil, cmd);
}

tmpname(): string
{
	return sys->sprint("/tmp/phil.corpus.%d.%d", sys->pctl(0, nil), ntmp++);
}

quote(s: string): string
{
	r := "'";
	for(i := 0; i < len s; i++){
		if(s[i] == '\'')
			r += "'";
		r[len r] = s[i];
	}
	return r + "'";
}

# SHA-1 of s, its first n bytes as hexadecimal digits
hex(s: string, n: int): string
{
	b := array of byte s;
	d := array[Keyring->SHA1dlen] of byte;
	kr->sha1(b, len b, d, nil);
	r := "";
	for(i := 0; i < n; i++)
		r += sys->sprint("%.2ux", int d[i]);
	return r;
}

atomname(s: string): (string, string)
{
	for(i := 0; i < len s && s[i] != '('; i++)
		;
	return (s[0:i], s[i:]);
}

sharedline(a: string): string
{
	for(l := shared; l != nil; l = tl l){
		(name, line) := hd l;
		if(name == a)
			return line;
	}
	return nil;
}

workof(id: string): ref Work
{
	for(l := works; l != nil; l = tl l)
		if((hd l).id == id)
			return hd l;
	return nil;
}

workbykey(key: string): ref Work
{
	for(l := works; l != nil; l = tl l)
		if((hd l).key == key && key != "-")
			return hd l;
	return nil;
}

lookup(s: string, l: list of (string, string)): string
{
	for(; l != nil; l = tl l){
		(a, b) := hd l;
		if(a == s)
			return b;
	}
	return nil;
}

member(s: string, l: list of string): int
{
	for(; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

stmtname(s: string): int
{
	if(s == nil)
		return 0;
	case s[0] {
	'P' or 'A' or 'C' or 'O' or 'R' =>
		return s == "C" || len s > 1 && s[1] >= '0' && s[1] <= '9';
	}
	return 0;
}

sentname(n: int): string
{
	if(n == 0)
		return "-";
	return "S" + string n;
}

isname(s: string): int
{
	if(s == nil || !isidstart(s[0]))
		return 0;
	for(i := 0; i < len s; i++)
		if(!isidchar(s[i]))
			return 0;
	return 1;
}

isidstart(c: int): int
{
	return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c == '_';
}

isidchar(c: int): int
{
	return isidstart(c) || c >= '0' && c <= '9';
}

# A formula without its blanks, but one between two words (ought p,
# all x), which it needs.
unspace(s: string): string
{
	r := "";
	for(i := 0; i < len s; i++){
		if(s[i] != ' ' && s[i] != '\t'){
			r[len r] = s[i];
			continue;
		}
		j := i;
		while(j < len s && (s[j] == ' ' || s[j] == '\t'))
			j++;
		if(len r > 0 && isidchar(r[len r-1]) && j < len s && isidchar(s[j]))
			r[len r] = ' ';
		i = j-1;
	}
	return r;
}

suffix(s, t: string): int
{
	return len s >= len t && s[len s - len t:] == t;
}

contains(s, t: string): int
{
	for(i := 0; i + len t <= len s; i++)
		if(s[i:i+len t] == t)
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

revst(l: list of ref St): list of ref St
{
	r: list of ref St;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

rev(l: list of ref Work): list of ref Work
{
	r: list of ref Work;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

revc(l: list of ref Claim): list of ref Claim
{
	r: list of ref Claim;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

revrel(l: list of (string, ref Work, ref St)): list of (string, ref Work, ref St)
{
	r: list of (string, ref Work, ref St);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

rev3(l: list of (string, string, string)): list of (string, string, string)
{
	r: list of (string, string, string);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

revpairs(l: list of (string, string)): list of (string, string)
{
	r: list of (string, string);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}
