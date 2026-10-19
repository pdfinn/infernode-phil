implement Join;

#
# phil/join part.logic ... - the logic files of a work's parts as one
# argument in steps: each part's statements numbered anew (P1 of the
# second part becomes, say, P7, and its from and against lines follow),
# and each part's conclusion C made a step, C1, C2, ..., drawn from what
# that part drew it from.  The atoms are the parts' together (a name
# two parts both declare keeps the first meaning); a part whose logic
# line differs from the first's is left out, saying so.  The last line,
# a comment, names the parts' conclusions as steps:
#	# steps: C3 C5 C9
# for phil/argue -w to have the model join them.  A premise of a later
# part that is an earlier part's conclusion, at its sentence and as
# written there, is that step: it is dropped, and what was drawn from it
# is drawn from the step.  With -a, only the atoms, the vocabulary the
# parts share so far; with -v, only those the next part is likely to
# need: the atoms the last three parts used, and those in any part's
# conclusion, which it may rest on; with -c, only the parts' conclusions, one to a
# line, S3<TAB>formula, for the next part to rest on.  With -t top,
# the lines that join the parts (phil/argue -w has the model write them)
# follow the parts; where the main conclusion they give is a part's
# conclusion, at its sentence and as written there, that step is made
# the main conclusion, drawn from what it was drawn from and what top
# adds.
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;

Join: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

out: ref Iobuf;
stderr: ref Sys->FD;
counter := array[256] of { * => 0 };	# by statement letter
atoms: list of string;
atomlines: list of string;
domains: list of string;
logic := "";
# the parts' conclusions so far: sentence, formula as written, step
concls: list of (string, string, string);
used: list of list of string;	# each part's atoms, as its statements use them, latest first
cused: list of string;	# the atoms of the parts' conclusions
Recent: con 3;	# the parts before the next whose atoms it is given

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	stderr = sys->fildes(2);
	bufio = load Bufio Bufio->PATH;
	args = tl args;
	aflag := 0;
	cflag := 0;
	vflag := 0;
	top := "";
	if(args != nil && hd args == "-t" && tl args != nil){
		top = hd tl args;
		args = tl tl args;
	}
	if(args != nil && hd args == "-a"){
		aflag = 1;
		args = tl args;
	}else if(args != nil && hd args == "-v"){
		aflag = vflag = 1;
		args = tl args;
	}else if(args != nil && hd args == "-c"){
		cflag = 1;
		args = tl args;
	}
	if(args == nil){
		sys->fprint(stderr, "usage: phil/join [-a | -c | -t top] part.logic ...\n");
		raise "fail:usage";
	}
	body := "";
	steps := "";
	for(i := 1; args != nil; args = tl args){
		(b, c, err) := part(hd args, i);
		if(err != nil){
			sys->fprint(stderr, "phil/join: %s\n", err);
			body += sys->sprint("# part %d, %s, left out: %s\n", i, hd args, err);
		}else{
			body += b;
			if(c != nil)
				steps += " " + c;
		}
		i++;
	}
	tail := "";
	if(top != nil)
		(body, tail) = jointop(body, top);
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);
	if(logic != "" && logic != "classical")
		out.puts("logic\t" + logic + "\n");
	need: list of string;
	if(vflag){
		need = cused;
		k := 0;
		for(ul := used; ul != nil && k < Recent; ul = tl ul){
			for(al := hd ul; al != nil; al = tl al)
				need = hd al :: need;
			k++;
		}
	}
	for(l := rev(atomlines); l != nil; l = tl l)
		if(!vflag || member(atomname(hd l), need))
			out.puts(hd l + "\n");
	if(domains != nil){
		d := "domain\t";
		for(l = rev(domains); l != nil; l = tl l)
			d += " " + hd l;
		out.puts(d + "\n");
	}
	if(cflag){
		for(cl := rev3(concls); cl != nil; cl = tl cl){
			(cs, cf, nil) := hd cl;
			out.puts(cs + "\t" + cf + "\n");
		}
		out.flush();
		return;
	}
	if(!aflag){
		out.puts(body);
		if(top != nil)
			out.puts("# how the parts are joined\n" + tail);
		else
			out.puts("# steps:" + steps + "\n");
	}
	out.flush();
}

