import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../logic/zakat_fitrah.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../utils/fmt.dart';
import '../../utils/input_formatters.dart';
import '../../utils/share_util.dart';

class _Member {
  _Member([String nama = '', this.kategori = KategoriAnggota.dewasa])
    : nama = TextEditingController(text: nama);
  final TextEditingController nama;
  KategoriAnggota kategori;
  final Key key = UniqueKey();
}

class ZakatFitrahScreen extends StatefulWidget {
  const ZakatFitrahScreen({super.key});

  @override
  State<ZakatFitrahScreen> createState() => _ZakatFitrahScreenState();
}

class _ZakatFitrahScreenState extends State<ZakatFitrahScreen> {
  bool _modeDaftar = false;
  int _jiwa = 4;
  final List<_Member> _members = [_Member('Saya')];
  Takaran _takaran = Takaran.beras25;
  JenisBeras _jenis = JenisBeras.medium;
  MetodeBayar _metode = MetodeBayar.uang;
  final _hargaCustom = TextEditingController(text: '15.000');
  bool _saving = false;

  @override
  void dispose() {
    _hargaCustom.dispose();
    for (final m in _members) {
      m.nama.dispose();
    }
    super.dispose();
  }

  int get _jiwaEfektif =>
      _modeDaftar
          ? ZakatFitrahCalculator.hitungJiwa(
            _members.map((m) => AnggotaKeluarga(kategori: m.kategori)).toList(),
          )
          : _jiwa;

  double _hargaPerKg(PricesProvider p) {
    switch (_jenis) {
      case JenisBeras.medium:
        return p.prices.riceMedium;
      case JenisBeras.premium:
        return p.prices.ricePremium;
      case JenisBeras.superior:
        return p.prices.riceSuper;
      case JenisBeras.custom:
        return Fmt.parseRupiah(_hargaCustom.text);
    }
  }

  FitrahInput _input(PricesProvider p) => FitrahInput(
    jumlahJiwa: _jiwaEfektif,
    takaran: _takaran,
    jenisBeras: _jenis,
    hargaPerKg: _hargaPerKg(p),
    metode: _metode,
  );

