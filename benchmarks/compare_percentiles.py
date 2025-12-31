import json, sys

BASE = json.load(open(sys.argv[1]))
CURR = json.load(open(sys.argv[2]))

THRESHOLD = 1.10  # 10% regression allowed

def check(p):
    b = BASE[p]
    c = CURR[p]
    if c > b * THRESHOLD:
        print(f"❌ {p} regression: {b}ms → {c}ms")
        sys.exit(1)
    print(f"✅ {p} OK: {b}ms → {c}ms")

for p in ("p95", "p99"):
    check(p)