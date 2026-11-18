import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../logic/zakat_maal.dart';
import '../../providers/data_providers.dart';
import '../../utils/fmt.dart';
import '../../utils/input_formatters.dart';
import '../../utils/share_util.dart';
import '../auth/auth_layout.dart' show ErrorBanner;

class ZakatMaalScreen extends StatefulWidget {
  const ZakatMaalScreen({super.key});

  @override
  State<ZakatMaalScreen> createState() => _ZakatMaalScreenState();
}

class _ZakatMaalScreenState extends State<ZakatMaalScreen> {
  static const _stepLabels = ['Dasar', 'Harta', 'Pengurang', 'Haul', 'Hasil'];
  static const _gramKeys = {'emasGram', 'perakGram'};
  static const _keys = [
    'hargaEmas',
    'hargaPerak',
    'uang',
    'deposito',
    'emasGram',
    'perakGram',
    'investasi',
    'piutang',
    'dagang',
    'properti',
    'penghasilan',
    'lainnya',
    'utang',
  ];

  late final Map<String, TextEditingController> _c = {
    for (final k in _keys) k: TextEditingController(),
  };
  int _step = 0;
  MetodeTahun _metode = MetodeTahun.hijriah;
  bool _haulPenuh = true;
  DateTime? _mulai;
  String? _error;
  bool _saving = false;
  bool _priceInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_priceInit) {
      _priceInit = true;
      _applyAdminPrices();
    }
  }

  void _applyAdminPrices() {
    final p = context.read<PricesProvider>().prices;
    _c['hargaEmas']!.text = Fmt.groupDigits(p.goldPerGram);
    _c['hargaPerak']!.text = Fmt.groupDigits(p.silverPerGram);
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  double _v(String k) =>
      _gramKeys.contains(k)
          ? Fmt.parseDecimal(_c[k]!.text)
          : Fmt.parseRupiah(_c[k]!.text);

  MaalInput _input() => MaalInput(
    hargaEmas: _v('hargaEmas'),
    hargaPerak: _v('hargaPerak'),
    metode: _metode,
    uangTunai: _v('uang'),
    deposito: _v('deposito'),
    emasGram: _v('emasGram'),
    perakGram: _v('perakGram'),
    investasi: _v('investasi'),
    piutang: _v('piutang'),
    asetDagang: _v('dagang'),
    properti: _v('properti'),
    penghasilan: _v('penghasilan'),
    lainnya: _v('lainnya'),
    utang: _v('utang'),
    haulPenuh: _haulPenuh,
    mulaiKepemilikan: _mulai,
  );

  void _next() {
    final i = _input();
    String? err;
    if (_step == 0 && !(i.hargaEmas > 0)) {
      err = 'Harga emas per gram harus lebih dari 0';
    } else if (_step == 1) {
      final total = ZakatMaalCalculator.komponenDari(
        i,
      ).values.fold<double>(0, (s, v) => s + v);
      if (i.perakGram > 0 && !(i.hargaPerak > 0)) {
        err = 'Isi harga perak per gram di langkah Dasar';
      } else if (total <= 0) {
        err = 'Isi minimal satu jenis harta';
      }
    } else if (_step == 3) {
      err = ZakatMaalCalculator.validate(i);
    }
    setState(() {
      _error = err;
      if (err == null) _step++;
    });
  }

  void _back() => setState(() {
    _error = null;
    if (_step > 0) _step--;
  });

  Future<void> _save(MaalResult r) async {
    setState(() => _saving = true);
    final err = await context.read<HistoryProvider>().add(
      'MAAL',
      r.toInputMap(),
      r.toResultMap(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    context.snack(err ?? 'Tersimpan ke riwayat', error: err != null);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _mulai ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Tanggal mulai memiliki harta',
    );
    if (d != null) setState(() => _mulai = d);
  }

  @override
  Widget build(BuildContext context) {
    final input = _input();
    final result =
        (_step == 4 && ZakatMaalCalculator.validate(input) == null)
            ? ZakatMaalCalculator.hitung(input)
            : null;

    return AppPage(
      title: 'Zakat Maal',
      subtitle: 'Hitung zakat harta langkah demi langkah.',
      onBack: () => context.go('/zakat'),
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(
            vertical: Sp.s4,
            horizontal: Sp.s3,
          ),
          child: StepIndicator(labels: _stepLabels, current: _step),
        ),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 900;
            if (_step == 4) {
              if (result == null) {
                return const AppCard(
                  child: Text('Data tidak valid. Kembali dan periksa isian.'),
                );
              }
              return _MaalResultView(
                result: result,
                wide: wide,
                saving: _saving,
                onSave: () => _save(result),
                onShare: () => shareText(context, result.ringkasan),
                onRestart:
                    () => setState(() {
                      _step = 0;
                      _error = null;
                    }),
              );
            }
            final form = _formCard(context);
            if (!wide) return form;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: form),
                const HGap(Sp.s6),
                SizedBox(width: 360, child: _LiveSummary(input: input)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _formCard(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Sp.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder:
                (child, anim) => FadeTransition(opacity: anim, child: child),
            child: KeyedSubtree(
              key: ValueKey<int>(_step),
              child: _stepBody(context),
            ),
          ),
          if (_error != null) ...[const VGap(Sp.s4), ErrorBanner(_error!)],
          const VGap(Sp.s5),
          Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: AppButton(
                    label: 'Kembali',
                    icon: Icons.arrow_back_rounded,
                    variant: AppButtonVariant.secondary,
                    onPressed: _back,
                  ),
                ),
              if (_step > 0) const HGap(Sp.s3),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: _step == 3 ? 'Hitung zakat' : 'Lanjut',
                  icon:
                      _step == 3
                          ? Icons.calculate_rounded
                          : Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _money(String key, String label, {String? helper, String? hint}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: Sp.s4),
        child: AppTextField(
          label: label,
          helper: helper,
          hint: hint ?? '0',
          prefixText: 'Rp ',
          controller: _c[key],
          keyboardType: TextInputType.number,
          inputFormatters: rupiahFormatters,
          onChanged: (_) => setState(() => _error = null),
        ),
      );

  Widget _gram(String key, String label, {String? helper}) => Padding(
    padding: const EdgeInsets.only(bottom: Sp.s4),
    child: AppTextField(
      label: label,
      helper: helper,
      hint: '0',
      suffixText: 'gram',
      controller: _c[key],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: decimalFormatters,
      onChanged: (_) => setState(() => _error = null),
    ),
  );

  Widget _title(String t, String s) => Padding(
    padding: const EdgeInsets.only(bottom: Sp.s4),
    child: AppSectionHeader(t, subtitle: s),
  );

  Widget _stepBody(BuildContext context) {
    switch (_step) {
      case 0:
        final nisab = ZakatMaalCalculator.nisabEmasGram * _v('hargaEmas');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title(
              'Dasar perhitungan',
              'Harga acuan emas, perak, dan metode tahun.',
            ),
            _money(
              'hargaEmas',
              'Harga emas per gram',
              helper: 'Boleh diubah sesuai harga yang digunakan.',
            ),
            _money('hargaPerak', 'Harga perak per gram'),
            Text('Perhitungan tahun', style: AppText.sm.medium),
            const VGap(Sp.s2),
            Wrap(
              spacing: Sp.s2,
              runSpacing: Sp.s2,
              children: [
                for (final m in MetodeTahun.values)
                  AppChip(
                    label: m.label,
                    selected: _metode == m,
                    onTap: () => setState(() => _metode = m),
                  ),
              ],
            ),
            const VGap(Sp.s4),
            AppCard(
              color: context.creamSurface,
              border: false,
              child: Row(
                children: [
                  Icon(Icons.flag_rounded, color: context.goldText),
                  const HGap(Sp.s3),
                  Expanded(
                    child: Text(
                      'Nisab = 85 gram x harga emas = ${Fmt.rupiah(nisab)}\n'
                      '(Nisab perak: 595 gram)',
                      style: AppText.sm,
                    ),
                  ),
                ],
              ),
            ),
            const VGap(Sp.s2),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title('Harta yang dimiliki', 'Semua opsional, isi minimal satu.'),
            _money('uang', 'Uang tunai & tabungan'),
            _money('deposito', 'Deposito / giro'),
            _gram(
              'emasGram',
              'Emas',
              helper: 'Dinilai dengan harga emas per gram.',
            ),
            _gram(
              'perakGram',
              'Perak',
              helper: 'Dinilai dengan harga perak per gram.',
            ),
            _money(
              'investasi',
              'Saham, reksa dana, obligasi & kripto',
              helper: 'Nilai pasar saat ini.',
            ),
            _money(
              'piutang',
              'Piutang lancar',
              helper: 'Piutang yang diharapkan kembali.',
            ),
            _money(
              'dagang',
              'Aset perdagangan',
              helper: 'Stok barang, kas usaha, piutang dagang.',
            ),
            _money('properti', 'Properti & kendaraan disewakan/diperdagangkan'),
            _money(
              'penghasilan',
              'Penghasilan terkumpul',
              helper: 'Yang belum pernah dizakati.',
            ),
            _money('lainnya', 'Harta produktif lain'),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title('Pengurang', 'Hanya utang jangka pendek yang dikurangkan.'),
            _money(
              'utang',
              'Utang jatuh tempo',
              helper:
                  'Cicilan, utang dagang, dan tagihan yang jatuh tempo dalam waktu dekat.',
            ),
            AppCard(
              color: context.creamSurface,
              border: false,
              child: Text(
                'Utang jangka panjang (misalnya sisa cicilan rumah bertahun-tahun) '
                'tidak dikurangkan seluruhnya, hanya bagian yang jatuh tempo.',
                style: AppText.sm.c(context.mutedText),
              ),
            ),
          ],
        );
      default:
        final auto =
            _mulai != null
                ? ZakatMaalCalculator.cekHaul(_input(), DateTime.now())
                : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title(
              'Haul (kepemilikan 1 tahun)',
              'Harta wajib dizakati bila sudah dimiliki penuh satu tahun.',
            ),
            Text('Sudah dimiliki penuh 1 tahun?', style: AppText.sm.medium),
            const VGap(Sp.s2),
            Wrap(
              spacing: Sp.s2,
              runSpacing: Sp.s2,
              children: [
                AppChip(
                  label: 'Ya',
                  icon: Icons.check_rounded,
                  selected: _haulPenuh,
                  onTap: () => setState(() => _haulPenuh = true),
                ),
                AppChip(
                  label: 'Belum',
                  icon: Icons.close_rounded,
                  selected: !_haulPenuh,
                  onTap: () => setState(() => _haulPenuh = false),
                ),
              ],
            ),
            const VGap(Sp.s5),
            Text('Tanggal mulai memiliki (opsional)', style: AppText.sm.medium),
            const VGap(Sp.s2),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: _mulai == null ? 'Pilih tanggal' : Fmt.date(_mulai!),
                    icon: Icons.event_rounded,
                    variant: AppButtonVariant.secondary,
                    onPressed: _pickDate,
                  ),
                ),
                if (_mulai != null) ...[
                  const HGap(Sp.s2),
                  IconButton(
                    tooltip: 'Hapus tanggal',
                    onPressed: () => setState(() => _mulai = null),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ],
            ),
            if (auto != null) ...[
              const VGap(Sp.s3),
              AppBadge(
                auto
                    ? 'Haul terpenuhi (>= ${_metode.haulHari} hari)'
                    : 'Haul belum terpenuhi (< ${_metode.haulHari} hari)',
                kind: auto ? BadgeKind.success : BadgeKind.warning,
              ),
              const VGap(Sp.s1),
              Text(
                'Pilihan "Ya/Belum" diabaikan jika tanggal diisi.',
                style: AppText.xs.c(context.mutedText),
              ),
            ],
          ],
        );
    }
  }
}

