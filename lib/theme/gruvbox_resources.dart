import 'package:fluent_ui/fluent_ui.dart';

/// Adapts the standard Fluent [ResourceDictionary] to the Gruvbox colour
/// palette.
///
/// The standard FDS (Fluent Design System) resources assume near-white text
/// on near-black backgrounds.  This class maps the same resource keys to
/// Gruvbox-equivalent values so every built-in widget — TreeView, CommandBar,
/// InfoBar, etc. — picks up the correct colours without per-widget overrides.
///
/// Call [forBrightness] to obtain the appropriate instance.
class GruvboxResources {
  GruvboxResources._();

  /// Returns a [ResourceDictionary] keyed to the Gruvbox palette for the
  /// given [brightness].
  static ResourceDictionary forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? _dark() : _light();
  }

  // -- Dark mode: Gruvbox dark hard (#282828 bg, #ebdbb2 fg) -----------

  static ResourceDictionary _dark() {
    const bg = Color(0xFF282828);
    const bgAlt = Color(0xFF1d2021);
    const fg = Color(0xFFebdbb2);
    const fgDim = Color(0xFFd5c4a1);
    const fgGray = Color(0xFFa89984);
    const fgDimGray = Color(0xFF928374);
    const card = Color(0xFF3c3836);
    const cardAlt = Color(0xFF32302f);
    const accent = Color(0xFF458588);

    return ResourceDictionary.raw(
      // -- Text fills ---------------------------------------------------
      textFillColorPrimary: fg,
      textFillColorSecondary: fgDim,
      textFillColorTertiary: fgGray,
      textFillColorDisabled: fgDimGray,
      textFillColorInverse: const Color(0xFF3c3836),

      // -- Accent text fills --------------------------------------------
      accentTextFillColorDisabled: fgDimGray,
      textOnAccentFillColorSelectedText: const Color(0xFFffffff),
      textOnAccentFillColorPrimary: const Color(0xFF000000),
      textOnAccentFillColorSecondary: const Color(0x80000000),
      textOnAccentFillColorDisabled: const Color(0x87ffffff),

      // -- Control fills ------------------------------------------------
      controlFillColorDefault: const Color(0x14ebdbb2),
      controlFillColorSecondary: const Color(0x1aebdbb2),
      controlFillColorTertiary: const Color(0x0bebdbb2),
      controlFillColorQuarternary: const Color(0x14ebdbb2),
      controlFillColorDisabled: const Color(0x0bebdbb2),
      controlFillColorTransparent: const Color(0x00ebdbb2),
      controlFillColorInputActive: const Color(0xb31e1e1e),

      // -- Strong control fills -----------------------------------------
      controlStrongFillColorDefault: const Color(0x8bffffff),
      controlStrongFillColorDisabled: const Color(0x3fffffff),

      // -- Solid control fills ------------------------------------------
      controlSolidFillColorDefault: card,

      // -- Subtle fills -------------------------------------------------
      subtleFillColorTransparent: const Color(0x00000000),
      subtleFillColorSecondary: const Color(0x0febdbb2),
      subtleFillColorTertiary: const Color(0x0aebdbb2),
      subtleFillColorDisabled: const Color(0x00000000),

      // -- Control alt fills --------------------------------------------
      controlAltFillColorTransparent: const Color(0x00000000),
      controlAltFillColorSecondary: const Color(0x19000000),
      controlAltFillColorTertiary: const Color(0x0bebdbb2),
      controlAltFillColorQuarternary: const Color(0x12ebdbb2),
      controlAltFillColorDisabled: const Color(0x00000000),

      // -- Control on-image fills ---------------------------------------
      controlOnImageFillColorDefault: const Color(0xb31c1c1c),
      controlOnImageFillColorSecondary: const Color(0xFF1a1a1a),
      controlOnImageFillColorTertiary: const Color(0xFF131313),
      controlOnImageFillColorDisabled: const Color(0xFF1e1e1e),

      // -- Accent fills -------------------------------------------------
      accentFillColorDisabled: const Color(0x28ffffff),

      // -- Control strokes ----------------------------------------------
      controlStrokeColorDefault: const Color(0x12ebdbb2),
      controlStrokeColorSecondary: const Color(0x18ebdbb2),
      controlStrokeColorOnAccentDefault: const Color(0x14ffffff),
      controlStrokeColorOnAccentSecondary: const Color(0x23000000),
      controlStrokeColorOnAccentTertiary: const Color(0x37000000),
      controlStrokeColorOnAccentDisabled: const Color(0x33000000),
      controlStrokeColorForStrongFillWhenOnImage: const Color(0x6b000000),

      // -- Card strokes -------------------------------------------------
      cardStrokeColorDefault: const Color(0x19000000),
      cardStrokeColorDefaultSolid: const Color(0xFF1c1c1c),

      // -- Strong control strokes ---------------------------------------
      controlStrongStrokeColorDefault: const Color(0x8bffffff),
      controlStrongStrokeColorDisabled: const Color(0x28ffffff),

      // -- Surface strokes ----------------------------------------------
      surfaceStrokeColorDefault: const Color(0x66757575),
      surfaceStrokeColorFlyout: const Color(0x33000000),
      surfaceStrokeColorInverse: const Color(0x0f000000),

      // -- Divider stroke -----------------------------------------------
      dividerStrokeColorDefault: const Color(0x15ebdbb2),

      // -- Focus strokes ------------------------------------------------
      focusStrokeColorOuter: accent,
      focusStrokeColorInner: const Color(0xb3000000),

      // -- Card backgrounds ---------------------------------------------
      cardBackgroundFillColorDefault: card,
      cardBackgroundFillColorSecondary: cardAlt,
      cardBackgroundFillColorTertiary: const Color(0xFF504945),

      // -- Smoke fill ---------------------------------------------------
      smokeFillColorDefault: const Color(0x4d000000),

      // -- Layer fills --------------------------------------------------
      layerFillColorDefault: cardAlt,
      layerFillColorAlt: const Color(0x0dffffff),
      layerOnAcrylicFillColorDefault: const Color(0x09ffffff),
      layerOnAccentAcrylicFillColorDefault: const Color(0x09ffffff),
      layerOnMicaBaseAltFillColorDefault: const Color(0x733a3a3a),
      layerOnMicaBaseAltFillColorSecondary: const Color(0x0fffffff),
      layerOnMicaBaseAltFillColorTertiary: const Color(0xFF2c2c2c),
      layerOnMicaBaseAltFillColorTransparent: const Color(0x00ffffff),

      // -- Solid backgrounds --------------------------------------------
      solidBackgroundFillColorBase: bg,
      solidBackgroundFillColorSecondary: bgAlt,
      solidBackgroundFillColorTertiary: bg,
      solidBackgroundFillColorQuarternary: cardAlt,
      solidBackgroundFillColorQuinary: const Color(0xFF333333),
      solidBackgroundFillColorSenary: const Color(0xFF373737),
      solidBackgroundFillColorTransparent: const Color(0x00282828),
      solidBackgroundFillColorBaseAlt: const Color(0xFF0a0a0a),

      // -- System fills -------------------------------------------------
      systemFillColorSuccess: const Color(0xFF6ccb5f),
      systemFillColorCaution: const Color(0xFFfce100),
      systemFillColorCritical: const Color(0xFFff99a4),
      systemFillColorNeutral: const Color(0x8bffffff),
      systemFillColorSolidNeutral: const Color(0xFF9d9d9d),
      systemFillColorAttentionBackground: const Color(0x08ffffff),
      systemFillColorSuccessBackground: const Color(0xFF393d1b),
      systemFillColorCautionBackground: const Color(0xFF433519),
      systemFillColorCriticalBackground: const Color(0xFF442726),
      systemFillColorNeutralBackground: const Color(0x08ffffff),
      systemFillColorSolidAttentionBackground: const Color(0xFF2e2e2e),
      systemFillColorSolidNeutralBackground: const Color(0xFF2e2e2e),
    );
  }

  // -- Light mode: Gruvbox light hard (#fbf1c7 bg, #3c3836 fg) --------

  static ResourceDictionary _light() {
    const bg = Color(0xFFfbf1c7);
    const bgAlt = Color(0xFFf2e5bc);
    const fg = Color(0xFF3c3836);
    const fgDim = Color(0xFF504945);
    const fgGray = Color(0xFF665c54);
    const fgDimGray = Color(0xFF7c6f64);
    const card = Color(0xFFebdbb2);
    const cardAlt = Color(0xFFd5c4a1);

    return ResourceDictionary.raw(
      // -- Text fills ---------------------------------------------------
      textFillColorPrimary: fg,
      textFillColorSecondary: fgDim,
      textFillColorTertiary: fgGray,
      textFillColorDisabled: fgDimGray,
      textFillColorInverse: const Color(0xFFffffff),

      // -- Accent text fills --------------------------------------------
      accentTextFillColorDisabled: fgDimGray,
      textOnAccentFillColorSelectedText: const Color(0xFFffffff),
      textOnAccentFillColorPrimary: const Color(0xFFffffff),
      textOnAccentFillColorSecondary: const Color(0xb3ffffff),
      textOnAccentFillColorDisabled: const Color(0xFFffffff),

      // -- Control fills ------------------------------------------------
      controlFillColorDefault: const Color(0xb3ffffff),
      controlFillColorSecondary: const Color(0x80f9f9f9),
      controlFillColorTertiary: const Color(0x4df9f9f9),
      controlFillColorQuarternary: const Color(0xc2f3f3f3),
      controlFillColorDisabled: const Color(0x4df9f9f9),
      controlFillColorTransparent: const Color(0x00ffffff),
      controlFillColorInputActive: const Color(0xFFffffff),

      // -- Strong control fills -----------------------------------------
      controlStrongFillColorDefault: const Color(0x72000000),
      controlStrongFillColorDisabled: const Color(0x51000000),

      // -- Solid control fills ------------------------------------------
      controlSolidFillColorDefault: const Color(0xFFffffff),

      // -- Subtle fills -------------------------------------------------
      subtleFillColorTransparent: const Color(0x00000000),
      subtleFillColorSecondary: const Color(0x09000000),
      subtleFillColorTertiary: const Color(0x06000000),
      subtleFillColorDisabled: const Color(0x00000000),

      // -- Control alt fills --------------------------------------------
      controlAltFillColorTransparent: const Color(0x00000000),
      controlAltFillColorSecondary: const Color(0x09000000),
      controlAltFillColorTertiary: const Color(0x06000000),
      controlAltFillColorQuarternary: const Color(0x06000000),
      controlAltFillColorDisabled: const Color(0x00000000),

      // -- Control on-image fills ---------------------------------------
      controlOnImageFillColorDefault: const Color(0xb31c1c1c),
      controlOnImageFillColorSecondary: const Color(0xFF1a1a1a),
      controlOnImageFillColorTertiary: const Color(0xFF131313),
      controlOnImageFillColorDisabled: const Color(0xFF1e1e1e),

      // -- Accent fills -------------------------------------------------
      accentFillColorDisabled: const Color(0x28000000),

      // -- Control strokes ----------------------------------------------
      controlStrokeColorDefault: const Color(0x0f000000),
      controlStrokeColorSecondary: const Color(0x1e000000),
      controlStrokeColorOnAccentDefault: const Color(0x14000000),
      controlStrokeColorOnAccentSecondary: const Color(0x23000000),
      controlStrokeColorOnAccentTertiary: const Color(0x37000000),
      controlStrokeColorOnAccentDisabled: const Color(0x33000000),
      controlStrokeColorForStrongFillWhenOnImage: const Color(0x6b000000),

      // -- Card strokes -------------------------------------------------
      cardStrokeColorDefault: const Color(0x19000000),
      cardStrokeColorDefaultSolid: const Color(0xFFbdbdbd),

      // -- Strong control strokes ---------------------------------------
      controlStrongStrokeColorDefault: const Color(0x72000000),
      controlStrongStrokeColorDisabled: const Color(0x28000000),

      // -- Surface strokes ----------------------------------------------
      surfaceStrokeColorDefault: const Color(0x66757575),
      surfaceStrokeColorFlyout: const Color(0x1f000000),
      surfaceStrokeColorInverse: const Color(0x0f000000),

      // -- Divider stroke -----------------------------------------------
      dividerStrokeColorDefault: const Color(0x0f3c3836),

      // -- Focus strokes ------------------------------------------------
      focusStrokeColorOuter: const Color(0xFF000000),
      focusStrokeColorInner: const Color(0xb3ffffff),

      // -- Card backgrounds ---------------------------------------------
      cardBackgroundFillColorDefault: card,
      cardBackgroundFillColorSecondary: cardAlt,
      cardBackgroundFillColorTertiary: const Color(0xFFbdae93),

      // -- Smoke fill ---------------------------------------------------
      smokeFillColorDefault: const Color(0x4d000000),

      // -- Layer fills --------------------------------------------------
      layerFillColorDefault: const Color(0x4c3a3a3a),
      layerFillColorAlt: const Color(0x09ffffff),
      layerOnAcrylicFillColorDefault: const Color(0x09ffffff),
      layerOnAccentAcrylicFillColorDefault: const Color(0x09ffffff),
      layerOnMicaBaseAltFillColorDefault: const Color(0x733a3a3a),
      layerOnMicaBaseAltFillColorSecondary: const Color(0x0fffffff),
      layerOnMicaBaseAltFillColorTertiary: const Color(0xFF2c2c2c),
      layerOnMicaBaseAltFillColorTransparent: const Color(0x00ffffff),

      // -- Solid backgrounds --------------------------------------------
      solidBackgroundFillColorBase: bg,
      solidBackgroundFillColorSecondary: bgAlt,
      solidBackgroundFillColorTertiary: bg,
      solidBackgroundFillColorQuarternary: bgAlt,
      solidBackgroundFillColorQuinary: const Color(0xFFebdbb2),
      solidBackgroundFillColorSenary: const Color(0xFFd5c4a1),
      solidBackgroundFillColorTransparent: const Color(0x00fbf1c7),
      solidBackgroundFillColorBaseAlt: const Color(0xFFf2e5bc),

      // -- System fills -------------------------------------------------
      systemFillColorSuccess: const Color(0xFF0d7a33),
      systemFillColorCaution: const Color(0xFF8a6d00),
      systemFillColorCritical: const Color(0xFFc42b1c),
      systemFillColorNeutral: const Color(0x72000000),
      systemFillColorSolidNeutral: const Color(0xFF9d9d9d),
      systemFillColorAttentionBackground: const Color(0x08000000),
      systemFillColorSuccessBackground: const Color(0xFFdff6dd),
      systemFillColorCautionBackground: const Color(0xFFfef4d4),
      systemFillColorCriticalBackground: const Color(0xFFfde7e9),
      systemFillColorNeutralBackground: const Color(0x08000000),
      systemFillColorSolidAttentionBackground: const Color(0xFFf2f2f2),
      systemFillColorSolidNeutralBackground: const Color(0xFFf2f2f2),
    );
  }
}
