import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text.dart';
import 'breakpoints.dart';
import 'extensions.dart';

/// Pola geometris islami (bintang 8 sudut) digambar tanpa gambar eksternal.
class IslamicPatternPainter extends CustomPainter {
  IslamicPatternPainter({required this.color, this.tile = 64, this.stroke = 1});
  final Color color;
  final double tile;
  final double stroke;

  void _star(Canvas canvas, Offset c, double outer, double inner, Paint p) {
    final path = Path();
    for (var i = 0; i < 16; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 8;
      final pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke;
    final cols = (size.width / tile).ceil() + 1;
    final rows = (size.height / tile).ceil() + 1;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final dx = (r.isOdd ? tile / 2 : 0) + c * tile;
        final center = Offset(dx, r * tile);
        _star(canvas, center, tile * 0.40, tile * 0.22, p);
        canvas.drawCircle(center, tile * 0.07, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter old) =>
      old.color != color || old.tile != tile || old.stroke != stroke;
}

/// Gradasi hijau untuk header / panel.
LinearGradient heroGradient(BuildContext context) => LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors:
      context.isDark
          ? const [Color(0xFF0F2A1A), Color(0xFF1B4D2E)]
          : [AppColors.green[800], AppColors.green[600]],
);

/// Header hero: gradasi hijau dengan pola islami dan ujung bawah lurus.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.contentMax,
    this.padding = const EdgeInsets.fromLTRB(Sp.s5, Sp.s4, Sp.s5, Sp.s6),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: heroGradient(context)),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(padding: padding, child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo IbadahKu: bulan sabit + bintang di dalam rounded-square.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo IbadahKu',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _LogoPainter()),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(s * 0.28),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green[500], AppColors.green[800]],
        ).createShader(Rect.fromLTWH(0, 0, s, s)),
    );
    canvas.save();
    canvas.clipRRect(rect);
    canvas.drawCircle(
      Offset(s * 0.85, s * 0.1),
      s * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );
    canvas.restore();

    // bulan sabit
    final c = Offset(s * 0.47, s * 0.52);
    final r = s * 0.27;
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: c, radius: r)),
      Path()..addOval(
        Rect.fromCircle(
          center: Offset(c.dx + r * 0.42, c.dy - r * 0.12),
          radius: r * 0.84,
        ),
      ),
    );
    canvas.drawPath(moon, Paint()..color = AppColors.cream[100]);

    // bintang kecil emas
    final sc = Offset(s * 0.66, s * 0.38);
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rr = i.isEven ? s * 0.085 : s * 0.036;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = Offset(sc.dx + rr * math.cos(a), sc.dy + rr * math.sin(a));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = AppColors.gold[300]);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Judul halaman di dalam HeroHeader (back button, judul, subjudul, aksi).
class HeroTitle extends StatelessWidget {
  const HeroTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.extra,
  });
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (onBack != null) ...[
              IconButton(
                tooltip: 'Kembali',
                onPressed: onBack,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const HGap(Sp.s3),
            ],
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.xl2
                    .c(Colors.white)
                    .copyWith(decoration: TextDecoration.none),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        if (subtitle != null) ...[
          const VGap(Sp.s1),
          Text(
            subtitle!,
            style: AppText.sm
                .c(Colors.white.withValues(alpha: 0.82))
                .copyWith(decoration: TextDecoration.none),
          ),
        ],
        if (extra != null) ...[const VGap(Sp.s3), extra!],
      ],
    );
  }
}