class _LiveSummary extends StatelessWidget {
  const _LiveSummary({required this.input});
  final MaalInput input;

  @override
  Widget build(BuildContext context) {
    final kotor = ZakatMaalCalculator.komponenDari(
      input,
    ).values.fold<double>(0, (s, v) => s + v);
    final bersih = (kotor - input.utang) < 0 ? 0.0 : kotor - input.utang;
    final nisab = ZakatMaalCalculator.nisabEmasGram * input.hargaEmas;

    Widget row(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(l, style: AppText.sm.c(context.mutedText))),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: AppText.sm.semibold,
            ),
          ),
        ],
      ),
    );

    return AppCard(
      shadow: Shd.md,
      padding: const EdgeInsets.all(Sp.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Ringkasan sementara', style: AppText.base.semibold),
          const VGap(Sp.s3),
          row('Harta kotor', Fmt.rupiah(kotor)),
          row('Pengurang', Fmt.rupiah(input.utang)),
          row('Harta bersih', Fmt.rupiah(bersih)),
          row('Nisab', Fmt.rupiah(nisab)),
          const VGap(Sp.s3),
          AnimatedProgress(value: nisab > 0 ? bersih / nisab : 0),
          const VGap(Sp.s2),
          Text(
            nisab > 0 && bersih >= nisab
                ? 'Harta bersih sudah mencapai nisab.'
                : 'Belum mencapai nisab.',
            style: AppText.xs.c(context.mutedText),
          ),
        ],
      ),
    );
  }
}

