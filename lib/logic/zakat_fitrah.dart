import '../utils/fmt.dart';

/// Takaran zakat fitrah per jiwa.
enum Takaran { beras25, beras27, liter35 }

extension TakaranX on Takaran {
  String get label {
    switch (this) {
      case Takaran.beras25:
        return '2,5 kg beras';
      case Takaran.beras27:
        return '2,7 kg beras';
      case Takaran.liter35:
        return '3,5 liter beras';
    }
  }

  String get catatan {
    switch (this) {
      case Takaran.beras25:
        return 'Standar BAZNAS / Kemenag';
      case Takaran.beras27:
        return 'Pendapat lain (setara 1 sha\')';
      case Takaran.liter35:
        return 'Ukuran volume, setara ± 2,7 kg';
    }
  }

  /// Berat beras per jiwa (kg). Untuk liter dipakai ekuivalen 2,7 kg (asumsi).
  double get kgPerJiwa => this == Takaran.beras25 ? 2.5 : 2.7;

  /// Volume per jiwa (liter) bila takaran berupa liter.
  double? get literPerJiwa => this == Takaran.liter35 ? 3.5 : null;
}

enum JenisBeras { medium, premium, superior, custom }

extension JenisBerasX on JenisBeras {
  String get label {
    switch (this) {
      case JenisBeras.medium:
        return 'Medium';
      case JenisBeras.premium:
        return 'Premium';
      case JenisBeras.superior:
        return 'Super';
      case JenisBeras.custom:
        return 'Custom';
    }
  }
}

enum MetodeBayar { uang, beras }

enum KategoriAnggota { dewasa, anak, bayiSebelumMaghrib, bayiSetelahMaghrib }

extension KategoriAnggotaX on KategoriAnggota {
  String get label {
    switch (this) {
      case KategoriAnggota.dewasa:
        return 'Dewasa';
      case KategoriAnggota.anak:
        return 'Anak';
      case KategoriAnggota.bayiSebelumMaghrib:
        return 'Bayi lahir sebelum maghrib';
      case KategoriAnggota.bayiSetelahMaghrib:
        return 'Bayi lahir setelah maghrib';
    }
  }

  /// Bayi yang lahir setelah maghrib akhir Ramadhan tidak wajib dizakati.
  bool get wajib => this != KategoriAnggota.bayiSetelahMaghrib;
}

class AnggotaKeluarga {
  AnggotaKeluarga({this.nama = '', this.kategori = KategoriAnggota.dewasa});
  String nama;
  KategoriAnggota kategori;
}

class FitrahInput {
  const FitrahInput({
    required this.jumlahJiwa,
    required this.takaran,
    required this.jenisBeras,
    required this.hargaPerKg,
    required this.metode,
  });
  final int jumlahJiwa;
  final Takaran takaran;
  final JenisBeras jenisBeras;
  final double hargaPerKg;
  final MetodeBayar metode;
}

class FitrahResult {
  const FitrahResult({
    required this.jumlahJiwa,
    required this.takaran,
    required this.jenisBeras,
    required this.metode,
    required this.hargaPerKg,
    required this.perJiwaKg,
    required this.perJiwaLiter,
    required this.perJiwaUang,
    required this.totalKg,
    required this.totalLiter,
    required this.totalUang,
  });

  final int jumlahJiwa;
  final Takaran takaran;
  final JenisBeras jenisBeras;
  final MetodeBayar metode;
  final double hargaPerKg;
  final double perJiwaKg;
  final double? perJiwaLiter;
  final double perJiwaUang;
  final double totalKg;
  final double? totalLiter;
  final double totalUang;

  /// Teks nominal utama sesuai metode bayar.
  String get nominalText => metode == MetodeBayar.uang
      ? Fmt.rupiah(totalUang)
      : (totalLiter != null
          ? '${Fmt.number(totalLiter!)} liter beras'
          : '${Fmt.number(totalKg)} kg beras');

  String get ringkasan {
    final b = StringBuffer()
      ..writeln('🕌 Zakat Fitrah - IbadahKu')
      ..writeln('Jumlah jiwa: $jumlahJiwa')
      ..writeln('Takaran: ${takaran.label} per jiwa')
      ..writeln('Jenis beras: ${jenisBeras.label} (${Fmt.rupiah(hargaPerKg)}/kg)')
      ..writeln('Total beras: ${Fmt.number(totalKg)} kg'
          '${totalLiter != null ? ' (${Fmt.number(totalLiter!)} liter)' : ''}')
      ..writeln('Total uang: ${Fmt.rupiah(totalUang)}')
      ..writeln('Dibayar dengan: ${metode == MetodeBayar.uang ? 'Uang' : 'Beras'}')
      ..writeln('\nHasil estimasi. Konsultasikan ke BAZNAS/LAZ resmi.');
    return b.toString();
  }

  Map<String, dynamic> toInputMap() => {
        'Jumlah jiwa': jumlahJiwa,
        'Takaran per jiwa': takaran.label,
        'Jenis beras': jenisBeras.label,
        'Harga beras per kg (Rp)': hargaPerKg,
        'Dibayar dengan': metode == MetodeBayar.uang ? 'Uang' : 'Beras',
      };

  Map<String, dynamic> toResultMap() => {
        'Beras per jiwa (kg)': perJiwaKg,
        'Uang per jiwa (Rp)': perJiwaUang,
        'Total beras (kg)': totalKg,
        if (totalLiter != null) 'Total beras (liter)': totalLiter,
        'Total uang (Rp)': totalUang,
        'nominal': totalUang,
        'nominalText': nominalText,
        'status': 'Wajib',
        'ringkasan': ringkasan,
      };
}

class ZakatFitrahCalculator {
  ZakatFitrahCalculator._();

  /// Jumlah jiwa yang wajib dizakati dari daftar anggota keluarga.
  static int hitungJiwa(List<AnggotaKeluarga> anggota) =>
      anggota.where((a) => a.kategori.wajib).length;

  /// Mengembalikan pesan error, atau null jika valid.
  static String? validate(FitrahInput i) {
    if (i.jumlahJiwa < 1) return 'Jumlah jiwa minimal 1';
    if (!(i.hargaPerKg > 0)) return 'Harga beras harus lebih dari 0';
    return null;
  }

  static FitrahResult hitung(FitrahInput i) {
    final err = validate(i);
    if (err != null) throw ArgumentError(err);
    final perKg = i.takaran.kgPerJiwa;
    final perLiter = i.takaran.literPerJiwa;
    final perUang = perKg * i.hargaPerKg;
    return FitrahResult(
      jumlahJiwa: i.jumlahJiwa,
      takaran: i.takaran,
      jenisBeras: i.jenisBeras,
      metode: i.metode,
      hargaPerKg: i.hargaPerKg,
      perJiwaKg: perKg,
      perJiwaLiter: perLiter,
      perJiwaUang: perUang,
      totalKg: perKg * i.jumlahJiwa,
      totalLiter: perLiter == null ? null : perLiter * i.jumlahJiwa,
      totalUang: perUang * i.jumlahJiwa,
    );
  }
}
