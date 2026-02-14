import json
import sys
import re
from pathlib import Path

def find_json_files(root: Path, qps:int):
    return sorted([p for p in root.rglob("*.json") if p.is_file() and p.name.find(qps)!=-1 and p.name.find("raw")==-1])

def flatten(obj, parent_key="", sep="."):
    items = {}
    if isinstance(obj, dict):
        for k, v in obj.items():
            new_key = f"{parent_key}{sep}{k}" if parent_key else k
            items.update(flatten(v, new_key, sep))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            new_key = f"{parent_key}{sep}{i}" if parent_key else str(i)
            items.update(flatten(v, new_key, sep))
    else:
        items[parent_key] = obj
    return items

def title_from_filename(p: Path):
    base = p.stem
    # parts = re.split(r"[\s._\-]+", base)
    parts = re.split(r"[\s.\-]+", base)
    return parts[0] if parts and parts[0] else base

# summary.py SOURCE_JSON_PATH SUMMARY_BENCHMARK_RPS
# summary.py results/ summary-5000.md
def main():
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("summary-5000.md")
    qps = re.split(r"[\s._\-]+", out.stem)[1]
    # print(qps)

    files = find_json_files(root, qps)
    if not files:
        print("No JSON files found under", root)
        sys.exit(1)

    datasets = []
    for f in files:
        with f.open() as fh:
            data = json.load(fh)
        datasets.append((f, flatten(data)))

    # Use keys from the first file (assumes same structure)
    keys = sorted(datasets[0][1].keys())

    headers = ["Metric"] + [title_from_filename(f) for f, _ in datasets]
    header_row = "| " + " | ".join(headers) + " |"
    align_row = "|---|" + "|".join(["---:"] * len(datasets)) + "|"

    rows = [header_row, align_row]
    for k in keys:
        vals = []
        for _, d in datasets:
            v = d.get(k, "N/A")
            if v is None:
                vals.append("N/A")
            elif isinstance(v, (int, float)):
                vals.append(str(v))
            else:
                vals.append(str(v))
        rows.append("| {} | {} |".format(k, " | ".join(vals)))

    out.parent.mkdir(parents=True, exist_ok=True)
    out_md="\n".join(rows) + "\n"
    # out.write_text("\n".join(rows) + "\n")
    out.write_text(out_md)
    print(out_md)
    print(f"Wrote summary to {out}")

if __name__ == "__main__":
    main()