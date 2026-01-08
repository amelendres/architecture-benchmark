import json, sys

BASE = json.load(open(sys.argv[1]))
CURR = json.load(open(sys.argv[2]))

# Percentile comparison
THRESHOLD = 1.10  # 10% regression allowed
TP = (THRESHOLD-1)*100 # percentage
def check(p):
    b = BASE[p]
    c = CURR[p]
    max = b * THRESHOLD
    if c > max:
        print(f"❌ {b} regression: {b}ms → {c}ms (max {max:.2f}ms with {TP:.0f}% threshold)")
        sys.exit(1)
    print(f"✅ {p} OK: {b}ms → {c}ms (max {max:.2f}ms with {TP:.0f}% threshold)") 

for p in ("p95", "p99"):
    check(p)