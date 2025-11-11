import 'package:azkark/core/res/color.dart';
import 'package:flutter/material.dart';

/// Picks black/white for readable foreground on top of [bg].
Color _onFor(Color bg) =>
    ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : Colors.black;

/// Lightness shift for container tones (positive -> lighter, negative -> darker).
Color _shiftLightness(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  final l = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}

ColorScheme buildSchemeTheme(bool isDarkMode) {
  // Base brand tones from your palette
  final primary    = AppColor.primaryColor.getColor(isDarkMode);
  final secondary  = AppColor.primaryColorDark.getColor(isDarkMode);
  final surface    = AppColor.scaffoldBackgroundColor.getColor(isDarkMode);
  final background = AppColor.backgroundColor.getColor(isDarkMode);
  final error      = AppColor.errorColor.getColor(isDarkMode);

  // Container tones (slightly lighter in dark mode, slightly darker in light mode)
  final primaryContainer   = _shiftLightness(primary,   isDarkMode ? 0.25 : -0.15);
  final secondaryContainer = _shiftLightness(secondary, isDarkMode ? 0.25 : -0.15);
  final tertiary           = AppColor.primaryColor.getColor(isDarkMode);
  final tertiaryContainer  = _shiftLightness(tertiary,  isDarkMode ? 0.25 : -0.15);
  final errorContainer     = _shiftLightness(error,     isDarkMode ? 0.20 : -0.10);

  // Variant surface for chips/cards/fields, created by tinting surface with primary
  final surfaceVariant = Color.alphaBlend(primary.withOpacity(0.08), surface);

  // Outline colors (dividers, strokes)
  final onSurface       = _onFor(surface);
  final outline         = onSurface.withOpacity(0.60); // prominent stroke
  final outlineVariant  = onSurface.withOpacity(0.30); // subtle stroke

  // Inverse surface (for bottom sheets/snackbars in opposite theme surfaces)
  final inverseSurface  = Color.alphaBlend(onSurface.withOpacity(0.90), Colors.transparent);
  final inversePrimary  = _shiftLightness(primary, isDarkMode ? 0.40 : -0.25);

  // Scrim/shadow (modals & elevation)
  final scrim  = Colors.black.withOpacity(0.60);
  final shadow = Colors.black.withOpacity(isDarkMode ? 0.80 : 0.20);

  // Surface tint used by Material 3 elevation overlays
  final surfaceTint = primary;

  return ColorScheme(

    // Overall theme brightness (drives component defaults)
    brightness: isDarkMode ? Brightness.dark : Brightness.light,

    // Brand color (FAB, filled buttons, active toggles)
    primary: primary,
    // Text/icons that sit on top of [primary] (must be readable)
    onPrimary: _onFor(primary),
    // Filled container version of primary (cards, chips, input fields in some variants)
    primaryContainer: primaryContainer,
    // Foreground on top of [primaryContainer]
    onPrimaryContainer: _onFor(primaryContainer),

    // Secondary accent (less emphasis than primary; filters, secondary buttons)
    secondary: secondary,
    // Foreground on [secondary]
    onSecondary: _onFor(secondary),
    // Container tone for secondary (chips, selected states)
    secondaryContainer: secondaryContainer,
    // Foreground on [secondaryContainer]
    onSecondaryContainer: _onFor(secondaryContainer),

    // Optional third accent color (charts, special highlights)
    tertiary: tertiary,
    // Foreground on [tertiary]
    onTertiary: _onFor(tertiary),
    // Container tone for tertiary
    tertiaryContainer: tertiaryContainer,
    // Foreground on [tertiaryContainer]
    onTertiaryContainer: _onFor(tertiaryContainer),

    // Error color (validation, error states)
    error: error,
    // Foreground on [error] (e.g., text on error button)
    onError: _onFor(error),
    // Error container (error chips/fields)
    errorContainer: errorContainer,
    // Foreground on [errorContainer]
    onErrorContainer: _onFor(errorContainer),

    // App background (scaffolds)
    background: background,
    // Default text color on background
    onBackground: _onFor(background),

    // Surfaces (cards, sheets, app bars)
    surface: surface,
    // Default text color on surfaces
    onSurface: onSurface,

    // Variant surface (chips, outlined fields, elevated components)
    surfaceVariant: surfaceVariant,
    // Text/icons on surfaceVariant (helper/label colors)
    onSurfaceVariant: _onFor(surfaceVariant),

    // Divider & outline strokes
    outline: outline,
    // Softer outline for low-emphasis borders
    outlineVariant: outlineVariant,

    // Drop shadows for elevated components
    shadow: shadow,
    // Backdrop dimmer for dialogs/sheets/menus
    scrim: scrim,

    // Opposite-surface used in some elevated components/snackbars
    inverseSurface: isDarkMode ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.90),
    // Text/icons on inverseSurface
    onInverseSurface: isDarkMode ? Colors.white : Colors.black,
    // Primary in the inverse theme (links on dark bars, etc.)
    inversePrimary: inversePrimary,

    // Tint used by Material 3 for elevation overlay on surfaces
    surfaceTint: surfaceTint,


  );
}
