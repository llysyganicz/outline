# Browse, Edit, and Preview Notes — Plan Brief

> Full plan: `context/changes/browse-edit-preview/plan.md`

## What & Why

This is S-01 — the north star slice that proves the core product premise works. A user opens
Outline, picks a notes directory, browses markdown files in a file tree, opens and edits a note
with syntax highlighting, and toggles to rendered HTML preview. Per the PRD: *"This flow working
end-to-end = the product works."* Nothing else in the roadmap is meaningful until this slice ships.

## Starting Point

`lib/main.dart` is a 26-line shell: `MaterialApp` wrapping an `EditorScreen` that renders
`Text('Outline')`. Zero feature code, zero dependencies beyond `flutter` itself.

## Desired End State

The user opens Outline, is prompted once to pick a notes folder (remembered on restart), sees a
file tree of `.md` files on the left, selects a note and edits it with markdown syntax
highlighting on the right, and toggles to a rendered HTML preview — all in a Gruvbox-themed
desktop UI that follows the OS dark/light preference.

## Key Decisions Made

| Decision | Choice | Why (1 sentence) | Source |
|---|---|---|---|
| Markdown preview library | `flutter_markdown_plus` | Official successor to discontinued `flutter_markdown`; Flutter 3.44 compatible | Roadmap |
| UI framework | `fluent_ui` with Gruvbox theme | Best-in-class desktop widget set (built-in TreeView); Gruvbox theming removes all Windows-specific aesthetics | Plan |
| Visual identity | Gruvbox (light + dark, OS auto-switch) | Developer-loved neutral palette; fully specified hex values; two variants already defined | Plan |
| Root directory UX | Native folder picker + `shared_preferences` persistence | Picks once, remembers forever — standard desktop UX | Plan |
| Layout | Two-panel: file tree left, editor/preview toggled right | Matches PRD "toggle" language; simpler than three-panel; full width for content | Plan |
| Editor widget | `code_text_field` + `flutter_highlight` | Editable with markdown highlighting; user accepted maintenance risk | Plan |
| Save mechanism | Auto-save on inactivity (0.5 s debounce) + app-close flush | Zero friction; nothing is ever lost | Plan |
| File tree scope | `.md` files + directories only | Focused note editor, not a file manager | Plan |
| Frontmatter in preview | Strip before rendering (body only) | Clean preview; YAML visible in edit mode only | Plan |
| Templates directory name | Case-insensitive `templates` / `Templates` | Plain readable name; no special prefix needed | Plan |
| Automated tests | None for this slice | Manual verification only; test infrastructure deferred | Plan |

## Scope

**In scope:**
- `FluentApp` + Gruvbox `FluentThemeData` (dark + light, OS auto-switch)
- Native folder picker + persisted root directory (`file_picker` + `shared_preferences`)
- File tree showing `.md` files and subdirectories (`fluent_ui` `TreeView`)
- Note loading on tree selection
- Syntax-highlighted plain-text editor (`code_text_field` + markdown language mode)
- Auto-save on inactivity (1 s debounce) + flush on app close
- HTML preview with frontmatter stripped (`flutter_markdown_plus`)
- Edit/preview toggle button in `CommandBar`

**Out of scope:**
- File creation, rename, deletion (S-02)
- Template creation or insertion (S-03, S-04)
- Resizable split panel
- Automated tests
- Syntax highlight token color customization

## Architecture / Approach

All state and logic live in `EditorNotifier`, which exposes each piece of state as a
`ValueNotifier`. All feature widgets are `StatelessWidget` and bind to notifiers via
`ValueListenableBuilder` — the Flutter analog of WPF data binding. `EditorNotifier` and
services are wired in a `kiwi` DI container (`setupDependencies()` in `lib/di/container.dart`),
called once in `main` before `runApp` — similar to .NET's `IServiceCollection`. `EditorScreen`
resolves `EditorNotifier` directly from the container; no `StatefulWidget` host is needed.
`EditorNotifier` also holds the `CodeController` and implements `WidgetsBindingObserver` for
the app-close flush.

## Phases at a Glance

| Phase | What it delivers | Key risk |
|---|---|---|
| 1. Project Setup & Theming | All deps added, `FluentApp` running with Gruvbox colors | `fluent_ui` version compatibility with Flutter 3.44 |
| 2. Root Directory & File Tree | Folder picker, persisted root, working file tree; `kiwi` DI container + `EditorNotifier` introduced | `fluent_ui` `TreeView` API learning curve |
| 3. Note Editor | Syntax-highlighted editable notes, auto-save | `code_text_field` markdown language import path |
| 4. Preview & Toggle | HTML preview, toggle button, <200 ms NFR verified | `MarkdownBody` render time for large notes |

**Prerequisites:** Flutter 3.44 stable installed; Dart SDK ^3.12.2; project scaffolded (confirmed — `lib/main.dart` exists)
**Estimated effort:** ~2–3 after-hours sessions across 4 phases

## Open Risks & Assumptions

- `fluent_ui` version compatibility with Flutter 3.44 must be verified at `flutter pub get` time —
  check pub.dev for the latest compatible release
- `code_text_field` uses `flutter_highlight` (5 years since last release); user accepted this risk
  based on evidence that the package tracks null-safety updates
- `didChangeAppLifecycleState(detached)` may not fire reliably on all Linux window managers for the
  flush-on-close guarantee — manual testing on the target platform is essential

## Success Criteria (Summary)

- User can pick a notes folder on first launch and have it remembered across restarts
- Selecting a `.md` file loads it into a syntax-highlighted editor; edits save automatically
- Toggling to preview shows correctly rendered HTML with no frontmatter visible, in under 200 ms
