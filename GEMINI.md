# YKReels (`com.ykreels.app`) — Agent Directives & Architecture Guide

> **Core Philosophy:** Minimalist, butter-smooth, native iOS short-drama reel player for iOS 17+ and iPadOS 17+. Disciplined pair-programming, clean modular architecture, zero-latency AVPlayer pooling, strict memory ceilings, zero fluff, and zero UI slop. 100% free forever with zero paywalls, zero coin grinding, and zero developer hosting costs.

---

## 1. Project Overview & Target Architecture
- **Language & Runtime:** Native Swift 5.10 / Swift 6 targeting **iOS 17.0+** and **iPadOS 17.0+**.
- **Package Manager:** Swift Package Manager (SPM) with 7 modular targets + XcodeGen ([`project.yml`](file:///c:/SIDEPROJECTS/ykreels-ios/project.yml)) for iOS Simulator `.app` and device `.ipa` packaging.
- **Repository Location:** `c:\SIDEPROJECTS\ykreels-ios` (`com.ykreels.app`).
- **Initial Showcase Drama:** *"Wrong Match, Right Crush"* (Full 25-episode college romance drama, unlocked and playable out of the box).

### Modular Architecture Map
1. [`Sources/ReelCore`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelCore): Universal domain models ([`Drama`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelCore/Models/Drama.swift), [`Episode`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelCore/Models/Episode.swift), [`PlaybackProgress`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelCore/Models/PlaybackProgress.swift), [`WatchHistory`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelCore/Models/WatchHistory.swift), [`StreamSource`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelCore/Models/StreamSource.swift)), design system tokens ([`ReelTheme`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelCore/Theme/ReelTheme.swift)), and error types. Zero external dependencies.
2. [`Sources/ReelDatabase`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelDatabase): `GRDB.swift` SQLite engine in WAL mode with foreign keys, FTS5 full-text search index for dramas/episodes, versioned schema migrations, and reactive repositories.
3. [`Sources/ReelEngine`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelEngine): Content resolution layer containing the curated catalog engine (pre-seeded with *"Wrong Match, Right Crush"*), dynamic feed parser, and sandboxed stream resolvers (handling HLS/m3u8, direct MP4, and web stream extractions).
4. [`Sources/ReelPlayer`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelPlayer): High-performance `AVPlayer` pool coordinator, pre-warming buffer queue, zero-latency vertical gesture pager, timeline scrubbing engine, audio session handling, and background playback/PiP integration.
5. [`Sources/ReelDownload`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelDownload): Background `URLSessionDownloadTask` daemon, smart 250MB LRU disk cache manager, and resume-data coordinator.
6. [`Sources/ReelUI`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelUI): Pure SwiftUI views adhering to Apple glassmorphism, Sakura Pink accent, and high-signal typography:
   - Feed: [`PlayerFeedView`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelUI/Feed/PlayerFeedView.swift) (Ultra-minimalist auto-hiding glass HUD).
   - Explore: [`ExploreView`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelUI/Explore/ExploreView.swift) (Frosted glass shelves & search).
   - Library: [`LibraryView`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelUI/Library/LibraryView.swift) (Continue watching & 250MB cache manager).
   - Navigation: [`AppRootView`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelUI/Navigation/AppRootView.swift) (Frosted tab bar).
7. [`Sources/ReelApp`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelApp): `@main YKReelsApp` entry point and app lifecycle coordinator.

---

## 2. Anti-Overengineering & Structural Boundaries

### 1. Strict Line & Scope Limits
- **File Size Cap:** Strictly **<400 lines per file**. Decompose views into focused child components well before approaching this ceiling.
- **Coordinators & Managers:** Strictly **<200 lines per class**. Delegate rendering, transforms, and state mechanics to dedicated lightweight structs/services.
- **Entrypoints & Handlers:** Strictly **<35 lines per method**. Use early guard clauses; maximum **2 levels of branch nesting**.
- **Zero Architectural Bloat:** Never introduce convoluted state machine frameworks, unnecessary reactive wrapper libraries, or micro-abstractions for straightforward tasks. Native `SwiftUI`, `AVFoundation`, and `GRDB` are all that is required.

### 2. High-Signal Copy & Anti-Overtext Rule
- **No Filler Text:** Eliminate redundant micro-captions, instructional helpers ("Tap here to play", "Click to watch next episode"), and repeated synopses over video viewports.
- **High-Signal Elements Only:** Display only essential metadata: Drama Title, compact `1 / 25` glass indicator pill, and time elapsed/remaining (`0:42 / 1:45`).
- **Domain Terminology:** Use clear, human-readable domain concepts rather than technical variable names in user-facing UI.

---

## 3. UI/UX Standards: Apple Glassmorphism & Sakura Pink

### 1. Aesthetic Profile
- **Backdrop:** Pure OLED True Black (`#000000`).
- **Primary Accent:** **Soft Pastel Sakura Pink** (`#FF8DA1` / RGB: `255, 141, 161`).
- **Secondary Accent & Highlights:** Light Sakura Mist (`#FFB3C1` / RGB: `255, 179, 193`).
- **Glowing Highlights:** Subtle pink atmospheric glow (`Color(hex: "#FF8DA1").opacity(0.15)` with small blur radius).
- **Glassmorphism Materials:**
  - Floating pills & buttons: `.ultraThinMaterial` with a subtle specular outline (`Color.white.opacity(0.14)`, stroke width `0.5pt`).
  - Cards & Drawers: `.thinMaterial` and `Color.white.opacity(0.06)` background.
  - Zero multi-color gradient borders or rainbow cards (Strict anti-slop).

### 2. Fluidity & Motion ("Butter Smooth")
- **Spring Physics:** Standardized on `Animation.spring(response: 0.32, dampingFraction: 0.82)` for vertical swipe transitions, drawer presentations, and HUD fades.
- **ProMotion 120Hz Harmony:** Avoid heavy dynamic blur recalculations per-frame during dragging. Animate transform offsets directly on cached layers.
- **Auto-Hiding HUD:** The player HUD automatically fades out after 3 seconds of user inactivity. A single tap smoothly toggles visibility.

---

## 4. Performance, Memory & Low-Storage Invariants

### 1. High-Performance AVPlayer Pool (Memory Ceiling)
- **Strict 3-Player Pool Cap:** The active `AVPlayer` pool must never exceed **3 instantiated players** (`Previous`, `Current`, `Next`).
- **RAM Cap:** Active memory consumption must remain strictly **<80MB** during continuous playback.
- **Immediate Resource Deallocation:** When swiping beyond the 3-player window, off-screen player items must immediately pause, detach from the layer, remove observation tokens, and release system decoders.

### 2. Smart LRU Disk Cache (Storage Ceiling)
- **Hard Storage Ceiling:** On-disk video chunk cache is hard-capped at **250MB**.
- **Auto-Eviction (LRU):** When cache exceeds 250MB, oldest unpinned video chunks are automatically purged in the background.
- **Manual Hygiene:** Users have a one-tap *Clear Video Cache* button in the Library tab.

### 3. Database Integrity (GRDB & SQLite)
- **WAL Mode Mandatory:** SQLite runs in Write-Ahead Logging (`WAL`) mode with foreign key constraints.
- **Additive Migrations Only:** Never execute destructive schema drops. Version migrations sequentially in `SchemaMigrations.swift`.
- **Throttled Progress Writes:** Throttle watch progress writes to GRDB to at most once every 3 seconds during active playback.

---

## 5. Curated Drama Specification: *"Wrong Match, Right Crush"*
- **Identifier:** `drama-wrong-match-right-crush`
- **Total Episodes:** 25 episodes (Complete miniseries).
- **Genre:** College Romance / Campus Drama / Coming-of-Age.
- **Lead Characters:** Nora (Freshman lead), Theo (Basketball captain / true crush), Beckett (Campus playboy / mistaken recipient), Chloe (Cheerleader antagonist).
- **Runtime per Episode:** ~90–120 seconds per episode.
- **Stream Resolutions:** 1080x1920 (Vertical 9:16) HLS adaptive bitrate with MP4 direct fallback.
- **State Guarantee:** Episodes 1 through 25 are 100% unlocked with zero paywalls and zero coin gates.
