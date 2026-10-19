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
# The output wants pic, then eqn, then troff: in InferNode with the
# troff package, pic | eqn /lib/troff/eqnrc - | troff | tr2pdf.  It
# reads prove's output, so a tree is typeset as it was proved, and
# nothing is proved here.
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";

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
};

Node: adt {
	lines:	list of ref Line;	# latest first
	kids:	list of ref Node;	# latest first
};

out: ref Iobuf;

# Sizes in inches, for text at 11 points on 14.
LH: con 0.215;	# a line
JW: con 0.06;	# a character of what a line came from, set smaller
NUMGAP: con 0.07;	# between a line's number and its formula
WHYGAP: con 0.3;	# between the formulas and what they came from
GAP: con 0.45;	# between branches side by side
DROP: con 0.32;	# down a branch's line

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
	# eqn: the formulas between $ and $; the connectives binary operators
	out.puts(".EQ\ndelim $$\n");
	for(cl := "∧" :: "∨" :: "→" :: "↔" :: nil; cl != nil; cl = tl cl)
		out.puts(sys->sprint("chartype bin \"%s\"\n", hd cl));
	out.puts("chartype punct \",\"\n.EN\n");
	title: string;
	body: list of string;
	for(l := readinput(args); l != nil; l = tl l){
		s := hd l;
		if(s != nil && s[len s-1] == '\n')
			s = s[0:len s-1];
		if(len s > 2 && s[0:2] == "#\t" && title != nil){
			body = s[2:] :: body;
			continue;
		}
		if(title != nil)
			draw(title, rev(body));
		(title, body) = (nil, nil);
		if(len s > 2 && s[0:2] == "# " && find(s, ", proved by a tableau") >= 0)
			title = s[2:find(s, ", proved by a tableau")];
	}
	if(title != nil)
		draw(title, rev(body));
	out.flush();
}

# The tree from prove's lines: each line's prefix, three characters to a
# level, says where it hangs; ├─ and └─ begin a branch.
draw(title: string, lines: list of string)
{
	root := ref Node(nil, nil);
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
			n := ref Node(nil, nil);
			stack[d-1].kids = n :: stack[d-1].kids;
			stack[d] = n;
		}
		if(stack[d] == nil)
			continue;
		stack[d].lines = parseline(s) :: stack[d].lines;
	}
	out.puts(".PS\n");
	(nil, nil, axis) := measure(root);
	out.puts(sys->sprint("\"\\fI%s\\fP\" at (%s,%s)\n", esc(title), fmt(axis), fmt(1.4 * LH)));
	place(root, 0.0, 0.0);
	out.puts(".PE\n.sp 0.6\n");
}

# "4. ¬q, w1   3 ¬□" or "× 8, 9": the number, the formula and what it
# came from, the last set apart by three blanks or more.
parseline(s: string): ref Line
{
	if(len s > 1 && s[0] == '×')
		return ref Line(nil, nil, trim(s[1:]), 0);
	num: string;
	for(i := 0; i < len s && s[i] >= '0' && s[i] <= '9'; i++)
		;
	if(i > 0 && i < len s && s[i] == '.'){
		num = s[0:i];
		s = trim(s[i+1:]);
	}
	for(i = 0; i+2 < len s; i++)
		if(s[i] == ' ' && s[i+1] == ' ' && s[i+2] == ' ')
			return ref Line(num, s[0:i], trim(s[i:]), 0);
	return ref Line(num, s, nil, 0);
}

# A branch's column: the width of its numbers, of its formulas and of
# what they came from.
column(n: ref Node): (real, real, real)
{
	(nw, fw, jw) := (0.0, 0.0, 0.0);
	for(l := n.lines; l != nil; l = tl l){
		x := hd l;
		if(x.num != nil && real (len x.num + 1) * JW > nw)
			nw = real (len x.num + 1) * JW;
		w := mathwidth(x.f);
		if(x.num == nil)
			w = real (len x.why + 2) * JW;
		if(w > fw)
			fw = w;
		if(x.num != nil && x.why != nil && !x.atfork && real len x.why * JW > jw)
			jw = real len x.why * JW;
	}
	return (nw, fw, jw);
}

# How wide the branch and all below it are, from its left edge; and
# where its axis, the middle of its formulas, falls.
measure(n: ref Node): (real, real, real)
{
	(nw, fw, jw) := column(n);
	own := nw + NUMGAP + fw + WHYGAP + jw;
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
			out.puts(sys->sprint("\"$times$ \\s-2%s\\s0\" ljust at (%s,%s)\n", esc(ln.why), fmt(fx), fmt(y)));
		else{
			out.puts(sys->sprint("\"\\s-2%s.\\s0\" rjust at (%s,%s)\n", ln.num, fmt(fx - NUMGAP), fmt(y)));
			out.puts(sys->sprint("\"%s\" ljust at (%s,%s)\n", mathof(ln.f), fmt(fx), fmt(y)));
			if(ln.why != nil && !ln.atfork)
				out.puts(sys->sprint("\"\\s-2%s\\s0\" ljust at (%s,%s)\n", esc(ln.why), fmt(jx), fmt(y)));
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
		out.puts(sys->sprint("\"\\s-2%s\\s0\" ljust at (%s,%s)\n", esc(why), fmt(jx), fmt(top - DROP * 0.45)));
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
