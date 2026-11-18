import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';

/// Kerangka Login/Register: 2 panel di layar lebar, 1 kolom di HP.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
  });
  final String title;
  final String subtitle;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 900;
          final card = AppCard(
            padding: const EdgeInsets.all(Sp.s6),
            shadow: Shd.lg,
            radius: Rad.xlR,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(title, style: AppText.xl2.semibold),
                const VGap(Sp.s1),
                Text(subtitle, style: AppText.sm.c(context.mutedText)),
                const VGap(Sp.s5),
                form,
              ],
            ),
          );

          if (wide) {
            return Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(Sp.s8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: card,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HeroHeader(
                  padding: const EdgeInsets.fromLTRB(
                    Sp.s6,
                    Sp.s8,
                    Sp.s6,
                    Sp.s4,
                  ),
                  child: Column(
                    children: [
                      const LogoMark(size: 72),
                      const VGap(Sp.s3),
                      Text('IbadahKu', style: AppText.xl3.c(Colors.white)),
                      Text(
                        'Hitung zakat & qurban dengan tenang',
                        textAlign: TextAlign.center,
                        style: AppText.sm.c(
                          Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Sp.s4,
                    Sp.s2,
                    Sp.s4,
                    Sp.s8,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: card,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    Widget feature(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: Sp.s4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: Rad.mdR,
            ),
            child: Icon(icon, color: AppColors.gold[200], size: 22),
          ),
          const HGap(Sp.s3),
          Expanded(
            child: Text(
              text,
              style: AppText.base.c(Colors.white.withValues(alpha: 0.92)),
            ),
          ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(gradient: heroGradient(context)),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: IslamicPatternPainter(
                color: Colors.white.withValues(alpha: 0.07),
                tile: 72,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Sp.s12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LogoMark(size: 88),
                    const VGap(Sp.s6),
                    Text('IbadahKu', style: AppText.xl4.c(Colors.white)),
                    const VGap(Sp.s2),
                    Text(
                      'Teman hitung ibadah finansial Anda.',
                      style: AppText.lg.c(Colors.white.withValues(alpha: 0.9)),
                    ),
                    const VGap(Sp.s8),
                    feature(
                      Icons.calculate_rounded,
                      'Kalkulator zakat fitrah & maal yang akurat',
                    ),
                    feature(
                      Icons.pets_rounded,
                      'Rencana qurban lengkap dengan patungan',
                    ),
                    feature(
                      Icons.cloud_done_rounded,
                      'Riwayat tersimpan aman di cloud',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner error inline.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sp.s3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.10),
        borderRadius: Rad.mdR,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.error,
          ),
          const HGap(Sp.s2),
          Expanded(
            child: Text(
              message,
              style: AppText.sm.c(
                context.isDark ? const Color(0xFFFCA5A5) : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
