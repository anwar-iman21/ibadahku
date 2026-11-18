import '../utils/fmt.dart';

enum Hewan { kambing, domba, sapi, kerbau, unta }

extension HewanX on Hewan {
  String get label {
    switch (this) {
      case Hewan.kambing:
        return 'Kambing';
      case Hewan.domba:
        return 'Domba';
      case Hewan.sapi:
        return 'Sapi';
      case Hewan.kerbau:
        return 'Kerbau';
      case Hewan.unta:
        return 'Unta';
    }
  }

  /// Maksimal peserta patungan (kambing/domba = 1 orang).
  int get maxPeserta =>
      (this == Hewan.kambing || this == Hewan.domba) ? 1 : 7;

  String get umurMinimal {
    switch (this) {
      case Hewan.kambing:
        return 'Minimal 1 tahun';
      case Hewan.domba:
        return 'Minimal 6 bulan - 1 tahun (sesuai mazhab)';
      case Hewan.sapi:
      case Hewan.kerbau:
        return 'Minimal 2 tahun';
      case Hewan.unta:
        return 'Minimal 5 tahun';
    }
  }

  /// Perkiraan bobot daging bersih (kg) per ekor. ASUMSI, hanya estimasi.
  double get perkiraanDagingKg {
    switch (this) {
      case Hewan.kambing:
        return 15;
      case Hewan.domba:
        return 15;
      case Hewan.sapi:
        return 150;
      case Hewan.kerbau:
        return 160;
      case Hewan.unta:
        return 200;
    }
  }
}

class QurbanInput {
  const QurbanInput({
    required this.hewan,
    required this.hargaHewan,
    this.transport = 0,
    this.pemotongan = 0,
    this.administrasi = 0,
    this.lainnya = 0,
    this.jumlahPeserta = 1,
    this.tabunganSaatIni = 0,
    required this.targetTanggal,
  });

  final Hewan hewan;
  final double hargaHewan;
  final double transport;
  final double pemotongan;
  final double administrasi;
  final double lainnya;
  final int jumlahPeserta;
  final double tabunganSaatIni;
  final DateTime targetTanggal;
}

class QurbanResult {
  const QurbanResult({
    required this.input,
    required this.biayaTambahan,
    required this.totalBiaya,
    required this.iuranPerOrang,
    required this.kekurangan,
    required this.hariTersisa,
    required this.bulanTersisa,
    required this.mingguTersisa,
    required this.perBulan,
    required this.perMinggu,
    required this.perHari,
    required this.progress,
    required this.dagingTotalKg,
    required this.dagingPerPesertaKg,
    required this.dagingSendiriKg,
    required this.dagingKerabatKg,
    required this.dagingFakirKg,
  });

  final QurbanInput input;
  final double biayaTambahan;
  final double totalBiaya;
  final double iuranPerOrang;
  final double kekurangan;
  final int hariTersisa;
  final int bulanTersisa;
  final int mingguTersisa;
  final double perBulan;
  final double perMinggu;
  final double perHari;
  final double progress;
  final double dagingTotalKg;
  final double dagingPerPesertaKg;
  final double dagingSendiriKg;
  final double dagingKerabatKg;
  final double dagingFakirKg;

  bool get sudahCukup => kekurangan <= 0;
  String get status => sudahCukup ? 'Dana cukup' : 'Perlu menabung';
  String get nominalText => Fmt.rupiah(iuranPerOrang);

  String get ringkasan {
    final h = input.hewan;
    final b = StringBuffer()
      ..writeln('🐐 Kalkulator Qurban - IbadahKu')
      ..writeln('Hewan: ${h.label} (${input.jumlahPeserta} peserta)')
      ..writeln('Total biaya: ${Fmt.rupiah(totalBiaya)}')
      ..writeln('Iuran per orang: ${Fmt.rupiah(iuranPerOrang)}')
      ..writeln('Tabungan saat ini: ${Fmt.rupiah(input.tabunganSaatIni)}')
      ..writeln('Target: ${Fmt.date(input.targetTanggal)} ($hariTersisa hari lagi)');
    if (sudahCukup) {
      b.writeln('Alhamdulillah, dana sudah cukup.');
    } else {
      b
        ..writeln('Kekurangan: ${Fmt.rupiah(kekurangan)}')
        ..writeln('Menabung: ${Fmt.rupiah(perBulan)}/bulan atau '
            '${Fmt.rupiah(perMinggu)}/minggu atau ${Fmt.rupiah(perHari)}/hari');
    }
    b
      ..writeln('Estimasi daging per peserta: ${Fmt.number(dagingPerPesertaKg)} kg')
      ..writeln('\nHasil estimasi, bukan fatwa.');
    return b.toString();
  }

