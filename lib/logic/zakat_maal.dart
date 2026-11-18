import '../utils/fmt.dart';

enum MetodeTahun { hijriah, masehi }

extension MetodeTahunX on MetodeTahun {
  String get label => this == MetodeTahun.hijriah
      ? 'Tahun Hijriah (2,5%)'
      : 'Tahun Masehi (2,5775%)';

  /// Tarif zakat: 2,5% (Hijriah) atau 2,5775% (Masehi, 365/354 x 2,5%).
  double get tarif => this == MetodeTahun.hijriah ? 0.025 : 0.025775;

  /// Lama satu haul dalam hari.
  int get haulHari => this == MetodeTahun.hijriah ? 354 : 365;
}

class MaalInput {
  const MaalInput({
    required this.hargaEmas,
    this.hargaPerak = 0,
    this.metode = MetodeTahun.hijriah,
    this.uangTunai = 0,
    this.deposito = 0,
    this.emasGram = 0,
    this.perakGram = 0,
    this.investasi = 0,
    this.piutang = 0,
    this.asetDagang = 0,
    this.properti = 0,
    this.penghasilan = 0,
    this.lainnya = 0,
    this.utang = 0,
    this.haulPenuh = true,
    this.mulaiKepemilikan,
  });

  final double hargaEmas;
  final double hargaPerak;
  final MetodeTahun metode;
  final double uangTunai;
  final double deposito;
  final double emasGram;
  final double perakGram;
  final double investasi;
  final double piutang;
  final double asetDagang;
  final double properti;
  final double penghasilan;
  final double lainnya;
  final double utang;
  final bool haulPenuh;
  final DateTime? mulaiKepemilikan;
}

class MaalResult {
  const MaalResult({
    required this.input,
    required this.komponen,
    required this.totalKotor,
    required this.utang,
    required this.bersih,
    required this.nisab,
    required this.nisabPerak,
    required this.diAtasNisab,
    required this.haulTerpenuhi,
    required this.wajib,
    required this.zakat,
    required this.kurangNisab,
    required this.progress,
    required this.tarif,
    required this.kontribusi,
    required this.alasan,
  });

  final MaalInput input;
  final Map<String, double> komponen;
  final double totalKotor;
  final double utang;
  final double bersih;
  final double nisab;
  final double nisabPerak;
  final bool diAtasNisab;
  final bool haulTerpenuhi;
  final bool wajib;
  final double zakat;
  final double kurangNisab;
  final double progress;
  final double tarif;
  final Map<String, double> kontribusi;
  final String alasan;

  String get status => wajib ? 'Wajib zakat' : 'Belum wajib';
  String get nominalText => Fmt.rupiah(zakat);

  String get ringkasan {
    final b = StringBuffer()
      ..writeln('🕌 Zakat Maal - IbadahKu')
      ..writeln('Total harta kotor: ${Fmt.rupiah(totalKotor)}')
      ..writeln('Pengurang (utang jangka pendek): ${Fmt.rupiah(utang)}')
      ..writeln('Harta bersih: ${Fmt.rupiah(bersih)}')
      ..writeln('Nisab (85 g emas): ${Fmt.rupiah(nisab)}')
      ..writeln('Status: ${status.toUpperCase()}')
      ..writeln(wajib
          ? 'Zakat yang dibayar: ${Fmt.rupiah(zakat)} (${Fmt.number(tarif * 100, maxDecimals: 4)}%)'
          : 'Keterangan: $alasan')
      ..writeln('\nHasil estimasi. Konsultasikan ke BAZNAS/LAZ resmi.');
    return b.toString();
  }

  Map<String, dynamic> toInputMap() => {
        'Harga emas per gram (Rp)': input.hargaEmas,
        'Harga perak per gram (Rp)': input.hargaPerak,
        'Metode tahun': input.metode.label,
        for (final e in komponen.entries)
          if (e.value > 0) '${e.key} (Rp)': e.value,
        'Utang jatuh tempo (Rp)': input.utang,
        'Sudah 1 tahun (haul)': haulTerpenuhi ? 'Ya' : 'Belum',
      };

  Map<String, dynamic> toResultMap() => {
        'Total harta kotor (Rp)': totalKotor,
        'Pengurang (Rp)': utang,
        'Harta bersih (Rp)': bersih,
        'Nisab (Rp)': nisab,
        'Zakat yang dibayar (Rp)': zakat,
        'Keterangan': alasan,
        'nominal': zakat,
        'nominalText': nominalText,
        'status': status,
        'ringkasan': ringkasan,
      };
}

