import 'package:flutter_test/flutter_test.dart';
import 'package:ibadahku/logic/qurban.dart';
import 'package:ibadahku/logic/zakat_fitrah.dart';
import 'package:ibadahku/logic/zakat_maal.dart';
import 'package:ibadahku/utils/fmt.dart';
import 'package:ibadahku/utils/hijri.dart';
import 'package:ibadahku/utils/validators.dart';

void main() {
  group('Zakat Fitrah', () {
    test('4 jiwa x 2,5 kg x Rp15.000', () {
      final r = ZakatFitrahCalculator.hitung(const FitrahInput(
        jumlahJiwa: 4,
        takaran: Takaran.beras25,
        jenisBeras: JenisBeras.medium,
        hargaPerKg: 15000,
        metode: MetodeBayar.uang,
      ));
      expect(r.perJiwaUang, 37500);
      expect(r.totalKg, 10);
      expect(r.totalUang, 150000);
    });

    test('takaran liter', () {
      final r = ZakatFitrahCalculator.hitung(const FitrahInput(
        jumlahJiwa: 4,
        takaran: Takaran.liter35,
        jenisBeras: JenisBeras.custom,
        hargaPerKg: 10000,
        metode: MetodeBayar.beras,
      ));
      expect(r.totalLiter, 14);
      expect(r.totalKg, closeTo(10.8, 1e-9));
    });

    test('daftar anggota: bayi setelah maghrib tidak dihitung', () {
      final n = ZakatFitrahCalculator.hitungJiwa([
        AnggotaKeluarga(kategori: KategoriAnggota.dewasa),
        AnggotaKeluarga(kategori: KategoriAnggota.anak),
        AnggotaKeluarga(kategori: KategoriAnggota.bayiSebelumMaghrib),
        AnggotaKeluarga(kategori: KategoriAnggota.bayiSetelahMaghrib),
      ]);
      expect(n, 3);
    });

    test('validasi', () {
      expect(
        ZakatFitrahCalculator.validate(const FitrahInput(
          jumlahJiwa: 0,
          takaran: Takaran.beras25,
          jenisBeras: JenisBeras.medium,
          hargaPerKg: 10000,
          metode: MetodeBayar.uang,
        )),
        isNotNull,
      );
    });
  });

  group('Zakat Maal', () {
    final now = DateTime(2026, 11, 7);

    test('wajib zakat Hijriah 2,5%', () {
      final r = ZakatMaalCalculator.hitung(
        const MaalInput(hargaEmas: 1000000, uangTunai: 100000000, utang: 10000000),
        now: now,
      );
      expect(r.nisab, 85000000);
      expect(r.bersih, 90000000);
      expect(r.wajib, isTrue);
      expect(r.zakat, closeTo(2250000, 1e-6));
    });

    test('tarif Masehi 2,5775%', () {
      final r = ZakatMaalCalculator.hitung(
        const MaalInput(
            hargaEmas: 1000000,
            uangTunai: 100000000,
            utang: 10000000,
            metode: MetodeTahun.masehi),
        now: now,
      );
      expect(r.zakat, closeTo(2319750, 1e-6));
    });

    test('belum haul -> tidak wajib', () {
      final r = ZakatMaalCalculator.hitung(
        const MaalInput(
            hargaEmas: 1000000, uangTunai: 100000000, haulPenuh: false),
        now: now,
      );
      expect(r.wajib, isFalse);
      expect(r.zakat, 0);
    });

    test('di bawah nisab: kurang & progress', () {
      final r = ZakatMaalCalculator.hitung(
        const MaalInput(hargaEmas: 1000000, uangTunai: 50000000),
        now: now,
      );
      expect(r.wajib, isFalse);
      expect(r.kurangNisab, 35000000);
      expect(r.progress, closeTo(50 / 85, 1e-9));
    });

    test('haul dari tanggal mulai', () {
      MaalInput mk(DateTime d) => MaalInput(
          hargaEmas: 1000000, uangTunai: 100000000, mulaiKepemilikan: d);
      expect(ZakatMaalCalculator.cekHaul(mk(now.subtract(const Duration(days: 400))), now), isTrue);
      expect(ZakatMaalCalculator.cekHaul(mk(now.subtract(const Duration(days: 100))), now), isFalse);
    });

    test('emas dihitung dari gram x harga & kontribusi proporsional', () {
      final r = ZakatMaalCalculator.hitung(
        const MaalInput(hargaEmas: 1000000, emasGram: 100, uangTunai: 100000000),
        now: now,
      );
      expect(r.komponen['Emas'], 100000000);
      expect(r.kontribusi['Emas']! + r.kontribusi['Uang tunai & tabungan']!,
          closeTo(r.zakat, 1e-6));
    });

    test('validasi: tidak ada harta', () {
      expect(ZakatMaalCalculator.validate(const MaalInput(hargaEmas: 1000000)),
          isNotNull);
    });
  });

  group('Qurban', () {
    final now = DateTime(2026, 1, 1);
    final target = DateTime(2026, 4, 11); // 100 hari

    QurbanInput sapi({int peserta = 7, DateTime? t}) => QurbanInput(
          hewan: Hewan.sapi,
          hargaHewan: 21000000,
          transport: 700000,
          pemotongan: 700000,
          jumlahPeserta: peserta,
          tabunganSaatIni: 1000000,
          targetTanggal: t ?? target,
        );

    test('patungan sapi 7 orang & rencana tabungan', () {
      final r = QurbanCalculator.hitung(sapi(), now: now);
      expect(r.totalBiaya, 22400000);
      expect(r.iuranPerOrang, 3200000);
      expect(r.kekurangan, 2200000);
      expect(r.hariTersisa, 100);
      expect(r.perHari, closeTo(22000, 1e-6));
      expect(r.perBulan, closeTo(550000, 1e-6));
      expect(r.perMinggu, closeTo(2200000 / 15, 1e-6));
    });

    test('batas peserta & tanggal', () {
      expect(QurbanCalculator.validate(sapi(peserta: 8), now: now), isNotNull);
      expect(QurbanCalculator.validate(sapi(t: DateTime(2025, 12, 1)), now: now),
          isNotNull);
    });

    test('kambing 1 orang, daging dibagi tiga', () {
      final r = QurbanCalculator.hitung(
        QurbanInput(
            hewan: Hewan.kambing,
            hargaHewan: 3000000,
            targetTanggal: target),
        now: now,
      );
      expect(r.dagingPerPesertaKg, 15);
      expect(r.dagingSendiriKg, 5);
    });
  });

  group('Utilitas', () {
    test('Hijriah', () {
      final a = HijriDate.fromGregorian(DateTime(2024, 3, 11));
      expect([a.year, a.month, a.day], [1445, 9, 1]);
      final b = HijriDate.fromGregorian(DateTime(2027, 5, 17));
      expect([b.year, b.month, b.day], [1448, 12, 10]);
    });

    test('Format', () {
      expect(Fmt.rupiah(1250000), 'Rp 1.250.000');
      expect(Fmt.parseRupiah('2.300.000'), 2300000);
      expect(Fmt.parseDecimal('2,5'), 2.5);
      expect(Fmt.parseDecimal('1.250,5'), 1250.5);
    });

    test('Validator username', () {
      expect(Validators.username('budi.s_1'), isNull);
      expect(Validators.username('Budi'), isNotNull);
      expect(Validators.username('abc'), isNotNull);
    });
  });
}
