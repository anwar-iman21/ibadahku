import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../models/models.dart';
import '../../providers/data_providers.dart';
import '../../services/firestore_service.dart';
import '../../utils/dialogs.dart';
import '../../utils/error_text.dart';
import '../../utils/fmt.dart';
import '../../utils/input_formatters.dart';
import '../user/settings_screen.dart';

// ======================= DASHBOARD =======================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<AdminStats> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<FirestoreService>().stats();
  }

  void _refresh() =>
      setState(() => _future = context.read<FirestoreService>().stats());

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Dashboard Admin',
      subtitle: 'Ringkasan penggunaan IbadahKu.',
      trailing: IconButton(
        tooltip: 'Muat ulang',
        onPressed: _refresh,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.16),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.refresh_rounded),
      ),
      children: [
        FutureBuilder<AdminStats>(
          future: _future,
          builder: (context, snap) {
            if (snap.hasError) {
              return AppCard(
                child: AppEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Gagal memuat statistik',
                  message: ErrorText.generic(snap.error!),
                  actionLabel: 'Coba lagi',
                  onAction: _refresh,
                ),
              );
            }
            if (!snap.hasData) {
              return const ResponsiveGrid(
                minTileWidth: 220,
                maxColumns: 4,
                children: [
                  SkeletonCard(),
                  SkeletonCard(),
                  SkeletonCard(),
                  SkeletonCard(),
                ],
              );
            }
            final s = snap.data!;
            return ResponsiveGrid(
              minTileWidth: 220,
              maxColumns: 4,
              children: [
                _Stat(Icons.group_rounded, 'Total pengguna', s.users),
                _Stat(Icons.calculate_rounded, 'Total perhitungan', s.history),
                _Stat.custom(
                  const CategoryImage(type: 'FITRAH', width: 52, height: 44),
                  'Zakat Fitrah',
                  s.fitrah,
                ),
                _Stat.custom(
                  const CategoryImage(type: 'MAAL', width: 52, height: 44),
                  'Zakat Maal',
                  s.maal,
                ),
                _Stat.custom(
                  const CategoryImage(type: 'QURBAN', width: 52, height: 44),
                  'Qurban',
                  s.qurban,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label, this.value) : leading = null;
  const _Stat.custom(this.leading, this.label, this.value) : icon = null;

  final IconData? icon;
  final Widget? leading;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      shadow: Shd.md,
      child: Row(
        children: [
          leading != null ? leading! : IconBadge(icon!, size: 52),
          const HGap(Sp.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CountUpText(
                  value: value.toDouble(),
                  format: (v) => Fmt.number(v.round(), maxDecimals: 0),
                  style: AppText.xl2.bold,
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.xs.c(context.mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= HARGA =======================
class AdminPricesScreen extends StatefulWidget {
  const AdminPricesScreen({super.key});

  @override
  State<AdminPricesScreen> createState() => _AdminPricesScreenState();
}

class _AdminPricesScreenState extends State<AdminPricesScreen> {
  static const _fields = <(String, String, String)>[
    ('goldPerGram', 'Emas per gram', 'Logam mulia'),
    ('silverPerGram', 'Perak per gram', 'Logam mulia'),
    ('riceMedium', 'Beras medium per kg', 'Beras'),
    ('ricePremium', 'Beras premium per kg', 'Beras'),
    ('riceSuper', 'Beras super per kg', 'Beras'),
    ('kambing', 'Kambing', 'Hewan qurban'),
    ('domba', 'Domba', 'Hewan qurban'),
    ('sapi', 'Sapi', 'Hewan qurban'),
    ('kerbau', 'Kerbau', 'Hewan qurban'),
    ('unta', 'Unta', 'Hewan qurban'),
  ];

  final _c = {for (final f in _fields) f.$1: TextEditingController()};
  final _form = GlobalKey<FormState>();
  bool _loaded = false;
  bool _saving = false;

  void _fill(Prices p) {
    final m = p.toMap();
    for (final f in _fields) {
      _c[f.$1]!.text = Fmt.groupDigits(m[f.$1] as num);
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Prices _read() {
    double v(String k) => Fmt.parseRupiah(_c[k]!.text);
    return Prices(
      goldPerGram: v('goldPerGram'),
      silverPerGram: v('silverPerGram'),
      riceMedium: v('riceMedium'),
      ricePremium: v('ricePremium'),
      riceSuper: v('riceSuper'),
      kambing: v('kambing'),
      domba: v('domba'),
      sapi: v('sapi'),
      kerbau: v('kerbau'),
      unta: v('unta'),
    );
  }

  Future<void> _save({bool seed = false}) async {
    if (!seed && !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    String? err;
    try {
      await context
          .read<FirestoreService>()
          .savePrices(seed ? Prices.defaults() : _read())
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      err = ErrorText.generic(e);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (seed && err == null) _fill(Prices.defaults());
    context.snack(
      err ?? (seed ? 'Data awal dibuat' : 'Harga disimpan'),
      error: err != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<PricesProvider>();
    if (!_loaded && !pp.loading) {
      _loaded = true;
      _fill(pp.prices);
    }

    final groups = <String, List<(String, String, String)>>{};
    for (final f in _fields) {
      groups.putIfAbsent(f.$3, () => []).add(f);
    }

    return AppPage(
      title: 'Kelola Harga',
      subtitle: 'Harga ini dipakai semua pengguna secara otomatis.',
      children: [
        if (!pp.loading && pp.usingDefaults)
          AppCard(
            color: context.creamSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data harga belum dibuat', style: AppText.base.semibold),
                const VGap(Sp.s1),
                Text(
                  'Buat data awal dengan nilai bawaan, lalu sesuaikan harganya.',
                  style: AppText.sm.c(context.mutedText),
                ),
                const VGap(Sp.s3),
                AppButton(
                  label: 'Buat data awal',
                  icon: Icons.add_circle_outline_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: _saving ? null : () => _save(seed: true),
                ),
              ],
            ),
          ),
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final g in groups.entries) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSectionHeader(g.key),
                      const VGap(Sp.s3),
                      ResponsiveGrid(
                        minTileWidth: 260,
                        maxColumns: 3,
                        children: [
                          for (final f in g.value)
                            AppTextField(
                              label: f.$2,
                              prefixText: 'Rp ',
                              controller: _c[f.$1],
                              keyboardType: TextInputType.number,
                              inputFormatters: rupiahFormatters,
                              validator:
                                  (v) =>
                                      Fmt.parseRupiah(v ?? '') > 0
                                          ? null
                                          : 'Harus lebih dari 0',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const VGap(Sp.s4),
              ],
              if (pp.prices.updatedAt != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Sp.s3),
                  child: Text(
                    'Terakhir diperbarui: ${Fmt.dateTime(pp.prices.updatedAt!)}',
                    style: AppText.xs.c(context.mutedText),
                  ),
                ),
              AppButton(
                label: 'Simpan harga',
                icon: Icons.save_rounded,
                loading: _saving,
                expand: true,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================= KONTEN =======================
class AdminContentScreen extends StatelessWidget {
  const AdminContentScreen({super.key});

  Future<void> _edit(BuildContext context, [Tip? tip]) async {
    final fs = context.read<FirestoreService>();
    final judul = TextEditingController(text: tip?.judul ?? '');
    final isi = TextEditingController(text: tip?.isi ?? '');
    var aktif = tip?.aktif ?? true;
    final form = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setS) => AlertDialog(
                  backgroundColor: ctx.surfaceCard,
                  surfaceTintColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: Rad.xlR),
                  title: Text(
                    tip == null ? 'Tambah tips' : 'Ubah tips',
                    style: AppText.xl.semibold,
                  ),
                  content: SizedBox(
                    width: 460,
                    child: SingleChildScrollView(
                      child: Form(
                        key: form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppTextField(
                              label: 'Judul',
                              controller: judul,
                              validator:
                                  (v) =>
                                      (v ?? '').trim().isEmpty
                                          ? 'Judul wajib diisi'
                                          : null,
                            ),
                            const VGap(Sp.s3),
                            AppTextField(
                              label: 'Isi',
                              controller: isi,
                              maxLines: 5,
                              validator:
                                  (v) =>
                                      (v ?? '').trim().isEmpty
                                          ? 'Isi wajib diisi'
                                          : null,
                            ),
                            const VGap(Sp.s2),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Tampilkan di Beranda'),
                              value: aktif,
                              onChanged: (v) => setS(() => aktif = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    AppButton(
                      label: 'Batal',
                      variant: AppButtonVariant.ghost,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                    AppButton(
                      label: 'Simpan',
                      onPressed: () {
                        if (form.currentState!.validate())
                          Navigator.of(ctx).pop(true);
                      },
                    ),
                  ],
                ),
          ),
    );

    if (saved == true) {
      String? err;
      try {
        if (tip == null) {
          await fs
              .addTip(judul.text.trim(), isi.text.trim(), aktif)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw 'timeout',
              );
        } else {
          await fs
              .updateTip(tip.id, judul.text.trim(), isi.text.trim(), aktif)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw 'timeout',
              );
        }
      } catch (e) {
        err = ErrorText.generic(e);
      }
      if (context.mounted) {
        context.snack(err ?? 'Tips disimpan', error: err != null);
      }
    }
    judul.dispose();
    isi.dispose();
  }

  Future<void> _delete(BuildContext context, Tip t) async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus tips?',
      message: '"${t.judul}" akan dihapus permanen.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    String? err;
    try {
      await context.read<FirestoreService>().deleteTip(t.id);
    } catch (e) {
      err = ErrorText.generic(e);
    }
    if (context.mounted) {
      context.snack(err ?? 'Tips dihapus', error: err != null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tips = context.watch<TipsProvider>();
    return AppPage(
      title: 'Kelola Konten',
      subtitle: 'Tips & info ibadah yang tampil di Beranda pengguna.',
      trailing: IconButton(
        tooltip: 'Tambah tips',
        onPressed: () => _edit(context),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.gold[400],
          foregroundColor: AppColors.gold[900],
        ),
        icon: const Icon(Icons.add_rounded),
      ),
      children: [
        if (tips.loading)
          const ResponsiveGrid(children: [SkeletonCard(), SkeletonCard()])
        else if (tips.tips.isEmpty)
          AppCard(
            child: AppEmptyState(
              icon: Icons.article_outlined,
              title: 'Belum ada tips',
              message: 'Tambahkan tips ibadah pertama Anda.',
              actionLabel: 'Tambah tips',
              onAction: () => _edit(context),
            ),
          )
        else
          ResponsiveGrid(
            minTileWidth: 340,
            children: [
              for (final t in tips.tips)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(t.judul, style: AppText.base.semibold),
                          ),
                          AppBadge(
                            t.aktif ? 'Aktif' : 'Nonaktif',
                            kind:
                                t.aktif ? BadgeKind.success : BadgeKind.neutral,
                          ),
                        ],
                      ),
                      const VGap(Sp.s2),
                      Text(
                        t.isi,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sm.c(context.mutedText),
                      ),
                      const VGap(Sp.s2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Ubah',
                            onPressed: () => _edit(context, t),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            onPressed: () => _delete(context, t),
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// ======================= PENGGUNA =======================
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _q = '';
  late final Stream<List<AppUser>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<FirestoreService>().usersStream();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Daftar Pengguna',
      subtitle: 'Hanya baca. Peran admin diatur lewat Firebase Console.',
      children: [
        AppTextField(
          hint: 'Cari username atau nama...',
          icon: Icons.search_rounded,
          onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
        ),
        StreamBuilder<List<AppUser>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return AppCard(
                child: AppEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Gagal memuat pengguna',
                  message: ErrorText.generic(snap.error!),
                ),
              );
            }
            if (!snap.hasData) {
              return const ResponsiveGrid(
                children: [SkeletonCard(), SkeletonCard(), SkeletonCard()],
              );
            }
            final list =
                snap.data!
                    .where(
                      (u) =>
                          _q.isEmpty ||
                          u.username.toLowerCase().contains(_q) ||
                          u.namaLengkap.toLowerCase().contains(_q),
                    )
                    .toList();
            if (list.isEmpty) {
              return const AppCard(
                child: AppEmptyState(
                  icon: Icons.person_search_rounded,
                  title: 'Pengguna tidak ditemukan',
                ),
              );
            }
            return ResponsiveGrid(
              children: [
                for (final u in list)
                  AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: context.tintBg,
                          child: Text(
                            u.username.isEmpty
                                ? '?'
                                : u.username[0].toUpperCase(),
                            style: AppText.base.semibold.c(context.tintFg),
                          ),
                        ),
                        const HGap(Sp.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '@${u.username}',
                                overflow: TextOverflow.ellipsis,
                                style: AppText.base.semibold,
                              ),
                              Text(
                                u.createdAt != null
                                    ? 'Daftar ${Fmt.date(u.createdAt!)}'
                                    : 'Baru mendaftar',
                                style: AppText.xs.c(context.mutedText),
                              ),
                            ],
                          ),
                        ),
                        AppBadge(
                          u.isAdmin ? 'Admin' : 'User',
                          kind: u.isAdmin ? BadgeKind.gold : BadgeKind.success,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ======================= AKUN =======================
class AdminAccountScreen extends StatelessWidget {
  const AdminAccountScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SettingsScreen(title: 'Akun Admin');
}
