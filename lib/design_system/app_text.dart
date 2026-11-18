import 'package:flutter/material.dart';

/// Skala tipografi ala Tailwind. Font Poppins di-set lewat ThemeData.
class AppText {
  AppText._();
  static const String font = 'Poppins';

  static const xs = TextStyle(fontSize: 12, height: 1.4);
  static const sm = TextStyle(fontSize: 14, height: 1.45);
  static const base = TextStyle(fontSize: 16, height: 1.5);
  static const lg = TextStyle(fontSize: 18, height: 1.45, fontWeight: FontWeight.w500);
  static const xl = TextStyle(fontSize: 20, height: 1.35, fontWeight: FontWeight.w600);
  static const xl2 = TextStyle(fontSize: 24, height: 1.3, fontWeight: FontWeight.w600);
  static const xl3 = TextStyle(fontSize: 30, height: 1.25, fontWeight: FontWeight.w700);
  static const xl4 = TextStyle(fontSize: 36, height: 1.2, fontWeight: FontWeight.w700);
}
