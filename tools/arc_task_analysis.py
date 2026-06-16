"""
ARC-AGI-1 Task Analysis — Acc_72
Categorizes the 383 failing tasks by the type of reasoning they require.
"""

import json
import os
from collections import Counter, defaultdict

DATA_DIR = "/home/ccaitwo/Mentova/data/arc_agi_1"

PASSING = {
    "1e0a9b12", "25ff71a9", "3906de3d", "3c9b0459", "6150a2bd",
    "67a3c6ac", "68b16354", "6f8cd79b", "74dd1130", "9172f3a0",
    "9dfd6313", "a416b8f3", "b1948b0a", "c59eb873", "c8f0f002",
    "d511f180", "ed36ccf7"
}


def grid_dims(grid):
    rows = len(grid)
    cols = len(grid[0]) if grid else 0
    return rows, cols


def unique_colors(grid):
    return set(c for row in grid for c in row)


def color_histogram(grid):
    h = Counter()
    for row in grid:
        for c in row:
            h[c] += 1
    return h


def is_same_dims(in_g, out_g):
    return grid_dims(in_g) == grid_dims(out_g)


def dims_ratio(in_g, out_g):
    ir, ic = grid_dims(in_g)
    or_, oc = grid_dims(out_g)
    if ir == 0 or ic == 0:
        return None
    return (or_ / ir, oc / ic)


def is_color_only(in_g, out_g):
    """Same dims, same structure but some cells have different colors."""
    if not is_same_dims(in_g, out_g):
        return False
    for r, (ri, ro) in enumerate(zip(in_g, out_g)):
        for ci, co in zip(ri, ro):
            if ci != co:
                return True  # at least one cell differs
    return False


def is_exact_same(in_g, out_g):
    return in_g == out_g


def count_connected_components(grid, color=None):
    """Count connected regions (4-connectivity). If color=None, count non-zero."""
    rows, cols = grid_dims(grid)
    visited = [[False] * cols for _ in range(rows)]
    count = 0

    def in_bounds(r, c):
        return 0 <= r < rows and 0 <= c < cols

    def matches(r, c):
        v = grid[r][c]
        if color is None:
            return v != 0
        return v == color

    def flood(r, c):
        stack = [(r, c)]
        while stack:
            cr, cc = stack.pop()
            if not in_bounds(cr, cc) or visited[cr][cc] or not matches(cr, cc):
                continue
            visited[cr][cc] = True
            for dr, dc in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                stack.append((cr + dr, cc + dc))

    for r in range(rows):
        for c in range(cols):
            if not visited[r][c] and matches(r, c):
                flood(r, c)
                count += 1
    return count


def classify_task(task_id, data):
    pairs = data["train"]
    results = []
    for pair in pairs:
        ig = pair["input"]
        og = pair["output"]
        results.append({
            "same_dims": is_same_dims(ig, og),
            "dims_ratio": dims_ratio(ig, og),
            "in_colors": unique_colors(ig),
            "out_colors": unique_colors(og),
            "in_dims": grid_dims(ig),
            "out_dims": grid_dims(og),
            "in_components": count_connected_components(ig),
            "out_components": count_connected_components(og),
        })

    # All pairs same dims?
    all_same_dims = all(r["same_dims"] for r in results)

    # Consistent size change ratio?
    ratios = [r["dims_ratio"] for r in results]
    all_scale_2 = all(r == (2.0, 2.0) for r in ratios)
    all_scale_3 = all(r == (3.0, 3.0) for r in ratios)
    shrink = all(r is not None and r[0] < 1.0 or r[1] < 1.0 for r in ratios) if ratios else False

    # Color changes
    all_colors_in = set()
    all_colors_out = set()
    for r in results:
        all_colors_in |= r["in_colors"]
        all_colors_out |= r["out_colors"]

    # Object counts
    avg_in_comp = sum(r["in_components"] for r in results) / len(results) if results else 0
    avg_out_comp = sum(r["out_components"] for r in results) / len(results) if results else 0

    # Categorize
    categories = []

    if all_scale_2 or all_scale_3:
        categories.append("scale")
    elif not all_same_dims:
        if shrink:
            categories.append("shrink/crop")
        else:
            categories.append("resize/tile/embed")

    if all_same_dims:
        # Same dims — what changed?
        # Check if color-only (non-black cells changed color)
        n_colors_changed = len(all_colors_in.symmetric_difference(all_colors_out))
        if n_colors_changed > 0:
            categories.append("recolor")
        # Check if looks like object movement (component count changes)
        if abs(avg_in_comp - avg_out_comp) > 0.3:
            categories.append("object_move_or_merge")
        else:
            categories.append("geometric_or_fill")

    if avg_in_comp > 2 or avg_out_comp > 2:
        if "object_move_or_merge" not in categories:
            categories.append("multi_object")

    if not categories:
        categories.append("unknown")

    return categories


