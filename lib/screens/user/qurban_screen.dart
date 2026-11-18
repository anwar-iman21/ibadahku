import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../logic/qurban.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../utils/fmt.dart';
import '../../utils/input_formatters.dart';
import '../../utils/share_util.dart';

class QurbanScreen extends StatefulWidget {
  const QurbanScreen({super.key});

  @override
  State<QurbanScreen> createState() => _QurbanScreenState();
}

class _QurbanScreenState extends State<QurbanScreen> {
  Hewan _hewan = Hewan.kambing;
  int _peserta = 1;
  // Perkiraan Idul Adha 1448 H (10 Dzulhijjah) = 17 Mei 2027. Cek kalender resmi.
  DateTime _target = DateTime(2027, 5, 17);
  final _harga = TextEditingController();
  final _transport = TextEditingController();
  final _potong = TextEditingController();
  final _admin = TextEditingController();
  final _lain = TextEditingController();
  final _tabungan = TextEditingController();
  bool _umur = false, _sehat = false, _cacat = false;
  bool _saving = false;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;
      _setHarga();
    }
  }

  double _hargaAdmin(Prices p, Hewan h) {
    switch (h) {
      case Hewan.kambing:
        return p.kambing;
      case Hewan.domba:
        return p.domba;
      case Hewan.sapi:
        return p.sapi;
      case Hewan.kerbau:
        return p.kerbau;
      case Hewan.unta:
        return p.unta;
    }
  }

  void _setHarga() {
    final p = context.read<PricesProvider>().prices;
    _harga.text = Fmt.groupDigits(_hargaAdmin(p, _hewan));
  }

  @override
  void dispose() {
    for (final c in [_harga, _transport, _potong, _admin, _lain, _tabungan]) {
      c.dispose();
    }
    super.dispose();
  }

  QurbanInput _input() => QurbanInput(
    hewan: _hewan,
    hargaHewan: Fmt.parseRupiah(_harga.text),
    transport: Fmt.parseRupiah(_transport.text),
    pemotongan: Fmt.parseRupiah(_potong.text),
    administrasi: Fmt.parseRupiah(_admin.text),
    lainnya: Fmt.parseRupiah(_lain.text),
    jumlahPeserta: _peserta,
    tabunganSaatIni: Fmt.parseRupiah(_tabungan.text),
    targetTanggal: _target,
  );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate:
          _target.isAfter(now) ? _target : now.add(const Duration(days: 1)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      helpText: 'Target tanggal Idul Adha',
    );
    if (d != null) setState(() => _target = d);
  }

  Future<void> _save(QurbanResult r) async {
    setState(() => _saving = true);
    final err = await context.read<HistoryProvider>().add(
      'QURBAN',
      r.toInputMap(),
      r.toResultMap(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    context.snack(err ?? 'Tersimpan ke riwayat', error: err != null);
  }

  Widget _money(TextEditingController c, String label, {String? helper}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: Sp.s3),
        child: AppTextField(
          label: label,
          helper: helper,
          hint: '0',
          prefixText: 'Rp ',
          controller: c,
          keyboardType: TextInputType.number,
          inputFormatters: rupiahFormatters,
          onChanged: (_) => setState(() {}),
        ),
      );

  @override
  Widget build(BuildContext context) {
    context.watch<PricesProvider>();
    final input = _input();
    final error = QurbanCalculator.validate(input);
    final result = error == null ? QurbanCalculator.hitung(input) : null;

    final form = _form(context);
    final panel = _panel(context, result, error);

    return AppPage(
      title: 'Kalkulator Qurban',
      subtitle: 'Rencanakan biaya, patungan, dan tabungan qurban Anda.',
      children: [
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth >= 860) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: form),
                  const HGap(Sp.s6),
                  SizedBox(width: 380, child: panel),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [form, const VGap(Sp.s5), panel],
            );
          },
        ),
        AppCard(
          color: context.creamSurface,
          child: Text(
            'Estimasi berat daging dan batas umur hewan bersifat perkiraan. '
            'Rujuk panduan resmi (Kemenag/MUI) dan penyedia hewan qurban terpercaya.',
            style: AppText.xs.c(context.mutedText),
          ),
        ),
      ],
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Pilih hewan'),
              const VGap(Sp.s3),
              Wrap(
                spacing: Sp.s2,
                runSpacing: Sp.s2,
                children: [
                  for (final h in Hewan.values)
                    AppChip(
                      label: h.label,
                      selected: _hewan == h,
                      onTap:
                          () => setState(() {
                            _hewan = h;
                            if (_peserta > h.maxPeserta)
                              _peserta = h.maxPeserta;
                            _umur = _sehat = _cacat = false;
                            _setHarga();
                          }),
                    ),
                ],
              ),
              const VGap(Sp.s4),
              _money(_harga, 'Harga hewan'),
              Text('Biaya tambahan', style: AppText.sm.semibold),
              const VGap(Sp.s2),
              _money(_transport, 'Transport'),
              _money(_potong, 'Pemotongan'),
              _money(_admin, 'Administrasi'),
              _money(_lain, 'Lainnya'),
            ],
          ),
        ),
        const VGap(Sp.s4),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Patungan'),
              const VGap(Sp.s3),
              if (_hewan.maxPeserta == 1)
                Text('${_hewan.label} untuk 1 orang.', style: AppText.sm)
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Kurangi peserta',
                      onPressed:
                          _peserta > 1
                              ? () => setState(() => _peserta--)
                              : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    SizedBox(
                      width: 120,
                      child: Column(
                        children: [
                          Text('$_peserta', style: AppText.xl3.bold),
                          Text(
                            'peserta (maks. ${_hewan.maxPeserta})',
                            textAlign: TextAlign.center,
                            style: AppText.xs.c(context.mutedText),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Tambah peserta',
                      onPressed:
                          _peserta < _hewan.maxPeserta
                              ? () => setState(() => _peserta++)
                              : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const VGap(Sp.s4),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Rencana tabungan'),
              const VGap(Sp.s3),
              _money(_tabungan, 'Tabungan saat ini'),
              Text('Target tanggal Idul Adha', style: AppText.sm.medium),
              const VGap(Sp.s2),
              AppButton(
                label: Fmt.dateLong(_target),
                icon: Icons.event_rounded,
                variant: AppButtonVariant.secondary,
                expand: true,
                onPressed: _pickDate,
              ),
              const VGap(Sp.s1),
              Text(
                'Default: perkiraan Idul Adha 1448 H. Sesuaikan dengan ketetapan pemerintah.',
                style: AppText.xs.c(context.mutedText),
              ),
            ],
          ),
        ),
        const VGap(Sp.s4),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Syarat hewan'),
              const VGap(Sp.s2),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _umur,
                onChanged: (v) => setState(() => _umur = v ?? false),
                title: Text(_hewan.umurMinimal, style: AppText.sm),
                subtitle: const Text('Umur minimal terpenuhi'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _sehat,
                onChanged: (v) => setState(() => _sehat = v ?? false),
                title: Text('Hewan sehat', style: AppText.sm),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _cacat,
                onChanged: (v) => setState(() => _cacat = v ?? false),
                title: Text(
                  'Tidak cacat (pincang, buta, sangat kurus, sakit parah)',
                  style: AppText.sm,
                ),
              ),
              if (_umur && _sehat && _cacat)
                const AppBadge(
                  'Hewan memenuhi syarat',
                  kind: BadgeKind.success,
                  icon: Icons.verified_rounded,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel(BuildContext context, QurbanResult? r, String? error) {
    if (r == null) {
      return AppCard(
        color: context.creamSurface,
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.warning),
            const HGap(Sp.s3),
            Expanded(child: Text(error ?? '', style: AppText.sm)),
          ],
        ),
      );
    }
    Widget row(String l, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(l, style: AppText.sm.c(context.mutedText))),
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
      shadow: Shd.md,
      padding: const EdgeInsets.all(Sp.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Iuran per orang', style: AppText.sm.c(context.mutedText)),
          CountUpText(
            value: r.iuranPerOrang,
            format: Fmt.rupiah,
            style: AppText.xl3.bold.c(context.goldText),
          ),
          const VGap(Sp.s2),
          AppBadge(
            r.status,
            kind: r.sudahCukup ? BadgeKind.success : BadgeKind.info,
          ),
          const VGap(Sp.s4),
          AnimatedProgress(value: r.progress),
          const VGap(Sp.s1),
          Text(
            '${(r.progress * 100).toStringAsFixed(0)}% dari iuran tercapai',
            style: AppText.xs.c(context.mutedText),
          ),
          const VGap(Sp.s3),
          const Divider(height: 1),
          const VGap(Sp.s2),
          row('Total biaya', Fmt.rupiah(r.totalBiaya)),
          row('Biaya tambahan', Fmt.rupiah(r.biayaTambahan)),
          row('Kekurangan', Fmt.rupiah(r.kekurangan)),
          row('Sisa waktu', '${r.hariTersisa} hari'),
          if (!r.sudahCukup) ...[
            row('Tabung / bulan', Fmt.rupiah(r.perBulan)),
            row('Tabung / minggu', Fmt.rupiah(r.perMinggu)),
            row('Tabung / hari', Fmt.rupiah(r.perHari)),
          ],
          const VGap(Sp.s3),
          const Divider(height: 1),
          const VGap(Sp.s3),
          Text(
            'Estimasi pembagian daging (per peserta)',
            style: AppText.sm.semibold,
          ),
          const VGap(Sp.s1),
          row(
            'Total daging',
            '${Fmt.number(r.dagingPerPesertaKg, maxDecimals: 1)} kg',
          ),
          row(
            '1/3 untuk sendiri',
            '${Fmt.number(r.dagingSendiriKg, maxDecimals: 1)} kg',
          ),
          row(
            '1/3 untuk kerabat',
            '${Fmt.number(r.dagingKerabatKg, maxDecimals: 1)} kg',
          ),
          row(
            '1/3 untuk fakir miskin',
            '${Fmt.number(r.dagingFakirKg, maxDecimals: 1)} kg',
          ),
          const VGap(Sp.s4),
          AppButton(
            label: 'Simpan ke riwayat',
            icon: Icons.bookmark_add_rounded,
            loading: _saving,
            expand: true,
            onPressed: () => _save(r),
          ),
          const VGap(Sp.s2),
          AppButton(
            label: 'Bagikan hasil',
            icon: Icons.ios_share_rounded,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () => shareText(context, r.ringkasan),
          ),
        ],
      ),
    );
  }
}
