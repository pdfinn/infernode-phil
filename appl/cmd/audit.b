implement Audit;

#
# phil/audit [-c chain] file ... - whether each reading is one a model
# wrote, as it now stands: its statements matched against the records
# phil/read and phil/argue sealed in the audit log (auditfs(4)), so that
# a provenance line is a fact the tools can show and not only a claim
# they make.  A file with a # read by line is a reading.  Its statements
# (every line not a comment) are hashed, SHA-256; the reading is backed
# when a phil/read record names that hash, or when a phil/argue record
# does (the reading argue kept, after settling and tidying) and every
# reading it names as its source has a phil/read record.  Anything else
# was written or changed by another hand after the model read: a
# finding at the # read by line,
#
#	x.logic:12: audit/unbacked: no sealed record of these statements: read by claude-opus-5-5, ...
#
# and a backed reading is said to be, with the record:
#
#	x.logic: audit/backed: phil/read, record 41, 2026-10-19
#
# then the counts.  A file with no # read by line is not a model's
# reading and is counted apart.  The chain is /mnt/audit/chain, or the
# one beside the log $philaudit names, unless -c names a copy of it; that the chain itself is whole is auditverify's
# to say (auditverify < chain), not this.  Fails when any reading is
# unbacked.
#
# phil/audit -h file ... prints the hash of each file's statements, the
# one the records carry, so that read and argue seal what this checks.
#

include "sys.m";
	sys: Sys;
include "draw.m";
include "bufio.m";
	bufio: Bufio;
	Iobuf: import bufio;
include "arg.m";
include "keyring.m";
	kr: Keyring;
include "daytime.m";
	daytime: Daytime;

Audit: module
{
	init:	fn(nil: ref Draw->Context, args: list of string);
};

# a sealed record of a reading or a kept reading
Rec: adt {
	seq:	string;
	when:	int;
	source:	string;
	sha:	string;
	from:	list of string;
};

out: ref Iobuf;

init(nil: ref Draw->Context, args: list of string)
{
	sys = load Sys Sys->PATH;
	bufio = load Bufio Bufio->PATH;
	kr = load Keyring Keyring->PATH;
	daytime = load Daytime Daytime->PATH;
	arg := load Arg Arg->PATH;
	if(bufio == nil || kr == nil || arg == nil || daytime == nil)
		fatal(sys->sprint("cannot load: %r"));
	arg->init(args);
	arg->setusage("phil/audit [-h] [-c chain] file ...");
	chain := "/mnt/audit/chain";
	if((pa := env("philaudit")) != nil) {
		for(i := len pa - 1; i > 0 && pa[i] != '/'; i--)
			;
		chain = pa[0:i] + "/chain";
	}
	hashonly := 0;
	while((o := arg->opt()) != 0)
		case o {
		'c' =>	chain = arg->earg();
		'h' =>	hashonly = 1;
		* =>	arg->usage();
		}
	files := arg->argv();
	if(files == nil)
		arg->usage();
	out = bufio->fopen(sys->fildes(1), Bufio->OWRITE);

	if(hashonly) {
		for(; files != nil; files = tl files) {
			(h, nil, nil, err) := statements(hd files);
			if(err != nil)
				fatal(err);
			out.puts(h + "\n");
		}
		out.flush();
		return;
	}

	(reads, kept, err) := records(chain);
	if(err != nil)
		fatal(err);
	nread := nbacked := nunbacked := nother := 0;
	for(; files != nil; files = tl files) {
		f := hd files;
		(h, line, prov, e) := statements(f);
		if(e != nil)
			fatal(e);
		if(line == 0) {
			nother++;
			continue;
		}
		nread++;
		r := find(reads, h);
		if(r == nil) {
			k := find(kept, h);
			if(k != nil) {
				missing := 0;
				for(l := k.from; l != nil; l = tl l)
					if(find(reads, hd l) == nil)
						missing++;
				if(missing == 0)
					r = k;
				else {
					nunbacked++;
					out.puts(sys->sprint("%s:%d: audit/unbacked: kept by %s, record %s, from %d reading(s) with no sealed record: %s\n",
						f, line, k.source, k.seq, missing, prov));
					continue;
				}
			}
		}
		if(r == nil) {
			nunbacked++;
			out.puts(sys->sprint("%s:%d: audit/unbacked: no sealed record of these statements: %s\n", f, line, prov));
			continue;
		}
		nbacked++;
		out.puts(sys->sprint("%s: audit/backed: %s, record %s, %s\n", f, r.source, r.seq, day(r.when)));
	}
	out.puts(sys->sprint("audit: readings %d, backed %d, unbacked %d, not read by a model %d\n",
		nread, nbacked, nunbacked, nother));
	out.flush();
	if(nunbacked > 0)
		raise "fail:unbacked";
}

