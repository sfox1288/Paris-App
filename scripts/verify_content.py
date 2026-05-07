#!/usr/bin/env python3
"""Lint the bundled POI / itinerary JSON.

Checks:
  - pois.json: every entry has the required keys, valid category,
    well-formed lat/lon, no duplicate ids
  - itinerary.json: every stop references a poiId that exists in pois.json,
    dates are ISO yyyy-MM-dd

Run from the repo root. Exits non-zero on any failure.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POIS_PATH = ROOT / "ParisCompanion" / "Resources" / "pois.json"
ITIN_PATH = ROOT / "ParisCompanion" / "Resources" / "itinerary.json"

REQUIRED_POI_KEYS = {
    "id", "name", "category", "lat", "lon", "address",
    "neighborhood", "rickSteves", "practical", "photos", "tags",
}
CATEGORIES = {"museum", "landmark", "church", "neighborhood", "restaurant", "viewpoint"}
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")


def fail(msg: str) -> None:
    print(f"FAIL: {msg}", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    if not POIS_PATH.exists():
        fail(f"{POIS_PATH} not found")
    if not ITIN_PATH.exists():
        fail(f"{ITIN_PATH} not found")

    pois = json.loads(POIS_PATH.read_text(encoding="utf-8"))
    itin = json.loads(ITIN_PATH.read_text(encoding="utf-8"))

    seen = set()
    for p in pois:
        missing = REQUIRED_POI_KEYS - set(p.keys())
        if missing:
            fail(f"POI {p.get('id')!r} missing keys: {sorted(missing)}")
        if p["category"] not in CATEGORIES:
            fail(f"POI {p['id']!r} unknown category {p['category']!r}")
        if not isinstance(p["lat"], (int, float)) or not isinstance(p["lon"], (int, float)):
            fail(f"POI {p['id']!r} lat/lon not numeric")
        if not (-90 <= p["lat"] <= 90) or not (-180 <= p["lon"] <= 180):
            fail(f"POI {p['id']!r} lat/lon out of range")
        if p["id"] in seen:
            fail(f"duplicate POI id {p['id']!r}")
        seen.add(p["id"])

    stops = 0
    for day in itin:
        if not DATE_RE.match(day.get("date", "")):
            fail(f"itinerary day has bad date: {day.get('date')!r}")
        for stop in day.get("stops", []):
            stops += 1
            pid = stop.get("poiId")
            if pid not in seen:
                fail(f"itinerary {day['date']!r} references unknown poiId {pid!r}")

    print(f"ok: {len(pois)} POIs, {len(itin)} itinerary days, {stops} stops")


if __name__ == "__main__":
    main()
