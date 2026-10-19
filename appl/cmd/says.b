implement Says;

#
# phil/says [-x] document - whom a document gives its claims to: each
# sentence that reports another's claim, by rule, with no model.  A
# report is a reporting verb with a named subject (Mill says, Hobbes
# argues that, the moderns maintain), the same verb after a quotation
# (says Mill), according to a name, a name's view or words, and as a
# name calls it; a pronoun subject (he holds) is given to the last name
# reported, and a report with no one named (it is said, it has been
# maintained) to "-".  What the writer says in the first person, or of
# anyone (one might say), is the writer's own.  The words are tagged by
# wwb's tagger (an averaged perceptron, wwb/tag).  Each report is a
# finding at its sentence:
#
#	file:line: says/report: S4: mill (says Mill)
#
# and the count follows, for gate.  It is what argue's readers mark with
# a premise's says field, found another way: the two can be held to
# each other, and the bench measures the one against the other.
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
include "tagger.m";
	tagger: Tagger;

Says: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

out: ref Iobuf;

# /lib/words: a word listed with a capital is a name (Hobbes, Locke), one
# listed in lower case is not (experience, mill); hashed
Nhash: con 4093;
capwords := array[Nhash] of list of string;
lowwords := array[Nhash] of list of string;

# The reporting verbs, in their forms.
VERBS := array[] of {
	"say", "says", "said", "saying",
	"argue", "argues", "argued", "arguing",
	"hold", "holds", "held", "holding",
	"maintain", "maintains", "maintained", "maintaining",
	"claim", "claims", "claimed", "claiming",
	"assert", "asserts", "asserted", "asserting",
	"contend", "contends", "contended",
	"think", "thinks", "thought",
	"believe", "believes", "believed",
	"deny", "denies", "denied",
	"teach", "teaches", "taught",
	"affirm", "affirms", "affirmed",
	"observe", "observes", "observed",
	"remark", "remarks", "remarked",
	"declare", "declares", "declared",
	"insist", "insists", "insisted",
	"write", "writes", "wrote",
	"tell", "tells", "told",
	"admit", "admits", "admitted",
	"grant", "grants", "granted",
	"urge", "urges", "urged",
	"object", "objects", "objected",
	"reply", "replies", "replied",
	"answer", "answers", "answered",
	"propose", "proposes", "proposed",
	"conclude", "concludes", "concluded",
	"suggest", "suggests", "suggested",
	"allege", "alleges", "alleged", "alledged",
	"describe", "describes", "described",
	"express", "expresses", "expressed",
	"explain", "explains", "explained", "explaining",
	"imagine", "imagines", "imagined",
	"suppose", "supposes", "supposed",
	"call", "calls", "called",
};

# What a name's report may be called.
VIEWS := array[] of {
	"view", "views", "opinion", "opinions", "doctrine", "doctrines",
	"words", "theory", "argument", "arguments", "position", "account",
	"principle", "principles", "maxim", "dictum", "saying", "definition",
};

# The writer, or anyone: not another's report.
OWN := array[] of { "i", "we", "you", "one", "us", "thou", "thee", "ye" };

# Proper nouns that are not people: languages and peoples.
NOTPERSON := array[] of { "greek", "greeks", "latin", "latins", "english", "french", "german", "hebrew", "italian", "roman", "romans" };

# Modals that make "it ... said" the writer's own: it must be said, it
# cannot be said (may, might: an objection put, someone's)
OWNMODAL := array[] of { "must", "should", "can", "cannot", "ought", "will", "shall", "not", "n't" };

# What may stand before a surname and is not it.
TITLES := array[] of { "dr", "dr.", "mr", "mr.", "st", "st.", "saint", "sir", "professor", "lord", "bishop" };

# Pronouns given to the last name reported.
HE := array[] of { "he", "she", "they" };

