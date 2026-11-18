import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text.dart';

/// Tema Material 3 yang dibangun dari token design system.
class AppTheme {
  AppTheme._();

  static final ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.green[600],
    onPrimary: Colors.white,
    primaryContainer: AppColors.green[100],
    onPrimaryContainer: AppColors.green[900],
    secondary: AppColors.gold[500],
    onSecondary: Colors.white,
    secondaryContainer: AppColors.gold[100],
    onSecondaryContainer: AppColors.gold[900],
    error: AppColors.error,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.cream[300],
    outline: AppColors.slate[300],
    outlineVariant: AppColors.slate[200],
  );

  static final ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.green[400],
    onPrimary: AppColors.green[900],
    primaryContainer: AppColors.green[800],
    onPrimaryContainer: AppColors.green[100],
    secondary: AppColors.gold[400],
    onSecondary: AppColors.gold[900],
    secondaryContainer: AppColors.gold[800],
    onSecondaryContainer: AppColors.gold[100],
    error: const Color(0xFFF87171),
    onError: Colors.black,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkText,
    surfaceContainerHighest: AppColors.darkSurfaceHigh,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkBorder,
  );

  static ThemeData get light => _build(_lightScheme, AppColors.cream[200]);
  static ThemeData get dark => _build(_darkScheme, AppColors.darkBg);

  static ThemeData _build(ColorScheme scheme, Color background) {
    final isDark = scheme.brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: AppText.font,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: isDark ? AppColors.darkBorder : AppColors.slate[200],
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: isDark ? AppColors.green[800] : AppColors.green[100],
        labelTextStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.xl)),
        ),
      ),
      scrollbarTheme: const ScrollbarThemeData(thickness: WidgetStatePropertyAll(6)),
    );
  }
}
