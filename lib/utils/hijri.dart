/// Konversi Masehi -> Hijriah (algoritma Kuwaiti, dihitung lokal).
/// Hasil bisa selisih +-1 hari dari kalender resmi pemerintah.
class HijriDate {
  const HijriDate(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;

  static const _namaBulan = [
    'Muharram', 'Safar', "Rabiul Awal", "Rabiul Akhir", 'Jumadil Awal',
    'Jumadil Akhir', 'Rajab', "Sya'ban", 'Ramadhan', 'Syawal',
    "Dzulqa'dah", 'Dzulhijjah'
  ];

  String get monthName => _namaBulan[(month - 1).clamp(0, 11).toInt()];

  @override
  String toString() => '$day $monthName $year H';

  static HijriDate fromGregorian(DateTime date) {
    final a = (14 - date.month) ~/ 12;
    final y2 = date.year + 4800 - a;
    final m2 = date.month + 12 * a - 3;
    final jd = date.day +
        (153 * m2 + 2) ~/ 5 +
        365 * y2 +
        y2 ~/ 4 -
        y2 ~/ 100 +
        y2 ~/ 400 -
        32045;

    var l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return HijriDate(year, month, day);
  }
}
