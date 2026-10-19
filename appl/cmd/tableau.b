implement Tableau;

#
# tableau - the tableaux phil/prove -P writes, typeset as the textbooks
# set them.  Each tree is a picture (pic) of its branches and the lines
# between them; every formula in it is mathematics (eqn), so it is set
# by eqn's rules in the mathematical font: atoms and variables italic,
# names of more than one letter roman, the connectives spaced as binary
# operators, ¬ □ ◇ O P close to what they govern, a world written w
# with its number below.  A branch is a column: each line's number
# set right in a gutter, its formula set left, and what it came from in
# a column of its own; a closed branch ends ×.  Where the tree branches,
# a line runs from under the branch to the head of each branch below.
#
# The connectives and the modal and deontic operators are the math
# font's (Libertinus Math's, font S), as TeX sets them, not the text
# font's; the box made the size of the diamond and set on the axis, as
# the font's own is an x-height square on the baseline.  A tree is
# kept whole on a page (.ne), and described for a tagged PDF (-mbook's
# .alt), its lines in order and each branch in turn.  Set alone (not
# under -mbook) the pages are given margins of an inch.
#
# An invalid conclusion's countermodel (prove's argue/countermodel) is
# a table (tbl): what is true where, a row to each claim or predicate
# and a column to each world (one, unnamed, outside modal logic), the
# worlds each sees (R) its last row, the domain (D) above it; T and F,
# each extension a set, every name and world as in the trees.
#
# The output wants pic, tbl, then eqn, then troff: in InferNode with the
# troff package, pic | tbl | eqn /lib/troff/eqnrc - | troff | tr2pdf.
# It reads prove's output, so a tree is typeset as it was proved, and
# nothing is proved here.
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
include "sh.m";

Tableau: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

progname := "phil/tableau";

include "findings.b";

Line: adt {
	num:	string;	# its number, or nil for a closing ×
	f:	string;	# the formula, as prove shows it
	why:	string;	# what it came from; for a ×, the lines that close it
	atfork:	int;	# what it came from is said at the fork above
	up:	int;	# an open branch's end (↑), why its case
	nw, fw, jw:	real;	# as troff sets them, in inches: its number, its formula (or ×), what it came from; -1.0 not measured
};

Node: adt {
	lines:	list of ref Line;	# latest first
	kids:	list of ref Node;	# latest first
	open:	int;	# the tree's: a branch stays open, the step not valid
};

out: ref Iobuf;

# Sizes in inches, for text at 11 points on 14.
LH: con 0.215;	# a line
JW: con 0.066;	# a character of what a line came from, set smaller
NUMGAP: con 0.07;	# between a line's number and its formula
WHYGAP: con 0.3;	# between the formulas and what they came from
GAP: con 0.45;	# between branches side by side
DROP: con 0.32;	# down a branch's line
TITLE: con 1.4;	# the title above the first line, in lines
APART: con 1.5;	# between trees, in lines

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	arg := load Arg Arg->PATH;
	arg->init(args);
	arg->setusage("phil/tableau [file ...]");
	while(arg->opt() != 0)
		arg->usage();
	args = arg->argv();
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);
	out.puts(PROLOGUE + PAGE + eqnprologue());
	title: string;
	body: list of string;
	open := 0;
	for(l := readinput(args); l != nil; l = tl l){
		s := hd l;
		if(s != nil && s[len s-1] == '\n')
			s = s[0:len s-1];
		if(len s > 2 && s[0:2] == "#\t" && title != nil){
			body = s[2:] :: body;
			continue;
		}
		if(title != nil)
			items = ref Item(title, mktree(rev(body), open), nil) :: items;
		(title, body) = (nil, nil);
		if(len s > 2 && s[0:2] == "# " && find(s, ", proved by a tableau") >= 0){
			title = s[2:find(s, ", proved by a tableau")];
			open = 0;
		}else if(len s > 2 && s[0:2] == "# " && find(s, ", not proved by a tableau") >= 0){
			title = s[2:find(s, ", not proved by a tableau")];
			open = 1;
		}
		else if((k := find(s, CM)) >= 0)
			items = ref Item(nil, nil, parsemodel(s[k+len CM:])) :: items;
	}
	if(title != nil)
		items = ref Item(title, mktree(rev(body), open), nil) :: items;
	items = revi(items);
	for(il := items; il != nil; il = tl il)
		if((hd il).root != nil)
			trees = ((hd il).title, (hd il).root) :: trees;
	trees = revt(trees);
	measureall(trees);
	for(il = items; il != nil; il = tl il){
		it := hd il;
		# an open tree before the countermodel read off it (prove
		# gives the model first)
		if(it.model != nil && tl il != nil && (hd tl il).root != nil &&
		   (hd tl il).root.open && (hd tl il).title == it.model.title){
			draw(((hd tl il).title, (hd tl il).root));
			il = tl il;
		}
		if(it.root != nil)
			draw((it.title, it.root));
		else if(it.model != nil)
			table(it.model);
	}
	out.flush();
}

