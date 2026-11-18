import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../utils/dialogs.dart';
import '../../utils/share_util.dart';
import '../../widgets/history_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _delete(BuildContext context, HistoryEntry e) async {
    final err = await context.read<HistoryProvider>().delete(e.id);
    if (context.mounted) {
      context.snack(err ?? 'Riwayat dihapus', error: err != null);
    }
  }

  Future<bool> _confirmDelete(BuildContext context, HistoryEntry e) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus riwayat ini?',
      message: '${e.title} akan dihapus permanen dan tidak dapat dikembalikan.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (ok && context.mounted) await _delete(context, e);
    return ok;
  }

  Future<void> _deleteAll(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus semua riwayat?',
      message: 'Semua riwayat perhitungan Anda akan dihapus permanen.',
      confirmLabel: 'Hapus semua',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    final err = await context.read<HistoryProvider>().deleteAll();
    if (context.mounted) {
      context.snack(err ?? 'Semua riwayat dihapus', error: err != null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HistoryProvider>();
    final list = h.filtered;
    final mobile = context.isMobile;

    Widget tile(HistoryEntry e) {
      if (mobile) {
        return Dismissible(
          key: ValueKey(e.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: Sp.s5),
            decoration: const BoxDecoration(
              color: AppColors.error,
              borderRadius: Rad.lgR,
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          confirmDismiss: (_) => _confirmDelete(context, e),
          child: HistoryTile(
            entry: e,
            onTap:
                () => showHistoryDetail(
                  context,
                  e,
                  onDelete: () => _confirmDelete(context, e).then((_) {}),
                ),
          ),
        );
      }
      return HistoryTile(
        entry: e,
        onTap:
            () => showHistoryDetail(
              context,
              e,
              onDelete: () => _confirmDelete(context, e).then((_) {}),
            ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Bagikan',
              onPressed: () => shareText(context, e.ringkasan),
              icon: const Icon(Icons.ios_share_rounded, size: 20),
            ),
            IconButton(
              tooltip: 'Hapus',
              onPressed: () => _confirmDelete(context, e),
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
            ),
          ],
        ),
      );
    }

    final filters = <(String, String?)>[
      ('Semua', null),
      ('Fitrah', 'FITRAH'),
      ('Maal', 'MAAL'),
      ('Qurban', 'QURBAN'),
    ];

    return AppPage(
      title: 'Riwayat',
      subtitle: 'Perhitungan tersimpan di cloud, hanya milik Anda.',
      trailing:
          h.items.isEmpty
              ? null
              : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Hapus semua',
                    onPressed: () => _deleteAll(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.16),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete_sweep_rounded),
                  ),
                ],
              ),
      children: [
        Wrap(
          spacing: Sp.s2,
          runSpacing: Sp.s2,
          children: [
            for (final f in filters)
              AppChip(
                label: f.$1,
                selected: h.filter == f.$2,
                onTap: () => h.setFilter(f.$2),
              ),
          ],
        ),
        if (h.loading)
          const ResponsiveGrid(
            children: [SkeletonCard(), SkeletonCard(), SkeletonCard()],
          )
        else if (h.error != null)
          AppCard(
            child: AppEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Gagal memuat riwayat',
              message: h.error,
            ),
          )
        else if (list.isEmpty)
          AppCard(
            child: AppEmptyState(
              icon: Icons.history_rounded,
              title: 'Belum ada riwayat',
              message:
                  'Simpan hasil perhitungan zakat atau qurban agar muncul di sini.',
              actionLabel: 'Hitung zakat',
              onAction: () => context.go('/zakat'),
            ),
          )
        else
          ResponsiveGrid(children: [for (final e in list) tile(e)]),
      ],
    );
  }
}
