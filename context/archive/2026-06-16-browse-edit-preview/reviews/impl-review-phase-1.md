<!-- IMPL-REVIEW-REPORT -->
# Implementation Review: Set up note browser, syntax-highlighted editor, and HTML preview toggle

- **Plan**: context/changes/browse-edit-preview/plan.md
- **Scope**: Phase 1 of 4
- **Date**: 2026-06-17
- **Verdict**: NEEDS ATTENTION
- **Findings**: 0 critical, 2 warnings, 0 observations

## Verdicts

| Dimension | Verdict |
|-----------|---------|
| Plan Adherence | WARNING |
| Scope Discipline | WARNING |
| Safety & Quality | PASS |
| Architecture | PASS |
| Pattern Consistency | PASS |
| Success Criteria | PASS |

## Findings

### F1 — themeMode uses custom GTK detection instead of ThemeMode.system

- **Severity**: ⚠️ WARNING
- **Impact**: 🔎 MEDIUM — real tradeoff; pause to reason through it
- **Dimension**: Plan Adherence
- **Location**: lib/main.dart:18–20, lib/utils/system_theme.dart
- **Detail**: Plan Phase 1 specifies `themeMode: ThemeMode.system`. Implementation uses a custom `_initialThemeMode()` function backed by `detectPlatformBrightness()` in `lib/utils/system_theme.dart`, which queries GTK settings directly (gsettings → env var → settings.ini). The GTK-based approach is more reliable on Linux than Flutter's built-in `ThemeMode.system`, so the end-user experience is consistent with the plan's intent. However, the mechanism was changed without documentation in the plan, and it introduces a synchronous process-call path at startup.
- **Fix**: Update the plan's Phase 1 contract to describe the Linux-specific brightness detection as an intentional design decision, and add `system_theme.dart` to the plan's "Changes Required" list.
  - Strength: Aligns the plan with reality; future reviewers will see the decision documented.
  - Tradeoff: None — the code is correct; only the plan needs updating.
  - Confidence: HIGH — one-sentence plan update, no code change.
  - Blind spot: None significant.
- **Decision**: FIXED — plan.md updated to document GTK detection approach and add system_theme.dart

### F2 — system_theme.dart is an unplanned module

- **Severity**: ⚠️ WARNING
- **Impact**: 🔎 MEDIUM — real tradeoff; pause to reason through it
- **Dimension**: Scope Discipline
- **Location**: lib/utils/system_theme.dart (entire file, 86 lines)
- **Detail**: `lib/utils/system_theme.dart` is not listed in any phase's "Changes Required". It was created to support F1's themeMode approach. The module is well-structured (proper fallback cascade: gsettings → env var → settings.ini → light fallback, null return on non-Linux). This is a genuine undocumented scope addition. While practically useful, it breaks the "What We're NOT Doing" boundary — the plan says no custom platform-specific logic.
- **Fix A ⭐ Recommended**: Document system_theme.dart in the plan as an intentional addendum to Phase 1.
  - Strength: Preserves useful code; plan stays truthful.
  - Tradeoff: Minor administrative overhead.
  - Confidence: HIGH — the file is small, correct, and justified.
  - Blind spot: None significant.
- **Fix B**: Remove system_theme.dart and revert main.dart to `ThemeMode.system`.
  - Strength: Restores exact plan adherence.
  - Tradeoff: On Linux without a compositor/DE that Flutter's engine recognises, dark mode detection may be unreliable.
  - Confidence: MEDIUM — depends on the user's target Linux environments.
  - Blind spot: Haven't tested `ThemeMode.system` on this distro.
- **Decision**: FIXED via Fix A — system_theme.dart now documented in plan.md as Phase 1 Change #3
