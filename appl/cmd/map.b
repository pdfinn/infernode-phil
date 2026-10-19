implement Map;

#
# map - an argument's shape, from its logic file: the conclusion, what
# each step is drawn from, down to the premises, as a tree in text; or
# with -a, in Argdown, for the argument-mapping tools that read it
# (each step a premise-conclusion structure, steps joined where one's
# conclusion is another's premise).
#
# Given the document, each statement is shown by its sentence, with its
# address; given phil/prove's findings (-f), each is marked with what
# prove found of it, and one the text never states is shown as prove
# reads it back (prove -e).  map decides nothing: prove judges, map
# draws.
#
#	phil/prove -e essay.logic essay.md > findings
#	phil/map -f findings essay.logic essay.md
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

Map: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

progname := "phil/map";

include "findings.b";

Node: adt {
	name:	string;
	sent:	int;
	formula:	string;
	from:	list of string;
	against:	list of string;
	reads:	string;		# as prove reads it back
	marks:	list of string;	# what prove found of it
	line:	int;		# in the logic file
	says:	string;	# whose claim it reports, if it reports one
};

nodes: list of ref Node;	# in the order of the file
doc: string;
sents: array of ref Sent;
logic: string;
out: ref Iobuf;

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	prose = load Prose Prose->PATH;
	if(prose == nil)
		fatal(sys->sprint("cannot load %s: %r", Prose->PATH));
	prose->init();
	arg := load Arg Arg->PATH;

	aflag := 0;
	ffile: string;
	arg->init(args);
	arg->setusage("phil/map [-a] [-f findings] logicfile [document]");
	while((o := arg->opt()) != 0)
		case o {
		'a' =>	aflag = 1;
		'f' =>	ffile = arg->earg();
		* =>	arg->usage();
		}
	args = arg->argv();
	if(args == nil || len args > 2)
		arg->usage();
	logic = hd args;
	if(tl args != nil){
		(name, lines, err) := prose->readtext(hd tl args, Prose->Fauto);
		if(err != nil)
			fatal(err);
		doc = name;
		sents = prose->sentences(name, lines);
	}
	readlogic(logic);
	if(ffile != nil)
		readfindings(ffile);
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);
	c := named("C");
	if(c == nil)
		fatal(logic + ": no conclusion (a line C)");
	if(aflag)
		argdown(c);
	else{
		tree(c, "", "", nil);
		# steps the conclusion does not rest on, after the tree
		head := 0;
		for(l := nodes; l != nil; l = tl l){
			n := hd l;
			if(isconcl(n.name) && n.name != "C" && !reached(n, c, nil)){
				if(!head++)
					out.puts("\nnot on the way to C:\n");
				tree(n, "", "", nil);
			}
		}
	}
	out.flush();
}

readlogic(file: string)
{
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil)
		fatal(sys->sprint("cannot open %s: %r", file));
	n := 0;
	r: list of ref Node;
	while((s := b.gets('\n')) != nil){
		n++;
		if(s[len s-1] == '\n')
			s = s[0:len s-1];
		(nf, fl) := sys->tokenize(s, "\t");
		if(nf < 3 || (hd fl)[0] == '#' || hd fl == "atom" || hd fl == "domain" || hd fl == "logic")
			continue;
		name := hd fl;
		where := hd tl fl;
		sn := 0;
		if(len where > 1 && where[0] == 'S')
			sn = int where[1:];
		nd := ref Node(name, sn, hd tl tl fl, nil, nil, nil, nil, n, nil);
		# after the formula, any order: from, against, says, kind
		for(xl := tl tl tl fl; xl != nil; xl = tl xl){
			(nil, ws) := sys->tokenize(hd xl, " ,");
			if(ws != nil && hd ws == "from")
				nd.from = tl ws;
			if(ws != nil && hd ws == "against")
				nd.against = tl ws;
			if(ws != nil && hd ws == "says" && tl ws != nil)
				nd.says = hd tl ws;
		}
		r = nd :: r;
	}
	for(; r != nil; r = tl r)
		nodes = hd r :: nodes;
}

# prove's findings about each statement: its reading back, and the rest
# by rule, short.
readfindings(file: string)
{
	for(l := readinput(file :: nil); l != nil; l = tl l){
		(f, nil) := parse(hd l);
		if(f == nil || len f.rule < 6 || f.rule[0:6] != "argue/")
			continue;
		name := f.msg;
		for(i := 0; i < len name; i++)
			if(name[i] == ' ' || name[i] == ':')
				break;
		n := named(name[0:i]);
		if(n == nil)
			continue;
		rule := f.rule[6:];
		# the case that refutes a step, as a model: no fault of its own
		if(rule == "countermodel")
			continue;
		if(rule == "says"){
			q := f.msg;
			for(i = 0; i < len q && q[i] != '"'; i++)
				;
			if(i < len q){
				q = q[i+1:];
				if(len q > 0 && q[len q-1] == '"')
					q = q[0:len q-1];
				n.reads = q;
			}
			continue;
		}
		if(!member(rule, n.marks))
			n.marks = rule :: n.marks;
	}
}

# What a statement rests on, as phil/prove takes it: what its from
# names, or for a conclusion without one, the steps before it and the
# premises they do not draw on.
support(n: ref Node): list of ref Node
{
	r: list of ref Node;
	if(n.from != nil){
		for(fl := n.from; fl != nil; fl = tl fl)
			if((s := named(hd fl)) != nil)
				r = s :: r;
		return rev(r);
	}
	if(!isconcl(n.name))
		return nil;
	for(l := nodes; l != nil && hd l != n; l = tl l){
		s := hd l;
		if(isconcl(s.name)){
			r = s :: r;
			continue;
		}
		drawn := 0;
		for(m := nodes; m != nil && hd m != n; m = tl m)
			if(member(s.name, (hd m).from))
				drawn = 1;
		if(!drawn)
			r = s :: r;
	}
	return rev(r);
}

