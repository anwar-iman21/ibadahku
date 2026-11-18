import 'package:flutter/widgets.dart';

enum ScreenSize { mobile, tablet, desktop }

/// Breakpoint ala Tailwind.
class Breakpoints {
  Breakpoints._();
  static const double sm = 640;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;

  /// Lebar konten maksimal di layar lebar.
  static const double contentMax = 1200;

  static ScreenSize of(double width) {
    if (width >= lg) return ScreenSize.desktop;
    if (width >= md) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  ScreenSize get screenSize => Breakpoints.of(screenWidth);
  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;
}

/// Widget builder responsif: `Responsive(builder: (context, size) => ...)`
class Responsive extends StatelessWidget {
  const Responsive({super.key, required this.builder});
  final Widget Function(BuildContext context, ScreenSize size) builder;

  @override
  Widget build(BuildContext context) => builder(context, context.screenSize);
}
