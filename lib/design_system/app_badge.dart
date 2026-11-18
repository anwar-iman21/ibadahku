import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text.dart';
import 'extensions.dart';

enum BadgeKind { success, warning, error, info, neutral, gold }

/// Lencana kecil berbentuk pil (status).
class AppBadge extends StatelessWidget {
  const AppBadge(
    this.text, {
    super.key,
    this.kind = BadgeKind.neutral,
    this.icon,
  });
  final String text;
  final BadgeKind kind;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    late Color base;
    switch (kind) {
      case BadgeKind.success:
        base = AppColors.success;
      case BadgeKind.warning:
        base = AppColors.warning;
      case BadgeKind.error:
        base = AppColors.error;
      case BadgeKind.info:
        base = AppColors.info;
      case BadgeKind.gold:
        base = AppColors.gold[600];
      case BadgeKind.neutral:
        base = AppColors.slate[500];
    }
    final fg = dark ? Color.lerp(base, Colors.white, 0.45)! : base;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.s3, vertical: 4),
      decoration: BoxDecoration(
        color: base.withValues(alpha: dark ? 0.22 : 0.12),
        borderRadius: Rad.fullR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const HGap(4)],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.xs.semibold.c(fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip pilihan (selected / tidak) dengan animasi halus.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.leading,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : context.mutedText;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? AppColors.green[600] : context.surfaceCard,
          borderRadius: Rad.fullR,
          border: Border.all(
            color: selected ? AppColors.green[600] : context.borderColor,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: Rad.fullR,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.s4,
                  vertical: Sp.s2,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const HGap(6),
                    ] else if (icon != null) ...[
                      Icon(icon, size: 16, color: fg),
                      const HGap(6),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sm.medium.c(fg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ikon dalam rounded-square berwarna lembut.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.size = 44, this.color, this.bg})
    : child = null;
  const IconBadge.custom(this.child, {super.key, this.size = 44, this.bg})
    : icon = null,
      color = null;

  final IconData? icon;
  final Widget? child;
  final double size;
  final Color? color;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg ?? context.tintBg,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child:
          child ??
          Icon(icon!, size: size * 0.5, color: color ?? context.tintFg),
    );
  }
}
