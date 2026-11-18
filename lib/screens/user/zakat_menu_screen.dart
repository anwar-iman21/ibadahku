import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/design_system.dart';

class ZakatMenuScreen extends StatelessWidget {
  const ZakatMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Kalkulator Zakat',
      subtitle: 'Pilih jenis zakat yang ingin Anda hitung.',
      children: [
        ResponsiveGrid(
          maxColumns: 2,
          minTileWidth: 420,
          children: [
            _ZakatCard(
              leading: const CategoryImage(
                type: 'FITRAH',
                width: 64,
                height: 56,
              ),
              title: 'Zakat Fitrah',
              desc:
                  'Zakat jiwa yang dikeluarkan pada bulan Ramadhan, berupa makanan pokok '
                  'atau uang yang senilai.',
              dasar:
                  'Dasar: hadis riwayat Bukhari dan Muslim tentang kewajiban zakat fitrah '
                  'bagi setiap muslim pada akhir Ramadhan.',
              onTap: () => context.go('/zakat/fitrah'),
            ),
            _ZakatCard(
              leading: const CategoryImage(type: 'MAAL', width: 64, height: 56),
              title: 'Zakat Maal',
              desc:
                  'Zakat atas harta (tabungan, emas, perdagangan, investasi, dll) yang '
                  'telah mencapai nisab dan haul.',
              dasar:
                  'Dasar: QS. At-Taubah ayat 103 dan QS. Al-Baqarah ayat 267; ketentuan '
                  'nisab setara 85 gram emas.',
              onTap: () => context.go('/zakat/maal'),
            ),
          ],
        ),
        AppCard(
          color: context.creamSurface,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: context.goldText),
              const HGap(Sp.s3),
              Expanded(
                child: Text(
                  'Hasil perhitungan adalah estimasi. Untuk kepastian hukum dan penyaluran, '
                  'konsultasikan dengan BAZNAS atau LAZ resmi.',
                  style: AppText.sm.c(context.mutedText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZakatCard extends StatelessWidget {
  const _ZakatCard({
    required this.leading,
    required this.title,
    required this.desc,
    required this.dasar,
    required this.onTap,
  });
  final Widget leading;
  final String title;
  final String desc;
  final String dasar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      shadow: Shd.md,
      padding: const EdgeInsets.all(Sp.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              leading,
              const HGap(Sp.s4),
              Expanded(child: Text(title, style: AppText.xl.semibold)),
              Icon(Icons.arrow_forward_rounded, color: context.mutedText),
            ],
          ),
          const VGap(Sp.s4),
          Text(desc, style: AppText.sm),
          const VGap(Sp.s3),
          Text(dasar, style: AppText.xs.c(context.mutedText)),
        ],
      ),
    );
  }
}
