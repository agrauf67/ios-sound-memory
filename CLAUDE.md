# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sound Memory is an iOS memory card game where players match pairs by listening to spoken words and/or viewing images. Built with SwiftUI, targeting iPhone and iPad (iOS 26.2+).

- **Bundle ID:** `de.djvlk.Sound-Memory`
- **Swift version:** 5.0 with Swift 6 concurrency defaults (`MainActor` default isolation, approachable concurrency enabled)
- **Xcode:** 26.2+

## Build & Run

```bash
# Build (debug)
xcodebuild -project "Sound Memory.xcodeproj" -scheme "Sound Memory" -sdk iphonesimulator build

# Build (release)
xcodebuild -project "Sound Memory.xcodeproj" -scheme "Sound Memory" -sdk iphonesimulator -configuration Release build
```

Note: StoreKit testing requires running from Xcode with `Products.storekit` set in the scheme (Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration).

## Architecture

MVVM architecture with observable managers. All source files live under `Sound Memory/` using Xcode's file system synchronized groups (new Swift files added to the folder are automatically included in the build).

- **App entry:** `Sound_MemoryApp.swift`
- **Root navigation:** `ContentView.swift` — TabView (Games, Play, Stats) + sheet navigation for Settings/Store/Help/About/HowToPlay/Walkthrough. Manages all sheet state and passes `SoundMemoryViewModel` to child views.
- **ViewModel:** `ViewModels/SoundMemoryViewModel.swift` — Single observable class owning all game logic: card flipping, matching, scoring, game set loading from `gamesets.json`. Owns `SettingsManager`, `GameResultRepository`, `StoreManager`, and `TtsManager`.
- **Models:** `Models/GameModels.swift` — `GameSet`, `MemoryCard`, `CardInfo`, `GameResult`, `loadGameImage()` helper
- **Managers:**
  - `SettingsManager` — `@Observable`, UserDefaults-backed (game mode, language, theme, timing, voice gender)
  - `GameResultRepository` — `@Observable`, persists game results to `Documents/game_results.json`
  - `StoreManager` — `@Observable`, StoreKit 2 consumable IAP with credit system, syncs to iCloud KVStore + UserDefaults
  - `TtsManager` — AVSpeechSynthesizer wrapper with language/gender voice selection and quality-based fallback chain
- **Views:** 9 screens in `Views/` — PlayScreen (4×6 card grid), LevelsScreen (game selection with lock/unlock), StatsScreen (leaderboards by game+mode), StoreScreen, SettingsScreen, WalkthroughScreen, HowToPlayScreen, HelpScreen, AboutScreen

## Swift Concurrency

- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — all types default to `@MainActor`
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`
- Mark types/functions as `nonisolated` explicitly when they don't need main actor isolation (e.g., Codable data structs, TTS delegate methods, static JSON loading)
- TTS delegate methods are `nonisolated` and dispatch back via `Task { @MainActor in ... }`
- `AVSpeechSynthesizer` is marked `nonisolated(unsafe)` for Sendable conformance

## In-App Purchases

Credit-based system using StoreKit 2 consumables:
- Category 0 (Colors) is always free; other categories require 1 credit to unlock
- 4 products: pack1 (1 credit), pack2 (2), pack3 (3), pack5 (5)
- Product IDs: `de.djvlk.soundmemory.pack{1,2,3,5}`
- Credits and unlocked categories persist to iCloud KVStore (with UserDefaults fallback)
- `Products.storekit` at project root — must be selected in scheme for simulator testing
- Entitlements: `Sound Memory.entitlements` enables iCloud KV store

## Game Data

- `gamesets.json` — 16 game sets (4 categories × 4 languages: de-DE, en-US, fr-FR, es-ES). Category = `index / 4`.
- `GameImages/` — 226 JPG files (320×240px), loaded via `Bundle.main.path(forResource:ofType:inDirectory:"GameImages")`
- Each game uses 12 random card pairs (24 cards total) from the set's card list

## Localization

- UI strings: `Localizable.xcstrings` (String Catalog, source: English, translated: German, French, Spanish)
- Game content: localized per language variant in `gamesets.json`
- Runtime language switching via `SettingsManager.language` → `.environment(\.locale, appLocale)` on all view hierarchies
- TabView uses `.id(viewModel.settings.language)` to force recreation on language change
- Known regions configured in project: en, de, fr, es

## Key Patterns

- All `@Observable` managers use `didSet` to auto-persist to UserDefaults
- Card flip timing uses `Task.sleep` with configurable delays; match registration is synchronous (not inside delayed Task) to avoid race conditions
- `.task(id: card.imageFileName)` on card images to force reload after game reset
- Card front content uses `.scaleEffect(x: -1, y: 1)` to counter-mirror the `rotation3DEffect` flip
- `AnyShapeStyle` used for conditional `.foregroundStyle()` with different shape style types
- Long press on game sets opens a card preview grid sheet