mktree(lines: list of string, open: int): ref Node
{
	t := build(lines);
	t.open = open;
	return t;
}

CM: con ": argue/countermodel: ";

# what is set, in the order read: a tree, or a countermodel
Item: adt {
	title:	string;
	root:	ref Node;
	model:	ref Model;
};
items: list of ref Item;

revi(l: list of ref Item): list of ref Item
{
	r: list of ref Item;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

trees: list of (string, ref Node);

revt(l: list of (string, ref Node)): list of (string, ref Node)
{
	r: list of (string, ref Node);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

# eqn: the formulas between $ and $; the connectives binary operators
eqnprologue(): string
{
	s := ".EQ\ndelim $$\n";
	for(cl := "∧" :: "∨" :: "→" :: "↔" :: nil; cl != nil; cl = tl cl)
		s += sys->sprint("chartype bin \"%s\"\n", hd cl);
	return s + "chartype punct \",\"\n.EN\n";
}

#
# Measured: every number, formula and what it came from set by eqn and
# troff as they will be (the same prologue, at 11 points), each alone in
# a diversion, its width (dl) said on troff's standard error.  The
# layout then places each column and line from what troff will set, not
# from a guess at it.  Where eqn or troff cannot be run (the troff
# package not bound in), the widths are guessed as before.
#
MEASURE: con "/tmp/tableau.";

lines(n: ref Node): list of ref Line
{
	r := n.lines;
	for(kl := n.kids; kl != nil; kl = tl kl)
		for(l := lines(hd kl); l != nil; l = tl l)
			r = hd l :: r;
	return r;
}

measureall(ts: list of (string, ref Node))
{
	all: list of ref Line;
	for(t := ts; t != nil; t = tl t){
		(nil, root) := hd t;
		for(l := lines(root); l != nil; l = tl l)
			all = hd l :: all;
	}
	if(all == nil)
		return;
	doc := PROLOGUE + ".ps 11\n.vs 14\n" + eqnprologue() + ".nf\n";
	n := 0;
	for(l := all; l != nil; l = tl l){
		x := hd l;
		if(x.num == nil)
			doc += item(ending(x));
		else{
			doc += item(number(x.num)) + item(mathof(x.f));
			if(x.why != nil)
				doc += item(small(x.why));
		}
	}
	name := MEASURE + string sys->pctl(0, nil);
	if(writefile(name + ".ms", doc) < 0)
		return;
	sh := load Sh Sh->PATH;
	if(sh != nil)
		sh->system(nil, "{eqn /lib/troff/eqnrc " + name + ".ms | troff > /dev/null} >[2] " + name + ".err");
	got := readfile(name + ".err");
	sys->remove(name + ".ms");
	sys->remove(name + ".err");
	w: list of real;
	for(ls := splitlines(got); ls != nil; ls = tl ls)
		if(len hd ls > 8 && (hd ls)[0:8] == "tableau ")
			w = real (hd ls)[8:] / 1000.0 :: w;
	w = revr(w);
	for(l = all; l != nil; l = tl l){
		x := hd l;
		if(x.num == nil){
			if(w == nil)
				break;
			(x.fw, w) = (hd w, tl w);
			continue;
		}
		if(w == nil || tl w == nil)
			break;
		(x.nw, w) = (hd w, tl w);
		(x.fw, w) = (hd w, tl w);
		if(x.why != nil){
			if(w == nil)
				break;
			(x.jw, w) = (hd w, tl w);
		}
	}
	if(w != nil || l != nil)	# not what was asked for: guess, all alike
		for(l = all; l != nil; l = tl l)
			(hd l).nw = (hd l).fw = (hd l).jw = -1.0;
	n = 0;
}

item(s: string): string
{
	return ".di tableau-d\n\\&" + s + "\n.br\n.di\n" +
		".nr tableau-w \\n[dl]*1000/1i\n.tm tableau \\n[tableau-w]\n";
}

# as the picture sets them
number(n: string): string
{
	return "\\s-1" + n + ".\\s0";
}

small(s: string): string
{
	return "\\s-1" + esc(s) + "\\s0";
}

closing(why: string): string
{
	return "$times$ " + small(why);
}

# a branch's end: closed (×, the lines that close it) or open (↑, the
# case it describes, each atom's value at each world, in eqn)
ending(x: ref Line): string
{
	if(!x.up)
		return closing(x.why);
	r := "";
	for(segs := split(x.why, ';'); segs != nil; segs = tl segs){
		g := trim(hd segs);
		if(r != "")
			r += " ;~";
		if((j := find(g, ": ")) >= 0 && g[0] == 'w' && alldigits(g[1:j])){
			r += inner(mathof(g[0:j])) + " : ~";
			g = g[j+2:];
		}
		first := 1;
		for(as := split(g, ','); as != nil; as = tl as){
			a := trim(hd as);
			if((j = find(a, " = ")) < 0)
				continue;
			if(!first)
				r += " ,";
			first = 0;
			r += inner(mathof(a[0:j])) + " = roman " + a[j+3:];
		}
	}
	if(r == "")
		return "$↑$";
	return "$↑ ~" + r + "$";
}

# The symbols from the math font (by glyph name, so that none is defined
# by itself); the box from a copy of it a third larger, lowered so that
# its middle is on the axis; rules drawn as lines (troff's .rules), not
# rows of glyphs.  The page, if no macros have set one (the
# traps set alone: macros defined in a .if's braces are not kept whole).
PROLOGUE: con ".char → \\f[S]\\N'arrowright'\n" +
	".char ↔ \\f[S]\\N'arrowboth'\n" +
	".char ∧ \\f[S]\\N'logicaland'\n" +
	".char ∨ \\f[S]\\N'logicalor'\n" +
	".char ¬ \\f[S]\\N'logicalnot'\n" +
	".char ∀ \\f[S]\\N'universal'\n" +
	".char ∃ \\f[S]\\N'existential'\n" +
	".char ◇ \\f[S]\\N'uni25C7'\n" +
	".char × \\f[S]\\N'multiply'\n" +
	".char ∅ \\f[S]\\N'emptyset'\n" +
	".char ↑ \\f[S]\\N'arrowup'\n" +
	".rules 1\n" +
	".fp 13 SZ S\n" +
	".fzoom SZ 1333\n" +
	".char □ \\v'0.072m'\\f[SZ]\\N'H22073'\\v'-0.072m'\n";

# Set alone: the page's margins, and the type the trees are measured in.
PAGE: con ".de tableau-hd\n'sp |1i\n..\n" +
	".de tableau-fo\n'bp\n..\n" +
	".if !\\n[book-ps] .wh 0 tableau-hd\n" +
	".if !\\n[book-ps] .wh -1i tableau-fo\n" +
	".if !\\n[book-ps] .ps 11\n" +
	".if !\\n[book-ps] .vs 14\n";

# The tree from prove's lines: each line's prefix, three characters to a
# level, says where it hangs; ├─ and └─ begin a branch.
build(lines: list of string): ref Node
{
	root := ref Node(nil, nil, 0);
	stack := array[64] of ref Node;
	stack[0] = root;
	for(; lines != nil; lines = tl lines){
		s := hd lines;
		d := 0;
		branch := 0;
		while(len s >= 3 && d < 63){
			p := s[0:3];
			if(p == "├─ " || p == "└─ ")
				branch = 1;
			else if(p != "│  " && p != "   ")
				break;
			s = s[3:];
			d++;
		}
		if(branch){
			n := ref Node(nil, nil, 0);
			stack[d-1].kids = n :: stack[d-1].kids;
			stack[d] = n;
		}
		if(stack[d] == nil)
			continue;
		stack[d].lines = parseline(s) :: stack[d].lines;
	}
	return root;
}

draw(t: (string, ref Node))
{
	(title, root) := t;
	# whole on a page: its title, its lines, and the space after it
	out.puts(sys->sprint(".ne %si\n", fmt((TITLE + 1.0) * LH + height(root))));
	forks(root);
	out.puts(".alt \"" + esc(describe(title, root)) + "\"\n");
	out.puts(".PS\n");
	(nil, nil, axis) := measure(root);
	not := "";
	if(root.open)
		not = ", not valid";
	out.puts(sys->sprint("\"\\fI%s\\fP%s\" at (%s,%s)\n", esc(title), not, fmt(axis), fmt(TITLE * LH)));
	place(root, 0.0, 0.0);
	out.puts(sys->sprint(".PE\n.sp %s\n", fmt(APART)));
}

# How far the branch and those below it reach down from its first line,
# as place sets them.
height(n: ref Node): real
{
	h := 0.0;
	for(l := n.lines; l != nil; l = tl l)
		h += LH;
	k := 0.0;
	for(kl := n.kids; kl != nil; kl = tl kl)
		if(height(hd kl) > k)
			k = height(hd kl);
	if(n.kids != nil)
		h += DROP + 0.1 * LH + k;
	return h;
}

# Each fork's rule found, its branches' first lines not to say it again.
forks(n: ref Node)
{
	if(n.kids == nil)
		return;
	forkwhy(revk(n.kids));
	for(kl := n.kids; kl != nil; kl = tl kl)
		forks(hd kl);
}

count(n: int): string
{
	case n {
	2 =>	return "two";
	3 =>	return "three";
	4 =>	return "four";
	}
	return string n;
}

# The tree as one reads it out: its lines in order, then each branch.
describe(title: string, root: ref Node): string
{
	if(root.open)
		title += ", not valid (a branch stays open)";
	return "A tableau for " + title + ": " + branch(root);
}

branch(n: ref Node): string
{
	s := "";
	for(l := revl(n.lines); l != nil; l = tl l){
		ln := hd l;
		if(ln.num == nil && ln.up)
			s += "Open: " + ln.why + ". ";
		else if(ln.num == nil)
			s += "Closed by " + ln.why + ". ";
		else{
			s += ln.num + ". " + ln.f;
			if(ln.why != nil && !ln.atfork)
				s += ", " + ln.why;
			s += ". ";
		}
	}
	if(n.kids == nil)
		return s;
	kids := revk(n.kids);
	nk := 0;
	for(kl := kids; kl != nil; kl = tl kl)
		nk++;
	s += sys->sprint("It branches in %s", count(nk));
	why := (hd revl((hd kids).lines)).why;
	if((hd revl((hd kids).lines)).atfork && why != nil)
		s += ", by " + why;
	s += ". ";
	i := 1;
	for(kl = kids; kl != nil; kl = tl kl)
		s += sys->sprint("Branch %d: ", i++) + branch(hd kl);
	return s;
}

# "4. ¬q, w1   3 ¬□", "× 8, 9" or "↑ p = T, q = F": the number, the
# formula and what it came from, the last set apart by three blanks or
# more; a branch closed, by the lines given; a branch open, the case it
# describes.
parseline(s: string): ref Line
{
	if(len s > 1 && (s[0] == '↑' || s[0] == '^'))
		return ref Line(nil, nil, trim(s[1:]), 0, 1, -1.0, -1.0, -1.0);
	if(len s > 1 && s[0] == '×')
		return ref Line(nil, nil, trim(s[1:]), 0, 0, -1.0, -1.0, -1.0);
	num: string;
	for(i := 0; i < len s && s[i] >= '0' && s[i] <= '9'; i++)
		;
	if(i > 0 && i < len s && s[i] == '.'){
		num = s[0:i];
		s = trim(s[i+1:]);
	}
	for(i = 0; i+2 < len s; i++)
		if(s[i] == ' ' && s[i+1] == ' ' && s[i+2] == ' ')
			return ref Line(num, s[0:i], trim(s[i:]), 0, 0, -1.0, -1.0, -1.0);
	return ref Line(num, s, nil, 0, 0, -1.0, -1.0, -1.0);
}

# A branch's column: the width of its numbers, of its formulas and of
# what they came from.
column(n: ref Node): (real, real, real)
{
	(nw, fw, jw) := (0.0, 0.0, 0.0);
	for(l := n.lines; l != nil; l = tl l){
		x := hd l;
		if(x.num != nil && guess(x.nw, real (len x.num + 1) * JW) > nw)
			nw = guess(x.nw, real (len x.num + 1) * JW);
		w := guess(x.fw, mathwidth(x.f));
		if(x.num == nil)
			w = guess(x.fw, real (len x.why + 2) * JW);
		if(x.up)	# an open branch's case: under what lines came from, if it must
			continue;
		if(w > fw)
			fw = w;
		if(x.num != nil && x.why != nil && !x.atfork && guess(x.jw, real len x.why * JW) > jw)
			jw = guess(x.jw, real len x.why * JW);
	}
	return (nw, fw, jw);
}

# How wide the branch and all below it are, from its left edge; and
# where its axis, the middle of its formulas, falls.
measure(n: ref Node): (real, real, real)
{
	(nw, fw, jw) := column(n);
	own := nw + NUMGAP + fw + WHYGAP + jw;
	for(l := n.lines; l != nil; l = tl l)	# an open branch's case as wide as it is
		if((hd l).up && nw + NUMGAP + upwidth(hd l) > own)
			own = nw + NUMGAP + upwidth(hd l);
	axis := nw + NUMGAP + fw / 2.0;
	if(n.kids == nil)
		return (own, 0.0, axis);
	k := 0.0;
	nk := 0;
	for(kl := n.kids; kl != nil; kl = tl kl){
		(w, nil, nil) := measure(hd kl);
		k += w;
		nk++;
	}
	k += GAP * real (nk - 1);
	# the branches below are centred under the axis: as wide as needed
	half := k / 2.0;
	left := axis - half;
	off := 0.0;
	if(left < 0.0){
		off = -left;
		left = 0.0;
	}
	w := own + off;
	if(left + k > w)
		w = left + k;
	return (w, off, axis + off);
}

# The branch with its left edge at x and its first line at y, and the
# branches below it.
place(n: ref Node, x, y: real)
{
	(nw, fw, nil) := column(n);
	(nil, off, axis) := measure(n);
	fx := x + off + nw + NUMGAP;
	jx := fx + fw + WHYGAP;
	for(l := revl(n.lines); l != nil; l = tl l){
		ln := hd l;
		if(ln.num == nil)
			out.puts(sys->sprint("\"%s\" ljust at (%s,%s)\n", ending(ln), fmt(fx), fmt(y)));
		else{
			out.puts(sys->sprint("\"%s\" rjust at (%s,%s)\n", number(ln.num), fmt(fx - NUMGAP), fmt(y)));
			out.puts(sys->sprint("\"%s\" ljust at (%s,%s)\n", mathof(ln.f), fmt(fx), fmt(y)));
			if(ln.why != nil && !ln.atfork)
				out.puts(sys->sprint("\"%s\" ljust at (%s,%s)\n", small(ln.why), fmt(jx), fmt(y)));
		}
		y -= LH;
	}
	if(n.kids == nil)
		return;
	kids := revk(n.kids);
	total := 0.0;
	nk := 0;
	for(kl := kids; kl != nil; kl = tl kl){
		(w, nil, nil) := measure(hd kl);
		total += w;
		nk++;
	}
	total += GAP * real (nk - 1);
	ax := x + axis;
	left := ax - total / 2.0;
	if(left < x)
		left = x;
	top := y + LH * 0.45;
	bot := top - DROP;
	# what the branches came from, once, level with the fork, in the
	# column of what the lines above came from
	why := forkwhy(kids);
	if(why != nil)
		out.puts(sys->sprint("\"%s\" ljust at (%s,%s)\n", small(why), fmt(jx), fmt(top - DROP * 0.45)));
	for(kl = kids; kl != nil; kl = tl kl){
		(w, nil, kaxis) := measure(hd kl);
		out.puts(sys->sprint("line from (%s,%s) to (%s,%s)\n", fmt(ax), fmt(top), fmt(left + kaxis), fmt(bot)));
		place(hd kl, left, bot - LH * 0.55);
		left += w + GAP;
	}
}

#
# A formula as prove shows it, as eqn's input: each name of more than
# one letter roman, after \& so that no name is taken for one of eqn's
# words (in, over, from); a world's number below its w; R and the deontic O and P
# roman; the symbols as they are, spaced by their chartype.
#

mathof(f: string): string
{
	r := "";
	for(i := 0; i < len f; ){
		c := f[i];
		if(isalnum(c)){
			j := i;
			while(j < len f && isalnum(f[j]))
				j++;
			w := f[i:j];
			i = j;
			if(len w > 1 && w[0] == 'w' && alldigits(w[1:]))
				r += " w sub " + w[1:] + " ";
			else if(w == "R")
				r += " ~roman R~ ";
			else if(w == "O" || w == "P")
				r += " roman " + w + " ^ ";
			else if(len w == 1)
				r += " " + w + " ";
			else
				r += " roman \\&" + w + " ";
			continue;
		}
		case c {
		' ' =>	;
		'(' or ')' =>	r += " " + f[i:i+1] + " ";
		',' =>	r += " , ";
		'∀' or '∃' =>	r += " " + f[i:i+1] + " ";
		* =>	r[len r] = c;
		}
		i++;
	}
	return "$" + r + "$";
}

# What every branch's first line came from, if it is the same: the
# rule that made the fork.  Those lines then do not say it again.
forkwhy(kids: list of ref Node): string
{
	why: string;
	for(kl := kids; kl != nil; kl = tl kl){
		l := revl((hd kl).lines);
		if(l == nil || (hd l).num == nil)
			return nil;
		if(why == nil)
			why = (hd l).why;
		else if((hd l).why != why)
			return nil;
	}
	for(kl = kids; kl != nil; kl = tl kl)
		for(l := (hd kl).lines; l != nil; l = tl l)
			if((hd l).why == why)
				(hd l).atfork = 1;
	return why;
}

#
# A countermodel, as prove gives it ("C (S3): D = {web1}; patched = ∅,
# secure = {web1}", "C: W = {w0, w1}; R = {(w0, w1), (w1, w1)}; w0:
# p = F; w1: p = T"), as a table.
#

Model: adt {
	title:	string;	# the conclusion's, as prove names it: C (S3)
	dom:	list of string;	# D, if a domain is given
	worlds:	list of string;	# W, if modal; else nil, one world
	rel:	string;	# R as given: W × W, ∅, or its pairs
	note:	string;	# a word on R (□ over W, O over R)
	names:	list of string;	# the claims and predicates, as first given
	vals:	list of (string, string, string);	# world, name, value
};

parsemodel(s: string): ref Model
{
	m := ref Model(nil, nil, nil, nil, nil, nil, nil);
	k := find(s, ": ");
	if(k < 0)
		return nil;
	m.title = s[0:k];
	for(segs := split(s[k+2:], ';'); segs != nil; segs = tl segs){
		g := trim(hd segs);
		if(prefix("D = ", g))
			m.dom = elements(g[4:]);
		else if(prefix("W = ", g))
			m.worlds = elements(g[4:]);
		else if(prefix("R = ", g))
			m.rel = g[4:];
		else if((j := find(g, ": R = ")) >= 0){
			m.note = g[0:j];
			m.rel = g[j+6:];
		}else{
			w := "";
			if((j = find(g, ": ")) >= 0 && g[0] == 'w' && alldigits(g[1:j])){
				w = g[0:j];
				g = g[j+2:];
			}
			for(as := split(g, ','); as != nil; as = tl as){
				a := trim(hd as);
				if((j = find(a, " = ")) < 0)
					continue;
				n := a[0:j];
				if(!memberstr(n, m.names))
					m.names = n :: m.names;
				m.vals = (w, n, a[j+3:]) :: m.vals;
			}
		}
	}
	m.names = rev(m.names);
	return m;
}

# a set's elements: {a, b}, {(a, b)}, ∅
elements(s: string): list of string
{
	s = trim(s);
	if(s == "∅" || s == "{}" || s == "{ }")
		return nil;
	if(len s >= 2 && s[0] == '{' && s[len s-1] == '}')
		s = s[1:len s-1];
	r: list of string;
	for(l := split(s, ','); l != nil; l = tl l)
		if(trim(hd l) != "")
			r = trim(hd l) :: r;
	return rev(r);
}

# s cut at c, but not within braces or parentheses
split(s: string, c: int): list of string
{
	r: list of string;
	depth := 0;
	b := 0;
	for(i := 0; i < len s; i++){
		case s[i] {
		'{' or '(' =>	depth++;
		'}' or ')' =>	depth--;
		* =>
			if(s[i] == c && depth == 0){
				r = s[b:i] :: r;
				b = i + 1;
			}
		}
	}
	r = s[b:] :: r;
	return rev(r);
}

# the worlds w sees, as R gives them
sees(m: ref Model, w: string): list of string
{
	r := trim(m.rel);
	if(r == "W × W" || r == "W x W")
		return m.worlds;
	got: list of string;
	for(l := elements(r); l != nil; l = tl l){
		p := hd l;
		if(len p > 2 && p[0] == '(' && p[len p-1] == ')'){
			ab := split(p[1:len p-1], ',');
			if(ab != nil && tl ab != nil && trim(hd ab) == w)
				got = trim(hd tl ab) :: got;
		}
	}
	return rev(got);
}

# a value: T or F, or an extension, a set in eqn
value(v: string): string
{
	if(v == "T" || v == "F")
		return v;
	return setof(elements(v));
}

setof(l: list of string): string
{
	if(l == nil)
		return "$∅$";
	r := "$roman \"{\"";
	for(; l != nil; l = tl l){
		r += inner(mathof(hd l));
		if(tl l != nil)
			r += " ,";
	}
	return r + " roman \"}\"$";
}

# eqn's text of a formula, without its delimiters
inner(f: string): string
{
	return f[1:len f-1];
}

table(m: ref Model)
{
	if(m == nil)
		return;
	worlds := m.worlds;
	cols := worlds;
	if(cols == nil)
		cols = "" :: nil;
	nrows := len m.names + 2;
	if(m.worlds != nil)
		nrows += 2;
	out.puts(sys->sprint(".ne %.2fi\n", real (nrows + 3) * LH));
	out.puts(".ce\n\\fI" + esc(m.title) + "\\fP, a countermodel\n");
	if(m.dom != nil)
		out.puts(".ce\n$D = " + inner(setof(m.dom)) + "$\n");
	# under -mbook, no space to stretch between the title and the table
	out.puts(".sp 0.4\n.nr book-keep 1\n.TS\ncenter;\nl");
	for(c := cols; c != nil; c = tl c)
		out.puts(" c");
	out.puts(".\n_\n");
	if(worlds != nil){
		for(c = worlds; c != nil; c = tl c)
			out.puts("\t" + mathof(hd c));
		out.puts("\n_\n.sp 0.2\n");
	}else
		out.puts(".sp 0.2\n");
	for(nl := m.names; nl != nil; nl = tl nl){
		out.puts(mathof(hd nl));
		for(c = cols; c != nil; c = tl c){
			v := "";
			for(vl := m.vals; vl != nil; vl = tl vl){
				(w, n, x) := hd vl;
				if(w == hd c && n == hd nl)
					v = value(x);
			}
			out.puts("\t" + v);
		}
		out.puts("\n");
	}
	if(worlds != nil){
		out.puts("$roman R ( w )$");
		for(c = worlds; c != nil; c = tl c)
			out.puts("\t" + setof(sees(m, hd c)));
		out.puts("\n");
	}
	out.puts(".sp 0.2\n_\n");
	if(m.note != nil)	# and none between it and its note
		out.puts(".nr book-keep 1\n");
	out.puts(".TE\n");
	if(m.note != nil)
		out.puts(".ce\n\\s-1" + esc(m.note) + "\\s0\n");
	out.puts(sys->sprint(".sp %s\n", fmt(APART)));
}

prefix(p, s: string): int
{
	return len s >= len p && s[0:len p] == p;
}

memberstr(s: string, l: list of string): int
{
	for(; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

upwidth(x: ref Line): real
{
	return guess(x.fw, real (len x.why + 2) * JW);
}

# The width measured, else the guess.
guess(measured, guessed: real): real
{
	if(measured >= 0.0)
		return measured;
	return guessed;
}

# About how wide eqn sets a formula: a roman name's letters narrower
# than an italic letter, a binary operator with its space each side.
mathwidth(f: string): real
{
	w := 0.0;
	for(i := 0; i < len f; ){
		if(isalnum(f[i])){
			j := i;
			while(j < len f && isalnum(f[j]))
				j++;
			if(j - i == 1)
				w += 0.075;
			else if(f[i] == 'w' && alldigits(f[i+1:j]))
				w += 0.11;
			else
				w += real (j - i) * 0.062;
			i = j;
			continue;
		}
		case f[i] {
		' ' =>	;
		'∧' or '∨' or '→' or '↔' =>	w += 0.27;
		',' =>	w += 0.09;
		'(' or ')' =>	w += 0.045;
		* =>	w += 0.1;
		}
		i++;
	}
	return w;
}

alldigits(s: string): int
{
	for(i := 0; i < len s; i++)
		if(s[i] < '0' || s[i] > '9')
			return 0;
	return len s > 0;
}

isalnum(c: int): int
{
	return c >= '0' && c <= '9' || c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c == '_';
}

trim(s: string): string
{
	while(s != nil && s[0] == ' ')
		s = s[1:];
	while(s != nil && s[len s-1] == ' ')
		s = s[0:len s-1];
	return s;
}

fmt(x: real): string
{
	return sys->sprint("%.3f", x);
}

# Quotation marks and backslashes, kept from pic and troff.
esc(s: string): string
{
	r := "";
	for(i := 0; i < len s; i++){
		if(s[i] == '"')
			r += "\\(dq";
		else if(s[i] == '\\')
			r += "\\e";
		else
			r[len r] = s[i];
	}
	return r;
}

writefile(name, s: string): int
{
	fd := sys->create(name, Sys->OWRITE, 8r600);
	if(fd == nil)
		return -1;
	b := array of byte s;
	if(sys->write(fd, b, len b) != len b)
		return -1;
	return 0;
}

readfile(name: string): string
{
	fd := sys->open(name, Sys->OREAD);
	if(fd == nil)
		return nil;
	r := "";
	buf := array[8192] of byte;
	while((n := sys->read(fd, buf, len buf)) > 0)
		r += string buf[0:n];
	return r;
}

splitlines(s: string): list of string
{
	r: list of string;
	(nil, l) := sys->tokenize(s, "\n");
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return rev(r);
}

revr(l: list of real): list of real
{
	r: list of real;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

find(s, t: string): int
{
	for(i := 0; i + len t <= len s; i++)
		if(s[i:i+len t] == t)
			return i;
	return -1;
}

rev(l: list of string): list of string
{
	r: list of string;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

revl(l: list of ref Line): list of ref Line
{
	r: list of ref Line;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

revk(l: list of ref Node): list of ref Node
{
	r: list of ref Node;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}
