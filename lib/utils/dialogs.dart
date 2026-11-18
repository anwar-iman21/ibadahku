import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Dialog konfirmasi bergaya konsisten. Mengembalikan true jika dikonfirmasi.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya',
  bool danger = false,
}) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.surfaceCard,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: Rad.xlR),
      title: Text(title, style: AppText.xl.semibold),
      content: Text(message, style: AppText.sm.c(ctx.mutedText)),
      actionsPadding: const EdgeInsets.fromLTRB(Sp.s4, 0, Sp.s4, Sp.s4),
      actions: [
        AppButton(
          label: 'Batal',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        AppButton(
          label: confirmLabel,
          variant: danger ? AppButtonVariant.danger : AppButtonVariant.primary,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return res ?? false;
}