# One part: its lines renumbered, and the name its conclusion now has.
part(file: string, n: int): (string, string, string)
{
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil)
		return (nil, nil, sys->sprint("cannot open %s: %r", file));
	lines: list of string;
	while((t := b.gets('\n')) != nil){
		if(t != nil && t[len t-1] == '\n')
			t = t[0:len t-1];
		lines = t :: lines;
	}
	lines = rev(lines);
	# its logic first: a part in another logic cannot join
	pl := "classical";
	for(l := lines; l != nil; l = tl l){
		(nil, f) := sys->tokenize(hd l, "\t");
		if(f != nil && hd f == "logic" && tl f != nil)
			pl = hd tl f;
	}
	# classical, s5 and kd join in s5kd, a kd part's necessity made ought
	if(logic == "")
		logic = pl;
	else if(pl != logic){
		m := logicbits(logic) | logicbits(pl);
		if(logicbits(logic) < 0 || logicbits(pl) < 0)
			return (nil, nil, sys->sprint("its logic is %s, the first part's %s", pl, logic));
		logic = bitslogic(m);
	}
	kd := pl == "kd";
	# an atom an earlier part declared with another meaning: the two
	# are different claims, so this part's takes a name of its own,
	# its name and the part's number, in its lines and its formulas
	aold, anew: list of string;
	note := "";
	for(l = lines; l != nil; l = tl l){
		(nf, f) := sys->tokenize(hd l, "\t");
		if(nf < 2 || hd f != "atom")
			continue;
		an := atomname(hd l);
		m := "";
		if(nf > 2)
			m = hd tl tl f;
		had := meaningof(an);
		if(had == nil || had == m || member(an, aold))
			continue;
		nn := sys->sprint("%s_%d", an, n);
		for(k := 2; meaningof(nn) != nil; k++)
			nn = sys->sprint("%s_%d_%d", an, n, k);
		aold = an :: aold;
		anew = nn :: anew;
		note += sys->sprint("# %s here is %s: an earlier part's %s means %s\n", an, nn, an, had);
	}
	# the new names; a premise that is an earlier part's conclusion is
	# that step
	old, new: list of string;
	linked: list of string;
	concl := "";
	cform := "";
	csent := "";
	for(l = lines; l != nil; l = tl l){
		(nil, f) := sys->tokenize(hd l, "\t");
		if(f == nil)
			continue;
		name := hd f;
		if(!stmtname(name))
			continue;
		if(name[0] == 'P' && tl f != nil && tl tl f != nil){
			step := earlier(hd tl f, deonticize(renameatoms(hd tl tl f, aold, anew), kd));
			if(step != nil){
				old = name :: old;
				new = step :: new;
				linked = name :: linked;
				continue;
			}
		}
		if(name == "C" && tl f != nil && tl tl f != nil){
			csent = hd tl f;
			cform = deonticize(renameatoms(hd tl tl f, aold, anew), kd);
		}
		c := name[0];
		if(c == 'C')
			c = 'C';
		counter[c]++;
		nn := sys->sprint("%c%d", c, counter[c]);
		old = name :: old;
		new = nn :: new;
		if(name == "C")
			concl = nn;
	}
	# a conclusion with no from rests on the part's steps and on the
	# premises and assumptions no step draws on: said outright, since
	# joined it would otherwise rest on every part before it
	drawn: list of string;
	cfrom := 0;
	for(l = lines; l != nil; l = tl l){
		(nf, f) := sys->tokenize(hd l, "\t");
		if(nf < 4 || !stmtname(hd f))
			continue;
		(nil, ws) := sys->tokenize(hd tl tl tl f, " ");
		if(ws != nil && (hd ws == "from")){
			if(hd f == "C")
				cfrom = 1;
			for(ws = tl ws; ws != nil; ws = tl ws)
				drawn = hd ws :: drawn;
		}
	}
	implicit := "";
	if(!cfrom)
		for(l = lines; l != nil; l = tl l){
			(nil, f) := sys->tokenize(hd l, "\t");
			if(f == nil || !stmtname(hd f) || hd f == "C" || member(hd f, drawn) || reports(f))
				continue;
			case (hd f)[0] {
			'P' or 'A' or 'C' =>
				implicit += " " + rename(hd f, old, new);
			}
		}
	pused: list of string;
	o := sys->sprint("# part %d: %s\n", n, file) + note;
	for(l = lines; l != nil; l = tl l){
		s := hd l;
		if(s == nil)
			continue;
		if(s[0] == '#'){
			o += s + "\n";
			continue;
		}
		(nil, f) := sys->tokenize(s, "\t");
		if(f == nil)
			continue;
		case hd f {
		"atom" =>
			if(tl f == nil)
				continue;
			an := atomname(s);
			if(member(an, aold)){
				nn := rename(an, aold, anew);
				s = "atom\t" + nn + (hd tl f)[len an:] + s[len "atom\t" + len hd tl f:];
				an = nn;
			}
			if(!member(an, atoms)){
				atoms = an :: atoms;
				atomlines = s :: atomlines;
			}
			continue;
		"domain" =>
			for(dl := tl f; dl != nil; dl = tl dl){
				(nil, ws) := sys->tokenize(hd dl, " ,");
				for(; ws != nil; ws = tl ws)
					if(!member(hd ws, domains))
						domains = hd ws :: domains;
			}
			continue;
		"logic" or "rivals" =>
			continue;
		}
		if(!stmtname(hd f) || member(hd f, linked))
			continue;
		# name, sentence, formula, and what follows: what it is from
		# or against (first, where it is either), whose claim it
		# reports, what kind of claim it is
		nfs := len f;
		if(nfs < 3)
			nfs = 3;
		fs := array[nfs] of { * => "" };
		k := 0;
		for(fl := f; fl != nil; fl = tl fl)
			fs[k++] = hd fl;
		fs[0] = rename(fs[0], old, new);
		fs[2] = deonticize(renameatoms(fs[2], aold, anew), kd);
		pused = idents(fs[2], pused);
		for(x := 3; x < nfs; x++){
			(nil, ws) := sys->tokenize(fs[x], " ");
			if(ws == nil || hd ws != "from" && hd ws != "against")
				continue;
			nt := "";
			for(; ws != nil; ws = tl ws){
				if(nt != "")
					nt += " ";
				nt += rename(hd ws, old, new);
			}
			fs[x] = nt;
		}
		o += fs[0] + "\t" + fs[1] + "\t" + fs[2];
		if(hd f == "C" && !cfrom && implicit != "")
			o += "\tfrom" + implicit;
		for(x = 3; x < nfs; x++)
			if(fs[x] != nil)
				o += "\t" + fs[x];
		o += "\n";
	}
	if(concl != nil){
		concls = (csent, squeeze(cform), concl) :: concls;
		cused = idents(cform, cused);
	}
	used = pused :: used;
	return (o, concl, nil);
}