# Verbs that report only with "as" before the name (as Bentham calls it):
# alone they are too common.
ASONLY := array[] of { "call", "calls", "called", "suppose", "supposes", "supposed", "imagine", "imagines", "imagined", "think", "thinks", "thought" };

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
	if((err := tagger->init(nil)) != nil)
		fatal(err);
	readwords("/lib/words");
	arg := load Arg Arg->PATH;
	arg->init(args);
	arg->setusage("phil/says [-x] document");
	while((o := arg->opt()) != 0)
		case o {
		'x' =>	prose->exact(1);
		* =>	arg->usage();
		}
	args = arg->argv();
	if(len args != 1)
		arg->usage();
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);
	file := hd args;
	(name, lines, rerr) := prose->readtext(file, Prose->Fauto);
	if(rerr != nil)
		fatal(rerr);
	sents := prose->sentences(name, lines);
	last := "";
	n := 0;
	for(i := 0; i < len sents; i++){
		s := sents[i];
		(reps, l) := reports(s.s, last);
		last = l;
		for(; reps != nil; reps = tl reps){
			(who, cue) := hd reps;
			out.puts(prose->finding(s.file, s.line, -1, -1, "says/report",
				sys->sprint("S%d: %s (%s)", i+1, who, cue)));
			n++;
		}
	}
	out.puts(sys->sprint("%s: says/reports %d\n", name, n));
	out.flush();
}

