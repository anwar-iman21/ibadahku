import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text.dart';
import 'extensions.dart';

/// Angka yang menghitung naik (count-up) saat nilai berubah.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });
  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(format(v), style: style),
    );
  }
}

/// Progress bar bergradasi dengan animasi.
class AnimatedProgress extends StatelessWidget {
  const AnimatedProgress({super.key, required this.value, this.height = 10});
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final track = context.isDark ? AppColors.darkSurfaceHigh : AppColors.slate[100];
    return Semantics(
      label: 'Progres ${(v * 100).round()} persen',
      child: ClipRRect(
        borderRadius: Rad.fullR,
        child: Container(
          height: height,
          color: track,
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: v),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, t, _) => FractionallySizedBox(
              widthFactor: t,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: Rad.fullR,
                  gradient: LinearGradient(
                      colors: [AppColors.green[500], AppColors.gold[400]]),
                ),
                child: SizedBox(height: height),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DonutSegment {
  const DonutSegment(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

/// Grafik donat sederhana (CustomPainter, tanpa package tambahan).
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 180,
    this.centerTitle,
    this.centerSubtitle,
  });
  final List<DonutSegment> segments;
  final double size;
  final String? centerTitle;
  final String? centerSubtitle;

  @override
  Widget build(BuildContext context) {
    final track = context.isDark ? AppColors.darkSurfaceHigh : AppColors.slate[100];
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) => CustomPaint(
          painter: _DonutPainter(segments, t, track),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size * 0.2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (centerTitle != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(centerTitle!, style: AppText.lg.semibold),
                    ),
                  if (centerSubtitle != null)
                    Text(centerSubtitle!,
                        textAlign: TextAlign.center,
                        style: AppText.xs.c(context.mutedText)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.segments, this.t, this.track);
  final List<DonutSegment> segments;
  final double t;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.15;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);

    final total = segments.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) return;
    var start = -math.pi / 2;
    const gap = 0.03;
    for (final s in segments) {
      if (s.value <= 0) continue;
      final sweep = (s.value / total) * math.pi * 2 * t;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = s.color;
      final drawSweep = segments.length > 1 ? math.max(0.0, sweep - gap) : sweep;
      canvas.drawArc(rect, start, drawSweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.t != t || old.segments != segments || old.track != track;
}

/// Indikator langkah (stepper kustom).
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.labels, required this.current});
  final List<String> labels;
  final int current;

  @override
  Widget build(BuildContext context) {
    final active = AppColors.green[600];
    final idle = context.borderColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0
                            ? Colors.transparent
                            : (i <= current ? active : idle),
                      ),
                    ),
                    _Dot(index: i, current: current),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == labels.length - 1
                            ? Colors.transparent
                            : (i < current ? active : idle),
                      ),
                    ),
                  ],
                ),
                const VGap(6),
                Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppText.xs.c(i <= current
                      ? (context.isDark ? AppColors.green[200] : AppColors.green[700])
                      : context.mutedText),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.index, required this.current});
  final int index;
  final int current;

  @override
  Widget build(BuildContext context) {
    final done = index < current;
    final isCurrent = index == current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (done || isCurrent) ? AppColors.green[600] : context.surfaceCard,
        border: Border.all(
            color: (done || isCurrent) ? AppColors.green[600] : context.borderColor,
            width: 2),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                    color: AppColors.green[600].withValues(alpha: 0.28),
                    blurRadius: 10,
                    spreadRadius: 2)
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: done
          ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
          : Text('${index + 1}',
              style: AppText.xs.semibold
                  .c(isCurrent ? Colors.white : context.mutedText)),
    );
  }
}

/// Grid adaptif: jumlah kolom menyesuaikan lebar yang tersedia (1/2/3).
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = Sp.s4,
    this.maxColumns = 3,
    this.minTileWidth = 300,
  });
  final List<Widget> children;
  final double spacing;
  final int maxColumns;
  final double minTileWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bc) {
      final w = bc.maxWidth;
      var cols = (w + spacing) ~/ (minTileWidth + spacing);
      cols = math.max(1, math.min(cols, maxColumns));
      final tileW = (w - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final c in children) SizedBox(width: tileW, child: c),
        ],
      );
    });
  }
}
