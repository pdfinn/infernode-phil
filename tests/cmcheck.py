# cmcheck.py file.p model - whether a countermodel as wwb/prove writes
# it (argue/countermodel, after the statement's name) makes every axiom
# of the TPTP problem prove -t writes true and its conjecture false.
# The formulas are evaluated over the model as given: variables named
# W1, W2, ... range over its worlds, the rest over its domain D.  An
# independent check on the models prove shows (tests/prove_z3_test.sh).
import re, sys
toks_re = re.compile(r"\s*(<=>|=>|\$true|\$false|[!?~&|(),:\[\]]|'[^']*'|[A-Za-z_][A-Za-z0-9_]*)")

def items(s):
	s = s.strip()
	if s in ('∅', '{}'): return []
	assert s[0] == '{' and s[-1] == '}', s
	out = []
	for t in re.findall(r'\([^)]*\)|[^,\s(][^,]*', s[1:-1]):
		t = t.strip()
		out.append(tuple(x.strip() for x in t[1:-1].split(',')) if t.startswith('(') else (t,))
	return out

def parse_model(m):
	worlds, R, univ, D = ['w0'], None, False, []
	vals = {}
	for part in [p.strip() for p in m.split('; ')]:
		if part.startswith('D = '): D = [t[0] for t in items(part[4:])]; continue
		if part.startswith('W = '): worlds = [t[0] for t in items(part[4:])]; continue
		mm = re.match(r'^(?:□|\[\]) over W, O over R: R = (.*)$', part)
		if mm: R = set(items(mm.group(1))); continue
		if part.startswith('R = '):
			r = part[4:]
			if r in ('W × W', 'W x W'): univ = True
			else: R = set(items(r))
			continue
		w = 'w0'
		mm = re.match(r'^(w\d+): (.*)$', part)
		if mm: w, part = mm.group(1), mm.group(2)
		for a in re.findall(r'(\w+) = (T|F|∅|\{\}|\{[^}]*\})', part):
			name, v = a
			vals[(w, name)] = v in ('T',) if v in ('T', 'F') else set(items(v))
	if univ: R = {(a, b) for a in worlds for b in worlds}
	return worlds, R or set(), D, vals

def tokenize(s):
	out, i = [], 0
	while i < len(s):
		m = toks_re.match(s, i)
		if not m or m.end() == i: raise ValueError(s[i:])
		out.append(m.group(1)); i = m.end()
	return out

class Ev:
	def __init__(s, t, model, modal):
		s.t, s.i = t, 0
		s.worlds, s.R, s.D, s.vals = model
		s.modal = modal
	def peek(s): return s.t[s.i] if s.i < len(s.t) else None
	def eat(s, x=None):
		t = s.t[s.i]; s.i += 1
		assert x is None or t == x, (t, x); return t
	# parse to a closure over an environment
	def form(s):
		l = s.unary()
		op = s.peek()
		if op in ('&', '|', '=>', '<=>'):
			s.eat(); r = s.unary()
			return {'&': lambda e: l(e) and r(e), '|': lambda e: l(e) or r(e),
				'=>': lambda e: not l(e) or r(e), '<=>': lambda e: l(e) == r(e)}[op]
		return l
	def unary(s):
		t = s.peek()
		if t == '~': s.eat(); f = s.unary(); return lambda e: not f(e)
		if t == '(': s.eat(); f = s.form(); s.eat(')'); return f
		if t in ('!', '?'):
			s.eat(); s.eat('['); v = s.eat(); s.eat(']'); s.eat(':')
			body = s.unary()
			dom = s.worlds if re.match(r'^W\d+$', v) else s.D
			if t == '!': return lambda e: all(body({**e, v: x}) for x in dom)
			return lambda e: any(body({**e, v: x}) for x in dom)
		if t == '$true': s.eat(); return lambda e: True
		if t == '$false': s.eat(); return lambda e: False
		name = s.eat(); args = []
		if s.peek() == '(':
			s.eat()
			while True:
				args.append(s.eat())
				if s.peek() == ',': s.eat(); continue
				s.eat(')'); break
		def val(e, name=name, args=args):
			a = [e.get(x, x) for x in args]
			if name == 'r': return (a[0], a[1]) in s.R
			w = 'w0'
			if s.modal and a and a[-1] in s.worlds: w, a = a[-1], a[:-1]
			v = s.vals.get((w, name.strip("'")))
			if v is None: return False
			if isinstance(v, bool): return v and not a
			return tuple(a) in v
		return val

def main():
	src = open(sys.argv[1]).read()
	model = parse_model(sys.argv[2])
	modal = 'standard translation' in src
	ok = True
	for name, role, body in re.findall(r'fof\((\w+), (axiom|conjecture), (.*)\)\.\s*$', src, re.M):
		if name == 'serial':
			v = all(any((w, u) in model[1] for u in model[0]) for w in model[0])
		elif name == 'reflexive':
			v = all((w, w) in model[1] for w in model[0])
		else:
			v = Ev(tokenize(body), model, modal).form()({})
		want = role == 'axiom'
		if v != want:
			print('%s is %s in the model' % (name, 'true' if v else 'false'))
			ok = False
	print('ok' if ok else 'not a countermodel')
main()
