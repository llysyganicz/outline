import 'package:fluent_ui/fluent_ui.dart';

import 'di/container.dart';
import 'theme/gruvbox_theme.dart';
import 'screens/editor_screen.dart';
import 'utils/system_theme.dart';

void main() {
  setupDependencies();
  runApp(const OutlineApp());
}

/// Determines the initial [ThemeMode] based on the platform.
///
/// On Linux, reads GTK settings (see [detectPlatformBrightness]). On other
/// platforms (Windows, macOS) delegates to [ThemeMode.system] which follows
/// the OS-level dark/light preference automatically.
ThemeMode _initialThemeMode() {
  final brightness = detectPlatformBrightness();
  if (brightness == null) return ThemeMode.system;
  return brightness == Brightness.dark
      ? ThemeMode.dark
      : ThemeMode.light;
}

class OutlineApp extends StatelessWidget {
  const OutlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Outline',
      debugShowCheckedModeBanner: false,
      theme: GruvboxTheme.light,
      darkTheme: GruvboxTheme.dark,
      themeMode: _initialThemeMode(),
      home: const EditorScreen(),
    );
  }
}
