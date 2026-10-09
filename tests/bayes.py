"""Bayesian reading of recorded bouts (tests/pairs.gd output).

Each unordered pairing has its own unknown chance p that the first fighter
beats the second; with a uniform Beta(1,1) prior, after w wins in n bouts the
posterior is Beta(1+w, 1+n-w). A pairing is settled once one side is more than
90% likely to be the favourite; the rest need more bouts. Each fighter's win
rate is the mean, over its opponents, of its posterior chance against each,
with a 90% credible interval by sampling.

Usage: python3 tests/bayes.py RESULTS.jsonl [NEXT_PAIRS.json]
"""
import json, random, sys
from collections import defaultdict
from statistics import mean

random.seed(1)
wins = defaultdict(lambda: [0, 0])  # (a, b) with a < b -> [a wins, bouts]
names = set()
for line in open(sys.argv[1]):
    r = json.loads(line)
    if r["winner"] < 0:
        continue
    a, b = r["a"], r["b"]
    names.update([a, b])
    first, second = sorted([a, b])
    winner = a if r["winner"] == 0 else b
    wins[(first, second)][1] += 1
    if winner == first:
        wins[(first, second)][0] += 1

def favour(w, n, draws=4000):
    """P(p > 0.5) under Beta(1+w, 1+n-w)."""
    return sum(random.betavariate(1 + w, 1 + n - w) > 0.5 for _ in range(draws)) / draws

settled, open_pairs = 0, []
for (a, b), (w, n) in sorted(wins.items()):
    pf = favour(w, n)
    if pf > 0.9 or pf < 0.1:
        settled += 1
    else:
        open_pairs.append([a, b])
print(f"pairings: {len(wins)}; settled (one side >90% likely the favourite): {settled}; open: {len(open_pairs)}")

rows = []
for x in sorted(names):
    samples = []
    for _ in range(2000):
        s = []
        for y in names:
            if y == x:
                continue
            first, second = sorted([x, y])
            w, n = wins[(first, second)]
            p = random.betavariate(1 + w, 1 + n - w)
            s.append(p if x == first else 1 - p)
        samples.append(mean(s))
    samples.sort()
    rows.append((mean(samples), samples[100], samples[1900], x))
rows.sort(reverse=True)
total = sum(n for _, n in wins.values())
print(f"bouts: {total}")
for m, lo, hi, x in rows:
    print(f"  {x:11s} {100*m:5.1f}%   90% interval {100*lo:4.1f}–{100*hi:4.1f}")

# The most one-sided settled pairings.
lop = sorted(((w / n if n else 0.5, a, b, w, n) for (a, b), (w, n) in wins.items() if n), key=lambda t: abs(t[0] - 0.5), reverse=True)[:6]
print("most one-sided:")
for frac, a, b, w, n in lop:
    win, lose = (a, b) if frac >= 0.5 else (b, a)
    print(f"  {win} beats {lose} {max(w, n - w)} of {n}")

if len(sys.argv) > 2:
    nxt = []
    for a, b in open_pairs:
        nxt += [[a, b], [b, a]]
    json.dump(nxt, open(sys.argv[2], "w"))
    print(f"next: {len(nxt)} ordered pairings written to {sys.argv[2]}")
