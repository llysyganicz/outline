# Browse, Edit, and Preview Notes — Implementation Plan

## Overview

Implement the first end-to-end user slice (S-01): replace the bare `EditorScreen` shell with a
fully functional two-panel layout where the user picks a notes directory, browses markdown files in
a fluent_ui file tree, edits notes with syntax highlighting, and toggles to rendered HTML preview.
Includes Gruvbox light/dark theming (OS auto-switch), auto-save on inactivity, and frontmatter
handling.

## Current State Analysis

`lib/main.dart` (lines 1–26): `MaterialApp` wrapping an empty `EditorScreen` that renders only
`Text('Outline')`. No feature code exists. `pubspec.yaml` declares zero feature dependencies —
only `flutter` + `flutter_lints`. No `lib/` subdirectories, no services, no widgets, no tests.

## Desired End State

The user can launch Outline, pick (or recall from last session) a notes root directory, navigate a
file tree showing only `.md` files and directories, open a note in a syntax-highlighted plain-text
editor, auto-save edits after 0.5 seconds of inactivity, and toggle to rendered HTML preview
(frontmatter stripped). The theme follows OS dark/light preference using Gruvbox colors.

### Key Discoveries:

- `lib/main.dart:1–26` is the only source file; the entire feature is built from scratch
- Roadmap resolves the preview library: `flutter_markdown_plus` (official successor to discontinued
  `flutter_markdown`; v1.0.7, Flutter 3.44 compatible)
- `fluent_ui` provides a `TreeView` widget that directly covers the file tree — no extra tree
  package needed
- `code_text_field` + `flutter_highlight` provide the editable syntax-highlighted text field; the
  `highlight` package (a dependency of `flutter_highlight`) ships a markdown language definition
- Frontmatter stripping is a simple string scan on `---\n…\n---\n` at file start — no YAML parsing
  library needed for this slice
- The `templates` / `Templates` directory (case-insensitive) shows in the tree as a regular
  directory — no special behavior in this slice

## What We're NOT Doing

- No file creation, rename, or deletion (S-02)
- No template creation or insertion (S-03, S-04)
- No separate template browser UI — templates directory visible in the regular file tree only
- No automated or widget tests — manual verification only for this slice
- No light/dark theme switcher UI — follows OS preference automatically
- No resizable split panel — left panel is fixed width in v1
- No syntax highlight color customization — `code_text_field` defaults used; Gruvbox token colors
  can be wired in a follow-up

## Implementation Approach

Build bottom-up: dependencies → Gruvbox theme → services → Notifier → file tree → editor →
preview. Each phase leaves the app in a runnable state.

All feature widgets are `StatelessWidget`. State and business logic live exclusively in
`EditorNotifier`, which exposes each piece of state as a `ValueNotifier`. Widgets bind to
notifiers via `ValueListenableBuilder` — the Flutter analog of WPF data binding. The Notifier
also carries all methods (`selectFile`, `onEditorChanged`, `togglePreview`, `changeRootDirectory`)
so widgets contain no logic.

`EditorNotifier` and services are registered in a `kiwi` container via `setupDependencies()`,
called once in `main` before `runApp`. `EditorScreen` resolves `EditorNotifier` directly from
the container — no `StatefulWidget` host, no constructor parameter threading. `kiwi` is a
pure DI container similar to .NET's `IServiceCollection` / `IServiceProvider`; it has no
opinion on state management and leaves `ValueNotifier` + `ValueListenableBuilder` fully intact.
`FluentApp` replaces `MaterialApp` in the app root.

## Critical Implementation Details

**`fluent_ui` `TreeView` vs `NavigationView`**: `NavigationView` is for app-level page navigation
(Home, Settings tabs), not file browsers. Use a plain `Row` layout with `fluent_ui`'s `TreeView`
in the left panel and a content area on the right. This avoids misusing `NavigationView` as a file
tree host.

**`code_text_field` markdown mode**: Import the markdown language definition via
`import 'package:highlight/languages/markdown.dart' show markdown;`. The `highlight` package ships
language definitions as individual Dart files. Pass `language: markdown` to `CodeController`. If
the import path differs in the installed version, check the package's `lib/languages/` directory.

