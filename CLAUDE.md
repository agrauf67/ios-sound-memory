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
- **UI:** `ContentView.swift` — root view loaded by the app
- **Assets:** `Assets.xcassets` — app icon and accent color

All source files live under `Sound Memory/`. The project uses Xcode's file system synchronized groups (no manual file references needed — new Swift files added to the folder are automatically included in the build).

## Swift Concurrency

The project uses strict Swift 6 concurrency defaults:
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — all types default to `@MainActor`
- `SWIFT_APPROACHABLE_CONCURRENCY = YES`
- `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`

Mark types/functions as `nonisolated` explicitly when they don't need main actor isolation.
