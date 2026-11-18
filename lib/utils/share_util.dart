import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../design_system/design_system.dart';

/// Bagikan teks; jika gagal (mis. di desktop) salin ke clipboard.
Future<void> shareText(BuildContext context, String text,
    {String subject = 'IbadahKu'}) async {
  try {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      context.snack('Hasil disalin ke clipboard');
    }
  }
}