# Whether a statement's fields say whose claim it reports (says): the
# work's account of another's claim, which nothing rests on unasked.
reports(f: list of string): int
{
	if(len f < 4)
		return 0;
	for(f = tl tl tl f; f != nil; f = tl f){
		(nil, ws) := sys->tokenize(hd f, " ");
		if(ws != nil && hd ws == "says")
			return 1;
	}
	return 0;
}

# What the atom an is said to mean by the part that declared it first;
# nil if none has.
meaningof(an: string): string
{
	for(l := atomlines; l != nil; l = tl l)
		if(atomname(hd l) == an){
			(nf, f) := sys->tokenize(hd l, "\t");
			if(nf > 2)
				return hd tl tl f;
			return "";
		}
	return nil;
}

# A formula with each atom in old named as in new.
renameatoms(f: string, old, new: list of string): string
{
	if(old == nil)
		return f;
	r := "";
	for(i := 0; i < len f; ){
		if(isid(f[i])){
			j := i;
			while(j < len f && isid(f[j]))
				j++;
			r += rename(f[i:j], old, new);
			i = j;
			continue;
		}
		r[len r] = f[i++];
	}
	return r;
}

# The lines that join the parts, after them; a main conclusion that is a
# part's made that step.
jointop(body, top: string): (string, string)
{
	b := bufio->open(top, Bufio->OREAD);
	if(b == nil){
		sys->fprint(stderr, "phil/join: cannot open %s: %r\n", top);
		return (body, "");
	}
	tail := "";
	while((t := b.gets('\n')) != nil){
		if(t != nil && t[len t-1] == '\n')
			t = t[0:len t-1];
		(nf, f) := sys->tokenize(t, "\t");
		if(nf == 0)
			continue;
		if(hd f == "atom" && nf > 1){
			an := hd tl f;
			for(p := 0; p < len an && an[p] != '('; p++)
				;
			an = an[0:p];
			if(!member(an, atoms)){
				atoms = an :: atoms;
				atomlines = t :: atomlines;
			}
			continue;
		}
		if(hd f == "C" && nf >= 3){
			step := earlier(hd tl f, hd tl tl f);
			if(step != nil){
				# the step is the main conclusion
				add: list of string;
				if(nf >= 4){
					(nil, ws) := sys->tokenize(hd tl tl tl f, " ");
					if(ws != nil && hd ws == "from")
						for(ws = tl ws; ws != nil; ws = tl ws)
							if(hd ws != step)
								add = hd ws :: add;
				}
				body = promote(body, step, rev(add));
				if((ss := stepsent(step)) != nil && ss != hd tl f)
					tail += sys->sprint("# C, argued at %s, is stated at %s too\n", ss, hd tl f);
				continue;
			}
		}
		if(t[0] == '#' || stmtname(hd f))
			tail += t + "\n";
	}
	return (body, tail);
}

