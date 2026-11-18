import 'package:flutter/widgets.dart';

/// Skala jarak kelipatan 4 (mirip Tailwind: s4 = 16px).
class Sp {
  Sp._();
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
}

/// Jarak vertikal: `VGap(Sp.s4)`
class VGap extends SizedBox {
  const VGap(double h, {super.key}) : super(height: h);
}

/// Jarak horizontal: `HGap(Sp.s2)`
class HGap extends SizedBox {
  const HGap(double w, {super.key}) : super(width: w);
}
