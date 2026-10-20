implement Canon;

#
# phil/canon [-t table] [file ...] - canonical citations in prose, read
# by rule and checked against the works they cite: Plato by Stephanus
# page and section (Republic 514a, Rep. I 349b-350c, Apology 40c-e),
# Aristotle by Bekker page, column and line (Metaphysics 1003a21,
# Sophistical Refutations 4, 165b32), the Critique of Pure Reason by its
# first and second editions (KrV A51/B75), Kant's other works by the
# Akademie edition's volume and page (Ak 4:421, GMS 4:421), the Summa by
# part, question and article (ST I q.2 a.3), the Presocratics by
# Diels-Kranz (DK 22 B 30).  The works, their names and abbreviations,
# and the first and last passage of each are the table's (-t, by default
# /lib/phil/canon: name, urn, system, first, last, author, title, a tab
# between; Plato's and Aristotle's from PerseusDL).  A finding at the
# citation's line:
#
#	x.md:4: canon/resolved: Republic 514a: Plato, Republic, Stephanus 514a, urn:cts:greekLit:tlg0059.tlg030:514a
#	x.md:9: canon/no-such-passage: Apology 52a: Plato, Apology runs from 17a to 42a
#	x.md:12: canon/unknown: Xen. 23a: an abbreviation the table does not have
#
# A Bekker citation is checked by page and column (the edition marks a
# line in five).  A title with no passage after it is not a citation.
# With no file, standard input.
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";

Canon: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

Work: adt {
	name:	string;
	urn:	string;
	sys:	string;
	first:	string;
	last:	string;
	author:	string;
	title:	string;
};

works: list of ref Work;	# longest name first
out: ref Iobuf;

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	arg := load Arg Arg->PATH;
	if(bufio == nil || arg == nil)
		fatal(sys->sprint("cannot load: %r"));
	arg->init(args);
	arg->setusage("phil/canon [-t table] [file ...]");
	table := "/lib/phil/canon";
	while((o := arg->opt()) != 0)
		case o {
		't' =>	table = arg->earg();
		* =>	arg->usage();
		}
	args = arg->argv();
	readtable(table);
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);
	if(args == nil)
		scan("-", bufio->fopen(sys->fildes(0), Bufio->OREAD));
	for(; args != nil; args = tl args) {
		b := bufio->open(hd args, Bufio->OREAD);
		if(b == nil)
			fatal(sys->sprint("cannot open %s: %r", hd args));
		scan(hd args, b);
	}
	out.flush();
}

readtable(f: string)
{
	b := bufio->open(f, Bufio->OREAD);
	if(b == nil)
		fatal(sys->sprint("cannot open %s: %r", f));
	l: list of ref Work;
	while((s := b.gets('\n')) != nil) {
		if(s[0] == '#')
			continue;
		if(s[len s - 1] == '\n')
			s = s[0:len s - 1];
		(n, fl) := sys->tokenize(s, "\t");
		if(n < 7)
			continue;
		a := array[7] of string;
		for(i := 0; i < 7; i++) {
			a[i] = hd fl;
			fl = tl fl;
		}
		l = ref Work(a[0], a[1], a[2], a[3], a[4], a[5], a[6]) :: l;
	}
	# longest name first, so that Nicomachean Ethics is found before Ethics
	for(;;) {
		best: ref Work;
		rest: list of ref Work;
		for(m := l; m != nil; m = tl m)
			if(best == nil || len (hd m).name > len best.name)
				best = hd m;
		if(best == nil)
			break;
		for(m = l; m != nil; m = tl m)
			if(hd m != best)
				rest = hd m :: rest;
		works = best :: works;
		l = rest;
	}
	r: list of ref Work;
	for(m := works; m != nil; m = tl m)
		r = hd m :: r;
	works = r;
}

