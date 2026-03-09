# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sound Memory is an iOS app built with SwiftUI. It targets iPhone and iPad (iOS 26.2+).

- **Bundle ID:** `de.djvlk.Sound-Memory`
- **Swift version:** 5.0 with Swift 6 concurrency defaults (`MainActor` default isolation, approachable concurrency enabled)
- **Xcode:** 26.2+

## Build & Run

```bash
# Build (debug)
xcodebuild -project "Sound Memory.xcodeproj" -scheme "Sound Memory" -sdk iphonesimulator build

# Build (release)
xcodebuild -project "Sound Memory.xcodeproj" -scheme "Sound Memory" -sdk iphonesimulator -configuration Release build

# Run on simulator
xcrun simctl boot "iPhone 16" 2>/dev/null; xcodebuild -project "Sound Memory.xcodeproj" -scheme "Sound Memory" -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 16" build && xcrun simctl install booted "$(xcodebuild -project 'Sound Memory.xcodeproj' -scheme 'Sound Memory' -sdk iphonesimulator -showBuildSettings | grep ' BUILT_PRODUCTS_DIR' | awk '{print $3}')/Sound Memory.app" && xcrun simctl launch booted de.djvlk.Sound-Memory
```

## Architecture

- **App entry point:** `Sound_MemoryApp.swift` — standard SwiftUI `@main` App struct
- **Root navigation:** `ContentView.swift` — TabView with 3 tabs (Games, Play, Stats) + sheet navigation for Settings/Help/About/HowToPlay
- **Assets:** `Assets.xcassets` — app icon and accent color

### Source Structure

All source files live under `Sound Memory/`. The project uses Xcode's file system synchronized groups (no manual file references needed — new Swift files added to the folder are automatically included in the build).

- `Models/GameModels.swift` — Data models: `GameSet`, `CardInfo`, `MemoryCard`, `GameResult`, and `loadGameImage()` helper
- `Managers/TtsManager.swift` — AVSpeechSynthesizer wrapper for text-to-speech
- `Managers/SettingsManager.swift` — `@Observable` class backed by UserDefaults (game mode, language, theme, timing, etc.)
- `Managers/GameResultRepository.swift` — `@Observable` class for persisting game results to JSON file
- `ViewModels/SoundMemoryViewModel.swift` — Main game logic: card flipping, matching, scoring, game set loading from `gamesets.json`
- `Views/PlayScreen.swift` — 4×6 card grid with flip animation, speaker overlay, card borders
- `Views/LevelsScreen.swift` — 3-column grid of available game sets filtered by language
- `Views/StatsScreen.swift` — Lifetime stats, last game, per-game leaderboards with star ratings
- `Views/SettingsScreen.swift` — Form-based settings (theme, language, game mode, timing, speech text)
- `Views/HowToPlayScreen.swift` — Game rules and instructions
- `Views/HelpScreen.swift` — Expandable FAQ and contact links
- `Views/AboutScreen.swift` — App info, developer, links
- `Views/WalkthroughScreen.swift` — 5-page onboarding pager (shown on first launch)

### Game Data

- `gamesets.json` — 16 game sets (4 categories × 4 languages: de-DE, en-US, fr-FR, es-ES)
- `GameImages/` — 226 JPG card images and deck overview images, loaded via `Bundle.main.path(forResource:ofType:inDirectory:)`

### Key Patterns

- All `@Observable` classes use `didSet` on properties to persist to UserDefaults
- TTS delegate methods are `nonisolated` and dispatch back to `@MainActor` via `Task`
- Card flip uses delayed `Task.sleep` for display timing and flip-back logic
- Game complete auto-resets after configurable delay

## Swift Concurrency

The project uses strict Swift 6 concurrency defaults:
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — all types default to `@MainActor`
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`

Mark types/functions as `nonisolated` explicitly when they don't need main actor isolation.
