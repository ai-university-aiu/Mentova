"""
Inspect a sample of failing ARC-AGI-1 tasks to identify needed transforms.
Shows the first training pair of each task plus grid dims and color info.
"""

import json, os

DATA_DIR = "/home/ccaitwo/Mentova/data/arc_agi_1"

PASSING = {
    "00d62c1b","1cf80156","1e0a9b12","25ff71a9","3906de3d","3c9b0459",
    "4347f46a","6150a2bd","67a3c6ac","68b16354","6f8cd79b","7468f01a",
    "74dd1130","9172f3a0","9dfd6313","a416b8f3","a5313dff","b1948b0a",
    "c59eb873","c8f0f002","d511f180","ed36ccf7"
}

def grid_dims(g): return len(g), len(g[0]) if g else 0
def colors(g): return sorted(set(c for row in g for c in row))
def fmt(g):
    return "\n  ".join(" ".join(str(c) for c in row) for row in g)

def conn_components(g):
    rows, cols = grid_dims(g)
    visited = set()
    count = 0
    def ff(r, c, color):
        stack = [(r,c)]
        while stack:
            cr,cc = stack.pop()
            if (cr,cc) in visited or not(0<=cr<rows and 0<=cc<cols) or g[cr][cc]!=color:
                continue
            visited.add((cr,cc))
            for dr,dc in [(-1,0),(1,0),(0,-1),(0,1)]:
                stack.append((cr+dr,cc+dc))
    for r in range(rows):
        for c in range(cols):
            if (r,c) not in visited:
                color = g[r][c]
                ff(r,c,color)
                count += 1
    return count

def guess_transform(inp, out):
    ir, ic = grid_dims(inp)
    or_, oc = grid_dims(out)
    hints = []
    if (ir,ic) == (or_,oc):
        hints.append("same_size")
        if inp == out:
            hints.append("IDENTITY")
        if all(inp[r][c]==out[r][c] or inp[r][c]==0 or out[r][c]==0 for r in range(ir) for c in range(ic)):
            hints.append("only_additions_or_removals")
    if or_ < ir or oc < ic:
        hints.append(f"shrinks_{ir}x{ic}->{or_}x{oc}")
    if or_ > ir or oc > ic:
        hints.append(f"grows_{ir}x{ic}->{or_}x{oc}")
    inc = colors(inp)
    outc = colors(out)
    if set(inc) != set(outc):
        added = set(outc)-set(inc)
        removed = set(inc)-set(outc)
        if added: hints.append(f"new_colors:{sorted(added)}")
        if removed: hints.append(f"lost_colors:{sorted(removed)}")
    # count non-zero components
    in_cc = sum(1 for r in range(ir) for c in range(ic) if inp[r][c]!=0
                and not any(True for dr,dc in [(-1,0),(1,0),(0,-1),(0,1)]
                            if 0<=r+dr<ir and 0<=c+dc<ic and inp[r+dr][c+dc]==inp[r][c]
                            and (r+dr,c+dc) < (r,c)))
    # check if out is sub-grid of inp
    return hints

task_files = sorted(os.listdir(DATA_DIR))
failing = [os.path.splitext(f)[0] for f in task_files
           if f.endswith(".json") and os.path.splitext(f)[0] not in PASSING]

print(f"Failing tasks: {len(failing)}\n")
print("="*60)

# Group by output size category
categories = {"same_size":[], "output_smaller":[], "output_larger":[]}
for tid in failing:
    with open(f"{DATA_DIR}/{tid}.json") as f:
        data = json.load(f)
    pair = data["train"][0]
    ir,ic = grid_dims(pair["input"])
    or_,oc = grid_dims(pair["output"])
    if (ir,ic)==(or_,oc):
        categories["same_size"].append(tid)
    elif or_<ir or oc<ic:
        categories["output_smaller"].append(tid)
    else:
        categories["output_larger"].append(tid)

print(f"Same size: {len(categories['same_size'])}")
print(f"Output smaller: {len(categories['output_smaller'])}")
print(f"Output larger: {len(categories['output_larger'])}")
print()

# Show first 5 from each category
for cat, tids in categories.items():
    print(f"\n{'='*60}")
    print(f"CATEGORY: {cat}  ({len(tids)} tasks)")
    print('='*60)
    for tid in tids[:5]:
        with open(f"{DATA_DIR}/{tid}.json") as f:
            data = json.load(f)
        pairs = data["train"]
        print(f"\nTask: {tid}  ({len(pairs)} training pairs)")
        for i, pair in enumerate(pairs[:2]):
            inp, out = pair["input"], pair["output"]
            ir,ic = grid_dims(inp)
            or_,oc = grid_dims(out)
            inc = colors(inp)
            outc = colors(out)
            print(f"  Pair {i+1}: {ir}x{ic} -> {or_}x{oc}  "
                  f"in_colors:{inc}  out_colors:{outc}")
            if ir <= 6 and ic <= 6 and or_ <= 6 and oc <= 6:
                print(f"  IN:\n  {fmt(inp)}")
                print(f"  OUT:\n  {fmt(out)}")
        print()
