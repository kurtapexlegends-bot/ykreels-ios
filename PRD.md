# YKReels — Product Requirements Document (PRD) & Architecture Foundations

> **Version:** 1.1.0  
> **Target OS:** iOS 17.0+ & iPadOS 17.0+ (Swift 5.10 / Swift 6)  
> **Core Guarantee:** 100% Free Forever (Zero Paywalls, Zero Ads, Zero Developer Hosting Costs).  
> **Design Language:** Apple Glassmorphism + Soft Pastel Sakura Pink (`#FF8DA1`) on True Black OLED (`#000000`).

---

## 1. Executive Summary & Design Vision

### 1.1 Problem Statement
Popular vertical short-drama apps (StoryReel, ReelShort, DramaBox) are riddled with aggressive monetization paywalls, coin systems, and visual clutter (flashing ads, countdown badges, crowded text banners).

### 1.2 The YKReels Philosophy
**YKReels** offers a modern, uncluttered, and butter-smooth vertical short-drama experience:
- **100% Free Forever:** Zero in-app purchases, zero locked episodes, zero artificial coin economies.
- **Minimalist, Non-Slop UI/UX:** Clean Apple glassmorphism (`.ultraThinMaterial`), True Black OLED background, and an elegant **Soft Pastel Sakura Pink** (`#FF8DA1`) accent with subtle glowing specular highlights.
- **Zero Overtexting:** Elimination of redundant helper text and intrusive captions. Only high-signal essentials (Title, compact `1 / 25` glass indicator, time elapsed) are displayed.
- **Ultra-Minimalist Auto-Hiding Glass HUD:** The player HUD automatically fades out after 3 seconds of inactivity, leaving pure 9:16 vertical video without distractions. A single tap smoothly brings it back.
- **Anti-Overengineering & Low Footprint:** Native Swift architecture with strict line limits (<400 lines/file, <200 lines/coordinator, <35 lines/method), RAM capped under 80MB, and on-disk video cache capped at 250MB with LRU auto-eviction.

---

## 2. Design System & Glassmorphism Tokens

### 2.1 Color Palette
- **OLED Backdrop:** Pure Black (`#000000`).
- **Primary Accent:** Soft Pastel Sakura Pink (`#FF8DA1` / RGB: `255, 141, 161`).
- **Secondary Highlight:** Light Sakura Mist (`#FFB3C1` / RGB: `255, 179, 193`).
- **Atmospheric Glow:** Sakura Pink opacity `0.15` with subtle gaussian blur.
- **Glass Specular Border:** White opacity `0.14` with `0.5pt` stroke width.
- **Text Hierarchy:**
  - Primary: Pure White (`#FFFFFF`).
  - Secondary: White opacity `0.72` (Subheadings & metadata).
  - Tertiary: White opacity `0.45` (Subtle timestamps).

### 2.2 Glassmorphism & Material Hierarchy
- **HUD Action Rail:** Floating `.ultraThinMaterial` circular pills with subtle specular border strokes.
- **Episode Quick Pill:** Translucent frosted glass capsule displaying `Ep 1 / 25`.
- **Episode Drawer Sheet:** Semi-translucent sheet with blurred backdrop and Sakura Pink active episode indicators.
- **Tab Bar:** Native frosted translucent bar with Sakura Pink selected icon tinting.

### 2.3 Motion & Fluidity Physics
- **Vertical Gesture Animation:** `Animation.spring(response: 0.32, dampingFraction: 0.82)`.
- **ProMotion 120Hz Harmony:** Fluid frame delivery with no continuous heavy CPU blur calculations during swiping.

---

## 3. Flagship Launch Drama: *"Wrong Match, Right Crush"*

