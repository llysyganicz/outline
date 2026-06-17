import 'package:fluent_ui/fluent_ui.dart';

import 'gruvbox_resources.dart';

/// Canonical Gruvbox color palette and theme data for Fluent UI.
///
/// Both variants use the published Gruvbox hex values without modification.
/// The accent color is Gruvbox aqua (#458588) for both light and dark modes.
class GruvboxTheme {
  GruvboxTheme._();

  // -- Palette constants ------------------------------------------------

  /// Gruvbox Dark background (hard).
  static const Color darkBg = Color(0xFF282828);

  /// Gruvbox Dark foreground.
  static const Color darkFg = Color(0xFFebdbb2);

  /// Gruvbox Light background (hard).
  static const Color lightBg = Color(0xFFfbf1c7);

  /// Gruvbox Light foreground.
  static const Color lightFg = Color(0xFF3c3836);

  /// Gruvbox aqua — used as the accent color in both modes.
  static const Color aqua = Color(0xFF458588);

  /// Gruvbox blue — a nearby alternative for accent swatch depth.
  static const Color blue = Color(0xFF83a598);

  // -- Accent colour (shared) ------------------------------------------

  static final AccentColor _accent = AccentColor.swatch({
    'darkest': const Color(0xFF2d5e67),
    'darker': const Color(0xFF3a747e),
    'dark': const Color(0xFF3f7d86),
    'normal': aqua,
    'light': const Color(0xFF5a9ca5),
    'lighter': const Color(0xFF76b1b9),
    'lightest': const Color(0xFF91c5cc),
  });

  // -- Theme instances --------------------------------------------------

  /// Gruvbox Dark [FluentThemeData].
  ///
  /// Background: `#282828`, foreground: `#ebdbb2`, accent: aqua `#458588`.
  static FluentThemeData get dark {
    return FluentThemeData(
      brightness: Brightness.dark,
      accentColor: _accent,
      scaffoldBackgroundColor: darkBg,
      inactiveColor: darkFg,
      activeColor: darkFg,
      cardColor: const Color(0xFF3c3836),
      menuColor: const Color(0xFF3c3836),
      selectionColor: aqua,
      resources: GruvboxResources.forBrightness(Brightness.dark),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Gruvbox Light [FluentThemeData].
  ///
  /// Background: `#fbf1c7`, foreground: `#3c3836`, accent: aqua `#458588`.
  static FluentThemeData get light {
    return FluentThemeData(
      brightness: Brightness.light,
      accentColor: _accent,
      scaffoldBackgroundColor: lightBg,
      inactiveColor: lightFg,
      activeColor: lightFg,
      cardColor: const Color(0xFFebdbb2),
      menuColor: const Color(0xFFebdbb2),
      selectionColor: aqua,
      resources: GruvboxResources.forBrightness(Brightness.light),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