# The reports in a sentence, each (whom, the words that say so), the
# first of each speaker; and the last name reported, for a pronoun in a
# sentence after.
reports(s: string, last: string): (list of (string, string), string)
{
	tt := tagger->tokens(s);
	n := len tt;
	if(n == 0)
		return (nil, last);
	w := array[n] of string;	# as written
	lw := array[n] of string;	# lower case
	for(i := 0; i < n; i++){
		(w[i], nil) = tt[i];
		lw[i] = lower(w[i]);
	}
	tg := tagger->tag(w);
	r: list of (string, string);
	for(i = 0; i < n; i++){
		# according to Locke
		if(lw[i] == "according" && i+2 < n && lw[i+1] == "to"){
			(who, e) := nameat(w, tg, i+2);
			if(who != nil){
				r = add(r, who, phrase(w, i, e));
				last = who;
			}
			continue;
		}
		# as we learn from Hesiod
		if(lw[i] == "from" && i > 0 && (lw[i-1] == "learn" || lw[i-1] == "learned" || lw[i-1] == "learnt" || lw[i-1] == "hear" || lw[i-1] == "heard") && i+1 < n){
			(who, e) := nameat(w, tg, i+1);
			if(who != nil){
				r = add(r, who, phrase(w, i-1, e-1));
				last = who;
			}
			continue;
		}
		# alleged by Bellarmine, held by the Stoics
		if(lw[i] == "by" && i > 0 && member(lw[i-1], VERBS) && tg[i-1] == "VBN" && i+1 < n){
			(who, e) := nameat(w, tg, i+1);
			if(who != nil){
				r = add(r, who, phrase(w, i-1, e-1));
				last = who;
			}
			continue;
		}
		# the doctrine of Epicurus, the words of Socrates
		if(lw[i] == "of" && i > 0 && member(lw[i-1], VIEWS) && w[i-1] == lw[i-1] && i+1 < n){
			(who, e) := nameat(w, tg, i+1);
			# a person's: not a common word written with a capital
			# (the principle of Utility)
			if(who != nil && !abstract(lower(w[e-1])) && (listed(capwords, w[e-1]) || !listed(lowwords, lower(w[e-1]))))
				r = add(r, who, phrase(w, i-1, e-1));
			continue;
		}
		# Locke's view, Locke's own words
		if(lw[i] == "'s" && i > 0 && i+1 < n){
			j := i+1;
			if(j < n && lw[j] == "own")
				j++;
			if(j < n && member(lw[j], VIEWS)){
				(who, b) := namebefore(w, tg, i-1);
				if(who != nil){
					r = add(r, who, phrase(w, b, j));
					last = who;
				}
			}
			continue;
		}
		# a reporting verb: so tagged, or followed by that, a comma or a
		# colon (the tagger takes "Hobbes argues" for two nouns)
		if(!member(lw[i], VERBS))
			continue;
		if(!isverb(tg[i]) && !(i+1 < n && (lw[i+1] == "that" || w[i+1] == "," || w[i+1] == ":")))
			continue;
		# the said book
		if(i > 0 && (tg[i-1] == "DT" || lw[i-1] == "the"))
			continue;
		# says Mill, after a quotation or a comma
		if(i > 0 && (w[i-1] == "\"" || w[i-1] == "''" || w[i-1] == "," || w[i-1] == "”") && i+1 < n){
			(who, e) := nameat(w, tg, i+1);
			if(who != nil){
				r = add(r, who, phrase(w, i, e));
				last = who;
				continue;
			}
		}
		# the subject before: a name, a group, a pronoun; adverbs,
		# himself, and a parenthesis in commas between
		j := i-1;
		perfect := 0;
		while(j >= 0 && (tg[j] == "RB" || tg[j] == "MD" || lw[j] == "himself" || lw[j] == "herself" || lw[j] == "themselves" ||
		    lw[j] == "also" || lw[j] == "too" || isaux(lw[j])))
			j--;
		for(m := j+1; m < i; m++)
			if(lw[m] == "has" || lw[m] == "have" || lw[m] == "had")
				perfect = 1;
		# texts alleged: a participle with no has is not its subject's
		# report (it is said is taken below)
		if(tg[i] == "VBN" && !perfect && !(j >= 0 && lw[j] == "it"))
			continue;
		if(j >= 0 && w[j] == ","){
			# Locke, however, holds
			k := j-1;
			while(k >= 0 && w[k] != "," && i-k < 8)
				k--;
			if(k >= 0 && w[k] == ",")
				j = k-1;
		}
		if(j < 0)
			continue;
		asonly := member(lw[i], ASONLY);
		if(asonly && !(j >= 1 && lw[j-1] == "as") && !(j >= 0 && isname(w[j], tg[j]) && j >= 1 && hasas(lw, j)))
			continue;
		if(member(lw[j], OWN))
			continue;
		if(member(lw[j], HE)){
			if(last != nil && !asonly)
				r = add(r, last, phrase(w, j, i) + ": " + lw[j] + ", " + last);
			continue;
		}
		# it is said, it has been maintained: no one named
		if(lw[j] == "it" && tg[i] == "VBN"){
			own := 0;
			for(m = j+1; m < i; m++)
				if(member(lw[m], OWNMODAL))
					own = 1;
			if(!own)
				r = add(r, "-", phrase(w, j, i));
			continue;
		}
		if(isname(w[j], tg[j])){
			(who, b) := namebefore(w, tg, j);
			if(who != nil){
				r = add(r, who, phrase(w, b, i));
				last = who;
			}
			continue;
		}
		# the philosophers maintain, the moderns hold
		if((tg[j] == "NNS" || tg[j] == "NNPS") && j >= 1 && (lw[j-1] == "the" || lw[j-1] == "some" || lw[j-1] == "many" || lw[j-1] == "these" || lw[j-1] == "those")){
			who := singular(lw[j]);
			r = add(r, who, phrase(w, j-1, i));
			continue;
		}
	}
	return (rev(r), last);
}

# Is "as" before the name ending at j (as Bentham calls it)?
hasas(lw: array of string, j: int): int
{
	for(k := j; k >= 0 && j-k < 4; k--)
		if(lw[k] == "as")
			return 1;
	return 0;
}

isaux(s: string): int
{
	return s == "has" || s == "have" || s == "had" || s == "does" || s == "did" || s == "do" ||
		s == "is" || s == "was" || s == "were" || s == "are" || s == "been" || s == "be" || s == "not" || s == "n't";
}

isverb(t: string): int
{
	return len t >= 2 && t[0:2] == "VB";
}

