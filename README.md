# Paris Companion

A personal iOS app for our Paris trip. Pre-loaded itinerary + Rick Steves notes,
offline POI browsing, MapKit pins, and walking-directions handoff to Google Maps.

iOS 17+, SwiftUI, MapKit, SwiftData. iPhone portrait only. Distributed via TestFlight (not App Store).

## Build (one-time setup)

You need a Mac with Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```sh
brew install xcodegen
xcodegen generate
open ParisCompanion.xcodeproj
```

Then in Xcode: select the **ParisCompanion** scheme, pick a simulator or device, and Run.

The `.xcodeproj` is **not** checked in — it's regenerated from `project.yml` whenever
files are added or removed. Re-run `xcodegen generate` after pulling changes.

## Project layout

```
project.yml                       # XcodeGen spec
ParisCompanion/
├── ParisCompanionApp.swift       # @main, TabView root
├── Info.plist                    # incl. LSApplicationQueriesSchemes for Google Maps
├── Models/
│   ├── POI.swift
│   ├── ItineraryDay.swift
│   ├── ContentStore.swift        # loads bundled JSON, in-memory cache
│   └── POIStatus.swift           # SwiftData: favorite / visited per POI
├── Views/
│   ├── TodayView.swift
│   ├── ItineraryView.swift
│   ├── MapView.swift
│   ├── BrowseView.swift
│   └── POIDetailView.swift
├── Components/
│   ├── POIRow.swift
│   ├── PracticalInfoBox.swift
│   └── DirectionsButton.swift    # Google Maps URL-scheme handoff
└── Resources/
    ├── pois.json
    └── itinerary.json
```

## Build phases

- [x] **Phase 1 — Skeleton + data.** Project scaffold, models, ContentStore loads 5 hand-coded POIs, Browse list confirms load. ← **you are here**
- [ ] **Phase 2 — POI Detail.** Practical info box, Markdown-rendered Rick Steves text, Google Maps directions button, favorite/visited toggle.
- [ ] **Phase 3 — Map + Browse.** MapKit pin view with category filter and tap-to-sheet. Browse polish.
- [ ] **Phase 4 — Itinerary.** Today view with date logic; full itinerary with expandable days.
- [ ] **Phase 5 — Real content.** Replace the 5 placeholder POIs with the full set; ingest Rick Steves text.
- [ ] **Phase 6 — Polish + TestFlight.** App icon, launch screen, empty/error states, device test in airplane mode, upload to TestFlight.

## Editing content

- **POIs:** edit `ParisCompanion/Resources/pois.json`. Each entry needs an `id`, `name`,
  `category` (one of `museum | landmark | church | neighborhood | restaurant | viewpoint`),
  `lat`/`lon`, and the rest of the fields shown in the existing entries. Itinerary stops
  reference POIs by `id`.
- **Itinerary:** edit `ParisCompanion/Resources/itinerary.json`. Dates are ISO `yyyy-MM-dd`,
  Europe/Paris timezone. Trip dates currently start **2026-06-15** — change to taste.
- No rebuild step beyond Xcode Run; JSON ships as a bundle resource.

## Trip dates

Sample itinerary covers **2026-06-15 → 2026-06-17**. Replace with real dates when ready.
The `Today` view will use the device clock against these dates to surface the right day.

## Copyright

Rick Steves' written content is copyrighted. Personal-use distribution via TestFlight
(family/friends on the trip) is fine. Do **not** publish builds containing his text
publicly or to the App Store.