### 3.1 Metadata & Overview
- **Drama ID:** `drama-wrong-match-right-crush`
- **Title:** *Wrong Match, Right Crush*
- **Total Episodes:** 25 Episodes (Complete Miniseries)
- **Genre:** College Romance, Campus Drama, Coming-of-Age, Friends-to-Lovers
- **Characters:** Nora (Lead), Theo (True Crush), Beckett (Playboy), Chloe (Antagonist)
- **Aspect Ratio:** 9:16 Vertical Full-Screen (1080 x 1920)
- **Runtime:** ~90–120 seconds per episode (~45 minutes total)
- **Status:** All 25 episodes 100% unlocked out of the box in [`WrongMatchRightCrushData.swift`](file:///c:/SIDEPROJECTS/ykreels-ios/Sources/ReelEngine/Curated/WrongMatchRightCrushData.swift).

### 3.2 Complete 25-Episode Roster
1. *The Wrong Number* (1m 45s) — Nora accidentally texts Beckett instead of Theo.
2. *Three Months in Secret* (1m 30s) — Late-night banter turns into emotional attachment.
3. *The Cheerleader's Arrival* (1m 50s) — Beckett breaks Nora's heart for Chloe.
4. *Heartbreak in the Hallway* (1m 35s) — Chloe publicly mocks Nora.
5. *A Knight on the Court* (1m 40s) — Theo steps in to defend Nora.
6. *The Study Session* (1m 30s) — Tutoring sparks easy chemistry.
7. *The Locker Room Gossip* (1m 45s) — Beckett feels sudden jealousy.
8. *Rainy Day Umbrella* (1m 25s) — Theo walks Nora home in the rain.
9. *Chloe's Prank* (1m 55s) — Nora is locked in the equipment room.
10. *Rescue and Comfort* (1m 40s) — Theo breaks the latch and comforts Nora.
11. *The Truth Unveiled* (1m 50s) — Beckett realizes Nora was his secret text girl.
12. *Beckett's Regret* (1m 35s) — Beckett begs Nora for another chance.
13. *Too Late* (1m 40s) — Nora chooses Theo's real actions over screen words.
14. *Basketball Championship* (2m 00s) — High-stakes court rivalry.
15. *The Winning Shot* (1m 45s) — Theo scores and hugs Nora in the stands.
16. *Chloe's Revenge Plot* (1m 50s) — Chloe tries to leak private text logs.
17. *The Leak Goes Wrong* (1m 35s) — The student body turns against Chloe.
18. *Late Night Confession* (1m 50s) — Theo confesses his feelings on the roof.
19. *The First Kiss* (1m 40s) — Under the city lights.
20. *Beckett's Desperation* (1m 45s) — Beckett corners Nora in the library.
21. *Theo Steps In* (1m 30s) — Theo enforces boundaries.
22. *The Exchange Program* (1m 35s) — Beckett transfers overseas.
23. *The Ominous Note* (1m 40s) — A sealed farewell note.
24. *Together Against the Storm* (1m 45s) — Nora and Theo face the future united.
25. *Right Match, Right Here* (2m 10s) — Campus gala finale celebration.

---

## 4. Anti-Overengineering & Architectural Scope Limits

| Scope Boundary | Strict Constraint | Rationale |
|:---|:---:|:---|
| **Max File Size** | **< 400 lines** | Prevents monolithic view files and encourages granular components. |
| **Max Controller / Coordinator** | **< 200 lines** | Keeps state managers lean and single-responsibility. |
| **Max Method Size** | **< 35 lines** | Enforces early guard clauses and prevents cognitive overload. |
| **Max Branch Nesting** | **<= 2 levels** | Eliminates arrow anti-patterns and deeply nested if/else blocks. |
| **External Dependencies** | **1 (GRDB.swift)** | Relies strictly on native Apple frameworks (`AVFoundation`, `SwiftUI`). |

---

## 5. Storage & Memory Invariants

### 5.1 Three-Player AVPlayer Pool (<80MB RAM)
- Active window: `Current` (playing), `Next` (pre-buffered 5–10s), and `Previous` (rewind buffer).
- Off-screen players are immediately purged to keep RAM under **80MB**.

### 5.2 Smart LRU Disk Cache (<250MB Storage)
- Local video chunks are saved in `Application Support/YKReels/VideoCache/`.
- Automatic background eviction purges oldest unpinned video chunks when storage approaches **250MB**.
- Manual one-tap cache flush available in the Library tab.

---

## 6. Sideloading & Zero-Cost CI/CD
- **Packaging:** XcodeGen (`project.yml`) builds `YKReels.xcodeproj` on iOS 17+.
- **Free GitHub Actions:** Automates `.ipa` packaging for AltStore, Sideloadly, TrollStore, and Scarlet, alongside `.app.zip` for Appetize.io browser testing.
