implement Kind;

#
# phil/kind logicfile - what kind of claim each premise and assumption
# of a reading is, by rule, with no model: normative (what ought to be:
# an ought or permitted in its formula, or a word of duty, right, virtue,
# justice, praise or blame), conceptual (what a word or concept means:
# a necessity in its formula, or a word of meaning, definition, essence
# or contradiction), or empirical (how things are or were: a verb in the
# past tense, or a word of observing, experience or what people do);
# tried in that order, from the words of the atoms the formula uses, as
# the reading gives them.  A claim with none of these is left untagged,
# as argue's readers are told to leave one whose kind is not plain.
# Each is a finding at its line, with the word that decided it, and the
# reader's own kind beside it where the reading gives one:
#
#	x.logic:9: kind/rule: P2 (S3): normative (ought); read conceptual
#
# The words are tagged by wwb's tagger, for the past tense.
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
include "tagger.m";
	tagger: Tagger;

Kind: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

out: ref Iobuf;

NORMATIVE := array[] of {
	"ought", "should", "duty", "duties", "obligation", "obligations", "obliged",
	"virtue", "virtues", "virtuous", "vice", "vices", "vicious",
	"just", "unjust", "justice", "injustice", "rightly", "wrongly", "wrongful",
	"permissible", "impermissible", "forbidden", "lawful", "unlawful",
	"deserve", "deserves", "deserved", "praise", "praiseworthy", "blame", "blameworthy",
	"desirable", "worthy", "unworthy", "shameful", "disgraceful", "honourable", "honorable",
	"dishonest", "sin", "sinful", "impious", "wicked",
};

CONCEPTUAL := array[] of {
	"means", "meaning", "meant", "defined", "definition", "consists", "consist",
	"essence", "essential", "essentially", "signifies", "signify", "denotes",
	"contradiction", "contradictory", "contradicts", "impossible", "necessarily",
	"identical", "tautology", "self-evident", "analytic",
};

EMPIRICAL := array[] of {
	"observe", "observes", "observed", "experience", "experienced", "history",
	"historians", "custom", "customs", "habit", "habits", "happens", "happened",
	"found", "saw", "seen", "perceive", "perceives", "perceived", "feel", "feels",
	"felt", "appears", "seems", "shows", "showed", "actually",
};

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	prose = load Prose Prose->PATH;
	if(prose == nil)
		fatal(sys->sprint("cannot load %s: %r", Prose->PATH));
	prose->init();
	tagger = load Tagger Tagger->PATH;
	if(tagger == nil)
		fatal(sys->sprint("cannot load %s: %r", Tagger->PATH));
	if((e := tagger->init(nil)) != nil)
		fatal(e);
	arg := load Arg Arg->PATH;
	arg->init(args);
	arg->setusage("phil/kind logicfile");
	while((o := arg->opt()) != 0)
		case o {
		* =>	arg->usage();
		}
	args = arg->argv();
	if(len args != 1)
		arg->usage();
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);
	file := hd args;
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil)
		fatal(sys->sprint("cannot open %s: %r", file));
	# the atoms' meanings, then each premise and assumption
	names: list of string;
	means: list of string;
	stmts: list of (int, string, string, string, string);	# line, name, sentence, formula, the rest
	n := 0;
	while((s := b.gets('\n')) != nil){
		n++;
		if(len s > 0 && s[len s-1] == '\n')
			s = s[0:len s-1];
		(nf, f) := sys->tokenize(s, "\t");
		if(nf < 3 || s[0] == '#')
			continue;
		if(hd f == "atom"){
			nm := hd tl f;
			for(i := 0; i < len nm; i++)
				if(nm[i] == '(')
					break;
			names = nm[0:i] :: names;
			means = hd tl tl f :: means;
			continue;
		}
		nm := hd f;
		if(nm == nil || nm[0] != 'P' && nm[0] != 'A')
			continue;
		rest := "";
		for(l := tl tl tl f; l != nil; l = tl l)
			rest += "\t" + hd l;
		stmts = (n, nm, hd tl f, hd tl tl f, rest) :: stmts;
	}
	tagged := 0;
	for(sl := rev(stmts); sl != nil; sl = tl sl){
		(line, nm, sent, form, rest) := hd sl;
		words := "";
		for(tl1 := tokens(form); tl1 != nil; tl1 = tl tl1){
			ml := means;
			for(nl := names; nl != nil; nl = tl nl){
				if(hd nl == hd tl1){
					words += " " + hd ml;
					break;
				}
				ml = tl ml;
			}
		}
		(k, cue) := classify(form, words);
		if(k == nil)
			continue;
		tagged++;
		at := nm;
		if(sent != "-")
			at += " (" + sent + ")";
		read := "";
		(nil, rl) := sys->tokenize(rest, "\t");
		for(; rl != nil; rl = tl rl){
			(nw, ws) := sys->tokenize(hd rl, " ");
			if(nw == 2 && hd ws == "kind")
				read = "; read " + hd tl ws;
		}
		out.puts(prose->finding(file, line, -1, -1, "kind/rule", sys->sprint("%s: %s (%s)%s", at, k, cue, read)));
	}
	out.puts(sys->sprint("%s: kind/tagged %d\n", file, tagged));
	out.flush();
}