**Auto-save + app lifecycle**: `EditorNotifier` instantiates an `AppLifecycleListener` (Flutter
3.13+, fully available in Flutter 3.44) in its constructor, passing `onDetach: _flushSync`.
This is cleaner than the older `WidgetsBindingObserver` mixin — no `addObserver` /
`removeObserver` calls, no `didChangeAppLifecycleState` switch, just a named callback.
Because `EditorNotifier` is a singleton that lives for the entire app process, the listener
also lives for the full process lifetime; explicit disposal is not required.

---

## Phase 1: Project Setup & Theming

### Overview

Add all feature dependencies to `pubspec.yaml`, run `flutter pub get`, scaffold the `lib/`
directory structure, and replace `MaterialApp` with `FluentApp` using Gruvbox light and dark
`FluentThemeData`. On Linux, brightness detection uses GTK settings directly (via
`system_theme.dart`) because Flutter's `ThemeMode.system` may report light mode
unreliably on that platform. After this phase the app shell runs with Gruvbox colors and the
placeholder text is still visible.

### Changes Required:

#### 1. Dependencies

**File**: `pubspec.yaml`

**Intent**: Add the six feature packages required by this slice so all subsequent phases can
import them without further manifest changes.

**Contract**: Add under `dependencies:`:
- `fluent_ui` — desktop UI framework (TreeView, CommandBar, FluentApp)
- `flutter_markdown_plus` — markdown-to-HTML preview renderer
- `code_text_field` — editable syntax-highlighted text field
- `file_picker` — native OS folder picker dialog
- `shared_preferences` — key-value storage for persisting root directory path
- `kiwi` — DI container (register + resolve); removes the need for a `StatefulWidget` host

Use `^` version constraints; check pub.dev for the latest versions compatible with Flutter 3.44.

#### 2. Gruvbox theme

**File**: `lib/theme/gruvbox_theme.dart` (new file)

**Intent**: Define the canonical Gruvbox color palette as Dart `Color` constants and expose two
`FluentThemeData` instances (`dark` and `light`) that the app root consumes. Both variants use
the published Gruvbox hex values without modification.

**Contract**: A `GruvboxTheme` class with:
- `static FluentThemeData dark` — built from Gruvbox Dark: bg `#282828`, fg `#ebdbb2`,
  accent (aqua) `#458588`
- `static FluentThemeData light` — built from Gruvbox Light: bg `#fbf1c7`, fg `#3c3836`,
  accent (aqua) `#458588`

`fluent_ui` uses `AccentColor` (a `Color` subclass with a swatch) for `FluentThemeData.accentColor`.
Construct it with the Gruvbox blue/aqua variants as swatch entries.

#### 3. System theme detection

**File**: `lib/utils/system_theme.dart` (new file)

**Intent**: Provide a platform-aware brightness detection function for Linux.
Flutter's built-in `ThemeMode.system` is unreliable on Linux (it may always
report light mode depending on the compositor/DE). This module queries GTK
settings as the canonical source of truth, with a fallback chain:
`gsettings` → `GTK_THEME` env var → `settings.ini` → light default.

**Contract**:
```dart
Brightness? detectPlatformBrightness()
```
Returns `Brightness.dark` or `Brightness.light` on Linux by querying GTK
settings; returns `null` on non-Linux platforms (Windows, macOS) so the
caller falls back to `ThemeMode.system`.

Resolution order:
1. `gsettings get org.gnome.desktop.interface color-scheme` (GNOME/KDE/GTK)
2. `GTK_THEME` environment variable
3. `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`
4. Fallback to `Brightness.light`

#### 4. App root

**File**: `lib/main.dart`

**Intent**: Replace `MaterialApp` with `FluentApp`, wire the Gruvbox themes,
and apply platform-aware dark-mode detection through `system_theme.dart`.
The app follows OS dark/light preference automatically, using GTK settings
on Linux and the Flutter engine's native detection on other platforms.

