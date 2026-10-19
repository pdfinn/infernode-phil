#!/usr/bin/env python3
"""stress.py outdir - logic files that grow along one dimension each,
to find where wwb/prove breaks and how (run.sh runs them).  Each family
doubles a size until the file is large; the answer of each is known:

	chain-N	N implications in a row; valid
	cnf-N	random 3-CNF over N atoms at the hard ratio; either
	wide-N	N independent premises and a conclusion from two; valid
	nest-N	a formula nested N deep (!!...!a); valid
	mono-K	K one-place predicates, all and some (2^K individuals); valid
	steps-N	N steps, each from the last; valid
	objs-N	N objections, each answering the one before; survives
		if N is even
"""
import os, random, sys

def write(path, text):
	open(path, 'w').write(text)

def atoms(names):
	return ''.join('atom\t%s\t%s holds\n' % (a, a) for a in names)

def main():
	out = sys.argv[1]
	os.makedirs(out, exist_ok=True)
	r = random.Random(7)
	for n in (100, 200, 400, 800, 1600, 3200, 6400):
		s = atoms(['c%d' % i for i in range(n+1)])
		s += ''.join('P%d\t-\tc%d -> c%d\n' % (i+1, i, i+1) for i in range(n))
		s += 'P%d\t-\tc0\nC\t-\tc%d\n' % (n+1, n)
		write(os.path.join(out, 'chain-%05d.logic' % n), s)
	for n in (50, 75, 100, 150, 200, 300):
		vs = ['v%d' % i for i in range(n)]
		s = atoms(vs)
		for i in range(int(4.26*n)):
			cl = r.sample(vs, 3)
			s += 'P%d\t-\t%s\n' % (i+1, ' | '.join(v if r.random() < .5 else '!' + v for v in cl))
		s += 'C\t-\t%s\n' % vs[0]
		write(os.path.join(out, 'cnf-%05d.logic' % n), s)
	for n in (100, 400, 1600, 6400, 25600):
		s = atoms(['w%d' % i for i in range(n)])
		s += ''.join('P%d\t-\tw%d\n' % (i+1, i) for i in range(n))
		s += 'C\t-\tw0 & w%d\n' % (n-1)
		write(os.path.join(out, 'wide-%05d.logic' % n), s)
	for n in (100, 1000, 10000, 100000):
		s = atoms(['a'])
		s += 'P1\t-\ta\nC\t-\t' + '!' * (2*n) + 'a\n'
		write(os.path.join(out, 'nest-%06d.logic' % n), s)
		s = atoms(['a'])
		s += 'P1\t-\ta\nC\t-\t' + '(' * n + 'a' + ')' * n + '\n'
		write(os.path.join(out, 'paren-%06d.logic' % n), s)
	for k in (2, 3, 4, 5, 6, 7, 8):
		ps = ['q%d' % i for i in range(k)]
		s = ''.join('atom\t%s(x)\tx is %s\n' % (p, p) for p in ps)
		# each predicate's all, chained, and some at the start
		s += ''.join('P%d\t-\tall x: %s(x) -> %s(x)\n' % (i+1, ps[i], ps[i+1]) for i in range(k-1))
		s += 'P%d\t-\tsome x: %s(x)\n' % (k, ps[0])
		s += 'C\t-\tsome x: %s(x)\n' % ps[-1]
		write(os.path.join(out, 'mono-%d.logic' % k), s)
	for n in (10, 50, 200, 800, 3200):
		s = atoms(['s%d' % i for i in range(n+1)])
		s += 'P0\t-\ts0\n' + ''.join('P%d\t-\ts%d -> s%d\n' % (i+1, i, i+1) for i in range(n))
		prev = 'P0'
		for i in range(n):
			name = 'C%d' % (i+1) if i < n-1 else 'C'
			s += '%s\t-\ts%d\tfrom %s P%d\n' % (name, i+1, prev, i+1)
			prev = name
		write(os.path.join(out, 'steps-%04d.logic' % n), s)
	for n in (10, 50, 200, 800, 3200):
		s = atoms(['g', 'b'])
		s += 'P1\t-\tg\nC\t-\tg\tfrom P1\n'
		prev = 'P1'
		for i in range(n):
			f = '!g' if i % 2 == 0 else 'g'
			s += 'O%d\t-\t%s\tagainst %s\n' % (i+1, f, prev) if i % 2 == 0 else 'R%d\t-\t%s\tagainst %s\n' % (i+1, f, prev)
			prev = ('O%d' if i % 2 == 0 else 'R%d') % (i+1)
		write(os.path.join(out, 'objs-%04d.logic' % n), s)

if __name__ == '__main__':
	main()