# A name: capitalized, and tagged one, or listed with a capital in
# /lib/words, or not listed at all (Bellarmine).
isname(s, t: string): int
{
	if(len s < 2 || s[0] < 'A' || s[0] > 'Z')
		return 0;
	if(t == "NNP" || t == "NNPS")
		return 1;
	if(t != "NN" && t != "NNS")
		return 0;
	if(listed(capwords, s))
		return 1;
	return !listed(lowwords, lower(s));
}

# An abstract noun by its ending: Utility, Reason, Justice are not people.
ABSTRACT := array[] of { "ity", "ism", "ness", "tion", "sion", "ance", "ence", "ment", "ship", "hood", "dom", "ice", "son", "ure", "ty" };

abstract(s: string): int
{
	for(i := 0; i < len ABSTRACT; i++){
		e := ABSTRACT[i];
		if(len s > len e + 2 && s[len s-len e:] == e)
			return 1;
	}
	return 0;
}

listed(h: array of list of string, s: string): int
{
	for(l := h[hash(s)]; l != nil; l = tl l)
		if(hd l == s)
			return 1;
	return 0;
}

hash(s: string): int
{
	h := 0;
	for(i := 0; i < len s; i++)
		h = (h*31 + s[i]) & 16r7FFFFFFF;
	return h % Nhash;
}

readwords(file: string)
{
	b := bufio->open(file, Bufio->OREAD);
	if(b == nil)
		return;
	while((s := b.gets('\n')) != nil){
		if(len s > 0 && s[len s-1] == '\n')
			s = s[0:len s-1];
		if(s == nil)
			continue;
		if(s[0] >= 'A' && s[0] <= 'Z')
			capwords[hash(s)] = s :: capwords[hash(s)];
		else
			lowwords[hash(s)] = s :: lowwords[hash(s)];
	}
}

# A name from i on: proper nouns, titles first; its surname and the
# index after it.
nameat(w, tg: array of string, i: int): (string, int)
{
	n := len w;
	j := i;
	while(j < n && member(lower(w[j]), TITLES))
		j++;
	if(j >= n || !isname(w[j], tg[j]))
		return (nil, i);
	while(j+1 < n && (isname(w[j+1], tg[j+1]) || w[j+1] == "." && j+2 < n && isname(w[j+2], tg[j+2])))
		j++;
	if(w[j] == ".")
		j--;
	if(member(surname(w[j]), NOTPERSON))
		return (nil, i);
	return (surname(w[j]), j+1);
}

# A name ending at j: its surname and where it begins.
namebefore(w, tg: array of string, j: int): (string, int)
{
	if(j < 0 || !isname(w[j], tg[j]))
		return (nil, j);
	b := j;
	while(b > 0 && (isname(w[b-1], tg[b-1]) || member(lower(w[b-1]), TITLES) || w[b-1] == "."))
		b--;
	if(member(surname(w[j]), NOTPERSON))
		return (nil, j);
	return (surname(w[j]), b);
}

surname(s: string): string
{
	s = lower(s);
	if(len s > 2 && s[len s-2:] == "'s")
		s = s[0:len s-2];
	while(len s > 0 && (s[len s-1] == '.' || s[len s-1] == ','))
		s = s[0:len s-1];
	return s;
}

# A group: the moderns, the philosophers.
singular(s: string): string
{
	return s;
}

phrase(w: array of string, a, b: int): string
{
	if(a < 0)
		a = 0;
	if(b >= len w)
		b = len w - 1;
	s := "";
	for(i := a; i <= b; i++){
		if(s != nil && w[i] != "," && w[i] != "'s" && w[i] != "." && w[i] != "''" )
			s += " ";
		s += w[i];
	}
	return s;
}

add(r: list of (string, string), who, cue: string): list of (string, string)
{
	for(l := r; l != nil; l = tl l){
		(w, nil) := hd l;
		if(w == who)
			return r;
	}
	return (who, cue) :: r;
}

rev(l: list of (string, string)): list of (string, string)
{
	r: list of (string, string);
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
	sys->fprint(sys->fildes(2), "phil/says: %s\n", s);
	raise "fail:error";
}
