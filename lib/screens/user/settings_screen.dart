import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../providers/auth_provider.dart';
import '../../utils/dialogs.dart';
import '../../utils/validators.dart';

/// Layar Akun / Pengaturan (dipakai User dan Admin).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.title = 'Akun & Pengaturan'});
  final String title;

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Keluar dari akun?',
      message: 'Anda perlu masuk kembali untuk memakai aplikasi.',
      confirmLabel: 'Keluar',
      danger: true,
    );
    if (ok && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  Future<void> _editProfile(BuildContext context, String currentName) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _EditProfileDialog(initialName: currentName),
    );
    if (saved == true && context.mounted) {
      context.snack('Profil berhasil diperbarui');
    }
  }

  Future<void> _changePassword(BuildContext context) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (changed == true && context.mounted) {
      context.snack('Password berhasil diperbarui');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return AppPage(
      title: title,
      subtitle: 'Kelola akun aplikasi.',
      children: [
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: context.tintBg,
                    child: Text(
                      (user?.username.isNotEmpty ?? false)
                          ? user!.username[0].toUpperCase()
                          : '?',
                      style: AppText.xl.semibold.c(context.tintFg),
                    ),
                  ),
                  const HGap(Sp.s4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.lg.semibold,
                        ),
                        Text(
                          '@${user?.username ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sm.c(context.mutedText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const VGap(Sp.s3),
              Row(
                children: [
                  AppBadge(
                    user?.isAdmin == true ? 'Admin' : 'Pengguna',
                    kind:
                        user?.isAdmin == true
                            ? BadgeKind.gold
                            : BadgeKind.success,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed:
                        user == null
                            ? null
                            : () => _editProfile(context, user.namaLengkap),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Ubah profil'),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionHeader('Keamanan akun'),
              const VGap(Sp.s2),
              _SettingsLink(
                icon: Icons.lock_reset_rounded,
                title: 'Ganti password',
                subtitle: 'Verifikasi password sekarang untuk mengubahnya.',
                onTap: () => _changePassword(context),
              ),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppSectionHeader('Panduan & informasi'),
              const VGap(Sp.s2),
              _SettingsLink(
                icon: Icons.menu_book_rounded,
                title: 'Panduan zakat & qurban',
                subtitle: 'Niat dan ringkasan tata cara ibadah.',
                onTap: () => context.push('/panduan'),
              ),
              const Divider(height: Sp.s2),
              _SettingsLink(
                icon: Icons.help_outline_rounded,
                title: 'FAQ & bantuan',
                subtitle: 'Jawaban pertanyaan umum tentang aplikasi.',
                onTap: () => context.push('/bantuan'),
              ),
              const Divider(height: Sp.s2),
              _SettingsLink(
                icon: Icons.privacy_tip_outlined,
                title: 'Kebijakan privasi',
                subtitle: 'Data yang digunakan dan cara penyimpanannya.',
                onTap: () => context.push('/privasi'),
              ),
              const Divider(height: Sp.s2),
              _SettingsLink(
                icon: Icons.gavel_rounded,
                title: 'Syarat penggunaan',
                subtitle: 'Ketentuan penggunaan dan batasan aplikasi.',
                onTap: () => context.push('/syarat'),
              ),
            ],
          ),
        ),
        AppCard(
          color: context.creamSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const LogoMark(size: 40),
                  const HGap(Sp.s3),
                  Text('Tentang IbadahKu', style: AppText.base.semibold),
                ],
              ),
              const VGap(Sp.s3),
              Text(
                'IbadahKu membantu menghitung zakat fitrah, zakat maal, dan rencana qurban. '
                'Harga acuan diatur oleh admin.\n\n'
                'Disclaimer: seluruh hasil adalah estimasi. Konsultasikan dengan BAZNAS/LAZ resmi '
                'atau ulama terpercaya untuk kepastian hukum.\n\nVersi 1.0.0',
                style: AppText.sm.c(context.mutedText),
              ),
            ],
          ),
        ),
        AppButton(
          label: 'Keluar',
          icon: Icons.logout_rounded,
          variant: AppButtonVariant.danger,
          expand: true,
          onPressed: () => _logout(context),
        ),
      ],
    );
  }
}

class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: IconBadge(icon, size: 42),
    title: Text(title, style: AppText.sm.semibold),
    subtitle: Text(subtitle, style: AppText.xs.c(context.mutedText)),
    trailing: Icon(Icons.chevron_right_rounded, color: context.mutedText),
    onTap: onTap,
  );
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.initialName});
  final String initialName;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await context.read<AuthProvider>().updateProfile(_name.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: context.surfaceCard,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: Rad.xlR),
    title: const Text('Ubah profil'),
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'Nama lengkap',
            controller: _name,
            icon: Icons.badge_outlined,
            validator: (v) => Validators.requiredText(v, 'Nama lengkap'),
          ),
          if (_error != null) ...[
            const VGap(Sp.s3),
            Text(_error!, style: AppText.xs.c(AppColors.error)),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      AppButton(
        label: 'Simpan',
        icon: Icons.check_rounded,
        loading: _saving,
        onPressed: _save,
      ),
    ],
  );
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await context.read<AuthProvider>().changePassword(
      _current.text,
      _next.text,
    );
    if (!mounted) return;
    if (error == null) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: context.surfaceCard,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: Rad.xlR),
    title: const Text('Ganti password'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Password sekarang',
                controller: _current,
                icon: Icons.lock_outline_rounded,
                obscure: true,
                validator:
                    (v) => Validators.requiredText(v, 'Password sekarang'),
              ),
              const VGap(Sp.s3),
              AppTextField(
                label: 'Password baru',
                controller: _next,
                icon: Icons.lock_reset_rounded,
                obscure: true,
                validator: Validators.password,
              ),
              const VGap(Sp.s3),
              AppTextField(
                label: 'Ulangi password baru',
                controller: _confirm,
                icon: Icons.verified_user_outlined,
                obscure: true,
                validator: Validators.confirmPassword(() => _next.text),
              ),
              if (_error != null) ...[
                const VGap(Sp.s3),
                Text(_error!, style: AppText.xs.c(AppColors.error)),
              ],
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      AppButton(
        label: 'Perbarui',
        icon: Icons.check_rounded,
        loading: _saving,
        onPressed: _save,
      ),
    ],
  );
}