# The tree in text: each statement, then what it rests on beneath it,
# and the objections to it, each with the replies to it.
tree(n: ref Node, lead, more: string, path: list of ref Node)
{
	out.puts(lead + label(n));
	if(inlistn(n, path)){
		out.puts("  (round in a circle)\n");
		return;
	}
	out.puts("\n");
	kids: list of (ref Node, string);
	for(sl := rev(support(n)); sl != nil; sl = tl sl)
		kids = (hd sl, "") :: kids;
	for(al := attackers(n); al != nil; al = tl al)
		kids = appendk(kids, hd al, "against: ");
	for(; kids != nil; kids = tl kids){
		(k, how) := hd kids;
		last := tl kids == nil;
		branch := "├─ ";
		next := "│  ";
		if(last){
			branch = "└─ ";
			next = "   ";
		}
		tree(k, more + branch + how, more + next, n :: path);
	}
}

# The objections and replies aimed at n, in the order of the file.
attackers(n: ref Node): list of ref Node
{
	r: list of ref Node;
	for(l := nodes; l != nil; l = tl l)
		if(member(n.name, (hd l).against))
			r = hd l :: r;
	return rev(r);
}


appendk(l: list of (ref Node, string), n: ref Node, how: string): list of (ref Node, string)
{
	if(l == nil)
		return (n, how) :: nil;
	return hd l :: appendk(tl l, n, how);
}

# A statement as the tree shows it: its name, its sentence or what it
# says, what prove found of it, and where it is.
label(n: ref Node): string
{
	s := n.name;
	if(n.sent > 0)
		s += sys->sprint(" (S%d)", n.sent);
	else if(n.name[0] == 'A')
		s += " (unstated)";
	if(n.says != nil)
		s += ", what " + n.says + " says";
	s += ": " + text(n);
	if(n.marks != nil){
		m := "";
		for(l := rev2(n.marks); l != nil; l = tl l){
			if(m != "")
				m += ", ";
			m += hd l;
		}
		s += "  [" + m + "]";
	}
	if(doc != nil && n.sent > 0 && n.sent <= len sents)
		s += "  " + sys->sprint("%s:%d", doc, sents[n.sent-1].line);
	return s;
}

text(n: ref Node): string
{
	if(doc != nil && n.sent > 0 && n.sent <= len sents)
		return sents[n.sent-1].s;
	if(n.reads != nil)
		return n.reads;
	return n.formula;
}

# Argdown: each step as premises above a line and its conclusion
# below, statements named as in the logic file so that a step's
# conclusion and a later step's premise are one statement.
argdown(c: ref Node)
{
	out.puts(sys->sprint("// %s, as phil/map draws it\n", logic));
	k := 0;
	for(l := nodes; l != nil; l = tl l){
		n := hd l;
		if(!isconcl(n.name))
			continue;
		ps := support(n);
		if(ps == nil)
			continue;
		out.puts(sys->sprint("\n<%s>", stepname(n, c)));
		if(n.marks != nil)
			out.puts(" #" + hd rev2(n.marks));
		out.puts("\n\n");
		i := 1;
		for(; ps != nil; ps = tl ps)
			out.puts(sys->sprint("(%d) %s\n", i++, adstatement(hd ps)));
		out.puts("----\n");
		out.puts(sys->sprint("(%d) %s\n", i, adstatement(n)));
		k++;
	}
	# objections and replies, as attacks between statements
	head := 0;
	for(l = nodes; l != nil; l = tl l){
		n := hd l;
		if(n.against != nil || attackers(n) == nil)
			continue;
		if(!head++)
			out.puts("\n// objections and replies\n");
		out.puts("\n[" + n.name + "]\n");
		adattacks(n, "    ", n :: nil);
	}
}

adattacks(n: ref Node, ind: string, path: list of ref Node)
{
	for(al := attackers(n); al != nil; al = tl al){
		a := hd al;
		if(inlistn(a, path)){
			out.puts(ind + "<- [" + a.name + "]\n");
			continue;
		}
		out.puts(ind + "<- " + adstatement(a) + "\n");
		adattacks(a, ind + "    ", a :: path);
	}
}

stepname(n, c: ref Node): string
{
	if(n == c)
		return "Argument";
	return "Step " + n.name;
}

adstatement(n: ref Node): string
{
	s := "[" + n.name + "]: " + text(n);
	if(n.name[0] == 'A')
		s += " #unstated";
	return s;
}

# Whether from n, going down what each step rests on, m is reached.
reached(m, n: ref Node, seen: list of ref Node): int
{
	if(n == m)
		return 1;
	if(inlistn(n, seen))
		return 0;
	for(l := support(n); l != nil; l = tl l)
		if(reached(m, hd l, n :: seen))
			return 1;
	return 0;
}

isconcl(n: string): int
{
	return n == "C" || len n > 1 && n[0] == 'C' && n[1] >= '0' && n[1] <= '9';
}

named(name: string): ref Node
{
	for(l := nodes; l != nil; l = tl l)
		if((hd l).name == name)
			return hd l;
	return nil;
}

inlistn(n: ref Node, l: list of ref Node): int
{
	for(; l != nil; l = tl l)
		if(hd l == n)
			return 1;
	return 0;
}

member(s: string, l: list of string): int
{
	for(; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

rev(l: list of ref Node): list of ref Node
{
	r: list of ref Node;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

rev2(l: list of string): list of string
{
	r: list of string;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

fatal(s: string)
{
	sys->fprint(sys->fildes(2), "phil/map: %s\n", s);
	raise "fail:error";
}
