#!/usr/bin/env python3
"""lwb.py lwbdir outdir logic [limit] - phil/prove on the Logics Workbench
benchmark (Balsiger, Heuerding and Schwendimann 2000) for modal logic K
or KT, beside KSP and Spartacus, the dedicated modal provers.

Each class (k_branch_p, k_d4_n, ...) has 21 formulas, harder as they go;
those of a class ending _p are theorems, _n not.  Each prover is run on
a class from the first formula up, with a limit of seconds each
(default 10), until it fails twice in a row; its score for the class is
the highest formula it decided, and any verdict against the class's is
reported as WRONG.  lwbdir is a checkout of
github.com/cormackikkert/LWB-benchmark-generator (its fmls_k, fmls_kt);
$WWB is the Writer's Workbench (by default beside this tree), $ROOT the InferNode tree, $KSP and $SPARTACUS
the provers' binaries (and $KSPCONF its conf.files directory).

	python3 -I tools/prove-bench/lwb.py lwb out k 10
"""
import os, re, subprocess, sys, time

PHIL = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
WWB = os.environ.get('WWB', os.path.join(os.path.dirname(PHIL), 'infernode-wwb'))
ROOT = os.environ['ROOT']
KSP = os.environ.get('KSP')
KSPCONF = os.environ.get('KSPCONF')
SPART = os.environ.get('SPARTACUS')
EMU = os.path.join(ROOT, 'emu', 'Linux', 'o.emu')

def formulas(path):
	fs = {}
	for line in open(path):
		m = re.match(r'\s*(\d+):\s*(.*\S)\s*$', line)
		if m:
			fs[int(m.group(1))] = m.group(2)
	return fs

def ours(f, logic):
	g = re.sub(r'\bbox\b', '[]', f.replace(' v ', ' | '))
	g = re.sub(r'\bdia\b', '<>', g)
	g = re.sub(r'\bfalse\b', '!true', g)
	atoms = sorted(set(re.findall(r'\bp\d+\b', g)), key=lambda a: int(a[1:]))
	s = 'logic\t%s\n' % logic
	s += ''.join('atom\t%s\t%s\n' % (a, a) for a in atoms)
	return s + 'C\t-\t%s\n' % g

def run(cmd, limit, cwd=None):
	t = time.perf_counter()
	try:
		r = subprocess.run(cmd, capture_output=True, text=True, timeout=limit, cwd=cwd)
		out = r.stdout + r.stderr
	except subprocess.TimeoutExpired:
		out = 'TIMEOUT'
	return out, time.perf_counter() - t

def prove(path, limit):
	script = os.path.join(os.path.dirname(path), 'prove1.inferno')
	if not os.path.exists(script):
		open(script, 'w').write('load std\nrun $1/philns $1 $2\nphil/prove $3 >[2=1]\necho halt > /dev/sysctl\n')
	out, t = run([EMU, '-c1', '-pheap=1024m', '-pmain=1024m', '-r' + ROOT, 'sh', '#U*' + script, '#U*' + PHIL, '#U*' + WWB, '#U*' + path], limit)
	m = re.search(r'argue/valid (-?\d)', out)
	if m:
		v = int(m.group(1))
		if v == 1 or v == 0 and ('argue/inconsistent' in out or 'argue/circular' in out):
			return 'valid', t, out
		if v == 0:
			return 'invalid', t, out
		return 'undecided', t, out
	if 'TIMEOUT' in out:
		return 'timeout', t, out
	return 'failed', t, out

def ksp(path, f, logic, limit):
	g = f.replace(' v ', ' | ')
	kf = path + '.ksp'
	open(kf, 'w').write('sos(formulas).\n~(%s).\nend_of_list.\n' % g)
	cmd = [KSP, '-c', os.path.join(KSPCONF, 'ijcar-2022', 'cord_mlple_K.conf')]
	if logic == 'kt':
		cmd += ['-global2local', '-c', os.path.join(KSPCONF, 'ijcar-2022', 'T_ref.conf')]
	out, t = run(cmd + ['-i', kf], limit)
	if 'Unsatisfiable.' in out:
		return 'valid', t, out
	if 'Satisfiable.' in out:
		return 'invalid', t, out
	return ('timeout' if out == 'TIMEOUT' else 'failed'), t, out

def spartacus(lwbfile, n, logic, limit):
	cmd = [SPART, '--lwbFile=' + lwbfile, '--index=%d' % n, '--negate']
	if logic == 'kt':
		cmd.append('--reflexive')
	out, t = run(cmd, limit)
	last = out.strip().splitlines()[-1].strip() if out.strip() else ''
	if last == 'unsatisfiable':
		return 'valid', t, out
	if last == 'satisfiable':
		return 'invalid', t, out
	return ('timeout' if out == 'TIMEOUT' else 'failed'), t, out

def main():
	lwbdir, outdir, logic = sys.argv[1], sys.argv[2], sys.argv[3]
	limit = float(sys.argv[4]) if len(sys.argv) > 4 else 10
	os.makedirs(outdir, exist_ok=True)
	fdir = os.path.join(lwbdir, 'fmls_' + logic)
	provers = ['prove', 'KSP', 'Spartacus']
	print('class\t' + '\t'.join(provers) + '\t(highest formula decided of 21; how the next failed)')
	for cls in sorted(f[:-4] for f in os.listdir(fdir) if f.endswith('.txt')):
		lwbfile = os.path.join(fdir, cls + '.txt')
		fs = formulas(lwbfile)
		want = 'valid' if cls.endswith('_p') else 'invalid'
		row = [cls]
		for p in provers:
			best, fails, why, wrong = 0, 0, '', []
			for n in sorted(fs):
				path = os.path.join(outdir, '%s-%02d.logic' % (cls, n))
				if p == 'prove':
					open(path, 'w').write(ours(fs[n], logic))
					v, t, out = prove(path, limit)
				elif p == 'KSP':
					v, t, out = ksp(path, fs[n], logic, limit)
				else:
					v, t, out = spartacus(lwbfile, n, logic, limit)
				if v in ('valid', 'invalid'):
					if v != want:
						wrong.append(n)
						print('WRONG %s %s %d: %s, not %s' % (p, cls, n, v, want), file=sys.stderr)
					best, fails = n, 0
				else:
					fails += 1
					if not why:
						why = v
						if v == 'failed':
							why += ': ' + ' '.join(out.split())[:80]
					if fails >= 2:
						break
			cell = '%d' % best
			if wrong:
				cell += ' WRONG' + ','.join(map(str, wrong))
			if best < max(fs) and why:
				cell += ' (%s)' % why.split(':')[0]
			row.append(cell)
		print('\t'.join(row), flush=True)

if __name__ == '__main__':
	main()
