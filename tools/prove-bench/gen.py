#!/usr/bin/env python3
"""gen.py outdir [seed] - arguments for benchmarking wwb/prove against
first-order provers (Z3, E, Vampire).  Each is a logic file as
wwb/argue writes them, named by its class:

	prop	propositional, a few atoms, as a paragraph's argument is
	propm	propositional, a dozen atoms and premises, a long document's
	chain-N	a chain of N implications among distractors, valid
	cnf-N	random 3-CNF over N atoms at the hard ratio (4.26 clauses
		an atom), the conclusion an atom: a search problem, not an
		argument anyone writes, to find where trying cases stops
	mono	one-place predicates, all and some, named individuals
	rel	two-place relations, some within all: not decidable in general
	s5, kd	propositional modal (necessity and possibility, in S5) and
		deontic (ought and permitted, in KD), operators nested to 2

Half the prop, propm and mono arguments are made to be valid (the
conclusion follows from two premises), so verdicts are not all one way.
The seed makes the set the same each time.

	python3 -I tools/prove-bench/gen.py /tmp/bench 1
"""
import os, random, sys

def lit(r, atoms):
	a = r.choice(atoms)
	return a if r.random() < 0.6 else '!' + a

def form(r, atoms, depth):
	if depth == 0 or r.random() < 0.3:
		return lit(r, atoms)
	op = r.choice(['&', '|', '->', '->', '<->'])
	return '(%s %s %s)' % (form(r, atoms, depth-1), op, form(r, atoms, depth-1))

def write(path, atoms, prems, concl, preds=None, logic=None):
	with open(path, 'w') as f:
		if logic:
			f.write('logic\t%s\n' % logic)
		for a in atoms:
			f.write('atom\t%s\t%s holds\n' % (a, a))
		for p, n in (preds or []):
			args = ','.join('xyz'[:n])
			f.write('atom\t%s(%s)\t%s\n' % (p, args, p + ' of ' + ' and '.join('xyz'[:n])))
		for i, p in enumerate(prems):
			f.write('P%d\t-\t%s\n' % (i+1, p))
		f.write('C\t-\t%s\n' % concl)

def prop(r, nat, nprem, depth, valid):
	atoms = ['a%d' % i for i in range(nat)]
	prems = [form(r, atoms, depth) for _ in range(nprem)]
	if valid:
		# the conclusion from two premises: whatever both make true
		c = form(r, atoms, 1)
		prems.append('(%s & %s) -> %s' % (prems[0], prems[1], c))
		r.shuffle(prems)
	else:
		c = form(r, atoms, depth)
	return atoms, prems, c

def mform(r, atoms, depth, mdepth):
	if depth == 0 or r.random() < 0.25:
		f = lit(r, atoms)
	else:
		op = r.choice(['&', '|', '->', '->', '<->'])
		f = '(%s %s %s)' % (mform(r, atoms, depth-1, mdepth), op, mform(r, atoms, depth-1, mdepth))
	if mdepth > 0 and r.random() < 0.45:
		f = r.choice(['[]', '<>']) + f
		if r.random() < 0.3:
			f = r.choice(['[]', '<>']) + f
	return f

def modal(r, logic, valid):
	atoms = ['m%d' % i for i in range(r.randint(2, 4))]
	prems = [mform(r, atoms, 2, 2) for _ in range(r.randint(1, 3))]
	if valid:
		c = mform(r, atoms, 1, 1)
		prems.append('(%s) -> %s' % (prems[0], c))
		r.shuffle(prems)
	else:
		c = mform(r, atoms, 2, 2)
	return atoms, prems, c, None, logic