class _MaalResultView extends StatelessWidget {
  const _MaalResultView({
    required this.result,
    required this.wide,
    required this.saving,
    required this.onSave,
    required this.onShare,
    required this.onRestart,
  });
  final MaalResult result;
  final bool wide;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _status(context),
        const VGap(Sp.s4),
        _summary(context),
        if (!result.diAtasNisab) ...[
          const VGap(Sp.s4),
          _nisabProgress(context),
        ],
        if (result.wajib) ...[const VGap(Sp.s4), _kontribusi(context)],
      ],
    );
    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _chart(context),
        const VGap(Sp.s4),
        _actions(context),
        const VGap(Sp.s4),
        _dasar(context),
      ],
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: left),
          const HGap(Sp.s6),
          Expanded(flex: 2, child: right),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [left, const VGap(Sp.s4), right],
    );
  }

  Widget _status(BuildContext context) {
    final r = result;
    return AppCard(
      shadow: Shd.md,
      padding: const EdgeInsets.all(Sp.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBadge(
            r.wajib ? 'WAJIB ZAKAT' : 'BELUM WAJIB',
            kind: r.wajib ? BadgeKind.success : BadgeKind.warning,
            icon: r.wajib ? Icons.check_circle_rounded : Icons.info_rounded,
          ),
          const VGap(Sp.s3),
          Text(
            r.wajib ? 'Zakat yang harus dibayar' : 'Zakat saat ini',
            style: AppText.sm.c(context.mutedText),
          ),
          CountUpText(
            value: r.zakat,
            format: Fmt.rupiah,
            style: AppText.xl3.bold.c(context.goldText),
          ),
          const VGap(Sp.s2),
          Text(r.alasan, style: AppText.sm),
          if (r.wajib)
            Padding(
              padding: const EdgeInsets.only(top: Sp.s1),
              child: Text(
                'Tarif ${Fmt.number(r.tarif * 100, maxDecimals: 4)}% x harta bersih',
                style: AppText.xs.c(context.mutedText),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final r = result;
    Widget row(String l, String v, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l,
              style:
                  bold ? AppText.sm.semibold : AppText.sm.c(context.mutedText),
            ),
          ),
          const HGap(Sp.s2),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: AppText.sm.semibold,
            ),
          ),
        ],
      ),
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader('Ringkasan perhitungan'),
          const VGap(Sp.s2),
          row('Total harta kotor', Fmt.rupiah(r.totalKotor)),
          row('Total pengurang', Fmt.rupiah(r.utang)),
          const Divider(height: Sp.s4),
          row('Harta bersih', Fmt.rupiah(r.bersih), bold: true),
          row('Nisab (85 g emas)', Fmt.rupiah(r.nisab)),
          if (r.nisabPerak > 0)
            row('Nisab perak (595 g) - info', Fmt.rupiah(r.nisabPerak)),
          row('Haul', r.haulTerpenuhi ? 'Terpenuhi' : 'Belum terpenuhi'),
          row('Metode tahun', r.input.metode.label),
        ],
      ),
    );
  }

  Widget _nisabProgress(BuildContext context) {
    final r = result;
    return AppCard(
      color: context.creamSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Menuju nisab', style: AppText.base.semibold),
          const VGap(Sp.s3),
          AnimatedProgress(value: r.progress),
          const VGap(Sp.s2),
          Text(
            'Kurang ${Fmt.rupiah(r.kurangNisab)} lagi untuk mencapai nisab '
            '(${(r.progress * 100).toStringAsFixed(0)}% tercapai).',
            style: AppText.sm,
          ),
        ],
      ),
    );
  }

  Widget _kontribusi(BuildContext context) {
    final r = result;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader(
            'Kontribusi tiap kategori',
            subtitle: 'Porsi zakat dari masing-masing harta',
          ),
          const VGap(Sp.s3),
          for (final e in r.kontribusi.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(child: Text(e.key, style: AppText.sm)),
                  const HGap(Sp.s2),
                  Text(
                    Fmt.rupiah(e.value),
                    style: AppText.sm.semibold.c(context.goldText),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chart(BuildContext context) {
    final r = result;
    final entries = r.komponen.entries.where((e) => e.value > 0).toList();
    final segments = <DonutSegment>[
      for (var i = 0; i < entries.length; i++)
        DonutSegment(
          entries[i].key,
          entries[i].value,
          AppColors.chart[i % AppColors.chart.length],
        ),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader('Komposisi harta'),
          const VGap(Sp.s4),
          Center(
            child: DonutChart(
              segments: segments,
              size: 190,
              centerTitle: Fmt.rupiah(r.totalKotor),
              centerSubtitle: 'harta kotor',
            ),
          ),
          const VGap(Sp.s4),
          for (final s in segments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const HGap(Sp.s2),
                  Expanded(
                    child: Text(
                      s.label,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.xs,
                    ),
                  ),
                  Text(
                    '${(s.value / r.totalKotor * 100).toStringAsFixed(1)}%',
                    style: AppText.xs.semibold,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: 'Simpan ke riwayat',
            icon: Icons.bookmark_add_rounded,
            loading: saving,
            expand: true,
            onPressed: onSave,
          ),
          const VGap(Sp.s2),
          AppButton(
            label: 'Bagikan hasil',
            icon: Icons.ios_share_rounded,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: onShare,
          ),
          const VGap(Sp.s2),
          AppButton(
            label: 'Hitung ulang',
            icon: Icons.restart_alt_rounded,
            variant: AppButtonVariant.ghost,
            expand: true,
            onPressed: onRestart,
          ),
        ],
      ),
    );
  }

  Widget _dasar(BuildContext context) {
    return AppCard(
      color: context.creamSurface,
      child: Text(
        'Dasar hukum: QS. At-Taubah: 103 dan QS. Al-Baqarah: 267. Nisab zakat maal setara '
        '85 gram emas dengan kadar 2,5% setelah dimiliki satu tahun (haul).\n\n'
        'Hasil ini adalah estimasi. Konsultasikan ke BAZNAS/LAZ resmi untuk kepastian.',
        style: AppText.xs.c(context.mutedText),
      ),
    );
  }
}
