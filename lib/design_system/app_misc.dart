import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_button.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text.dart';
import 'extensions.dart';

/// Judul bagian + subjudul + aksi di kanan.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.lg.semibold),
              if (subtitle != null)
                Text(subtitle!, style: AppText.sm.c(context.mutedText)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Tampilan kosong dengan ilustrasi vektor sederhana + ajakan.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sp.s8, horizontal: Sp.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(140, 120),
                  painter: _EmptyPainter(ring: context.tintBg),
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: context.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Icon(icon, size: 32, color: context.tintFg),
                ),
              ],
            ),
          ),
          const VGap(Sp.s3),
          Text(title, textAlign: TextAlign.center, style: AppText.lg.semibold),
          if (message != null) ...[
            const VGap(Sp.s1),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppText.sm.c(context.mutedText),
            ),
          ],
          if (actionLabel != null) ...[
            const VGap(Sp.s4),
            AppButton(
              label: actionLabel!,
              onPressed: onAction,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ],
      ),
    );
  }
}

class AnimalHeadIcon extends StatelessWidget {
  const AnimalHeadIcon(this.animal, {super.key, this.color, this.size = 24});
  final String animal;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final name = animal.toLowerCase();
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.asset(
          'assets/animals/$name.jpg',
          fit: BoxFit.contain,
          errorBuilder:
              (context, error, stackTrace) => CustomPaint(
                painter: _AnimalHeadPainter(
                  animal: animal,
                  color: color ?? context.tintFg,
                ),
              ),
        ),
      ),
    );
  }
}

class RiceIcon extends StatelessWidget {
  const RiceIcon({super.key, this.size = 24, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/icons/padi.jpg',
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) => Icon(
              Icons.grass_rounded,
              size: size,
              color: color ?? context.tintFg,
            ),
      ),
    );
  }
}

const _categoryImagePaths = <String, String>{
  'ZAKAT': 'assets/icons/kakulator-zakat.jpg',
  'QURBAN': 'assets/icons/kalkulator-qurban.jpg',
  'FITRAH': 'assets/icons/zakat fitrah.jpg',
  'MAAL': 'assets/icons/zakat-mal.jpg',
};

class CategoryImage extends StatelessWidget {
  const CategoryImage({
    super.key,
    required this.type,
    this.width = 56,
    this.height = 48,
  });

  final String type;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final path = _categoryImagePaths[type.toUpperCase()];
    final placeholder = ColoredBox(
      color: context.tintBg,
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          size: height * 0.45,
          color: context.tintFg,
        ),
      ),
    );

    return Semantics(
      label: type,
      child: ClipOval(
        child: SizedBox(
          width: width,
          height: height,
          child:
              path == null
                  ? placeholder
                  : Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => placeholder,
                  ),
        ),
      ),
    );
  }
}

class _AnimalHeadPainter extends CustomPainter {
  const _AnimalHeadPainter({required this.animal, required this.color});
  final String animal;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    final outline =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.07
          ..strokeCap = StrokeCap.round;

