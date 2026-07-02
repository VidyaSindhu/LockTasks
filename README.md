# LockTasks

A Google Keep–style sticky-note task tracker for iOS with an interactive Lock Screen widget. Create colorful notes, add tasks with details, reorder priorities, and complete tasks without unlocking your phone.

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-green)
![SwiftData](https://img.shields.io/badge/Data-SwiftData-purple)
![WidgetKit](https://img.shields.io/badge/Widget-WidgetKit-lightgrey)

---

## Features

### Main App
- **Sticky notes** — Create color-coded notes in a grid layout
- **Task management** — Add, complete, rename, reorder, and delete tasks per note
- **Task details** — Attach bullet points, paragraphs, or freeform notes to any task
- **Priority ordering** — Drag to reorder pending tasks; the top task appears on the Lock Screen widget
- **History** — View all completed tasks across notes, sorted by completion date
- **Note editing** — Rename notes and change their color after creation
- **Pin to widget** — Pin a note so the Lock Screen widget shows its next task

### Lock Screen Widget (`.accessoryRectangular`)
- Shows the active note title and highest-priority pending task
- **Tap note title** → Opens the app directly to that note
- **Tap ⟫ chevron** → Cycles to the next note (no app launch)
- **Tap task row** → Marks the task complete (no app launch)

---

## Screenshots

| Home | Note Detail | Lock Screen Widget |
|------|-------------|--------------------|
| Sticky-note grid | Tasks + reorder + details | Interactive rectangular widget |

---

## Architecture

```
LockTasks/
├── LockTasks/              # Main app target
│   ├── Models/             # (via Shared/)
│   ├── Managers/           # DatabaseManager
│   └── Views/
│       ├── Home/           # Grid, add note, rename
│       ├── Detail/         # Note detail, task rows, task editor
│       └── History/        # Completed tasks
│
├── TaskWidget/             # Widget extension target
│   ├── Intents/            # CompleteTaskIntent, CycleNoteIntent
│   ├── Provider/           # Timeline provider + entry
│   └── Views/              # Lock Screen widget UI
│
└── Shared/                 # Compiled into BOTH targets
    ├── Models/             # StickyNote, TaskItem (SwiftData)
    ├── Managers/           # WidgetStateManager (UserDefaults)
    └── AppConstants.swift  # App Group ID, deep links
```

### Data Layer
| Component | Purpose |
|-----------|---------|
| **SwiftData** | Persistent storage for `StickyNote` and `TaskItem` |
| **App Group** | `group.com.vsd-local.LockTasks` — shared store between app and widget |
| **UserDefaults** | Stores `currentActiveNoteID` for widget note selection |
| **Deep links** | `locktasks://note/<uuid>` — widget → specific note in app |

### Key Models

**StickyNote** — `id`, `title`, `colorHex`, `createdAt`  
↳ 1-to-many **TaskItem** (cascade delete)

**TaskItem** — `id`, `title`, `details`, `isCompleted`, `completedAt`, `sortOrder`, `createdAt`

---

## Requirements

- **Xcode 15+** (Swift 5.9+)
- **iOS 17.0+** (required for interactive widget buttons via App Intents)
- **Apple Developer account** (free tier works for personal device installs)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/VidyaSindhu/LockTasks.git
cd LockTasks
```

### 2. Open in Xcode

```bash
open LockTasks.xcodeproj
```

### 3. Configure signing

For **both** targets (`LockTasks` and `TaskWidgetExtension`):

1. Select the target → **Signing & Capabilities**
2. Enable **Automatically manage signing**
3. Choose your **Team** (Apple ID)
4. Confirm **App Groups** includes `group.com.vsd-local.LockTasks`

> If App Groups doesn't appear, add the capability manually and use the same group ID on both targets.

### 4. Run on your iPhone

1. Connect your iPhone
2. Select the **LockTasks** scheme (not the widget scheme)
3. Choose your device as the run destination
4. Press **Run** (⌘R)

### 5. Add the Lock Screen widget

1. Long-press the Lock Screen → **Customize**
2. Tap a widget slot → **Add Widgets**
3. Find **Lock Tasks** → add the **rectangular** widget
4. In the app, open a note and tap the **pin** icon to set the active note

---

## Project Structure

| Target | Bundle ID | Description |
|--------|-----------|-------------|
| **LockTasks** | `com.vsd-local.LockTasks` | Main SwiftUI app |
| **TaskWidgetExtension** | `com.vsd-local.LockTasks.TaskWidget` | Lock Screen widget |

### Shared files (both targets)

These live in `Shared/` and must be included in both target memberships:

- `Shared/Models/StickyNote.swift`
- `Shared/Models/TaskItem.swift`
- `Shared/Managers/WidgetStateManager.swift`
- `Shared/Extensions/Color+Hex.swift`
- `Shared/AppConstants.swift`

---

## Widget Interactions

```
┌─────────────────────────────────────┐
│  📁  Personal Tasks          ⟫     │  ← Tap title: open app → note
│  ─────────────────────────────────  │     Tap ⟫: cycle note
│  ○  Buy groceries                   │  ← Tap: mark complete
└─────────────────────────────────────┘
```

| Action | Behavior |
|--------|----------|
| Tap note title | Deep-links to that note in the app (after unlock) |
| Tap ⟫ chevron | Cycles to next note via `CycleNoteIntent` |
| Tap task circle | Completes task via `CompleteTaskIntent` |
| Long-press widget | iOS Lock Screen editor (system behavior, not customizable) |

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Widget doesn't update | Confirm App Group is identical on both targets |
| Task status stale after widget complete | App refreshes on foreground via `scenePhase`; switch tabs if needed |
| Signing errors | Re-select Team under Signing & Capabilities |
| App Group not found | Add capability on both targets with `group.com.vsd-local.LockTasks` |
| Migration error after schema change | Delete app + widget from device and reinstall |
| Icon doesn't update | Delete app from device, clean build (⇧⌘K), reinstall |

---

## Tech Stack

- **SwiftUI** — App and widget UI
- **SwiftData** — Local persistence with App Group shared store
- **WidgetKit** — Lock Screen `.accessoryRectangular` widget
- **App Intents** — Interactive widget buttons (`CompleteTaskIntent`, `CycleNoteIntent`)

---

## License

This project is open source. Feel free to use, modify, and distribute.

---

## Author

**Vidya Sindhu Dubey** — [GitHub](https://github.com/VidyaSindhu)
