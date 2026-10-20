implement Align;

#
# phil/align [-w min] a.logic b.logic - which atoms of two readings of
# one text are one claim, by rule: where both readings have a statement
# at the same sentence of the same form (each atom a letter in the order
# it is first used, as phil/shape gives it), their atoms stand in the
# same places, and each such place is a vote that the two are one
# (where a sentence has several statements of one form in each, they are
# paired one to one, the pair whose atoms' meanings agree best first).  An
# atom of a goes with the atom of b that has most votes; a line each, as
# a corpus's align file has them, the last field what decided it:
#
#	same	a:earth_common	b:common_earth	rule=shape votes=2 sentences=S1,S4 words=1.00
#
# words is how far the two atoms' meanings share their content words
# (Dice, each word without its ending): a second opinion, from the
# words, beside the first, from the form.  An atom that had votes for
# another atom of b too says so (contested=name); one that is the same
# at no sentence, but whose meaning shares at least min of its words
# with an atom of b (-w, 0.6 by default), is proposed on the words alone,
# as negates where one meaning denies and the other does not:
#
#	same	a:removes	b:removed	rule=words words=0.83
#	negates	a:need_god	b:no_need_god	rule=words words=0.91
#
# A predicate's arity is part of its form.  An alignment by form whose
# meanings share less than 0.3 of their words says doubt=words: where a
# sentence has many statements of one form, the form can pair the
# wrong ones, and the words are the check.
#
# Nothing is decided: the lines are proposals, for phil/settle or a
# person, and for phil/prove -c once b's atoms are renamed by them.
# Two readings of one text by two readers, of two models or a model and
# phil/skeleton, are compared this way where their atoms differ.  For
# two works, which share no sentences, only the words propose.
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";

Align: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

Stmt: adt {
	sent:	string;
	form:	string;
	atoms:	array of string;	# in the order of the form's letters
};

Reading: adt {
	name:	string;
	stmts:	list of ref Stmt;
	atoms:	list of (string, string);	# name, meaning
};

Vote: adt {
	a:	string;
	b:	string;
	n:	int;
	sents:	list of string;
};

STOP := array[] of {
	"a", "an", "the", "this", "that", "these", "those", "it", "its", "he", "she", "they", "them",
	"his", "her", "their", "we", "us", "our", "i", "me", "my", "you", "your", "one", "x", "y",
	"be", "is", "are", "was", "were", "been", "being", "am", "have", "has", "had", "hath",
	"do", "does", "did", "will", "would", "shall", "should", "must", "may", "might", "can", "could",
	"ought", "who", "whom", "which", "what", "whose", "there", "then", "also", "very", "only",
	"to", "of", "in", "on", "at", "by", "for", "with", "from", "as", "into", "upon", "if",
	"so", "and", "or", "but", "not", "no", "all", "every", "each", "some", "any", "than",
};

