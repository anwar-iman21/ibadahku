import 'package:flutter/material.dart';

import '../design_system/design_system.dart';
import '../models/models.dart';
import '../utils/fmt.dart';
import '../utils/share_util.dart';

Widget historyIcon(String type, {double size = 22}) {
  return CategoryImage(type: type, width: size * 1.25, height: size);
}

BadgeKind historyBadgeKind(HistoryEntry e) {
  if (e.type == 'MAAL') {
    return e.status == 'Wajib zakat' ? BadgeKind.success : BadgeKind.warning;
  }
  if (e.type == 'QURBAN') {
    return e.status == 'Dana cukup' ? BadgeKind.success : BadgeKind.info;
  }
  return BadgeKind.gold;
}

/// Kartu satu item riwayat.
class HistoryTile extends StatelessWidget {
  const HistoryTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.trailing,
  });
  final HistoryEntry entry;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          historyIcon(entry.type, size: 44),
          const HGap(Sp.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.base.semibold,
                ),
                Text(
                  Fmt.dateTime(entry.createdAt),
                  style: AppText.xs.c(context.mutedText),
                ),
                const VGap(6),
                if (entry.status.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppBadge(
                      entry.status,
                      kind: historyBadgeKind(entry),
                    ),
                  ),
              ],
            ),
          ),
          const HGap(Sp.s2),
          Flexible(
            child: Text(
              entry.nominalText,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.base.semibold.c(context.goldText),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Detail lengkap riwayat dalam bottom sheet.
Future<void> showHistoryDetail(
  BuildContext context,
  HistoryEntry e, {
  Future<void> Function()? onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder:
        (ctx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder:
              (ctx, controller) => _DetailBody(
                entry: e,
                controller: controller,
                onDelete: onDelete,
              ),
        ),
  );
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.entry,
    required this.controller,
    this.onDelete,
  });
  final HistoryEntry entry;
  final ScrollController controller;
  final Future<void> Function()? onDelete;

  static const _hidden = {'nominal', 'nominalText', 'status', 'ringkasan'};

  Widget _rows(BuildContext context, String title, Map<String, dynamic> data) {
    final rows = <Widget>[];
    data.forEach((k, v) {
      if (_hidden.contains(k) || v == null) return;
      var label = k;
      String value;
      if (k.endsWith('(Rp)') && v is num) {
        label = k.replaceAll(' (Rp)', '');
        value = Fmt.rupiah(v);
      } else if (v is num) {
        value = Fmt.number(v);
      } else {
        value = v.toString();
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Text(label, style: AppText.sm.c(context.mutedText)),
              ),
              const HGap(Sp.s3),
              Expanded(
                flex: 4,
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: AppText.sm.medium,
                ),
              ),
            ],
          ),
        ),
      );
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppText.base.semibold),
        const VGap(Sp.s2),
        ...rows,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(Sp.s5, 0, Sp.s5, Sp.s6),
      children: [
        Row(
          children: [
            historyIcon(entry.type, size: 52),
            const HGap(Sp.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.title, style: AppText.xl.semibold),
                  Text(
                    Fmt.dateTime(entry.createdAt),
                    style: AppText.xs.c(context.mutedText),
                  ),
                ],
              ),
            ),
          ],
        ),
        const VGap(Sp.s4),
        AppCard(
          color: context.creamSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hasil utama', style: AppText.xs.c(context.mutedText)),
              const VGap(2),
              Text(
                entry.nominalText,
                style: AppText.xl2.bold.c(context.goldText),
              ),
              const VGap(Sp.s2),
              if (entry.status.isNotEmpty)
                AppBadge(entry.status, kind: historyBadgeKind(entry)),
            ],
          ),
        ),
        const VGap(Sp.s5),
        _rows(context, 'Data yang dimasukkan', entry.input),
        const Divider(height: Sp.s8),
        _rows(context, 'Rincian hasil', entry.result),
        const VGap(Sp.s6),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Bagikan',
                icon: Icons.ios_share_rounded,
                onPressed: () => shareText(context, entry.ringkasan),
              ),
            ),
            if (onDelete != null) ...[
              const HGap(Sp.s3),
              Expanded(
                child: AppButton(
                  label: 'Hapus',
                  icon: Icons.delete_outline_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onDelete!();
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