def chain(r, n):
	atoms = ['c%d' % i for i in range(n+1)] + ['d%d' % i for i in range(n//2)]
	prems = ['c%d -> c%d' % (i, i+1) for i in range(n)]
	ds = atoms[n+1:]
	for i in range(n//2):
		prems.append('(%s | %s) -> %s' % (r.choice(ds), r.choice(atoms[:n+1]), r.choice(ds)))
	r.shuffle(prems)
	return atoms, prems, 'c0 -> c%d' % n

def cnf(r, n):
	atoms = ['v%d' % i for i in range(n)]
	prems = []
	for _ in range(int(4.26 * n)):
		vs = r.sample(atoms, 3)
		prems.append('(' + ' | '.join(v if r.random() < 0.5 else '!' + v for v in vs) + ')')
	return atoms, prems, r.choice(atoms)

def mono(r, valid):
	ps = ['p', 'q', 'r', 's'][:r.randint(2, 4)]
	consts = ['k1', 'k2']
	def ml(v):
		p = r.choice(ps)
		return '%s(%s)' % (p, v) if r.random() < 0.6 else '!%s(%s)' % (p, v)
	def mf():
		k = r.random()
		if k < 0.4:
			return 'all x: %s -> %s' % (ml('x'), ml('x'))
		if k < 0.6:
			return 'some x: %s & %s' % (ml('x'), ml('x'))
		if k < 0.8:
			return ml(r.choice(consts))
		return 'all x: %s | %s' % (ml('x'), ml('x'))
	prems = [mf() for _ in range(r.randint(2, 5))]
	if valid:
		# all x: A -> B, A(k) |- B(k), with A and B new predicates' literals
		a, b = r.choice(ps), r.choice(ps)
		k = r.choice(consts)
		prems += ['all x: %s(x) -> %s(x)' % (a, b), '%s(%s)' % (a, k)]
		r.shuffle(prems)
		c = '%s(%s)' % (b, k)
	else:
		c = mf()
	return [], prems, c, [(p, 1) for p in ps]

def rel(r):
	prems = [
		r.choice(['all x: some y: e(x,y)', 'all x: some y: e(y,x)', 'some x: all y: e(x,y)']),
		r.choice(['all x: all y: e(x,y) -> e(y,x)', 'all x: all y: e(x,y) -> !e(y,x)', 'all x: !e(x,x)', 'all x: all y: e(x,y) -> m(y)']),
		r.choice(['some x: m(x)', 'all x: m(x) -> some y: e(y,x)', 'm(k1)']),
	]
	c = r.choice(['some x: e(x,x)', 'some x: all y: e(y,x)', 'all x: some y: e(y,x)', 'some y: (some x: e(y,x)) & !(some z: e(z,y))', 'some x: m(x)'])
	return [], prems, c, [('e', 2), ('m', 1)]

def main():
	out = sys.argv[1]
	r = random.Random(int(sys.argv[2]) if len(sys.argv) > 2 else 1)
	os.makedirs(out, exist_ok=True)
	n = 0
	def emit(cls, i, t):
		nonlocal n
		atoms, prems, c = t[0], t[1], t[2]
		preds = t[3] if len(t) > 3 else None
		logic = t[4] if len(t) > 4 else None
		write(os.path.join(out, '%s-%03d.logic' % (cls, i)), atoms, prems, c, preds, logic)
		n += 1
	for i in range(200):
		emit('prop', i, prop(r, r.randint(3, 6), r.randint(2, 5), 2, i % 2 == 0))
	for i in range(100):
		emit('propm', i, prop(r, r.randint(10, 14), r.randint(6, 10), 3, i % 2 == 0))
	for k in (10, 20, 40, 80, 160):
		for i in range(3):
			emit('chain%d' % k, i, chain(r, k))
	for k in (10, 20, 30, 40, 50):
		for i in range(4):
			emit('cnf%d' % k, i, cnf(r, k))
	for i in range(200):
		emit('mono', i, mono(r, i % 2 == 0))
	for i in range(100):
		emit('rel', i, rel(r))
	for logic in ('s5', 'kd'):
		for i in range(150):
			emit(logic, i, modal(r, logic, i % 2 == 0))
	print(n, 'arguments in', out)

if __name__ == '__main__':
	main()
