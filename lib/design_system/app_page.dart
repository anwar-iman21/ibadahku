import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'app_spacing.dart';
import 'breakpoints.dart';
import 'islamic.dart';

/// Kerangka halaman standar: hero header + konten ditengah (max 1200)
/// dengan animasi staggered pada setiap bagian.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.heroExtra,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? heroExtra;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final pad = context.isMobile ? Sp.s4 : Sp.s6;
    return Scrollbar(
      child: SingleChildScrollView(
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroHeader(
              child: HeroTitle(
                title: title,
                subtitle: subtitle,
                onBack: onBack,
                trailing: trailing,
                extra: heroExtra,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Breakpoints.contentMax,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(pad, Sp.s4, pad, Sp.s10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        children[i]
                            .animate(delay: (70 * i).ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.05, end: 0, duration: 380.ms),
                        if (i != children.length - 1) const VGap(Sp.s5),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
