import 'package:flutter/material.dart';

/// Ikon domba (vektor, tanpa gambar). Warna mengikuti tema navigasi.
/// filled = false -> outline (belum dipilih), true -> solid (dipilih).
class SheepIcon extends StatelessWidget {
  const SheepIcon({super.key, this.size = 24, this.filled = false, this.color});

  final double size;
  final bool filled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SheepPainter(c, filled)),
    );
  }
}

class _SheepPainter extends CustomPainter {
  _SheepPainter(this.color, this.filled);

  final Color color;
  final bool filled;

  Path _circle(double x, double y, double r) =>
      Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);

    // Bulu (gabungan lingkaran)
    const wool = [
      [6.6, 10.6, 3.3],
      [10.0, 8.8, 3.6],
      [13.6, 9.2, 3.4],
      [15.2, 12.6, 3.0],
      [8.0, 13.8, 3.0],
      [11.6, 14.0, 3.2],
    ];
    Path shape = _circle(wool[0][0], wool[0][1], wool[0][2]);
    for (final w in wool.skip(1)) {
      shape = Path.combine(PathOperation.union, shape, _circle(w[0], w[1], w[2]));
    }

    // Kaki
    for (final x in const [7.0, 10.0, 13.2, 15.8]) {
      final leg = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 14, 1.7, 7.5),
          const Radius.circular(0.85),
        ));
      shape = Path.combine(PathOperation.union, shape, leg);
    }

    // Kepala + telinga
    final head = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(17, 8.6, 21.8, 15.6),
        const Radius.circular(2.4),
      ));
    final ear = Path()..addOval(const Rect.fromLTRB(16.2, 8, 18.6, 11));
    shape = Path.combine(PathOperation.union, shape, head);
    shape = Path.combine(PathOperation.union, shape, ear);

    final eye = _circle(20.1, 11.1, 0.55);

    if (filled) {
      // Solid, mata dilubangi
      final solid = Path.combine(PathOperation.difference, shape, eye);
      canvas.drawPath(solid, Paint()..color = color);
    } else {
      // Outline, mata titik
      canvas.drawPath(
        shape,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.drawPath(eye, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_SheepPainter old) =>
      old.color != color || old.filled != filled;
}