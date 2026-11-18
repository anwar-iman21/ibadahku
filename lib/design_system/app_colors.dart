import 'package:flutter/material.dart';

/// Skala warna ala Tailwind: AppColors.green[600], AppColors.gold[400], dst.
class ColorScale {
  const ColorScale(this.c50, this.c100, this.c200, this.c300, this.c400,
      this.c500, this.c600, this.c700, this.c800, this.c900);

  final Color c50, c100, c200, c300, c400, c500, c600, c700, c800, c900;

  Color operator [](int shade) {
    switch (shade) {
      case 50:
        return c50;
      case 100:
        return c100;
      case 200:
        return c200;
      case 300:
        return c300;
      case 400:
        return c400;
      case 500:
        return c500;
      case 600:
        return c600;
      case 700:
        return c700;
      case 800:
        return c800;
      case 900:
        return c900;
    }
    throw ArgumentError('Shade tidak valid: $shade');
  }
}

class AppColors {
  AppColors._();

  /// Hijau (warna primer)
  static const green = ColorScale(
    Color(0xFFE8F5E9),
    Color(0xFFC8E6C9),
    Color(0xFFA5D6A7),
    Color(0xFF81C784),
    Color(0xFF66BB6A),
    Color(0xFF43A047),
    Color(0xFF2E7D32),
    Color(0xFF1B5E20),
    Color(0xFF144A19),
    Color(0xFF0D3311),
  );

  /// Cream (permukaan hangat)
  static const cream = ColorScale(
    Color(0xFFFFFDF8),
    Color(0xFFFFF8E7),
    Color(0xFFFAF7F0),
    Color(0xFFF1EBDA),
    Color(0xFFE6DCC3),
    Color(0xFFD6C9A6),
    Color(0xFFB8A980),
    Color(0xFF8F8362),
    Color(0xFF665D45),
    Color(0xFF3D3828),
  );

  /// Emas (aksen kecil)
  static const gold = ColorScale(
    Color(0xFFFFF9E1),
    Color(0xFFFCEFB8),
    Color(0xFFF6E08A),
    Color(0xFFEBCB5A),
    Color(0xFFDDB63A),
    Color(0xFFC9A227),
    Color(0xFFA8841B),
    Color(0xFF856815),
    Color(0xFF624C10),
    Color(0xFF40320A),
  );

  /// Slate kehijauan (teks & border)
  static const slate = ColorScale(
    Color(0xFFF6F8F6),
    Color(0xFFEDF1ED),
    Color(0xFFDDE4DD),
    Color(0xFFC3CEC4),
    Color(0xFF98A89A),
    Color(0xFF6E8070),
    Color(0xFF55665A),
    Color(0xFF3F4E43),
    Color(0xFF2B372F),
    Color(0xFF1C2B1E),
  );

  // Semantik
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFD97706);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF0284C7);

  static const textPrimary = Color(0xFF1C2B1E);

  // Dark mode: hijau gelap elegan (bukan hitam polos)
  static const darkBg = Color(0xFF0C1A12);
  static const darkSurface = Color(0xFF13251A);
  static const darkSurfaceHigh = Color(0xFF1B3325);
  static const darkBorder = Color(0xFF284633);
  static const darkText = Color(0xFFE8F1E9);

  /// Warna untuk grafik (harmonis dengan tema)
  static const chart = <Color>[
    Color(0xFF2E7D32),
    Color(0xFFC9A227),
    Color(0xFF66BB6A),
    Color(0xFF0284C7),
    Color(0xFF8F8362),
    Color(0xFF144A19),
    Color(0xFFEBCB5A),
    Color(0xFF0F766E),
    Color(0xFF98A89A),
    Color(0xFFA5D6A7),
  ];
}