# The step's line, made the main conclusion, with more to draw from.
promote(body, step: string, add: list of string): string
{
	(nil, ls) := sys->tokenize(body, "\n");
	o := "";
	for(; ls != nil; ls = tl ls){
		t := hd ls;
		(nf, f) := sys->tokenize(t, "\t");
		if(nf >= 3 && hd f == step){
			fs := array[4] of { * => "" };
			k := 0;
			for(; f != nil && k < 4; f = tl f)
				fs[k++] = hd f;
			from := fs[3];
			if(from == nil)
				from = "from";
			(nil, have) := sys->tokenize(from, " ");
			for(al := add; al != nil; al = tl al)
				if(!member(hd al, have)){
					from += " " + hd al;
					have = hd al :: have;
				}
			t = "C\t" + fs[1] + "\t" + fs[2];
			if(from != "from")
				t += "\t" + from;
		}
		o += t + "\n";
	}
	return o;
}

# The step an earlier part concluded at sentence sent, as formula.
# The sentence a step was drawn at.
stepsent(step: string): string
{
	for(l := concls; l != nil; l = tl l){
		(cs, nil, st) := hd l;
		if(st == step)
			return cs;
	}
	return nil;
}

earlier(sent, formula: string): string
{
	f := squeeze(formula);
	for(l := concls; l != nil; l = tl l){
		(cs, cf, step) := hd l;
		if(cs == sent && cf == f)
			return step;
	}
	# the same claim stated elsewhere, as an abstract or an introduction
	# states what a chapter argues: the step argued is the conclusion
	same: string;
	for(l = concls; l != nil; l = tl l){
		(nil, cf, step) := hd l;
		if(cf == f && same == nil)
			same = step;
	}
	return same;
}

