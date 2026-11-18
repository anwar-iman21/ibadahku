import 'package:intl/intl.dart';

/// Format angka, Rupiah, dan tanggal (bahasa Indonesia).
/// Tanggal diformat manual agar tidak perlu inisialisasi locale intl.
class Fmt {
  Fmt._();

  static final NumberFormat _rp = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static String rupiah(num v) => _rp.format(v.isFinite ? v : 0);

  /// Angka dengan pemisah ribuan titik & desimal koma, mis. 1.250,5
  static String number(num v, {int maxDecimals = 2}) {
    final f = NumberFormat.decimalPattern('id_ID')
      ..maximumFractionDigits = maxDecimals;
    return f.format(v.isFinite ? v : 0);
  }

  /// Hanya pemisah ribuan (untuk isi field Rupiah): 2300000 -> "2.300.000"
  static String groupDigits(num v) =>
      NumberFormat.decimalPattern('id_ID').format(v.round());

  /// Baca angka Rupiah dari teks ber-format ("2.300.000" -> 2300000).
  static double parseRupiah(String s) =>
      double.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  /// Baca angka desimal; menerima koma maupun titik ("2,5" / "2.5").
  static double parseDecimal(String s) {
    var t = s.trim();
    if (t.isEmpty) return 0;
    if (t.contains(',') && t.contains('.')) {
      // "1.250,5" -> titik = ribuan, koma = desimal
      t = t.replaceAll('.', '').replaceAll(',', '.');
    } else {
      t = t.replaceAll(',', '.');
    }
    return double.tryParse(t) ?? 0;
  }

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  static const _hari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  static String date(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1].substring(0, 3)} ${d.year}';

  static String dateLong(DateTime d) =>
      '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';

  static String dateTime(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date(d)}, ${two(d.hour)}:${two(d.minute)}';
  }
}