scan(file: string, b: ref Iobuf)
{
	n := 0;
	while((s := b.gets('\n')) != nil) {
		n++;
		for(i := 0; i < len s; ) {
			# a name at a word's start
			if(i > 0 && letter(s[i-1])) {
				i++;
				continue;
			}
			w := match(s, i);
			if(w == nil) {
				j := unknown(s, i);
				if(j > i) {
					out.puts(sys->sprint("%s:%d: canon/unknown: %s: an abbreviation the table does not have\n", file, n, s[i:j]));
					i = j;
				} else
					i++;
				continue;
			}
			e := i + len w.name;
			(ok, cite, msg, j) := locate(w, s, e);
			if(ok == 0) {
				i = e;
				continue;
			}
			rule := "canon/resolved";
			if(ok < 0)
				rule = "canon/no-such-passage";
			out.puts(sys->sprint("%s:%d: %s: %s %s: %s\n", file, n, rule, w.name, cite, msg));
			i = j;
		}
	}
}

# the work whose name begins s at i, ending at a word's end
match(s: string, i: int): ref Work
{
	for(l := works; l != nil; l = tl l) {
		w := hd l;
		e := i + len w.name;
		if(e > len s || s[i:e] != w.name)
			continue;
		if(e < len s && letter(s[e]) && w.name[len w.name - 1] != '.')
			continue;
		return w;
	}
	return nil;
}

# the citation after work w's name, from e: 1 resolved, -1 no such
# passage, 0 none; what it cites, the finding's words, where it ends
locate(w: ref Work, s: string, e: int): (int, string, string, int)
{
	i := skipbook(s, e, w.sys);
	case w.sys {
	"stephanus" =>
		return stephanus(w, s, i);
	"bekker" =>
		return bekker(w, s, i);
	"krv" =>
		return krv(w, s, i);
	"aa" =>
		return aa(w, s, i);
	"summa" =>
		return summa(w, s, e);
	"dk" =>
		return dk(w, s, i);
	}
	return (0, nil, nil, e);
}

# past blanks, commas, and a book's number before the page (Republic I
# 349b, Sophistical Refutations 4, 165b32, Met. Gamma 2, 1003a33)
skipbook(s: string, i: int, system: string): int
{
	i = blanks(s, i);
	if(system != "stephanus" && system != "bekker")
		return i;
	for(k := 0; k < 2; k++) {
		j := i;
		while(j < len s && (roman(s[j]) || isdigit(s[j]) || greek(s[j])))
			j++;
		if(j == i)
			break;
		# a page has a letter after its number: not a book
		if(j < len s && ((s[j] >= 'a' && s[j] <= 'e') || s[j] == 'a' || s[j] == 'b') && isdigit(s[j-1]))
			break;
		if(j < len s && s[j] == '.' && j + 1 < len s && isdigit(s[j+1]))
			j++;	# I.7 is a book and chapter, not a page
		while(j < len s && (isdigit(s[j]) || roman(s[j])))
			j++;
		k2 := blanks(s, j);
		if(k2 < len s && s[k2] == ',')
			k2 = blanks(s, k2 + 1);
		if(k2 == j && !(j < len s && s[j] == ' '))
			break;
		i = k2;
	}
	return i;
}

stephanus(w: ref Work, s: string, i: int): (int, string, string, int)
{
	(p, j) := number(s, i);
	if(p < 0 || j >= len s || s[j] < 'a' || s[j] > 'e')
		return (0, nil, nil, i);
	sec := s[j];
	j++;
	(nil, j) = number(s, j);	# a line
	start := string p + sec2(sec);
	cite := start;
	# a range: -e, -350c, 70c-72a
	k := j;
	if(k < len s && (s[k] == '-' || s[k] == '–')) {
		(p2, k2) := number(s, k + 1);
		if(k2 < len s && s[k2] >= 'a' && s[k2] <= 'e') {
			if(p2 < 0)
				p2 = p;
			cite = start + "-" + string p2 + sec2(s[k2]);
			k2++;
			(nil, k2) = number(s, k2);
			j = k2;
		}
	}
	(fp, fs) := page(w.first);
	(lp, ls) := page(w.last);
	if(p < fp || p > lp || (p == fp && sec < fs) || (p == lp && sec > ls))
		return (-1, cite, sys->sprint("%s, %s runs from %s to %s", w.author, w.title, w.first, w.last), j);
	return (1, cite, sys->sprint("%s, %s, Stephanus %s, %s:%s", w.author, w.title, cite, w.urn, start), j);
}