  Future<void> _save(FitrahResult r) async {
    setState(() => _saving = true);
    final err = await context.read<HistoryProvider>().add(
      'FITRAH',
      r.toInputMap(),
      r.toResultMap(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    context.snack(err ?? 'Tersimpan ke riwayat', error: err != null);
  }

  @override
  Widget build(BuildContext context) {
    final prices = context.watch<PricesProvider>();
    final input = _input(prices);
    final error = ZakatFitrahCalculator.validate(input);
    final result = error == null ? ZakatFitrahCalculator.hitung(input) : null;

    final form = _buildForm(context, prices);
    final panel = _ResultPanel(
      result: result,
      error: error,
      saving: _saving,
      onSave: result == null ? null : () => _save(result),
      onShare:
          result == null ? null : () => shareText(context, result.ringkasan),
    );

    return AppPage(
      title: 'Zakat Fitrah',
      subtitle: 'Hitung zakat jiwa untuk Anda dan keluarga.',
      onBack: () => context.go('/zakat'),
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
        const _FitrahInfo(),
      ],
    );
  }

  Widget _buildForm(BuildContext context, PricesProvider prices) {
    final p = prices.prices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- jumlah jiwa ---
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Jumlah jiwa'),
              const VGap(Sp.s3),
              Wrap(
                spacing: Sp.s2,
                runSpacing: Sp.s2,
                children: [
                  AppChip(
                    label: 'Input jumlah',
                    selected: !_modeDaftar,
                    onTap: () => setState(() => _modeDaftar = false),
                  ),
                  AppChip(
                    label: 'Daftar anggota keluarga',
                    selected: _modeDaftar,
                    onTap: () => setState(() => _modeDaftar = true),
                  ),
                ],
              ),
              const VGap(Sp.s4),
              if (!_modeDaftar) _counter(context) else _memberList(context),
            ],
          ),
        ),
        const VGap(Sp.s4),

        // --- takaran ---
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Takaran per jiwa'),
              const VGap(Sp.s3),
              Wrap(
                spacing: Sp.s2,
                runSpacing: Sp.s2,
                children: [
                  for (final t in Takaran.values)
                    AppChip(
                      label: t.label,
                      selected: _takaran == t,
                      onTap: () => setState(() => _takaran = t),
                    ),
                ],
              ),
              const VGap(Sp.s2),
              Text(_takaran.catatan, style: AppText.xs.c(context.mutedText)),
            ],
          ),
        ),
        const VGap(Sp.s4),

        // --- jenis beras ---
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Jenis beras'),
              const VGap(Sp.s3),
              Wrap(
                spacing: Sp.s2,
                runSpacing: Sp.s2,
                children: [
                  for (final j in JenisBeras.values)
                    AppChip(
                      label:
                          j == JenisBeras.custom
                              ? 'Custom'
                              : '${j.label} - ${Fmt.rupiah(_defaultHarga(p, j))}',
                      selected: _jenis == j,
                      onTap: () => setState(() => _jenis = j),
                    ),
                ],
              ),
              if (_jenis == JenisBeras.custom) ...[
                const VGap(Sp.s4),
                AppTextField(
                  label: 'Harga beras per kg',
                  prefixText: 'Rp ',
                  controller: _hargaCustom,
                  keyboardType: TextInputType.number,
                  inputFormatters: rupiahFormatters,
                  onChanged: (_) => setState(() {}),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: Sp.s2),
                  child: Text(
                    'Harga mengikuti pengaturan admin.',
                    style: AppText.xs.c(context.mutedText),
                  ),
                ),
            ],
          ),
        ),
        const VGap(Sp.s4),

        // --- metode bayar ---
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader('Metode pembayaran'),
              const VGap(Sp.s3),
              Wrap(
                spacing: Sp.s2,
                runSpacing: Sp.s2,
                children: [
                  AppChip(
                    label: 'Uang',
                    icon: Icons.payments_rounded,
                    selected: _metode == MetodeBayar.uang,
                    onTap: () => setState(() => _metode = MetodeBayar.uang),
                  ),
                  AppChip(
                    label: 'Beras langsung',
                    leading: RiceIcon(
                      size: 20,
                      color:
                          _metode == MetodeBayar.beras
                              ? Colors.white
                              : context.tintFg,
                    ),
                    selected: _metode == MetodeBayar.beras,
                    onTap: () => setState(() => _metode = MetodeBayar.beras),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _defaultHarga(Prices p, JenisBeras j) {
    switch (j) {
      case JenisBeras.medium:
        return p.riceMedium;
      case JenisBeras.premium:
        return p.ricePremium;
      case JenisBeras.superior:
        return p.riceSuper;
      case JenisBeras.custom:
        return 0;
    }
  }

  Widget _counter(BuildContext context) {
    Widget btn(IconData icon, String tip, VoidCallback? onTap) =>
        IconButton.filledTonal(
          tooltip: tip,
          onPressed: onTap,
          iconSize: 24,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: Icon(icon),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        btn(
          Icons.remove_rounded,
          'Kurangi jiwa',
          _jiwa > 1 ? () => setState(() => _jiwa--) : null,
        ),
        SizedBox(
          width: 110,
          child: Column(
            children: [
              Text('$_jiwa', style: AppText.xl3.bold),
              Text('jiwa', style: AppText.xs.c(context.mutedText)),
            ],
          ),
        ),
        btn(
          Icons.add_rounded,
          'Tambah jiwa',
          _jiwa < 99 ? () => setState(() => _jiwa++) : null,
        ),
      ],
    );
  }

  Widget _memberList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _members.length; i++)
          Padding(
            key: _members[i].key,
            padding: const EdgeInsets.only(bottom: Sp.s3),
            child: Container(
              padding: const EdgeInsets.all(Sp.s3),
              decoration: BoxDecoration(
                color: context.creamSurface,
                borderRadius: Rad.mdR,
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          hint: 'Nama anggota ${i + 1}',
                          icon: Icons.person_outline_rounded,
                          controller: _members[i].nama,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Hapus anggota',
                        onPressed:
                            _members.length > 1
                                ? () => setState(() {
                                  _members.removeAt(i).nama.dispose();
                                })
                                : null,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
                  const VGap(Sp.s2),
                  Wrap(
                    spacing: Sp.s2,
                    runSpacing: Sp.s2,
                    children: [
                      for (final k in KategoriAnggota.values)
                        AppChip(
                          label: k.label,
                          selected: _members[i].kategori == k,
                          onTap: () => setState(() => _members[i].kategori = k),
                        ),
                    ],
                  ),
                  if (!_members[i].kategori.wajib)
                    Padding(
                      padding: const EdgeInsets.only(top: Sp.s2),
                      child: Text(
                        'Tidak dihitung (belum wajib dizakati).',
                        style: AppText.xs.c(AppColors.warning),
                      ),
                    ),
                ],
              ),
            ),
          ),
        AppButton(
          label: 'Tambah anggota',
          icon: Icons.person_add_alt_1_rounded,
          variant: AppButtonVariant.secondary,
          onPressed: () => setState(() => _members.add(_Member())),
        ),
        const VGap(Sp.s3),
        Text(
          'Jiwa yang wajib dizakati: $_jiwaEfektif',
          style: AppText.sm.semibold.c(context.tintFg),
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.result,
    required this.error,
    required this.saving,
    required this.onSave,
    required this.onShare,
  });
  final FitrahResult? result;
  final String? error;
  final bool saving;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final r = result;
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

    final isUang = r.metode == MetodeBayar.uang;
    return AppCard(
      shadow: Shd.md,
      padding: const EdgeInsets.all(Sp.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isUang ? 'Total zakat fitrah (uang)' : 'Total zakat fitrah (beras)',
            style: AppText.sm.c(context.mutedText),
          ),
          const VGap(Sp.s1),
          CountUpText(
            value: isUang ? r.totalUang : (r.totalLiter ?? r.totalKg),
            format:
                (v) =>
                    isUang
                        ? Fmt.rupiah(v)
                        : (r.totalLiter != null
                            ? '${Fmt.number(v)} liter'
                            : '${Fmt.number(v)} kg'),
            style: AppText.xl3.bold.c(context.goldText),
          ),
          const VGap(Sp.s4),
          const Divider(height: 1),
          const VGap(Sp.s3),
          row('Jiwa wajib', '${r.jumlahJiwa} jiwa'),
          row('Beras per jiwa', '${Fmt.number(r.perJiwaKg)} kg'),
          if (r.perJiwaLiter != null)
            row('Volume per jiwa', '${Fmt.number(r.perJiwaLiter!)} liter'),
          row('Uang per jiwa', Fmt.rupiah(r.perJiwaUang)),
          row('Total beras', '${Fmt.number(r.totalKg)} kg'),
          if (r.totalLiter != null)
            row('Total volume', '${Fmt.number(r.totalLiter!)} liter'),
          row('Total uang', Fmt.rupiah(r.totalUang)),
          const VGap(Sp.s5),
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
        ],
      ),
    );
  }
}