**Contract**: Call `setupDependencies()` (defined in `lib/di/container.dart`, see Phase 2)
at the top of `main()` before `runApp`. Then:
- Use `_initialThemeMode()` (backed by `detectPlatformBrightness()`) instead of
  bare `ThemeMode.system` — this ensures reliable dark-mode detection on Linux
  while delegating to the engine on other platforms
- `FluentApp(theme: GruvboxTheme.light, darkTheme: GruvboxTheme.dark, themeMode: _initialThemeMode(), home: const EditorScreen())`
- Remove `MaterialApp` and its import; add `fluent_ui` import
- Add imports for `system_theme.dart` and `editor_screen.dart`

### Success Criteria:

#### Automated Verification:

- `flutter pub get` completes with no errors
- `flutter analyze` reports no issues
- `flutter build linux` completes without compile errors

#### Manual Verification:

- App launches and shows a Gruvbox Dark background when OS is in dark mode
- App shows Gruvbox Light background when OS is in light mode
- `Text('Outline')` placeholder is still visible (EditorScreen not yet changed)

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to the next phase. Phase blocks use plain bullets — the corresponding `- [ ]` checkboxes for these items live in the `## Progress` section at the bottom of the plan.

---

## Phase 2: Root Directory & File Tree

### Overview

Implement `PreferencesService` (persist the root path), `FileService` (scan `.md` files), and the
`FileTree` widget using `fluent_ui`'s `TreeView`. On first launch, open the native folder picker;
on subsequent launches, restore the previously chosen root. Move `EditorScreen` to its own file
and wire the two-panel layout.

### Changes Required:

#### 1. Preferences service

**File**: `lib/services/preferences_service.dart` (new file)

**Intent**: Wrap `shared_preferences` with a typed interface for getting and setting the root
directory path. Keeps all preference key strings in one place.

**Contract**:
```dart
class PreferencesService {
  static const _rootDirKey = 'root_directory';
  Future<String?> getRootDirectory();
  Future<void> setRootDirectory(String path);
}
```

#### 2. File service

**File**: `lib/services/file_service.dart` (new file)

**Intent**: Provide the three filesystem operations this slice needs: list `.md` files +
subdirectories recursively, read a file as a string, and write a string to a file.

**Contract**:
```dart
class FileSystemEntry {
  final String path;
  final String name;
  final bool isDirectory;
  final List<FileSystemEntry> children; // populated only for directories
}

class FileService {
  List<FileSystemEntry> listDirectory(String dirPath);
  Future<String> readFile(String filePath);
  Future<void> writeFile(String filePath, String content);
}
```

`listDirectory` uses `dart:io` `Directory.listSync(recursive: false)`. Filter: keep entries where
`isDirectory == true` OR `path.toLowerCase().endsWith('.md')`. Sort: directories before files;
both groups alphabetically by name. Call recursively for directory children.

#### 3. File tree widget

**File**: `lib/widgets/file_tree.dart` (new file)

**Intent**: A `StatelessWidget` that renders a `fluent_ui` `TreeView` populated from
`FileService.listDirectory`. Emits a callback when a `.md` file leaf is tapped. Directory
nodes expand/collapse on tap.

**Contract**:
```dart
class FileTree extends StatelessWidget {
  final String rootPath;
  final ValueListenable<String?> selectedFilePath;
  final void Function(String filePath) onFileTapped;
}
```

Uses a `ValueListenableBuilder` on `selectedFilePath` to highlight the active file. Converts
`List<FileSystemEntry>` → `List<TreeViewItem>` recursively. File leaf items store `filePath` as
their `value`. The `TreeView` widget's `onItemInvoked` dispatches to `onFileTapped` for file
leaves and toggles expansion for directory nodes.

#### 4. DI container setup

**File**: `lib/di/container.dart` (new file)

**Intent**: Centralise all dependency registrations in one `setupDependencies()` function called
from `main` before `runApp`. Mirrors .NET's `IServiceCollection.Add*` pattern.

**Contract**:
```dart
void setupDependencies() {
  final container = KiwiContainer();
  container.registerSingleton((c) => PreferencesService());
  container.registerSingleton((c) => FileService());
  container.registerSingleton(
    (c) => EditorNotifier(c<PreferencesService>(), c<FileService>()),
  );
}
```

