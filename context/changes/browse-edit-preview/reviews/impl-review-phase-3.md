<!-- IMPL-REVIEW-REPORT -->
# Implementation Review: Browse, Edit, and Preview Notes

- **Plan**: context/changes/browse-edit-preview/plan.md
- **Scope**: Phase 3 of 4
- **Date**: 2026-06-17
- **Verdict**: NEEDS ATTENTION → APPROVED (after triage)
- **Findings**: 0 critical, 2 warnings, 2 observations

## Verdicts

| Dimension | Verdict |
|-----------|---------|
| Plan Adherence | WARNING → PASS (F1 fixed) |
| Scope Discipline | WARNING → PASS (F2 documented as addendum) |
| Safety & Quality | OBSERVATION (F3 skipped — matches plan intent) |
| Architecture | PASS |
| Pattern Consistency | OBSERVATION (F4 — auto-resolved by F1 edit cleanup) |
| Success Criteria | PASS |

## Findings

### F1 — Async flush on lifecycle detach vs plan's sync spec

- **Severity**: ⚠️ WARNING
- **Impact**: 🔎 MEDIUM — real tradeoff; pause to reason through it
- **Dimension**: Plan Adherence / Safety & Quality
- **Location**: lib/notifiers/editor_notifier.dart:9
- **Detail**: Plan specifies `onDetach: _flushSync` (synchronous). Implementation used `unawaited(_flush())` (async fire-and-forget) risking data loss on shutdown.
- **Fix A ⭐ Recommended**: Replace with synchronous `_flushSync()` using `File.writeAsStringSync()`; extract shared pre-write checks into `_prepareFlush()` to avoid duplication.
- **Decision**: FIXED via Fix A

### F2 — Gruvbox syntax highlighting themes added outside plan scope

- **Severity**: ⚠️ WARNING
- **Impact**: 🏃 LOW — quick decision; fix is obvious and narrowly scoped
- **Dimension**: Scope Discipline
- **Location**: lib/widgets/note_editor.dart:9-11 / pubspec.yaml:15
- **Detail**: Plan's "What We're NOT Doing" defers highlight colour theming. Implementation adds `flutter_highlight` and Gruvbox `CodeTheme` wrapping. Welcome improvement but drifts from scope.
- **Fix**: Document as addendum in plan — code stays.
- **Decision**: FIXED — addendum documented in plan.md

### F3 — `dispose()` defined but never called on singleton notifier

- **Severity**: 👁️ OBSERVATION
- **Impact**: 🏃 LOW — quick decision; fix is obvious and narrowly scoped
- **Dimension**: Safety & Quality
- **Location**: lib/notifiers/editor_notifier.dart:95
- **Detail**: Notifier defines `dispose()` but is registered as singleton with no teardown path. Plan explicitly accepts this.
- **Fix**: No action — matches plan intent.
- **Decision**: SKIPPED — matches plan intent

### F4 — Extra blank lines before `dispose()` method

- **Severity**: 👁️ OBSERVATION
- **Impact**: 🏃 LOW — quick decision; fix is obvious and narrowly scoped
- **Dimension**: Pattern Consistency
- **Location**: lib/notifiers/editor_notifier.dart:91-93
- **Detail**: Three consecutive blank lines. Already cleaned up by F1 edit.
- **Fix**: None needed.
- **Decision**: RESOLVED (auto-cleanup from F1)