class _FitrahInfo extends StatelessWidget {
  const _FitrahInfo();

  @override
  Widget build(BuildContext context) {
    Widget line(String a, String b) => Padding(
      padding: const EdgeInsets.only(bottom: Sp.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(a, style: AppText.sm.semibold.c(context.tintFg)),
          ),
          Expanded(child: Text(b, style: AppText.sm)),
        ],
      ),
    );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            leading: const Icon(Icons.schedule_rounded),
            title: Text('Waktu pembayaran', style: AppText.base.semibold),
            childrenPadding: const EdgeInsets.fromLTRB(Sp.s4, 0, Sp.s4, Sp.s4),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              line('Mubah', 'Sejak awal Ramadhan hingga akhir Ramadhan.'),
              line(
                'Wajib',
                'Sejak terbenam matahari di akhir Ramadhan hingga sebelum salat Idul Fitri.',
              ),
              line(
                'Afdal',
                'Setelah salat Subuh hingga sebelum salat Idul Fitri.',
              ),
              line(
                'Makruh',
                'Setelah salat Id hingga sebelum terbenam matahari di hari raya.',
              ),
              line(
                'Haram',
                'Setelah hari raya Idul Fitri berakhir (tanpa uzur).',
              ),
            ],
          ),
          const Divider(height: 1),
          ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            leading: const Icon(Icons.groups_rounded),
            title: Text(
              'Penerima zakat (8 asnaf)',
              style: AppText.base.semibold,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(Sp.s4, 0, Sp.s4, Sp.s4),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final a in const [
                'Fakir',
                'Miskin',
                'Amil',
                'Muallaf',
                'Riqab (hamba sahaya)',
                'Gharimin (orang berutang)',
                'Fisabilillah',
                'Ibnu sabil (musafir)',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: context.tintFg,
                      ),
                      const HGap(Sp.s2),
                      Expanded(child: Text(a, style: AppText.sm)),
                    ],
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(Sp.s4),
            child: Text(
              'Hasil adalah estimasi. Konsultasikan ke BAZNAS/LAZ resmi untuk ketentuan terbaru.',
              style: AppText.xs.c(context.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}