All three are singletons — one instance per process. `EditorNotifier`'s constructor instantiates `AppLifecycleListener(onDetach: _flushSync)`,
so lifecycle registration happens automatically at resolution time.

#### 5. EditorNotifier — root directory state

**File**: `lib/notifiers/editor_notifier.dart` (new file)

**Intent**: Introduce the Notifier as the single owner of all app state and logic. In this phase,
scaffold the class with root-directory concerns only: the `rootDirectory` notifier, the
`PreferencesService` + `FileService` dependencies, and the `initialize()` + `changeRootDirectory()`
methods. Remaining notifiers and methods are added in Phases 3 and 4.

**Contract**:
```dart
class EditorNotifier {
  EditorNotifier(this._prefs, this._files) {
    _lifecycleListener = AppLifecycleListener(onDetach: _flushSync);
  }

  final PreferencesService _prefs;
  final FileService _files;
  late final AppLifecycleListener _lifecycleListener;

  final ValueNotifier<String?> rootDirectory = ValueNotifier(null);
  final ValueNotifier<String?> selectedFilePath = ValueNotifier(null);
  // fileContent and isPreviewMode added in Phase 3 / 4

  Future<void> initialize();
  Future<void> changeRootDirectory();
}
```

`initialize()`: reads stored root via `PreferencesService`; if none found, calls
`FilePicker.platform.getDirectoryPath()` and persists the result.
`changeRootDirectory()`: calls `file_picker`, persists, updates `rootDirectory.value`.

#### 6. EditorScreen

**File**: `lib/screens/editor_screen.dart` (new file)

**Intent**: Move `EditorScreen` to its own file as a pure `StatelessWidget`. Resolves
`EditorNotifier` from the kiwi container in the constructor and composes the two-panel layout.

**Contract**:
```dart
class EditorScreen extends StatelessWidget {
  EditorScreen({super.key})
      : _notifier = KiwiContainer().resolve<EditorNotifier>();

  final EditorNotifier _notifier;
}
```

Layout: `Column` → `CommandBar` toolbar + `Row` with:
- `SizedBox(width: 260)` containing `ValueListenableBuilder` on `_notifier.rootDirectory` →
  when non-null, renders `FileTree(rootPath: root, selectedFilePath: _notifier.selectedFilePath,
  onFileTapped: _notifier.selectFile)`
- A 1 px vertical divider
- `Expanded(child: placeholder)` — replaced in Phase 3
Toolbar: "Change folder" `CommandBarButton` calls `_notifier.changeRootDirectory()`.

#### 7. Remove EditorScreen from main.dart

**File**: `lib/main.dart`

**Intent**: Call `setupDependencies()`, delete the inline `EditorScreen` class, and wire the
imports.

**Contract**: Call `setupDependencies()` at the top of `main()` before `runApp`. Add
`import 'screens/editor_screen.dart';` and `import 'di/container.dart';`. Remove the old
`EditorScreen` class body. `home:` becomes `const EditorScreen()`.

#### 8. Gruvbox resource dictionary (addendum to Phase 1)

**File**: `lib/theme/gruvbox_resources.dart` (new file)

**Intent**: Provide a `ResourceDictionary` that maps Fluent Design System resource keys to
Gruvbox-colour-equivalent values so every built-in Fluent widget (TreeView, CommandBar, etc.)
picks up the correct colours without per-widget overrides.

**Contract**: A `GruvboxResources` class with:
- `static ResourceDictionary forBrightness(Brightness brightness)` — returns dark or light
  resource dictionary

Also modify `lib/theme/gruvbox_theme.dart` (Phase 1) to pass `resources:` to both
`FluentThemeData` instances so the resource dictionary is applied globally.

### Success Criteria:

#### Automated Verification:

- `flutter analyze` passes with no issues
- `flutter build linux` compiles cleanly

#### Manual Verification:

- First launch opens a native folder picker dialog
- After selecting a directory, the file tree shows `.md` files and subdirectories with Gruvbox styling
- Directories expand and collapse on click
- Non-`.md` files are not shown in the tree
- "Change folder" toolbar button re-opens the picker and refreshes the tree
- App restart restores the previously chosen directory without showing the picker

**Implementation Note**: Pause for manual confirmation before proceeding to Phase 3.

---

## Phase 3: Note Editor

### Overview

Build the `NoteEditor` widget with `code_text_field` + markdown syntax highlighting. Wire file
loading when a tree node is selected. Implement the 0.5-second auto-save debounce and flush
unsaved content on app lifecycle `detached`.

### Changes Required:

#### 1. EditorNotifier — file content state

**File**: `lib/notifiers/editor_notifier.dart`

**Intent**: Extend the Notifier with file-content concerns: the `fileContent` notifier, the
`CodeController` (owned by the Notifier, not any widget), the debounce timer, and the
`selectFile` / `onEditorChanged` / `_flush` methods. The lifecycle observer (`detached` →
flush) is also wired here.

**Contract** additions to `EditorNotifier`:
```dart
final ValueNotifier<String> fileContent = ValueNotifier('');
final CodeController codeController = CodeController(language: markdown);

Future<void> selectFile(String path); // reads file, sets fileContent + codeController.text
void onEditorChanged(String content); // updates fileContent, resets debounce timer

// lifecycle handled by AppLifecycleListener(onDetach: _flushSync) in constructor
// no didChangeAppLifecycleState override needed
```

`selectFile`: reads via `FileService.readFile`, sets `selectedFilePath.value`,
`fileContent.value`, and `codeController.text` to the loaded content.
`onEditorChanged`: sets `fileContent.value = content`, `_isDirty = true`, cancels `_saveTimer`,
starts `Timer(Duration(milliseconds: 500), _flush)`.
`_flush`: calls `FileService.writeFile(selectedFilePath.value!, fileContent.value)`, clears
`_isDirty`.
`dispose`: adds `codeController.dispose()` and timer cancellation.

#### 2. Note editor widget

**File**: `lib/widgets/note_editor.dart` (new file)

**Intent**: A `StatelessWidget` wrapping `CodeField`. Receives the `CodeController` from the
Notifier — it owns no state.

**Contract**:
```dart
class NoteEditor extends StatelessWidget {
  final CodeController controller;
  final void Function(String content) onChanged;
}
```

`CodeField(controller: controller, onChanged: onChanged)` fills the available space.
No `inputFormatters`, no `textCapitalization` — the editor does not modify the user's text.

#### 3. EditorScreen — wire editor into right panel

**File**: `lib/screens/editor_screen.dart`

**Intent**: Replace the right panel placeholder with `NoteEditor`, binding to the Notifier's
`CodeController` and `selectedFilePath` notifier.

**Contract** change to `EditorScreen.build`:
- Right panel: `ValueListenableBuilder` on `notifier.selectedFilePath`; when non-null, show
  `NoteEditor(controller: notifier.codeController, onChanged: notifier.onEditorChanged)`;
  otherwise show a centred "Select a note" placeholder
- No state added to any widget; all logic remains in `EditorNotifier`

### Success Criteria:

#### Automated Verification:

- `flutter analyze` passes

#### Manual Verification:

- Selecting a file in the tree loads its content into the editor with markdown syntax highlighting
  visible (headers, bold/italic markers, code spans styled differently)
- Editing content waits approximately 0.5 seconds after the last keystroke, then saves to disk
  (verifiable by checking file mtime or opening in an external editor)
- Closing the app immediately after an edit (before 1 s elapses) still saves the content to disk
- Frontmatter (`---` delimiters + YAML content) is visible as plain text in edit mode — not hidden,
  not reformatted

**Implementation Note**: Pause for manual confirmation before proceeding to Phase 4.

---

## Phase 4: Preview & Toggle

### Overview

Add the `NotePreview` widget (`flutter_markdown_plus` with frontmatter stripped) and a toggle
button in the `CommandBar` to switch between edit and preview modes. Verify the <200 ms mode-switch
NFR.

### Changes Required:

#### 1. Frontmatter utility

**File**: `lib/utils/frontmatter.dart` (new file)

**Intent**: Provide `stripFrontmatter(String content) → String` — returns the body with the YAML
frontmatter block removed, or the original content unchanged if no frontmatter is present. Used by
`NotePreview` before passing content to the markdown renderer.

**Contract**: A frontmatter block is present when the content starts with `---\n` and contains a
subsequent `\n---` (with optional trailing newline). Detection: `content.startsWith('---\n')` +
`content.indexOf('\n---', 3)`. The body starts immediately after the closing `---\n`. Edge case: if
`---` appears at the start but no closing delimiter is found, return content unchanged — do not
silently discard the entire file.

#### 2. Note preview widget

**File**: `lib/widgets/note_preview.dart` (new file)

**Intent**: A stateless widget that strips frontmatter from `content` and passes the result to
`MarkdownBody` (from `flutter_markdown_plus`) inside a scrollable padded container. Applies
Gruvbox-appropriate text styles.

**Contract**:
```dart
class NotePreview extends StatelessWidget {
  final String content; // raw file content including possible frontmatter
}
```

Internally calls `stripFrontmatter(content)` then renders via `MarkdownBody`. Wrap in
`SingleChildScrollView` + `Padding`. Build a `MarkdownStyleSheet` from `FluentTheme.of(context)`
colors so headings, code, and links use Gruvbox palette values.

#### 3. EditorNotifier — preview toggle state

**File**: `lib/notifiers/editor_notifier.dart`

**Intent**: Add `isPreviewMode` notifier and `togglePreview()` method to the Notifier.

**Contract** additions:
```dart
final ValueNotifier<bool> isPreviewMode = ValueNotifier(false);
void togglePreview(); // flips isPreviewMode.value; does not touch fileContent or trigger save
```

Add `isPreviewMode.dispose()` to the existing `dispose()` method.

#### 4. EditorScreen — wire preview toggle

**File**: `lib/screens/editor_screen.dart`

**Intent**: Replace the right panel's `ValueListenableBuilder` to also react to `isPreviewMode`,
and add the toggle button to the `CommandBar`.

**Contract** changes:
- Right panel: nest two `ValueListenableBuilder`s — outer on `selectedFilePath`, inner on
  `isPreviewMode`; render `NotePreview` or `NoteEditor` accordingly
- Add `CommandBarButton` (pencil ↔ eye icon) that calls `notifier.togglePreview()`; disabled
  when `notifier.selectedFilePath.value == null`
- No `setState` anywhere; all state changes flow through the Notifier

### Success Criteria:

#### Automated Verification:

- `flutter analyze` passes

#### Manual Verification:

- Toggle button switches between edit and preview — file content is not modified on toggle
- Preview renders markdown correctly: headers (H1–H3), bold, italic, inline code, code blocks,
  unordered lists, links
- Frontmatter block (`---` delimiters + YAML) is absent from the preview — only the body renders
- Mode switch feels instant (subjectively well under 200 ms; verified by toggling rapidly)
- A note with no frontmatter renders its full content in preview
- A note with frontmatter but no body renders an empty (blank) preview — no YAML visible
- Gruvbox colors are visually consistent between edit mode and preview mode

**Implementation Note**: Pause for manual confirmation that this phase is complete.

---

## Testing Strategy

### Unit Tests:

*Deferred for this slice — manual verification only (agreed during planning).*

The `lib/utils/frontmatter.dart` and `lib/services/file_service.dart` logic are the highest-value
candidates for unit tests in a future testing slice.

### Integration Tests:

*Deferred.*

### Manual Testing Steps:

1. Launch app fresh (no stored preferences) → folder picker opens automatically
2. Select a directory with `.md` files, subdirectories, and non-`.md` files → only `.md` + dirs
   shown in tree