# the SHA-256 of the file's statements (every line that is not a
# comment), the line of its first # read by, and that line's text
statements(f: string): (string, int, string, string)
{
	b := bufio->open(f, Bufio->OREAD);
	if(b == nil)
		return (nil, 0, nil, sys->sprint("cannot open %s: %r", f));
	state: ref Keyring->DigestState;
	n := 0;
	line := 0;
	prov := "";
	while((s := b.gets('\n')) != nil) {
		n++;
		if(s[0] == '#') {
			if(line == 0 && prefix("# read by ", s)) {
				line = n;
				prov = s[2:];
				if(prov != "" && prov[len prov - 1] == '\n')
					prov = prov[0:len prov - 1];
			}
			continue;
		}
		a := array of byte s;
		state = kr->sha256(a, len a, nil, state);
	}
	digest := array[Keyring->SHA256dlen] of byte;
	kr->sha256(nil, 0, digest, state);
	h := "";
	for(i := 0; i < len digest; i++)
		h += sys->sprint("%2.2ux", int digest[i]);
	return (h, line, prov, nil);
}

# the chain's records of readings (phil/read reading) and of readings
# kept (phil/argue kept): seq time source event chainhash msg, where msg
# is name=value words, sha256= and from= among them
records(chain: string): (list of ref Rec, list of ref Rec, string)
{
	b := bufio->open(chain, Bufio->OREAD);
	if(b == nil)
		return (nil, nil, sys->sprint("cannot open %s: %r", chain));
	reads, kept: list of ref Rec;
	while((s := b.gets('\n')) != nil) {
		(n, w) := sys->tokenize(s, " \t\n");
		if(n < 6)
			continue;
		seq := hd w; w = tl w;
		when := int hd w; w = tl w;
		source := hd w; w = tl w;
		event := hd w; w = tl w;
		w = tl w;	# the chain's hash
		r := ref Rec(seq, when, source, nil, nil);
		for(; w != nil; w = tl w) {
			if(prefix("sha256=", hd w))
				r.sha = (hd w)[7:];
			else if(prefix("from=", hd w)) {
				(nil, fl) := sys->tokenize((hd w)[5:], ",");
				r.from = fl;
			}
		}
		if(r.sha == nil)
			continue;
		if(source == "phil/read" && event == "reading")
			reads = r :: reads;
		else if(source == "phil/argue" && event == "kept")
			kept = r :: kept;
	}
	return (reads, kept, nil);
}

find(l: list of ref Rec, h: string): ref Rec
{
	for(; l != nil; l = tl l)
		if((hd l).sha == h)
			return hd l;
	return nil;
}

day(t: int): string
{
	tm := daytime->gmt(t);
	return sys->sprint("%d-%.2d-%.2d", tm.year + 1900, tm.mon + 1, tm.mday);
}

env(name: string): string
{
	fd := sys->open("/env/" + name, Sys->OREAD);
	if(fd == nil)
		return nil;
	b := array[1024] of byte;
	n := sys->read(fd, b, len b);
	if(n <= 0)
		return nil;
	s := string b[0:n];
	if(s[len s - 1] == '\0')
		s = s[0:len s - 1];
	return s;
}

prefix(p, s: string): int
{
	return len s >= len p && s[0:len p] == p;
}

fatal(s: string)
{
	sys->fprint(sys->fildes(2), "phil/audit: %s\n", s);
	raise "fail:error";
}
