# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Race Simulator (TAY ZEKA)** — An iOS SwiftUI app for Turkish horse racing. Integrates with the TJK (Türkiye Jokey Kulübü) API to display race programs, odds, results, betting tickets, and live race simulations.

## Build & Run

Open `Race Simulator.xcodeproj` in Xcode and build/run via Xcode (⌘R). No package manager setup required — there are no external dependencies.

There is no test suite to run; the project has minimal test coverage.

## Architecture

**Pattern:** SwiftUI + MVVM-lite. State lives in views via `@State`/`@Binding`. No centralized state store (no ViewModel classes, no Combine subjects).

**Navigation:** `NavigationStack`-based with a custom tab bar (`CustomBottomBar.swift`). Entry point is `RootView` (Matrix splash) → `MainShellView` (5-tab container).

**Networking:** `JsonParser.swift` is the sole API client, using `async/await` with `URLSession`. Three endpoints: race cities, program data, and race results — all from `https://ebayi.tjk.org/s/d/`. No local persistence; all data is fetched live.

**Tabs:**
1. Home (`MainView`) — race program by date/city
2. Race detail (`RaceDetailView`) — horse list, results, photo/video
3. AI insights (prepared, not fully implemented)
4. Odds (`OddsView`) — AGF and betting odds
5. Tickets (`TicketSetupView`) — kupon creation

## Key Files

| File | Purpose |
|------|---------|
| `Race_SimulatorApp.swift` | App entry, `UIApplicationDelegateAdaptor` for orientation lock (portrait only) |
| `MainShellView.swift` | Tab container wiring |
| `CustomBottomBar.swift` | Custom animated tab bar with glassmorphism |
| `JsonParser.swift` | All TJK API calls |
| `Horse.swift` | 50+ field model matching TJK JSON; custom `Codable` for mixed types |
| `Race.swift` | Race metadata + `[Horse]` array |
| `RaceResult.swift` | Post-race results with `HorseResult` |
| `SimulationView.swift` | AGF-weighted timer-driven race animation |

## Domain Conventions

**Turkish field names** — TJK API uses Turkish abbreviations throughout. Key ones:
- `KOD` = code, `AD` = name, `JOKEYADI` = jockey, `KOSMAZ` = non-runner
- `AGF` = performance rating used for simulation weighting
- `DON` = coat color: `"k"` (gray), `"a"` (orange), `"d"` (brown), `"y"` (black)

**Date format for API:** `yyyyMMdd` (e.g., `"20260304"`). Display uses `"tr_TR"` locale.

**CDN URL pattern:** Horse form images use `medya.tjk.org`; replace with `medya-cdn.tjk.org` for HTTPS.

**Coat color theming:** `DON` field drives `coatTheme` computed property on `Horse` and `HorseResult` — used to color-code cards throughout the UI.

## UI Conventions

- Dark theme with cyan (`#00FFFF`) primary accents and orange secondary accents
- `drawingGroup()` used on animated views for GPU acceleration
- `AsyncImage` for horse forma images (SwiftUI default caching)
- Custom corner radii helpers used on cards (top-only or bottom-only rounded corners)
- Orientation is locked to portrait via `AppDelegate`
