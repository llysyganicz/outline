import 'dart:async';

import 'dart:io';

import 'package:code_text_field/code_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:highlight/languages/markdown.dart' show markdown;

import '../services/preferences_service.dart';
import '../services/file_service.dart';

class EditorNotifier {
  EditorNotifier(this._prefs, this._files) {
    _lifecycleListener = AppLifecycleListener(onDetach: _flushSync);
  }

  final PreferencesService _prefs;
  final FileService _files;
  late final AppLifecycleListener _lifecycleListener;

  final ValueNotifier<String?> rootDirectory = ValueNotifier(null);
  final ValueNotifier<String?> selectedFilePath = ValueNotifier(null);
  final ValueNotifier<String> fileContent = ValueNotifier('');
  final ValueNotifier<bool> isPreviewMode = ValueNotifier(false);

  final CodeController codeController = CodeController(
    language: markdown,
  );

  bool _isDirty = false;
  Timer? _saveTimer;

  /// Restores persisted root, or opens folder picker on first launch.
  /// Call after first frame so [FilePicker.getDirectoryPath] has a window.
  Future<void> initialize() async {
    final stored = await _prefs.getRootDirectory();
    if (stored != null && stored.isNotEmpty) {
      rootDirectory.value = stored;
    } else {
      await changeRootDirectory();
    }
  }

  /// Opens picker, persists choice, resets editor state.
  Future<void> changeRootDirectory() async {
    final path = await FilePicker.getDirectoryPath();
    if (path != null) {
      rootDirectory.value = path;
      selectedFilePath.value = null;
      fileContent.value = '';
      codeController.text = '';
      await _prefs.setRootDirectory(path);
    }
  }

  /// Reads file and populates editor with syntax highlighting.
  Future<void> selectFile(String path) async {
    selectedFilePath.value = path;
    isPreviewMode.value = false;
    final content = await _files.readFile(path);
    if (content != null) {
      fileContent.value = content;
      codeController.text = content;
    }
    _isDirty = false;
    _saveTimer?.cancel();
  }

  /// Switches between edit and preview mode without modifying file content.
  void togglePreview() {
    isPreviewMode.value = !isPreviewMode.value;
  }

  /// Updates content, marks dirty, resets 500ms auto-save timer.
  void onEditorChanged(String content) {
    fileContent.value = content;
    _isDirty = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _flush);
  }

  /// Shared pre-write check: returns the file path if dirty, or null to skip.
  String? _prepareFlush() {
    if (!_isDirty) return null;
    final path = selectedFilePath.value;
    if (path == null) return null;
    _isDirty = false;
    _saveTimer?.cancel();
    return path;
  }

  /// Synchronous flush used on app lifecycle [AppLifecycleAction.detach].
  /// Guarantees data reaches disk before the callback returns.
  void _flushSync() {
    final path = _prepareFlush();
    if (path == null) return;
    try {
      File(path).writeAsStringSync(fileContent.value);
    } catch (e, st) {
      debugPrint('EditorNotifier._flushSync failed for $path: $e\n$st');
    }
  }

  /// Debounced async flush called from [onEditorChanged] after 500 ms.
  Future<void> _flush() async {
    final path = _prepareFlush();
    if (path == null) return;
    await _files.writeFile(path, fileContent.value);
  }

  void dispose() {
    _saveTimer?.cancel();
    codeController.dispose();
    isPreviewMode.dispose();
    _lifecycleListener.dispose();
  }
}