sec2(c: int): string
{
	r := "";
	r[0] = c;
	return r;
}

bekker(w: ref Work, s: string, i: int): (int, string, string, int)
{
	(p, j) := number(s, i);
	if(p < 0 || j >= len s || (s[j] != 'a' && s[j] != 'b'))
		return (0, nil, nil, i);
	col := s[j];
	j++;
	(ln, j2) := number(s, j);
	cite := string p + sec2(col);
	if(ln >= 0)
		cite += string ln;
	j = j2;
	if(j < len s && (s[j] == '-' || s[j] == '–')) {
		k := j + 1;
		while(k < len s && (isdigit(s[k]) || s[k] == 'a' || s[k] == 'b'))
			k++;
		if(k > j + 1) {
			cite += "-" + s[j+1:k];
			j = k;
		}
	}
	(fp, fc) := page(w.first);
	(lp, lc) := page(w.last);
	if(p < fp || p > lp || (p == fp && col < fc) || (p == lp && col > lc))
		return (-1, cite, sys->sprint("%s, %s runs from %s to %s", w.author, w.title, w.first, w.last), j);
	return (1, cite, sys->sprint("%s, %s, Bekker %s, %s", w.author, w.title, cite, w.urn), j);
}

# KrV A51/B75, A 51/B 75, B75
krv(w: ref Work, s: string, i: int): (int, string, string, int)
{
	a := -1;
	b := -1;
	j := i;
	if(j < len s && s[j] == 'A') {
		(a, j) = number(s, blanks(s, j + 1));
		if(a < 0)
			return (0, nil, nil, i);
		j = blanks(s, j);
		if(j < len s && s[j] == '/')
			j = blanks(s, j + 1);
	}
	if(j < len s && s[j] == 'B') {
		k := j;
		(b, j) = number(s, blanks(s, j + 1));
		if(b < 0)
			j = k;
	}
	if(a < 0 && b < 0)
		return (0, nil, nil, i);
	cite := "";
	if(a >= 0)
		cite = "A" + string a;
	if(b >= 0) {
		if(cite != "")
			cite += "/";
		cite += "B" + string b;
	}
	if(a > 856 || b > 884 || a == 0 || b == 0)
		return (-1, cite, "the first edition runs to A856, the second to B884", j);
	return (1, cite, sys->sprint("%s, %s, %s", w.author, w.title, cite), j);
}

# Ak 4:421, GMS 4:421
aa(w: ref Work, s: string, i: int): (int, string, string, int)
{
	(v, j) := number(s, i);
	if(v < 0 || j >= len s || s[j] != ':')
		return (0, nil, nil, i);
	(p, k) := number(s, j + 1);
	if(p < 0)
		return (0, nil, nil, i);
	cite := string v + ":" + string p;
	(fv, fp) := volpage(w.first);
	(lv, lp) := volpage(w.last);
	if(v < fv || v > lv || (v == fv && p < fp) || (w.name != "AA" && w.name != "Ak" && w.name != "Ak." && v == lv && p > lp))
		return (-1, cite, sys->sprint("%s, %s runs from %s to %s", w.author, w.title, w.first, w.last), k);
	return (1, cite, sys->sprint("%s, %s, Akademie-Ausgabe %s", w.author, w.title, cite), k);
}

