<!-- IMPL-REVIEW-REPORT -->
# Implementation Review: Set up note browser, syntax-highlighted editor, and HTML preview toggle

- **Plan**: context/changes/browse-edit-preview/plan.md
- **Scope**: Phase 2 of 4
- **Date**: 2026-06-17
- **Verdict**: NEEDS ATTENTION
- **Findings**: 0 critical, 1 warning, 2 observations

## Verdicts

| Dimension | Verdict |
|-----------|---------|
| Plan Adherence | WARNING |
| Scope Discipline | WARNING |
| Safety & Quality | WARNING |
| Architecture | PASS |
| Pattern Consistency | PASS |
| Success Criteria | PASS |

## Findings

### F1 — Missing error handling in FileService I/O operations

- **Severity**: ⚠️ WARNING
- **Impact**: 🔎 MEDIUM — real tradeoff; pause to reason through it
- **Dimension**: Safety & Quality
- **Location**: lib/services/file_service.dart:58, 82, 88
- **Detail**: `readFile` (line 82), `writeFile` (line 88), and `listDirectory` (line 58) all perform synchronous or async I/O with no try/catch. An unreadable file (permission denied, deleted between listing and read), a non-existent directory, or a disk-full scenario would throw an unhandled `FileSystemException`, crashing the app. The plan does not specify error handling requirements, but a note-taking app that crashes on a missing file creates a poor user experience.
- **Fix**: Wrap each method body in try/catch. For `readFile`, return `null` (and skip the editor load in the Notifier). For `writeFile`, log the error silently. For `listDirectory`, return `[]` and optionally surface a message via the Notifier.
  - Strength: Graceful degradation — the app stays alive and the user sees "unable to load" instead of a crash.
  - Tradeoff: Minor — adds ~3 try/catch blocks; callers must handle nullable return from `readFile`.
  - Confidence: HIGH — standard defensive I/O pattern; well-understood.
  - Blind spot: Haven't tested with actual permission-denied scenarios on Linux (e.g., `/root/` as the selected directory).
- **Decision**: FIXED — try/catch added to all three methods; `readFile` return type changed to `String?`

### F2 — gruvbox_resources.dart is an unplanned addition

- **Severity**: 👁️ OBSERVATION
- **Impact**: 🏃 LOW — quick decision; fix is obvious and narrowly scoped
- **Dimension**: Scope Discipline
- **Location**: lib/theme/gruvbox_resources.dart (entire file, 278 lines)
- **Detail**: `lib/theme/gruvbox_resources.dart` was created in the Phase 2 commit (a696214) but is not listed in any phase's "Changes Required". It provides a `ResourceDictionary` for fluent_ui widgets so they pick up Gruvbox colours without per-widget overrides. The `gruvbox_theme.dart` file was also modified in Phase 2 to reference it (adding `resources:` to both `FluentThemeData` instances). The module is well-structured and practically useful — without it, built-in widgets would use default Fluent colours instead of Gruvbox. However, it's undocumented scope.
- **Fix**: Accept and document. Add `lib/theme/gruvbox_resources.dart` to Phase 2's "Changes Required" list (or to Phase 1 as an addendum), and note the `gruvbox_theme.dart` modification in the plan.
  - Strength: Plan becomes truthful about what shipped; no code change needed.
  - Tradeoff: None — purely administrative.
  - Confidence: HIGH — the file is correct and already integrated.
  - Blind spot: None significant.
- **Decision**: FIXED — documented in plan as Phase 2 Change #8

### F3 — FileTree does not toggle directory expansion on tap

- **Severity**: 👁️ OBSERVATION
- **Impact**: 🏃 LOW — quick decision; fix is obvious and narrowly scoped
- **Dimension**: Plan Adherence
- **Location**: lib/widgets/file_tree.dart:47–53
- **Detail**: The plan's "Contract" for `FileTree` specifies that the `onItemInvoked` handler should dispatch to `onFileTapped` for file leaves and **toggle expansion for directory nodes**. The current implementation only handles `.md` file taps — directory node taps are silently ignored. The `fluent_ui` `TreeView` widget does handle expand/collapse via the chevron button by default, so the core UX (browsing directories) still works, just not via clicking the directory text/icon.
- **Fix**: In the `onItemInvoked` handler, when `item.value` points to a directory, toggle its `expanded` state programmatically. `fluent_ui`'s `TreeView` manages expansion internally via the item's `TreeViewController` — the standard pattern is to set `expanded` on the `TreeViewItem`.
  - Strength: Matches the plan's spec exactly; consistent UX (click anywhere on the directory row to expand).
  - Tradeoff: Minor — ~4 lines of code; need to track which items are expanded.
  - Confidence: MEDIUM — `fluent_ui`'s TreeView expansion API is `expanded` property on TreeViewItem, but toggling it from `onItemInvoked` requires either mutable state or force-rebuilding the item list.
  - Blind spot: Haven't verified the exact `fluent_ui` API for programmatic expand/collapse in `onItemInvoked`.
- **Decision**: DISMISSED — `fluent_ui` TreeView handles expand/collapse natively (verified by user); plan's language described built-in behavior, not custom logic