# The kind, and the word that decided it.
classify(form, words: string): (string, string)
{
	# an ought or permitted in the formula
	if(has(form, "ought") || has(form, "permitted") || deonticop(form))
		return ("normative", "ought in the formula");
	toks := tagger->tokens(words);
	w := array[len toks] of string;
	for(i := 0; i < len toks; i++)
		(w[i], nil) = toks[i];
	lw := array[len w] of string;
	for(i = 0; i < len w; i++)
		lw[i] = lower(w[i]);
	for(i = 0; i < len lw; i++)
		if(member(lw[i], NORMATIVE))
			return ("normative", lw[i]);
	if(has(form, "□") || has(form, "[]"))
		return ("conceptual", "necessity in the formula");
	for(i = 0; i < len lw; i++)
		if(member(lw[i], CONCEPTUAL))
			return ("conceptual", lw[i]);
	for(i = 0; i < len lw; i++)
		if(member(lw[i], EMPIRICAL))
			return ("empirical", lw[i]);
	if(len w > 0){
		tg := tagger->tag(w);
		for(i = 0; i < len tg; i++)
			if(tg[i] == "VBD")
				return ("empirical", lw[i] + ", in the past tense");
	}
	return (nil, nil);
}

# O or P, logic's symbols for ought and permitted: a capital alone
# before a space or a bracket
deonticop(s: string): int
{
	for(i := 0; i < len s; i++)
		if((s[i] == 'O' || s[i] == 'P') && (i == 0 || !isalnum(s[i-1])) && i+1 < len s && (s[i+1] == ' ' || s[i+1] == '('))
			return 1;
	return 0;
}

isalnum(c: int): int
{
	return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c >= '0' && c <= '9' || c == '_';
}

has(s, t: string): int
{
	for(i := 0; i+len t <= len s; i++)
		if(s[i:i+len t] == t)
			return 1;
	return 0;
}

# The names in a formula: words of lower-case letters, digits and _.
tokens(s: string): list of string
{
	r: list of string;
	i := 0;
	while(i < len s){
		c := s[i];
		if(c >= 'a' && c <= 'z' || c == '_'){
			j := i;
			while(j < len s && (s[j] >= 'a' && s[j] <= 'z' || s[j] >= '0' && s[j] <= '9' || s[j] == '_'))
				j++;
			r = s[i:j] :: r;
			i = j;
		}else
			i++;
	}
	return r;
}

rev(l: list of (int, string, string, string, string)): list of (int, string, string, string, string)
{
	r: list of (int, string, string, string, string);
	for(; l != nil; l = tl l)
		r = hd l :: r;
	return r;
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
	for(i := 0; i < len s; i++)
		if(s[i] >= 'A' && s[i] <= 'Z')
			s[i] += 'a' - 'A';
	return s;
}

fatal(s: string)
{
	sys->fprint(sys->fildes(2), "phil/kind: %s\n", s);
	raise "fail:error";
}