out: ref Iobuf;

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	arg := load Arg Arg->PATH;
	if(bufio == nil || arg == nil)
		fatal(sys->sprint("cannot load: %r"));
	arg->init(args);
	arg->setusage("phil/align [-w min] a.logic b.logic");
	minw := 0.6;
	while((o := arg->opt()) != 0)
		case o {
		'w' =>	minw = real arg->earg();
		* =>	arg->usage();
		}
	args = arg->argv();
	if(len args != 2)
		arg->usage();
	a := read(hd args);
	b := read(hd tl args);
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);

	# votes: statements at one sentence of one form, paired one to one,
	# the pair whose atoms' meanings agree best first
	votes: list of ref Vote;
	used: list of ref Stmt;
	for(;;) {
		bx, by: ref Stmt;
		bs := -1.0;
		for(sa := a.stmts; sa != nil; sa = tl sa)
			for(sb := b.stmts; sb != nil; sb = tl sb) {
				x := hd sa;
				y := hd sb;
				if(x.sent != y.sent || x.sent == "-" || x.form != y.form)
					continue;
				if(inlist(used, x) || inlist(used, y))
					continue;
				sc := 0.0;
				for(i := 0; i < len x.atoms && i < len y.atoms; i++)
					sc += dice(meaning(a, x.atoms[i]), meaning(b, y.atoms[i]));
				if(sc > bs) {
					bs = sc;
					bx = x;
					by = y;
				}
			}
		if(bx == nil)
			break;
		used = bx :: by :: used;
		for(i := 0; i < len bx.atoms && i < len by.atoms; i++)
			votes = vote(votes, bx.atoms[i], by.atoms[i], bx.sent);
	}

	done: list of string;
	for(al := rev(a.atoms); al != nil; al = tl al) {
		(an, am) := hd al;
		best: ref Vote;
		second := "";
		for(vl := votes; vl != nil; vl = tl vl) {
			v := hd vl;
			if(v.a != an)
				continue;
			if(best == nil || v.n > best.n) {
				if(best != nil)
					second = best.b;
				best = v;
			} else if(v.b != best.b)
				second = v.b;
		}
		if(best != nil) {
			w := dice(am, meaning(b, best.b));
			s := sys->sprint("same\t%s:%s\t%s:%s\trule=shape votes=%d sentences=%s words=%.2f",
				a.name, an, b.name, best.b, best.n, join(rev1(best.sents)), w);
			if(second != "")
				s += " contested=" + second;
			# the form says one, the words almost nothing in common
			if(w < 0.3)
				s += " doubt=words";
			out.puts(s + "\n");
			done = an :: done;
			continue;
		}
		# no sentence of one form: the words alone, the best above min
		bw := 0.0;
		bn := "";
		for(bl := b.atoms; bl != nil; bl = tl bl) {
			(n, m) := hd bl;
			w := dice(am, m);
			if(w > bw) {
				bw = w;
				bn = n;
			}
		}
		if(bn != "" && bw >= minw) {
			# one meaning denied and the other not: the one negates the other
			rel := "same";
			if(denied(am) != denied(meaning(b, bn)))
				rel = "negates";
			out.puts(sys->sprint("%s\t%s:%s\t%s:%s\trule=words words=%.2f\n", rel, a.name, an, b.name, bn, bw));
		}
	}
	out.flush();
}