def main():
    task_files = [f for f in os.listdir(DATA_DIR) if f.endswith(".json")]
    task_files.sort()

    failing_ids = [os.path.splitext(f)[0] for f in task_files
                   if os.path.splitext(f)[0] not in PASSING]

    print(f"Total tasks: {len(task_files)}")
    print(f"Passing (Acc_71): {len(PASSING)}")
    print(f"Failing: {len(failing_ids)}")
    print()

    category_counter = Counter()
    size_change_counter = Counter()
    component_buckets = Counter()

    per_task = {}
    for tid in failing_ids:
        path = os.path.join(DATA_DIR, f"{tid}.json")
        with open(path) as f:
            data = json.load(f)

        cats = classify_task(tid, data)
        per_task[tid] = cats
        for c in cats:
            category_counter[c] += 1

        # Size change analysis
        pairs = data["train"]
        for pair in pairs:
            ir, ic = grid_dims(pair["input"])
            or_, oc = grid_dims(pair["output"])
            if (ir, ic) == (or_, oc):
                size_change_counter["same_size"] += 1
            elif or_ > ir or oc > ic:
                size_change_counter["output_larger"] += 1
            else:
                size_change_counter["output_smaller"] += 1

        # Component analysis on first training pair
        ig = pairs[0]["input"]
        n_comp = count_connected_components(ig)
        if n_comp == 1:
            component_buckets["1 object"] += 1
        elif n_comp == 2:
            component_buckets["2 objects"] += 1
        elif n_comp <= 5:
            component_buckets["3-5 objects"] += 1
        elif n_comp <= 10:
            component_buckets["6-10 objects"] += 1
        else:
            component_buckets[">10 objects"] += 1

    print("=== TASK CATEGORY DISTRIBUTION ===")
    print("(categories are not mutually exclusive)")
    for cat, count in category_counter.most_common():
        pct = count / len(failing_ids) * 100
        print(f"  {cat:<30} {count:>4}  ({pct:.1f}%)")
    print()

    print("=== INPUT/OUTPUT SIZE RELATIONSHIP ===")
    total_pairs = sum(size_change_counter.values())
    for k, v in size_change_counter.most_common():
        pct = v / total_pairs * 100
        print(f"  {k:<25} {v:>5}  ({pct:.1f}% of training pairs)")
    print()

    print("=== CONNECTED COMPONENTS IN FIRST TRAINING INPUT ===")
    for k, v in sorted(component_buckets.items(), key=lambda x: x[1], reverse=True):
        pct = v / len(failing_ids) * 100
        print(f"  {k:<25} {v:>4}  ({pct:.1f}%)")
    print()

    print("=== OUTPUT GRID SIZE DISTRIBUTION ===")
    out_size_counter = Counter()
    for tid in failing_ids:
        path = os.path.join(DATA_DIR, f"{tid}.json")
        with open(path) as f:
            data = json.load(f)
        first_out = data["train"][0]["output"]
        r, c = grid_dims(first_out)
        if r == 1 and c == 1:
            out_size_counter["1x1 (single cell)"] += 1
        elif r <= 3 and c <= 3:
            out_size_counter["tiny (<=3x3)"] += 1
        elif r <= 10 and c <= 10:
            out_size_counter["small (<=10x10)"] += 1
        else:
            out_size_counter["large (>10x10)"] += 1

    for k, v in out_size_counter.most_common():
        pct = v / len(failing_ids) * 100
        print(f"  {k:<30} {v:>4}  ({pct:.1f}%)")
    print()

    # Tasks with 1x1 output (likely counting tasks)
    print("=== SAMPLE TASKS WITH 1x1 OUTPUT ===")
    count_1x1 = 0
    for tid in failing_ids:
        path = os.path.join(DATA_DIR, f"{tid}.json")
        with open(path) as f:
            data = json.load(f)
        outs = [p["output"] for p in data["train"]]
        if all(grid_dims(o) == (1, 1) for o in outs):
            print(f"  {tid}  outputs: {[o[0][0] for o in outs]}")
            count_1x1 += 1
            if count_1x1 >= 10:
                print("  ... (truncated)")
                break

    print()
    print("Analysis complete.")


if __name__ == "__main__":
    main()
