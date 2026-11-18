import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text.dart';
import 'extensions.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

/// Tombol dengan 4 varian, state loading, dan animasi tekan.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool loading;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _down = false;

  void _setDown(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    late final Color bg;
    late final Color fg;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = AppColors.green[600];
        fg = Colors.white;
      case AppButtonVariant.secondary:
        bg = dark ? AppColors.darkSurfaceHigh : AppColors.green[50];
        fg = dark ? AppColors.green[200] : AppColors.green[700];
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = dark ? AppColors.green[300] : AppColors.green[700];
      case AppButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
    }

    final shape = RoundedRectangleBorder(borderRadius: Rad.mdR);
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: Sp.s5, vertical: Sp.s3)),
      shape: WidgetStatePropertyAll(shape),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return dark ? AppColors.darkSurfaceHigh : AppColors.slate[200];
        }
        return bg;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.slate[400];
        }
        return fg;
      }),
      overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.08)),
      textStyle: WidgetStatePropertyAll(AppText.base.semibold),
    );

    final content = widget.loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20),
                const HGap(Sp.s2),
              ],
              Flexible(
                child: Text(widget.label,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    // Saat loading, tombol tetap berwarna normal namun tidak melakukan apa pun.
    final VoidCallback? handler =
        widget.loading ? () {} : widget.onPressed;
    final button = FilledButton(
      onPressed: handler,
      style: style,
      child: content,
    );

    return Listener(
      onPointerDown: (_) => _setDown(true),
      onPointerUp: (_) => _setDown(false),
      onPointerCancel: (_) => _setDown(false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.expand
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}
