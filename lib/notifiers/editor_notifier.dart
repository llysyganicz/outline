import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';

import '../services/preferences_service.dart';
import '../services/file_service.dart';

/// Single owner of all app state and business logic.
///
/// Exposes state as [ValueNotifier] fields that widgets bind to via
/// [ValueListenableBuilder]. The notifier also carries all mutation methods
/// so widgets remain pure [StatelessWidget]s with zero logic.
///
/// ### Initialization
///
/// Call [initialize] once after the first frame (e.g. from a post-frame
/// callback in `main`) to restore the persisted root directory or show the
/// native folder picker on first launch.
class EditorNotifier {
  EditorNotifier(this._prefs, this._files) {
    _lifecycleListener = AppLifecycleListener(onDetach: _flushSync);
  }

  final PreferencesService _prefs;
  // ignore: unused_field — used in Phase 3 for auto-save.
  final FileService _files;
  late final AppLifecycleListener _lifecycleListener;

  // -- State notifiers --------------------------------------------------

  /// The currently-selected notes root directory, or `null` if none chosen.
  final ValueNotifier<String?> rootDirectory = ValueNotifier(null);

  /// The full path of the file currently selected in the tree, or `null`.
  final ValueNotifier<String?> selectedFilePath = ValueNotifier(null);

  // -- Public API -------------------------------------------------------

  /// Loads the persisted root directory, or shows the native folder picker
  /// on first launch.
  ///
  /// Should be called once after the first frame so that
  /// [FilePicker.getDirectoryPath] has a valid window handle.
  Future<void> initialize() async {
    final stored = await _prefs.getRootDirectory();
    if (stored != null && stored.isNotEmpty) {
      rootDirectory.value = stored;
    } else {
      await changeRootDirectory();
    }
  }

  /// Opens the native folder picker and persists the chosen directory.
  ///
  /// If the user cancels the picker, the current root is unchanged.
  Future<void> changeRootDirectory() async {
    final path = await FilePicker.getDirectoryPath();
    if (path != null) {
      rootDirectory.value = path;
      selectedFilePath.value = null;
      await _prefs.setRootDirectory(path);
    }
  }

  /// Selects a file in the tree (called when user taps a `.md` leaf).
  void selectFile(String path) {
    selectedFilePath.value = path;
  }

  // -- Lifecycle --------------------------------------------------------

  /// Flushes pending auto-save when the app is about to be detached.
  ///
  /// This is a no-op until Phase 3 wires the editor state.
  void _flushSync() {
    // Will be wired in Phase 3 to save pending edits on app detach.
  }

  /// Releases resources held by this notifier.
  void dispose() {
    _lifecycleListener.dispose();
  }
}