  Map<String, dynamic> toInputMap() => {
        'Hewan': input.hewan.label,
        'Harga hewan (Rp)': input.hargaHewan,
        'Biaya tambahan (Rp)': biayaTambahan,
        'Jumlah peserta': input.jumlahPeserta,
        'Tabungan saat ini (Rp)': input.tabunganSaatIni,
        'Target tanggal': Fmt.date(input.targetTanggal),
      };

  Map<String, dynamic> toResultMap() => {
        'Total biaya (Rp)': totalBiaya,
        'Iuran per orang (Rp)': iuranPerOrang,
        'Kekurangan (Rp)': kekurangan,
        'Tabungan per bulan (Rp)': perBulan,
        'Tabungan per minggu (Rp)': perMinggu,
        'Tabungan per hari (Rp)': perHari,
        'Daging per peserta (kg)': dagingPerPesertaKg,
        'nominal': iuranPerOrang,
        'nominalText': nominalText,
        'status': status,
        'ringkasan': ringkasan,
      };
}

class QurbanCalculator {
  QurbanCalculator._();

  static String? validate(QurbanInput i, {DateTime? now}) {
    if (!(i.hargaHewan > 0)) return 'Harga hewan harus lebih dari 0';
    if (i.transport < 0 ||
        i.pemotongan < 0 ||
        i.administrasi < 0 ||
        i.lainnya < 0 ||
        i.tabunganSaatIni < 0) {
      return 'Nilai tidak boleh negatif';
    }
    if (i.jumlahPeserta < 1 || i.jumlahPeserta > i.hewan.maxPeserta) {
      return '${i.hewan.label} maksimal ${i.hewan.maxPeserta} peserta';
    }
    final today = _dateOnly(now ?? DateTime.now());
    if (!_dateOnly(i.targetTanggal).isAfter(today)) {
      return 'Tanggal target harus setelah hari ini';
    }
    return null;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static QurbanResult hitung(QurbanInput i, {DateTime? now}) {
    final err = validate(i, now: now);
    if (err != null) throw ArgumentError(err);

    final today = _dateOnly(now ?? DateTime.now());
    final hari = _dateOnly(i.targetTanggal).difference(today).inDays;
    final bulan = (hari / 30.4375).ceil().clamp(1, 100000).toInt();
    final minggu = (hari / 7).ceil().clamp(1, 100000).toInt();

    final tambahan = i.transport + i.pemotongan + i.administrasi + i.lainnya;
    final total = i.hargaHewan + tambahan;
    final iuran = total / i.jumlahPeserta;
    final kurang = (iuran - i.tabunganSaatIni) < 0 ? 0.0 : iuran - i.tabunganSaatIni;

    final dagingTotal = i.hewan.perkiraanDagingKg;
    final dagingPeserta = dagingTotal / i.jumlahPeserta;
    final sepertiga = dagingPeserta / 3;

    return QurbanResult(
      input: i,
      biayaTambahan: tambahan,
      totalBiaya: total,
      iuranPerOrang: iuran,
      kekurangan: kurang,
      hariTersisa: hari,
      bulanTersisa: bulan,
      mingguTersisa: minggu,
      perBulan: kurang / bulan,
      perMinggu: kurang / minggu,
      perHari: kurang / hari,
      progress: iuran > 0 ? (i.tabunganSaatIni / iuran).clamp(0.0, 1.0).toDouble() : 0,
      dagingTotalKg: dagingTotal,
      dagingPerPesertaKg: dagingPeserta,
      dagingSendiriKg: sepertiga,
      dagingKerabatKg: sepertiga,
      dagingFakirKg: sepertiga,
    );
  }
}
