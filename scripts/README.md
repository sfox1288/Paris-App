# Content scripts

Tools for editing the bundled POI / itinerary data without hand-writing JSON.

## `build_content.py`

Builds `ParisCompanion/Resources/pois.json` from a CSV plus a folder of
per-POI Markdown files.

```sh
python3 scripts/build_content.py scripts/sample_content/
# → wrote 5 POIs to ParisCompanion/Resources/pois.json
```

To target a different output path:

```sh
python3 scripts/build_content.py scripts/sample_content/ /tmp/preview.json
```

### Input layout

```
my_content/
├── pois.csv
└── content/
    ├── louvre.md
    ├── notre-dame.md
    └── ...
```

### CSV columns

| column | required | notes |
|---|---|---|
| `id` | yes | unique slug, used by itinerary stops |
| `name` | yes | display name |
| `category` | yes | one of `museum`, `landmark`, `church`, `neighborhood`, `restaurant`, `viewpoint` |
| `lat`, `lon` | yes | decimal degrees |
| `address` | yes | full street address |
| `neighborhood` | yes | `1er — Louvre / Tuileries` style |
| `hours` | optional | free text, e.g. `Daily 9:00–18:00` |
| `cost` | optional | free text, e.g. `€22, free first Sun` |
| `duration` | optional | free text |
| `reservation` | optional | free text |
| `tags` | optional | pipe-separated (`must-see|indoor`) |
| `photos` | optional | pipe-separated filenames in `Photos.xcassets/` |

The Markdown body of `content/<id>.md` becomes the POI's `rickSteves` field.
SwiftUI renders it as inline-only Markdown (paragraph breaks preserved,
inline emphasis/links honored — no headings or lists).

## `verify_content.py`

Lints the bundled JSON: catches itinerary stops that point at missing POI
ids, duplicate ids, malformed coordinates. Run before committing content
changes:

```sh
python3 scripts/verify_content.py
# → ok: 5 POIs, 3 itinerary days, 5 stops
```

Exits non-zero on any failure.
