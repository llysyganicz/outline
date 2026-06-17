<!-- IMPL-REVIEW-REPORT -->
# Implementation Review: Browse, Edit, and Preview Notes

- **Plan**: context/changes/browse-edit-preview/plan.md
- **Scope**: Phase 1–4 (Full Plan)
- **Date**: 2026-06-17
- **Verdict**: NEEDS ATTENTION
- **Findings**: 0 critical, 3 warnings, 1 observation

## Verdicts

| Dimension | Verdict |
|-----------|---------|
| Plan Adherence | WARNING |
| Scope Discipline | PASS |
| Safety & Quality | WARNING |
| Architecture | PASS |
| Pattern Consistency | WARNING |
| Success Criteria | PASS |

## Findings

### F1 — readFile returns nullable; plan contract said non-nullable String

- **Severity**: ⚠️ WARNING
- **Impact**: 🏃 LOW — quick decision; fix is obvious and narrowly scoped
- **Dimension**: Plan Adherence
- **Location**: lib/services/file_service.dart:57
- **Detail**: Plan contract: `Future<String> readFile` → Implementation: `Future<String?> readFile` (returns null on error). Code is safe — selectFile guards with `if (content != null)`. The contract document was stale.
- **Fix**: Update the plan's Phase 2 contract to `Future<String?>` and add a note that null signals read failure. No code change needed.
- **Decision**: FIXED — plan contract updated.

### F2 — DI resolution in FileTree.build() vs constructor injection

- **Severity**: ⚠️ WARNING
- **Impact**: 🔎 MEDIUM — real tradeoff; pause to reason through it
- **Dimension**: Pattern Consistency / Architecture
- **Location**: lib/widgets/file_tree.dart:40
- **Detail**: EditorScreen resolves EditorNotifier in its constructor (one-time). FileTree resolved FileService inside build() on every rebuild. The codebase pattern is constructor resolution; FileTree did it at render time instead.
- **Fix Applied**: Thread FileService through FileTree's constructor, consistent with EditorScreen's pattern. EditorScreen resolves FileService from kiwi in its constructor and passes it down.
- **Decision**: FIXED via Fix B

### F3 — Silent error swallowing across all service boundaries

- **Severity**: ⚠️ WARNING
- **Impact**: 🔬 HIGH — architectural stakes; think carefully before deciding
- **Dimension**: Safety & Quality
- **Location**: lib/services/file_service.dart (multiple), lib/notifiers/editor_notifier.dart:73,82, lib/utils/system_theme.dart (multiple)
- **Detail**: Every external boundary swallows exceptions silently with empty catch blocks. On disk-full, permission errors, or symlink loops the app silently degrades with zero feedback. Six+ catch-all sites with no diagnostic output.
- **Fix Applied**: Added `debugPrint` to all 5 swallowed catch blocks. Errors now appear in debug console; no behavior change in release builds. Roadmap S-05 (structured-logging) added for file-based logging follow-up.
- **Decision**: FIXED via Fix A + roadmap item for structured logging

### F4 — selectFile resets preview mode (not in plan contract)

- **Severity**: 📋 OBSERVATION
- **Impact**: 🏃 LOW — quick decision; fix is obvious and narrowly scoped
- **Dimension**: Plan Adherence
- **Location**: lib/notifiers/editor_notifier.dart:41
- **Detail**: EditorNotifier.selectFile sets isPreviewMode.value = false, forcing edit mode when switching files. The plan's Phase 4 contract for selectFile only specified reading the file — didn't mention preview-mode state. Sensible UX behavior but undocumented addition.
- **Fix**: Document this behavior in the plan's Phase 3 contract as an addendum.
- **Decision**: FIXED — plan contract updated.