# ST I q.2 a.3, Summa Theologica I, tr. ..., q.2 a.3: the part after the
# name, then a question and an article on the same line
summa(w: ref Work, s: string, e: int): (int, string, string, int)
{
	i := blanks(s, e);
	part := "";
	for(;;) {
		if(prefix(s, i, "I-II") || prefix(s, i, "II-II")) {
			j := i;
			while(j < len s && (s[j] == 'I' || s[j] == '-'))
				j++;
			part = s[i:j];
			i = j;
			break;
		}
		j := i;
		while(j < len s && (s[j] == 'I'))
			j++;
		if(j > i && (j >= len s || !letter(s[j]))) {
			part = s[i:j];
			i = j;
		}
		break;
	}
	if(part == "")
		return (0, nil, nil, e);
	q := -1;
	a := -1;
	end := i;
	for(k := i; k < len s && k < i + 160; k++) {
		if(q < 0 && s[k] == 'q' && (k == 0 || !letter(s[k-1]))) {
			m := k + 1;
			if(m < len s && s[m] == '.')
				m++;
			(q, end) = number(s, blanks(s, m));
			if(q >= 0)
				k = end - 1;
			continue;
		}
		if(q >= 0 && s[k] == 'a' && (k == 0 || !letter(s[k-1])) && k + 1 < len s && (s[k+1] == '.' || isdigit(s[k+1]) || s[k+1] == ' ')) {
			m := k + 1;
			if(m < len s && s[m] == '.')
				m++;
			(a, end) = number(s, blanks(s, m));
			if(a >= 0)
				break;
		}
	}
	if(q < 0)
		return (0, nil, nil, e);
	cite := part + " q." + string q;
	if(a >= 0)
		cite += " a." + string a;
	max := 0;
	case part {
	"I" =>	max = 119;
	"I-II" =>	max = 114;
	"II-II" =>	max = 189;
	"III" =>	max = 90;
	}
	if(max == 0 || q < 1 || q > max)
		return (-1, cite, sys->sprint("%s, %s: part %s has %d questions", w.author, w.title, part, max), end);
	return (1, cite, sys->sprint("%s, %s, %s", w.author, w.title, cite), end);
}

# DK 22 B 30
dk(w: ref Work, s: string, i: int): (int, string, string, int)
{
	(c, j) := number(s, i);
	if(c < 0)
		return (0, nil, nil, i);
	j = blanks(s, j);
	if(j >= len s || (s[j] != 'A' && s[j] != 'B' && s[j] != 'C'))
		return (0, nil, nil, i);
	kind := s[j];
	(f, k) := number(s, blanks(s, j + 1));
	if(f < 0)
		return (0, nil, nil, i);
	cite := string c + " " + sec2(kind) + " " + string f;
	if(c < 1 || c > 90)
		return (-1, cite, "Diels-Kranz has 90 chapters", k);
	return (1, cite, sys->sprint("%s, %s, %s", w.author, w.title, cite), k);
}

# an abbreviation the table lacks, before what reads as a Stephanus or
# Bekker number: a capital, up to six letters, a full stop, a page
unknown(s: string, i: int): int
{
	if(i >= len s || s[i] < 'A' || s[i] > 'Z')
		return i;
	j := i + 1;
	while(j < len s && s[j] >= 'a' && s[j] <= 'z' && j - i <= 6)
		j++;
	if(j - i < 2 || j >= len s || s[j] != '.')
		return i;
	k := blanks(s, j + 1);
	(p, m) := number(s, k);
	if(p < 0 || p > 1500 || m >= len s || m - k < 2)
		return i;
	if(s[m] < 'a' || s[m] > 'e')
		return i;
	if(m + 1 < len s && letter(s[m+1]))
		return i;
	return m + 1;
}

page(s: string): (int, int)
{
	(p, j) := number(s, 0);
	c := 0;
	if(j < len s)
		c = s[j];
	return (p, c);
}

volpage(s: string): (int, int)
{
	(v, j) := number(s, 0);
	p := 0;
	if(j < len s && s[j] == ':')
		(p, nil) = number(s, j + 1);
	return (v, p);
}

number(s: string, i: int): (int, int)
{
	j := i;
	while(j < len s && isdigit(s[j]))
		j++;
	if(j == i)
		return (-1, i);
	return (int s[i:j], j);
}

blanks(s: string, i: int): int
{
	while(i < len s && (s[i] == ' ' || s[i] == '\t'))
		i++;
	return i;
}

prefix(s: string, i: int, p: string): int
{
	return i + len p <= len s && s[i:i+len p] == p;
}

isdigit(c: int): int
{
	return c >= '0' && c <= '9';
}

letter(c: int): int
{
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z');
}

roman(c: int): int
{
	case c {
	'I' or 'V' or 'X' or 'L' or 'i' or 'v' or 'x' =>
		return 1;
	}
	return 0;
}

greek(c: int): int
{
	return c >= 16r391 && c <= 16r3C9;
}

fatal(s: string)
{
	sys->fprint(sys->fildes(2), "phil/canon: %s\n", s);
	raise "fail:error";
}
