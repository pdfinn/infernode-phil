# fof2z3.py file.p - decide a TPTP fof problem, the subset phil/prove -t
# writes, with Z3: Theorem if the axioms and the denied conjecture are
# unsatisfiable, CounterSatisfiable if satisfiable, else Unknown.  An
# independent check on phil/prove (tests/prove_z3_test.sh).
import re, sys, z3
toks_re = re.compile(r"\s*(<=>|=>|\$true|\$false|[!?~&|(),:\[\]]|'[^']*'|[A-Za-z_][A-Za-z0-9_]*)")
U = z3.DeclareSort('U')
preds, consts = {}, {}
def tokenize(s):
	out, i = [], 0
	while i < len(s):
		m = toks_re.match(s, i)
		if not m or m.end() == i: raise ValueError(s[i:])
		out.append(m.group(1)); i = m.end()
	return out
class P:
	def __init__(s, t): s.t, s.i = t, 0
	def peek(s): return s.t[s.i] if s.i < len(s.t) else None
	def eat(s, x=None):
		t = s.t[s.i]; s.i += 1
		assert x is None or t == x, (t, x); return t
def form(p, env):
	f = binary(p, env)
	return f
def binary(p, env):
	l = unary(p, env)
	op = p.peek()
	if op in ('&', '|', '=>', '<=>'):
		p.eat(); r = unary(p, env)
		return {'&': z3.And, '|': z3.Or, '=>': z3.Implies, '<=>': lambda a, b: a == b}[op](l, r)
	return l
def unary(p, env):
	t = p.peek()
	if t == '~': p.eat(); return z3.Not(unary(p, env))
	if t == '(': p.eat(); f = form(p, env); p.eat(')'); return f
	if t in ('!', '?'):
		p.eat(); p.eat('['); v = p.eat(); p.eat(']'); p.eat(':')
		x = z3.Const(v, U); e = dict(env); e[v] = x
		body = unary(p, e)
		return z3.ForAll([x], body) if t == '!' else z3.Exists([x], body)
	if t == '$true': p.eat(); return z3.BoolVal(True)
	if t == '$false': p.eat(); return z3.BoolVal(False)
	name = p.eat(); args = []
	if p.peek() == '(':
		p.eat()
		while True:
			a = p.eat()
			args.append(env[a] if a in env else consts.setdefault(a, z3.Const('c_' + a, U)))
			if p.eat() == ')': break
	key = (name, len(args))
	if key not in preds:
		preds[key] = z3.Function(name, *([U] * len(args) + [z3.BoolSort()])) if args else z3.Bool(name)
	return preds[key](*args) if args else preds[key]
def decide(path, timeout=10000):
	"""Theorem, CounterSatisfiable or Unknown for the TPTP file at path."""
	preds.clear(); consts.clear()
	axioms, conj = [], None
	for line in open(path):
		m = re.match(r'fof\(([^,]+),\s*(axiom|conjecture),\s*(.*)\)\.\s*$', line)
		if not m: continue
		f = form(P(tokenize(m.group(3))), {})
		if m.group(2) == 'axiom': axioms.append(f)
		else: conj = f
	s = z3.Solver(); s.set('timeout', timeout)
	s.add(*axioms)
	if conj is not None: s.add(z3.Not(conj))
	r = s.check()
	return 'Theorem' if r == z3.unsat else 'CounterSatisfiable' if r == z3.sat else 'Unknown'

if __name__ == '__main__':
	print(decide(sys.argv[1]))