3. Select a `.md` file with frontmatter → raw YAML block visible in edit mode
4. Edit content, wait 2 seconds → confirm file updated on disk via external editor or `cat`
5. Edit content, immediately close app → confirm file updated on disk (flush on close)
6. Toggle to preview → frontmatter absent, body renders with correct markdown
7. Toggle back to edit → same raw content, no modifications applied
8. Relaunch app → previous root directory restored, no folder picker shown
9. Click "Change folder" → picker opens, new root replaces old one, tree refreshes
10. Navigate to a `templates` (or `Templates`) subdirectory → it appears and expands like any
    other directory
11. Toggle OS dark/light mode → app theme switches between Gruvbox Dark and Gruvbox Light without
    requiring a restart

## Performance Considerations

The `<200 ms` mode-switch NFR is the primary concern. Switching between `NoteEditor` and
`NotePreview` is a single widget swap triggered by `isPreviewMode.value` flipping — Flutter re-renders one frame via `ValueListenableBuilder`. `MarkdownBody`
rendering is synchronous but for typical note sizes (a few hundred lines) well within 200 ms.

The auto-save `FileService.writeFile` runs on the main isolate. For very large notes (>1 MB), a
synchronous write could briefly jank the UI. Acceptable for v1; if it becomes a real problem in
practice, move writes to a background isolate via `compute`.

## References

- PRD: `context/foundation/prd.md` — US-01, FR-001, FR-002, FR-003, FR-004, FR-009, FR-010
- Roadmap: `context/foundation/roadmap.md` — S-01
- `fluent_ui` package: https://pub.dev/packages/fluent_ui
- `flutter_markdown_plus` package: https://pub.dev/packages/flutter_markdown_plus
- `code_text_field` package: https://pub.dev/packages/code_text_field
- `file_picker` package: https://pub.dev/packages/file_picker
- `shared_preferences` package: https://pub.dev/packages/shared_preferences

---

## Progress

> Convention: `- [ ]` pending, `- [x]` done. Append ` — <commit sha>` when a step lands. Do not rename step titles.

### Phase 1: Project Setup & Theming

#### Automated

- [x] 1.1 `flutter pub get` completes with no errors — bdab30d
- [x] 1.2 `flutter analyze` reports no issues — bdab30d
- [x] 1.3 `flutter build linux` completes without compile errors — bdab30d

#### Manual

- [x] 1.4 App launches with Gruvbox Dark background in OS dark mode — bdab30d
- [x] 1.5 App shows Gruvbox Light background in OS light mode — bdab30d
- [x] 1.6 `Text('Outline')` placeholder visible — bdab30d

### Phase 2: Root Directory & File Tree

#### Automated

- [x] 2.1 `flutter analyze` passes with no issues — 80ca0942
- [x] 2.2 `flutter build linux` compiles cleanly — 80ca0942

#### Manual

- [x] 2.3 First launch opens native folder picker — 80ca0942
- [x] 2.4 File tree shows `.md` files and subdirectories with Gruvbox styling — 80ca0942
- [x] 2.5 Directories expand and collapse on click — 80ca0942
- [x] 2.6 Non-`.md` files are not shown in the tree — 80ca0942
- [x] 2.7 "Change folder" button re-opens picker and refreshes tree — 80ca0942
- [x] 2.8 App restart restores previously chosen directory without picker — 80ca0942

### Phase 3: Note Editor

#### Automated

- [ ] 3.1 `flutter analyze` passes

#### Manual

- [ ] 3.2 Selecting a file loads content with markdown syntax highlighting
- [ ] 3.3 Editing content saves to disk after ~0.5 seconds inactivity
- [ ] 3.4 Closing app immediately after edit still saves content to disk
- [ ] 3.5 Frontmatter visible as plain text in edit mode

### Phase 4: Preview & Toggle

#### Automated

- [ ] 4.1 `flutter analyze` passes

#### Manual

- [ ] 4.2 Toggle switches edit/preview without modifying file content
- [ ] 4.3 Preview renders markdown correctly (headers, bold, italic, code, lists, links)
- [ ] 4.4 Frontmatter absent from preview, only body rendered
- [ ] 4.5 Mode switch feels instant (< 200 ms subjectively)
- [ ] 4.6 Notes without frontmatter render full content correctly
- [ ] 4.7 Gruvbox colors consistent across edit and preview modes
