import 'dart:io';

import 'package:flutter/material.dart';

/// Detects the system brightness preference on Linux by querying GTK settings.
///
/// Resolution order:
/// 1. `gsettings get org.gnome.desktop.interface color-scheme` (GNOME/KDE/GTK)
/// 2. `GTK_THEME` environment variable
/// 3. `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`
/// 4. Fallback to [Brightness.light]
///
/// On non-Linux platforms this returns `null`, meaning the caller should fall
/// back to [ThemeMode.system] (which works correctly on Windows and macOS).
Brightness? detectPlatformBrightness() {
  if (!Platform.isLinux) return null;

  // 1. gsettings (most reliable for GTK-based DEs)
  final gsettings = _tryGsettings();
  if (gsettings != null) return gsettings;

  // 2. GTK_THEME environment variable
  final env = _tryEnvVar();
  if (env != null) return env;

  // 3. settings.ini files (works even without gsettings)
  final ini = _trySettingsIni();
  if (ini != null) return ini;

  return Brightness.light;
}

Brightness? _tryGsettings() {
  try {
    final result = Process.runSync(
      'gsettings',
      ['get', 'org.gnome.desktop.interface', 'color-scheme'],
    );
    if (result.exitCode == 0) {
      final value = result.stdout.toString().trim();
      if (value.contains("'prefer-dark'")) return Brightness.dark;
      if (value.contains("'prefer-light'")) return Brightness.light;
      // 'default' — look at gtk-theme below
      if (value.contains("'default'")) {
        // Try reading gtk-theme name
        final themeResult = Process.runSync(
          'gsettings',
          ['get', 'org.gnome.desktop.interface', 'gtk-theme'],
        );
        if (themeResult.exitCode == 0 &&
            themeResult.stdout.toString().trim().toLowerCase().contains('dark')) {
          return Brightness.dark;
        }
      }
    }
  } catch (_) {
    // gsettings not available
  }
  return null;
}

Brightness? _tryEnvVar() {
  final theme = Platform.environment['GTK_THEME'];
  if (theme != null && theme.toLowerCase().contains('dark')) {
    return Brightness.dark;
  }
  return null;
}

Brightness? _trySettingsIni() {
  try {
    final home = Platform.environment['HOME'] ?? '';
    for (final version in ['gtk-3.0', 'gtk-4.0']) {
      final file = File('$home/.config/$version/settings.ini');
      if (!file.existsSync()) continue;
      final content = file.readAsStringSync();
      if (content.contains('gtk-application-prefer-dark-theme=1')) {
        return Brightness.dark;
      }
      if (RegExp(r'gtk-theme-name\s*=\s*.*[Dd]ark').hasMatch(content)) {
        return Brightness.dark;
      }
    }
  } catch (_) {}
  return null;
}
