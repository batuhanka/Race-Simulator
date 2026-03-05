# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Race Simulator (TAY ZEKA)** — An iOS SwiftUI app for Turkish horse racing. Integrates with the TJK (Türkiye Jokey Kulübü) API to display race programs, odds, results, betting tickets, and live race simulations.

## Build & Run

Open `Race Simulator.xcodeproj` in Xcode and build/run via Xcode (⌘R). No external dependencies — pure SwiftUI + URLSession. No test suite exists.

## Architecture

**Pattern:** SwiftUI + MVVM-lite. Simple state lives in views via `@State`/`@Binding`. Complex state uses `@Observable` ViewModels (`OddsViewModel`, `TicketViewModel`). No Combine, no centralized store.

**Navigation:** `NavigationStack` + custom tab bar (`CustomBottomBar.swift`). Entry: `RootView` (Matrix splash, 3s) → `MainShellView` (5-tab container).

**Tabs (0–4):**
0. Home (`MainView`) — date picker, city race cards
1. Program (`RaceDetailView`) — horse list, AGF, results, photo/video
2. AI insights (prepared, not implemented)
3. Odds (`OddsView` + `OddsViewModel`) — Muhtemeller & AGF tables, live refresh every 15s
4. Tickets (`TicketSetupView` + `TicketViewModel`) — kupon creation with AI generation

## Networking — JsonParser.swift

Single API client. All calls `async/await` + `URLSession`. Key endpoints:

| Method | URL pattern | Returns |
|--------|-------------|---------|
| `getRaceCities(raceDate:)` | `.../program/{yyyyMMdd}/yarislar.json` | `[String]` city names |
| `getProgramData(raceDate:cityName:)` | `.../program/{yyyyMMdd}/full/{city}.json` | `[String: Any]` with `hava`, `kosular`, `agf` keys |
| `getProgramResponse(date:cityName:)` | same URL | `ProgramResponse` (Decodable) |
| `getRaceResult(raceDate:cityName:targetKod:)` | `.../sonuclar/{yyyyMMdd}/full/{UPPERCASECITY}.json` | `RaceResult?` |
| `getMuhtemellerChecksum(date:)` | `vhs-medya.tjk.org/muhtemeller/s/{yyyy/MM/dd}/checksum.json` | `{runs: {key: [hash]}}` |
| `getMuhtemeller(date:raceKey:hash:)` | `vhs-medya-cdn.tjk.org/muhtemeller/s/.../key-hash.json` | `RaceDetailResponse` |
| `getBetData()` | `ebayi.tjk.org/s/d/bet/checksum.json` → `emedya-cdn.tjk.org/.../bet-{hash}.json` | `BetDataResponse` |

**Date format:** `yyyyMMdd` for program/results, `yyyy/MM/dd` for Muhtemeller.

## Domain Conventions

**Turkish field names** — TJK API uses Turkish abbreviations:
- `KOD` = code, `AD` = name, `JOKEYADI` = jockey, `KOSMAZ` = non-runner
- `AGF` = performance rating (used for simulation weighting and odds)
- `DON` / `YAS` = coat color code: `"k"` gray, `"a"` chestnut/orange, `"d"` brown, `"y"` black
- `RACENO` = race number (String), `MESAFE` = distance (m), `PIST` = track surface
- `PISTKODU` / `PISTADI_TR` = track type: `"Kum"`, `"Çim"`, `"Sentetik"`
- `BAHIS` = bet type name, `POOLUNIT` = unit cost (divide by 100 for TL)

**Mixed-type JSON fields** — Many API fields arrive as either String or Bool (e.g. `ONEMLIKOSUADI_TR` can be a race name String or `false`). Use `try? container.decodeIfPresent(String.self, ...)` first, then fall back. See `Race.swift` `decodeSafeBool` helper and `ONEMLIKOSUADI_TR` decoder pattern.

**CDN URLs** — Horse forma images: `medya.tjk.org` → replace with `medya-cdn.tjk.org` (HTTPS). Done in `Horse.swift` Codable init. Ekuri icons: `medya-cdn.tjk.org/imageftp/Img/e{ekuri}.gif`.

## Shared UI Patterns

### Track Type (PIST) Color Coding
Applied to background gradients and selected race buttons in `RaceDetailView`, `OddsView`, `SimulationSetupView`. Always implement as:
```swift
let pist = (race.PIST ?? "").lowercased(with: Locale(identifier: "tr_TR"))
if pist.contains("çim") || pist.contains("cim") { /* green */ }
else if pist.contains("kum")                    { /* brown */ }
else if pist.contains("sentetik")               { /* gray */ }
```
Background: `Color.black` base + `LinearGradient` top-to-bottom, `.animation(.easeInOut(duration: 0.6), value: selectedIndex)`.

### Turkish City Display
`String.turkishCityUppercased` extension lives in `RaceCardButton.swift`. Uses a lookup table for cities with problematic ASCII uppercasing (İZMİR, ŞANLIURFA, etc.). Apply everywhere a city name is displayed to the user.

### Weather Display (HavaData)
`weatherSFSymbol` mapping `icon-w-{1..8}` → SF Symbols lives in **both** `RaceDetailView` and `OddsView`. Format: `Image(systemName:) + Text(havaTr) + "·" + "\(sicaklik)°C" + "·" + "%\(nem)"`. `HavaData` is `Decodable` via `CodingKeys` in `HavaData.swift`.

### Coat Color Theming
`Horse.coatTheme` and `HorseResult.coatTheme` compute `(bg: Color, fg: Color)` from `DON`/`YAS` field. Opacity fades with horse age (2y = 0.95 → 10y = 0.60). Used to color-code horse cards in `ListItemView` and `ResultRowView`.

### Card Style
- `cornerRadius(20)`, `stroke(Color.white.opacity(0.15), lineWidth: 1)`
- Press animation: `CardPressEffectStyle` (scale 0.96, opacity 0.9) in `RaceCardButton.swift`
- Shadows: `.shadow(color: .cyan.opacity(0.25), radius: 12)` on city cards

## Key Files

| File | Purpose |
|------|---------|
| `Race_SimulatorApp.swift` | App entry; `UIApplicationDelegateAdaptor` locks orientation to portrait |
| `MainShellView.swift` | Tab container wiring; passes `selectedBottomTab` binding |
| `JsonParser.swift` | All TJK API calls |
| `Horse.swift` | 50+ field model; custom `Codable` for mixed-type fields |
| `Race.swift` | Race metadata + `[Horse]`; `decodeSafeBool` helper |
| `RaceCardButton.swift` | City card button + `String.turkishCityUppercased` extension |
| `OddsViewModel.swift` | `@Observable` — Muhtemeller data, 15s refresh timer, `pistPerRun`, `havaData` |
| `TicketViewModel.swift` | `@Observable` — bet selection, combination math, AI generation |
| `OddsModels.swift` | `ProgramResponse`, `DynamicTableRow`, `TableCell`; `BetRaceDay.id = KEY` (not KOD) |

## Known Issues

- **Boolean decoding duplication**: `decodeSafeBool` in `Race.swift` is repeated inline in other models. No shared utility.
- **Silent API failures**: Network errors only `print()` to console; no user-facing retry UI.
- **`OddsViewModel` timer**: Must call `stopRefreshTimer()` on disappear (done via `.onDisappear`); verify any new navigation paths also call it.
- **`BetRaceDay.id`**: Uses `KEY` (date-inclusive), not `KOD` — important for ForEach deduplication when same city races on multiple days.
- **Date format**: Two formats in use (`yyyyMMdd` vs `yyyy/MM/dd`). Always check which endpoint expects which.
