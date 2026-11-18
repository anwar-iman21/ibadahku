import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../design_system/design_system.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: heroGradient(context)),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: IslamicPatternPainter(
                    color: Colors.white.withValues(alpha: 0.07), tile: 72),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LogoMark(size: 112)
                      .animate()
                      .scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1, 1),
                          duration: 700.ms,
                          curve: Curves.easeOutBack)
                      .fadeIn(duration: 500.ms),
                  const VGap(Sp.s6),
                  Text('IbadahKu', style: AppText.xl4.c(Colors.white))
                      .animate(delay: 350.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),
                  const VGap(Sp.s2),
                  Text(
                    'Hitung zakat & qurban dengan tenang',
                    textAlign: TextAlign.center,
                    style: AppText.sm.c(Colors.white.withValues(alpha: 0.85)),
                  ).animate(delay: 600.ms).fadeIn(duration: 500.ms),
                  const VGap(Sp.s10),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.6, color: Colors.white),
                  ).animate(delay: 900.ms).fadeIn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
