import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Helper ala utilitas Tailwind: `Text('Hai').p(16).rounded(12)`
extension WidgetUtils on Widget {
  Widget p(double v) => Padding(padding: EdgeInsets.all(v), child: this);
  Widget px(double v) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: v), child: this);
  Widget py(double v) =>
      Padding(padding: EdgeInsets.symmetric(vertical: v), child: this);
  Widget pt(double v) => Padding(padding: EdgeInsets.only(top: v), child: this);
  Widget pb(double v) =>
      Padding(padding: EdgeInsets.only(bottom: v), child: this);
  Widget pl(double v) =>
      Padding(padding: EdgeInsets.only(left: v), child: this);
  Widget pr(double v) =>
      Padding(padding: EdgeInsets.only(right: v), child: this);

  Widget rounded(double r) =>
      ClipRRect(borderRadius: BorderRadius.circular(r), child: this);
  Widget get center => Center(child: this);
  Widget expanded([int flex = 1]) => Expanded(flex: flex, child: this);
  Widget flexible([int flex = 1]) => Flexible(flex: flex, child: this);
  Widget opacity(double v) => Opacity(opacity: v, child: this);
  Widget sized({double? w, double? h}) =>
      SizedBox(width: w, height: h, child: this);
  Widget align(AlignmentGeometry a) => Align(alignment: a, child: this);
}

extension TextStyleUtils on TextStyle {
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semibold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle c(Color color) => copyWith(color: color);
}

/// Warna adaptif terang/gelap + utilitas konteks.
extension ThemeContext on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceCard => isDark ? AppColors.darkSurface : Colors.white;
  Color get borderColor => isDark ? AppColors.darkBorder : AppColors.slate[200];
  Color get mutedText => isDark ? AppColors.slate[300] : AppColors.slate[600];
  Color get tintBg => isDark ? AppColors.darkSurfaceHigh : AppColors.green[50];
  Color get tintFg => isDark ? AppColors.green[300] : AppColors.green[700];
  Color get fieldFill =>
      isDark ? AppColors.darkSurfaceHigh : AppColors.slate[50];
  Color get creamSurface =>
      isDark ? AppColors.darkSurfaceHigh : AppColors.cream[100];
  Color get goldText => isDark ? AppColors.gold[300] : AppColors.gold[700];

  void snack(String message, {bool error = false}) {
    final m = ScaffoldMessenger.of(this);
    m.hideCurrentSnackBar();
    m.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.error : AppColors.green[800],
        margin: const EdgeInsets.all(16),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
    );
  }
}
