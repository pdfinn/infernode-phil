#!/usr/bin/env python3
"""compare.py benchdir [vampire] - phil/prove's verdicts and times (from
run.inferno) set beside Z3's, E's and Vampire's on the same arguments,
written as TPTP by prove -t.  Each prover gets 10 seconds an argument.

Verdicts are in logic's terms: Theorem (the conclusion follows),
CounterSatisfiable (a case refutes it), or Unknown (undecided, out of
time).  prove's own verdict is read from its measure argue/valid (1, 0,
-1); where it calls an argument invalid because its premises
contradict each other or its conclusion restates one, the conclusion
still follows in logic, and that is counted as Theorem.

E is $EPROVER, or eprover on the path.

Times are the wall time of the whole command, as a user or an agent
running it would wait for it (for prove, inside the emulator, the
loading of its modules included); Z3's is also given as the solver's
alone, in this process.
"""
import os, re, subprocess, sys, time, statistics, importlib.util

here = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location('fof2z3', os.path.join(here, '..', '..', 'tests', 'fof2z3.py'))
fof2z3 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fof2z3)

LIMIT = 10

def ours(path):
	s = open(path).read()
	m = re.search(r'argue/valid (-?\d)', s)
	if not m:
		return 'Error'
	v = int(m.group(1))
	if v == 1:
		return 'Theorem'
	if v == 0:
		if 'argue/inconsistent' in s or 'argue/circular' in s:
			return 'Theorem'
		return 'CounterSatisfiable'
	return 'Unknown'

def szs(out):
	m = re.search(r'SZS status (\w+)', out)
	if not m:
		return 'Unknown'
	s = m.group(1)
	if s in ('Theorem', 'Unsatisfiable', 'ContradictoryAxioms'):
		return 'Theorem'
	if s in ('CounterSatisfiable', 'Satisfiable'):
		return 'CounterSatisfiable'
	return 'Unknown'

def timed(cmd):
	t = time.perf_counter()
	try:
		r = subprocess.run(cmd, capture_output=True, text=True, timeout=LIMIT + 5)
		out = r.stdout + r.stderr
	except subprocess.TimeoutExpired:
		out = ''
	return out, time.perf_counter() - t

def main():
	d = sys.argv[1]
	vampire = sys.argv[2] if len(sys.argv) > 2 else None
	rows = []
	for line in open(os.path.join(d, 'times')):
		name, t0, t1 = line.split()
		p = os.path.join(d, name + '.p')
		# no TPTP (prove failed before writing it): nothing to compare
		if not os.path.exists(p) or 'conjecture' not in open(p).read():
			print('SKIPPED %s: no TPTP written' % name, file=sys.stderr)
			continue
		row = {'name': name, 'cls': re.sub(r'-\d+$', '', name),
			'ours': ours(os.path.join(d, name + '.ours')), 'ours_t': (int(t1) - int(t0)) / 1e6}
		t = time.perf_counter()
		try:
			row['z3'] = fof2z3.decide(p, LIMIT * 1000)
		except Exception as e:
			row['z3'] = 'Error'
		row['z3_t'] = time.perf_counter() - t
		out, row['z3p_t'] = timed(['python3', '-I', os.path.join(here, '..', '..', 'tests', 'fof2z3.py'), p])
		out, row['e_t'] = timed([os.environ.get('EPROVER', 'eprover'), '--auto', '--cpu-limit=%d' % LIMIT, '-s', p])
		row['e'] = szs(out)
		if vampire:
			out, row['v_t'] = timed([vampire, '--mode', 'casc', '-t', str(LIMIT), p])
			row['v'] = szs(out)
			if row['v'] == 'Unknown':
				out, t2 = timed([vampire, '--mode', 'casc_sat', '-t', str(LIMIT), p])
				row['v'] = szs(out)
				row['v_t'] += t2
		rows.append(row)
	provers = ['ours', 'z3', 'e'] + (['v'] if vampire else [])
	names = {'ours': 'prove', 'z3': 'Z3', 'e': 'E', 'v': 'Vampire'}
	# the answer: what any prover proved or refuted (they must not differ)
	for r in rows:
		known = {r[k] for k in provers if r[k] in ('Theorem', 'CounterSatisfiable')}
		r['truth'] = known.pop() if len(known) == 1 else ('Conflict' if known else 'Unknown')
	classes = []
	for r in rows:
		if r['cls'] not in classes:
			classes.append(r['cls'])
	print('class\tn\tvalid\t' + '\t'.join('%s right/undecided/wrong' % names[k] for k in provers))
	for c in classes:
		rs = [r for r in rows if r['cls'] == c]
		line = '%s\t%d\t%d' % (c, len(rs), sum(r['truth'] == 'Theorem' for r in rs))
		for k in provers:
			right = sum(r[k] == r['truth'] and r[k] != 'Unknown' for r in rs)
			unk = sum(r[k] in ('Unknown', 'Error') for r in rs)
			wrong = sum(r[k] in ('Theorem', 'CounterSatisfiable') and r[k] != r['truth'] for r in rs)
			line += '\t%d/%d/%d' % (right, unk, wrong)
		print(line)
	print()
	cols = [('ours_t', 'prove'), ('z3_t', 'Z3 solver'), ('z3p_t', 'Z3 command'), ('e_t', 'E')] + ([('v_t', 'Vampire')] if vampire else [])
	print('seconds, median (max)\t' + '\t'.join(n for _, n in cols))
	for c in classes:
		rs = [r for r in rows if r['cls'] == c]
		print(c + '\t' + '\t'.join('%.3f (%.2f)' % (statistics.median(r[k] for r in rs), max(r[k] for r in rs)) for k, _ in cols))
	print()
	bad = [r for r in rows if r['truth'] == 'Conflict' or any(r[k] in ('Theorem', 'CounterSatisfiable') and r[k] != r['truth'] for k in provers)]
	for r in bad:
		print('DISAGREE %s: %s' % (r['name'], ', '.join('%s %s' % (names[k], r[k]) for k in provers)))
	if not bad:
		print('no disagreements')

if __name__ == '__main__':
	main()