inlist(l: list of ref Stmt, s: ref Stmt): int
{
	for(; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

vote(l: list of ref Vote, a, b, sent: string): list of ref Vote
{
	for(v := l; v != nil; v = tl v)
		if((hd v).a == a && (hd v).b == b) {
			(hd v).n++;
			if(!has((hd v).sents, sent))
				(hd v).sents = sent :: (hd v).sents;
			return l;
		}
	return ref Vote(a, b, 1, sent :: nil) :: l;
}

# a reading: its atoms and meanings, and each statement's sentence, form
# and atoms; its name the file's, less .logic and its directories
read(f: string): ref Reading
{
	b := bufio->open(f, Bufio->OREAD);
	if(b == nil)
		fatal(sys->sprint("cannot open %s: %r", f));
	n := f;
	for(i := len n - 1; i >= 0; i--)
		if(n[i] == '/') {
			n = n[i+1:];
			break;
		}
	for(i = 0; i + 6 <= len n; i++)
		if(n[i:i+6] == ".logic") {
			n = n[0:i] + n[i+6:];
			break;
		}
	r := ref Reading(n, nil, nil);
	while((s := b.gets('\n')) != nil) {
		if(s[len s - 1] == '\n')
			s = s[0:len s - 1];
		(nf, fl) := sys->tokenize(s, "\t");
		if(nf < 3)
			continue;
		k := hd fl;
		if(k == "atom") {
			an := hd tl fl;
			for(j := 0; j < len an; j++)
				if(an[j] == '(') {
					an = an[0:j];
					break;
				}
			r.atoms = (an, hd tl tl fl) :: r.atoms;
			continue;
		}
		if(!stmt(k))
			continue;
		(form, atoms) := shape(ascii(hd tl tl fl));
		r.stmts = ref Stmt(hd tl fl, form, atoms) :: r.stmts;
	}
	return r;
}

stmt(k: string): int
{
	if(k == "")
		return 0;
	case k[0] {
	'P' or 'A' or 'O' or 'R' =>
		return len k > 1 && k[1] >= '0' && k[1] <= '9';
	'C' =>
		return len k == 1 || (k[1] >= '0' && k[1] <= '9');
	}
	return 0;
}

KEEP := array[] of {"all", "some", "ought", "permitted", "nec", "pos"};

# the form, each atom (a name, with its arguments if it has them) a
# letter in the order it is first used, and the atoms in that order
shape(f: string): (string, array of string)
{
	form := "";
	names: list of string;
	n := 0;
	for(i := 0; i < len f; ) {
		c := f[i];
		if(c == ' ' || c == '\t') {
			i++;
			continue;
		}
		if(!((c >= 'a' && c <= 'z') || c == '_')) {
			form[len form] = c;
			i++;
			continue;
		}
		j := i;
		while(j < len f && ((f[j] >= 'a' && f[j] <= 'z') || (f[j] >= '0' && f[j] <= '9') || f[j] == '_'))
			j++;
		w := f[i:j];
		# a quantifier's variable (x:), or a word of the notation
		if(member(w, KEEP) || (j < len f && f[j] == ':' && len w == 1)) {
			form += w;
			i = j;
			continue;
		}
		# a predicate's arguments go with it, and how many it has is
		# part of the form
		arity := 0;
		if(j < len f && f[j] == '(') {
			arity = 1;
			while(j < len f && f[j] != ')') {
				if(f[j] == ',')
					arity++;
				j++;
			}
			if(j < len f)
				j++;
		}
		name := w;
		k := 0;
		found := -1;
		for(l := revs(names); l != nil; l = tl l) {
			if(hd l == name)
				found = k;
			k++;
		}
		if(found < 0) {
			names = name :: names;
			found = n++;
		}
		form[len form] = 'a' + found;
		if(arity)
			form += "/" + string arity;
		i = j;
	}
	a := array[n] of string;
	k := 0;
	for(l := revs(names); l != nil; l = tl l)
		a[k++] = hd l;
	return (form, a);
}

# the notation's other spelling, as phil/prove reads it
ascii(s: string): string
{
	r := "";
	for(i := 0; i < len s; i++) {
		case s[i] {
		'→' =>	r += "->";
		'↔' =>	r += "<->";
		'∧' =>	r += "&";
		'∨' =>	r += "|";
		'¬' =>	r += "!";
		'□' =>	r += "[]";
		'◇' =>	r += "<>";
		'∀' =>
			if(i + 1 < len s) {
				r += "all " + s[i+1:i+2] + ": ";
				i++;
			}
		'∃' =>
			if(i + 1 < len s) {
				r += "some " + s[i+1:i+2] + ": ";
				i++;
			}
		* =>	r[len r] = s[i];
		}
	}
	return r;
}

meaning(r: ref Reading, n: string): string
{
	for(l := r.atoms; l != nil; l = tl l) {
		(an, am) := hd l;
		if(an == n)
			return am;
	}
	return "";
}

NEG := array[] of {"not", "no", "never", "nothing", "none", "nobody", "cannot", "neither", "nor"};

# whether a meaning denies: an odd number of its words are denials
denied(s: string): int
{
	n := 0;
	w := "";
	for(i := 0; i <= len s; i++) {
		c := ' ';
		if(i < len s)
			c = s[i];
		if(c >= 'A' && c <= 'Z')
			c += 'a' - 'A';
		if(c >= 'a' && c <= 'z' || c == '\'') {
			w[len w] = c;
			continue;
		}
		if(member(w, NEG) || (len w > 3 && w[len w - 3:] == "n't"))
			n++;
		w = "";
	}
	return n % 2;
}

# how far two meanings share their content words: Dice's coefficient
dice(a, b: string): real
{
	ka := words(a);
	kb := words(b);
	if(ka == nil || kb == nil)
		return 0.0;
	both := 0;
	for(l := ka; l != nil; l = tl l)
		if(has(kb, hd l))
			both++;
	return 2.0 * real both / real (len ka + len kb);
}

words(s: string): list of string
{
	r: list of string;
	w := "";
	for(i := 0; i <= len s; i++) {
		c := ' ';
		if(i < len s)
			c = s[i];
		if(c >= 'A' && c <= 'Z')
			c += 'a' - 'A';
		if(c >= 'a' && c <= 'z') {
			w[len w] = c;
			continue;
		}
		if(w != "" && !member(w, STOP)) {
			w = stem(w);
			if(!has(r, w))
				r = w :: r;
		}
		w = "";
	}
	return r;
}

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

join(l: list of string): string
{
	s := "";
	for(; l != nil; l = tl l) {
		if(s != "")
			s += ",";
		s += hd l;
	}
	return s;
}

rev(l: list of (string, string)): list of (string, string)
{
	r: list of (string, string);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

rev1(l: list of string): list of string
{
	r: list of string;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

revs(l: list of string): list of string
{
	return rev1(l);
}

fatal(s: string)
{
	sys->fprint(sys->fildes(2), "phil/align: %s\n", s);
	raise "fail:error";
}
