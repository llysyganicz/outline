import 'package:shared_preferences/shared_preferences.dart';

/// Typed wrapper around [SharedPreferences] for app preferences.
///
/// Keeps all preference key strings in one place and exposes domain-specific
/// getters / setters instead of raw key-value access. The underlying
/// [SharedPreferences] instance is initialised lazily so that the service can
/// be registered synchronously in the DI container.
class PreferencesService {
  static const _rootDirKey = 'root_directory';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// Returns the previously-saved root directory path, or `null` if none has
  /// been stored.
  Future<String?> getRootDirectory() async {
    final prefs = await _instance;
    return prefs.getString(_rootDirKey);
  }

  /// Persists the given directory [path] so it can be restored on next launch.
  Future<void> setRootDirectory(String path) async {
    final prefs = await _instance;
    await prefs.setString(_rootDirKey, path);
  }
}