    switch (animal.toLowerCase()) {
      case 'kambing':
        canvas.drawOval(
          Rect.fromCenter(center: c, width: s * 0.58, height: s * 0.68),
          paint,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx - s * 0.25, c.dy - s * 0.20),
            width: s * 0.30,
            height: s * 0.42,
          ),
          0.2,
          2.4,
          false,
          outline,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx + s * 0.25, c.dy - s * 0.20),
            width: s * 0.30,
            height: s * 0.42,
          ),
          0.5,
          -2.4,
          false,
          outline,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(c.dx, c.dy + s * 0.18),
              width: s * 0.26,
              height: s * 0.18,
            ),
            Radius.circular(s * 0.08),
          ),
          Paint()..color = color.withValues(alpha: 0.35),
        );
        break;
      case 'domba':
        canvas.drawCircle(
          Offset(c.dx - s * 0.18, c.dy - s * 0.06),
          s * 0.22,
          paint,
        );
        canvas.drawCircle(
          Offset(c.dx + s * 0.18, c.dy - s * 0.06),
          s * 0.22,
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy + s * 0.08),
            width: s * 0.48,
            height: s * 0.56,
          ),
          Paint()..color = color.withValues(alpha: 0.72),
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx - s * 0.22, c.dy - s * 0.10),
            width: s * 0.28,
            height: s * 0.38,
          ),
          0.4,
          2.8,
          false,
          outline,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx + s * 0.22, c.dy - s * 0.10),
            width: s * 0.28,
            height: s * 0.38,
          ),
          0.4,
          -2.8,
          false,
          outline,
        );
        break;
      case 'sapi':
        canvas.drawOval(
          Rect.fromCenter(center: c, width: s * 0.62, height: s * 0.66),
          paint,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx - s * 0.31, c.dy - s * 0.20),
            width: s * 0.40,
            height: s * 0.34,
          ),
          -0.2,
          -2.8,
          false,
          outline,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx + s * 0.31, c.dy - s * 0.20),
            width: s * 0.40,
            height: s * 0.34,
          ),
          0.2,
          2.8,
          false,
          outline,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy + s * 0.20),
            width: s * 0.34,
            height: s * 0.18,
          ),
          Paint()..color = color.withValues(alpha: 0.38),
        );
        break;
      case 'kerbau':
        canvas.drawOval(
          Rect.fromCenter(center: c, width: s * 0.68, height: s * 0.62),
          paint,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx - s * 0.34, c.dy - s * 0.10),
            width: s * 0.46,
            height: s * 0.56,
          ),
          -1.1,
          2.7,
          false,
          outline,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(c.dx + s * 0.34, c.dy - s * 0.10),
            width: s * 0.46,
            height: s * 0.56,
          ),
          1.1,
          -2.7,
          false,
          outline,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx, c.dy + s * 0.20),
            width: s * 0.38,
            height: s * 0.16,
          ),
          Paint()..color = color.withValues(alpha: 0.38),
        );
        break;
      default:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(c.dx + s * 0.05, c.dy - s * 0.10),
            width: s * 0.48,
            height: s * 0.56,
          ),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - s * 0.18, c.dy - s * 0.20)
            ..quadraticBezierTo(
              c.dx - s * 0.38,
              c.dy - s * 0.38,
              c.dx - s * 0.42,
              c.dy - s * 0.12,
            )
            ..close(),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - s * 0.24, c.dy - s * 0.08)
            ..quadraticBezierTo(
              c.dx - s * 0.44,
              c.dy + s * 0.10,
              c.dx - s * 0.20,
              c.dy + s * 0.28,
            )
            ..quadraticBezierTo(
              c.dx - s * 0.10,
              c.dy + s * 0.06,
              c.dx - s * 0.24,
              c.dy - s * 0.08,
            )
            ..close(),
          Paint()..color = color.withValues(alpha: 0.72),
        );
        canvas.drawCircle(
          Offset(c.dx + s * 0.16, c.dy - s * 0.12),
          s * 0.035,
          Paint()..color = Colors.white,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimalHeadPainter old) =>
      old.animal != animal || old.color != color;
}

class _EmptyPainter extends CustomPainter {
  _EmptyPainter({required this.ring});
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()..color = ring;
    canvas.drawCircle(c, 58, p..color = ring.withValues(alpha: 0.6));
    canvas.drawCircle(c, 46, p..color = ring);
  }

  @override
  bool shouldRepaint(covariant _EmptyPainter old) => old.ring != ring;
}

/// Placeholder loading dengan efek shimmer.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = Rad.sm,
  });
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final base =
        context.isDark ? AppColors.darkSurfaceHigh : AppColors.slate[100];
    return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(radius),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color:
              context.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.8),
        );
  }
}

/// Skeleton berbentuk kartu riwayat.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.all(0), child: _SkeletonBody());
  }
}

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody();

  @override
  Widget build(BuildContext context) {
    return AppCard2(
      child: const Row(
        children: [
          AppSkeleton(width: 44, height: 44, radius: 14),
          HGap(Sp.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 120, height: 14),
                VGap(Sp.s2),
                AppSkeleton(width: 80, height: 12),
              ],
            ),
          ),
          AppSkeleton(width: 70, height: 18),
        ],
      ),
    );
  }
}

/// Pembungkus kartu sederhana untuk skeleton (tanpa interaksi).
class AppCard2 extends StatelessWidget {
  const AppCard2({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.s4),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: Rad.lgR,
        border: Border.all(color: context.borderColor),
      ),
      child: child,
    );
  }
}