class ZakatMaalCalculator {
  ZakatMaalCalculator._();

  static const double nisabEmasGram = 85;
  static const double nisabPerakGram = 595;

  /// Nama tiap kategori harta (urutan tampil).
  static const kategori = <String>[
    'Uang tunai & tabungan',
    'Deposito & giro',
    'Emas',
    'Perak',
    'Saham, reksa dana, obligasi & kripto',
    'Piutang lancar',
    'Aset perdagangan',
    'Properti & kendaraan (disewakan/diperdagangkan)',
    'Penghasilan terkumpul',
    'Harta produktif lain',
  ];

  static Map<String, double> komponenDari(MaalInput i) => {
        kategori[0]: i.uangTunai,
        kategori[1]: i.deposito,
        kategori[2]: i.emasGram * i.hargaEmas,
        kategori[3]: i.perakGram * i.hargaPerak,
        kategori[4]: i.investasi,
        kategori[5]: i.piutang,
        kategori[6]: i.asetDagang,
        kategori[7]: i.properti,
        kategori[8]: i.penghasilan,
        kategori[9]: i.lainnya,
      };

  static String? validate(MaalInput i) {
    if (!(i.hargaEmas > 0)) return 'Harga emas per gram harus lebih dari 0';
    final nilai = komponenDari(i).values.toList();
    if (nilai.any((v) => v < 0) || i.utang < 0) {
      return 'Nilai tidak boleh negatif';
    }
    if (i.perakGram > 0 && !(i.hargaPerak > 0)) {
      return 'Isi harga perak per gram untuk menghitung perak';
    }
    if (!nilai.any((v) => v > 0)) return 'Isi minimal satu jenis harta';
    return null;
  }

  static bool cekHaul(MaalInput i, DateTime now) {
    final mulai = i.mulaiKepemilikan;
    if (mulai == null) return i.haulPenuh;
    final a = DateTime(mulai.year, mulai.month, mulai.day);
    final b = DateTime(now.year, now.month, now.day);
    return b.difference(a).inDays >= i.metode.haulHari;
  }

  static MaalResult hitung(MaalInput i, {DateTime? now}) {
    final err = validate(i);
    if (err != null) throw ArgumentError(err);

    final komponen = komponenDari(i);
    final totalKotor = komponen.values.fold<double>(0, (s, v) => s + v);
    final bersih = (totalKotor - i.utang) < 0 ? 0.0 : totalKotor - i.utang;
    final nisab = nisabEmasGram * i.hargaEmas;
    final nisabPerak = i.hargaPerak > 0 ? nisabPerakGram * i.hargaPerak : 0.0;

    final diAtas = bersih >= nisab;
    final haul = cekHaul(i, now ?? DateTime.now());
    final wajib = diAtas && haul;
    final tarif = i.metode.tarif;
    final zakat = wajib ? bersih * tarif : 0.0;

    // Kontribusi per kategori: porsi nilai kategori dari harta kotor x zakat.
    final kontribusi = <String, double>{};
    if (wajib && totalKotor > 0) {
      for (final e in komponen.entries) {
        if (e.value > 0) kontribusi[e.key] = e.value / totalKotor * zakat;
      }
    }

    String alasan;
    if (wajib) {
      alasan = 'Harta bersih mencapai nisab dan sudah dimiliki satu tahun (haul).';
    } else if (!diAtas && !haul) {
      alasan = 'Harta bersih di bawah nisab dan belum mencapai haul.';
    } else if (!diAtas) {
      alasan = 'Harta bersih di bawah nisab.';
    } else {
      alasan = 'Harta belum dimiliki penuh satu tahun (haul).';
    }

    return MaalResult(
      input: i,
      komponen: komponen,
      totalKotor: totalKotor,
      utang: i.utang,
      bersih: bersih,
      nisab: nisab,
      nisabPerak: nisabPerak,
      diAtasNisab: diAtas,
      haulTerpenuhi: haul,
      wajib: wajib,
      zakat: zakat,
      kurangNisab: diAtas ? 0 : nisab - bersih,
      progress: nisab > 0 ? (bersih / nisab).clamp(0.0, 1.0).toDouble() : 0,
      tarif: tarif,
      kontribusi: kontribusi,
      alasan: alasan,
    );
  }
}