# A formula without its blanks, to compare as written.
# A formula without its blanks, its connectives in ASCII, so that one
# written in logic's symbols (prove -f) is the same as one that is not.
squeeze(s: string): string
{
	t := "";
	for(i := 0; i < len s; i++)
		case s[i] {
		' ' or '\t' =>	;
		'¬' =>	t += "!";
		'∧' =>	t += "&";
		'∨' =>	t += "|";
		'→' =>	t += "->";
		'↔' =>	t += "<->";
		'□' =>	t += "[]";
		'◇' =>	t += "<>";
		'⊤' =>	t += "true";
		* =>	t[len t] = s[i];
		}
	return t;
}

rev3(l: list of (string, string, string)): list of (string, string, string)
{
	r: list of (string, string, string);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}

# An atom line's name, without its parameters.
atomname(l: string): string
{
	(nil, f) := sys->tokenize(l, "\t");
	if(f == nil || tl f == nil)
		return "";
	a := hd tl f;
	for(p := 0; p < len a && a[p] != '('; p++)
		;
	return a[0:p];
}

# The names a formula uses, added to l.
idents(f: string, l: list of string): list of string
{
	for(i := 0; i < len f; i++){
		if(!isid(f[i]) || i > 0 && isid(f[i-1]))
			continue;
		j := i;
		while(j < len f && isid(f[j]))
			j++;
		w := f[i:j];
		case w {
		"all" or "some" or "ought" or "permitted" or "nec" or "pos" or "necessarily" or "possibly" or "not" or "O" or "P" =>
			;
		* =>
			if(!member(w, l))
				l = w :: l;
		}
		i = j - 1;
	}
	return l;
}

# A logic as bits: classical 0, s5 1, kd 2, s5kd both; -1 for another.
logicbits(l: string): int
{
	case l {
	"classical" =>	return 0;
	"s5" =>	return 1;
	"kd" =>	return 2;
	"s5kd" =>	return 3;
	}
	return -1;
}

bitslogic(m: int): string
{
	case m {
	0 =>	return "classical";
	1 =>	return "s5";
	2 =>	return "kd";
	}
	return "s5kd";
}

# In kd, necessity is ought and possibility permitted: said so, for s5kd.
deonticize(f: string, kd: int): string
{
	if(!kd)
		return f;
	t := "";
	for(i := 0; i < len f; i++){
		if(i+1 < len f && f[i:i+2] == "[]"){
			t += "ought ";
			i++;
			continue;
		}
		if(i+1 < len f && f[i:i+2] == "<>"){
			t += "permitted ";
			i++;
			continue;
		}
		if(f[i] == '□'){
			t += "ought ";
			continue;
		}
		if(f[i] == '◇'){
			t += "permitted ";
			continue;
		}
		if(isid(f[i]) && (i == 0 || !isid(f[i-1]))){
			j := i;
			while(j < len f && isid(f[j]))
				j++;
			w := f[i:j];
			case w {
			"nec" or "necessarily" =>	w = "ought";
			"pos" or "possibly" =>	w = "permitted";
			}
			t += w;
			i = j - 1;
			continue;
		}
		t[len t] = f[i];
	}
	return t;
}

isid(c: int): int
{
	return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == '_';
}

stmtname(s: string): int
{
	if(s == "C")
		return 1;
	if(len s < 2)
		return 0;
	case s[0] {
	'P' or 'A' or 'O' or 'R' or 'C' =>
		for(i := 1; i < len s; i++)
			if(s[i] < '0' || s[i] > '9')
				return 0;
		return 1;
	}
	return 0;
}

rename(s: string, old, new: list of string): string
{
	for(; old != nil; (old, new) = (tl old, tl new))
		if(hd old == s)
			return hd new;
	return s;
}

member(s: string, l: list of string): int
{
	for(; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

rev(l: list of string): list of string
{
	r: list of string;
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
}
