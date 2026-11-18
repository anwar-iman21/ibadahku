import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'extensions.dart';

/// Kartu putih sudut membulat, border tipis, shadow halus.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Sp.s4),
    this.onTap,
    this.color,
    this.gradient,
    this.border = true,
    this.shadow = Shd.sm,
    this.radius = Rad.lgR,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final bool border;
  final List<BoxShadow> shadow;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final deco = BoxDecoration(
      color: gradient == null ? (color ?? context.surfaceCard) : null,
      gradient: gradient,
      borderRadius: radius,
      border: border ? Border.all(color: context.borderColor) : null,
      boxShadow: context.isDark ? null : shadow,
    );
    return DecoratedBox(
      decoration: deco,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          hoverColor: AppColors.green[600].withValues(alpha: 0.05),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
