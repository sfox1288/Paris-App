#!/usr/bin/env python3
"""Build pois.json from a CSV + per-POI Markdown directory.

Usage:
    python3 scripts/build_content.py <input_dir> [output_path]

<input_dir> contains:
  - pois.csv    — header row, one row per POI
  - content/    — directory with one <id>.md file per POI

CSV columns (in any order):
    id, name, category, lat, lon, address, neighborhood,
    hours, cost, duration, reservation, tags, photos

`tags` and `photos` are pipe-separated (`a|b|c`). Empty cells become null
in the practical block, [] for tags/photos.

Default output: ParisCompanion/Resources/pois.json
"""
import csv
import json
import sys
from pathlib import Path

REQUIRED = ["id", "name", "category", "lat", "lon", "address", "neighborhood"]
CATEGORIES = {"museum", "landmark", "church", "neighborhood", "restaurant", "viewpoint"}


def build(input_dir: Path, output: Path) -> None:
    csv_path = input_dir / "pois.csv"
    content_dir = input_dir / "content"
    if not csv_path.exists():
        sys.exit(f"error: {csv_path} not found")
    if not content_dir.is_dir():
        sys.exit(f"error: {content_dir} not found")

    pois = []
    with csv_path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            for col in REQUIRED:
                if not (row.get(col) or "").strip():
                    sys.exit(f"error: row missing required column '{col}': {row}")
            cat = row["category"].strip()
            if cat not in CATEGORIES:
                sys.exit(f"error: unknown category '{cat}' for id={row['id']}")
            md_path = content_dir / f"{row['id'].strip()}.md"
            if not md_path.exists():
                sys.exit(f"error: {md_path} not found for poi id={row['id']}")
            try:
                lat = float(row["lat"])
                lon = float(row["lon"])
            except ValueError:
                sys.exit(f"error: bad lat/lon for id={row['id']}")
            tags = [t.strip() for t in (row.get("tags") or "").split("|") if t.strip()]
            photos = [p.strip() for p in (row.get("photos") or "").split("|") if p.strip()]
            pois.append({
                "id": row["id"].strip(),
                "name": row["name"].strip(),
                "category": cat,
                "lat": lat,
                "lon": lon,
                "address": row["address"].strip(),
                "neighborhood": row["neighborhood"].strip(),
                "rickSteves": md_path.read_text(encoding="utf-8").strip(),
                "practical": {
                    "hours": _opt(row.get("hours")),
                    "cost": _opt(row.get("cost")),
                    "duration": _opt(row.get("duration")),
                    "reservation": _opt(row.get("reservation")),
                },
                "photos": photos,
                "tags": tags,
            })

    ids = [p["id"] for p in pois]
    if len(ids) != len(set(ids)):
        dupes = sorted({i for i in ids if ids.count(i) > 1})
        sys.exit(f"error: duplicate POI ids: {dupes}")

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8") as f:
        json.dump(pois, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"wrote {len(pois)} POIs to {output}")


def _opt(v):
    if v is None:
        return None
    s = v.strip()
    return s or None


def main() -> None:
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print(__doc__.strip(), file=sys.stderr)
        sys.exit(2)
    input_dir = Path(sys.argv[1])
    output = Path(sys.argv[2]) if len(sys.argv) == 3 else Path("ParisCompanion/Resources/pois.json")
    build(input_dir, output)


if __name__ == "__main__":
    main()
