import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_providers.dart';
import '../../utils/fmt.dart';
import '../../utils/hijri.dart';
import '../../widgets/history_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prices = context.watch<PricesProvider>();
    final history = context.watch<HistoryProvider>();
    final tips = context.watch<TipsProvider>();
    final now = DateTime.now();
    final hijri = HijriDate.fromGregorian(now);
    final name = auth.user?.displayName ?? '';

    return AppPage(
      title: 'Assalamualaikum, $name',
      subtitle: 'Semoga ibadah Anda dimudahkan hari ini.',
      heroExtra: Wrap(
        spacing: Sp.s2,
        runSpacing: Sp.s2,
        children: [
          _DateChip(
            icon: Icons.calendar_today_rounded,
            text: Fmt.dateLong(now),
          ),
          _DateChip(icon: Icons.nightlight_round, text: hijri.toString()),
        ],
      ),
      children: [
        _PriceCard(prices: prices),
        ResponsiveGrid(
          maxColumns: 2,
          minTileWidth: 360,
          children: [
            _BigActionCard(
              leading: const CategoryImage(
                type: 'ZAKAT',
                width: 68,
                height: 54,
              ),
              title: 'Kalkulator Zakat',
              subtitle:
                  'Zakat fitrah & zakat maal lengkap dengan nisab dan haul.',
              onTap: () => context.go('/zakat'),
            ),
            _BigActionCard(
              leading: const CategoryImage(
                type: 'QURBAN',
                width: 68,
                height: 54,
              ),
              title: 'Kalkulator Qurban',
              subtitle:
                  'Patungan, rencana tabungan, dan estimasi pembagian daging.',
              onTap: () => context.go('/qurban'),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionHeader(
              'Riwayat terakhir',
              trailing: TextButton(
                onPressed: () => context.go('/riwayat'),
                child: const Text('Lihat semua'),
              ),
            ),
            const VGap(Sp.s3),
            if (history.loading)
              const ResponsiveGrid(children: [SkeletonCard(), SkeletonCard()])
            else if (history.items.isEmpty)
              AppCard(
                child: AppEmptyState(
                  icon: Icons.history_rounded,
                  title: 'Belum ada riwayat',
                  message:
                      'Hasil perhitungan yang Anda simpan akan muncul di sini.',
                  actionLabel: 'Mulai hitung zakat',
                  onAction: () => context.go('/zakat'),
                ),
              )
            else
              ResponsiveGrid(
                children: [
                  for (final e in history.items.take(3))
                    HistoryTile(
                      entry: e,
                      onTap: () => showHistoryDetail(context, e),
                    ),
                ],
              ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSectionHeader('Tips & info ibadah'),
            const VGap(Sp.s3),
            if (tips.loading)
              const ResponsiveGrid(children: [SkeletonCard(), SkeletonCard()])
            else if (tips.active.isEmpty)
              const AppCard(
                child: AppEmptyState(
                  icon: Icons.lightbulb_outline_rounded,
                  title: 'Belum ada tips',
                  message: 'Admin belum menambahkan tips ibadah.',
                ),
              )
            else
              ResponsiveGrid(
                minTileWidth: 340,
                children: [
                  for (final t in tips.active.take(6)) _TipCard(tip: t),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Sp.s3, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: Rad.fullR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gold[200]),
          const HGap(6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppText.xs.medium.c(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.prices});
  final PricesProvider prices;

  @override
  Widget build(BuildContext context) {
    final p = prices.prices;
    final updated = p.updatedAt;

    Widget item(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.xs.c(context.mutedText)),
          const VGap(2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.lg.semibold.c(context.goldText)),
          ),
        ],
      ),
    );

    return AppCard(
      color: context.creamSurface,
      shadow: Shd.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(
                Icons.trending_up_rounded,
                size: 36,
                bg: context.isDark ? AppColors.gold[800] : AppColors.gold[100],
                color: context.goldText,
              ),
              const HGap(Sp.s3),
              Expanded(
                child: Text(
                  'Harga acuan hari ini',
                  style: AppText.base.semibold,
                ),
              ),
              if (prices.usingDefaults && !prices.loading)
                const AppBadge('Nilai awal', kind: BadgeKind.warning),
            ],
          ),
          const VGap(Sp.s4),
          if (prices.loading)
            const Row(
              children: [
                AppSkeleton(width: 100, height: 28),
                HGap(Sp.s6),
                AppSkeleton(width: 100, height: 28),
              ],
            )
          else
            Row(
              children: [
                item('Emas / gram', Fmt.rupiah(p.goldPerGram)),
                const HGap(Sp.s3),
                item('Beras medium / kg', Fmt.rupiah(p.riceMedium)),
              ],
            ),
          const VGap(Sp.s3),
          Text(
            updated != null
                ? 'Diperbarui pada ${Fmt.date(updated)}'
                : 'Diatur oleh admin. Belum ada tanggal pembaruan.',
            style: AppText.xs.c(context.mutedText),
          ),
          if (prices.error != null) ...[
            const VGap(Sp.s2),
            Text(prices.error!, style: AppText.xs.c(AppColors.error)),
          ],
        ],
      ),
    );
  }
}

class _BigActionCard extends StatelessWidget {
  const _BigActionCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      shadow: Shd.md,
      padding: const EdgeInsets.all(Sp.s5),
      child: Row(
        children: [
          leading,
          const HGap(Sp.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.lg.semibold),
                const VGap(2),
                Text(subtitle, style: AppText.sm.c(context.mutedText)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.mutedText),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});
  final Tip tip;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            Icons.lightbulb_outline_rounded,
            size: 40,
            bg: context.isDark ? AppColors.gold[800] : AppColors.gold[100],
            color: context.goldText,
          ),
          const HGap(Sp.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip.judul, style: AppText.base.semibold),
                const VGap(4),
                Text(
                  tip.isi,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sm.c(context.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
