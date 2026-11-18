import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import 'auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _nama = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _nama.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<AuthProvider>().register(
          username: _username.text,
          namaLengkap: _nama.text,
          password: _password.text,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Buat Akun',
      subtitle: 'Daftar gratis untuk menyimpan riwayat perhitungan Anda.',
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              ErrorBanner(_error!),
              const VGap(Sp.s4),
            ],
            AppTextField(
              label: 'Username',
              hint: '4-20 karakter: huruf kecil, angka, . dan _',
              icon: Icons.alternate_email_rounded,
              controller: _username,
              textInputAction: TextInputAction.next,
              validator: Validators.username,
            ),
            const VGap(Sp.s4),
            AppTextField(
              label: 'Nama lengkap (opsional)',
              hint: 'Nama Anda',
              icon: Icons.badge_outlined,
              controller: _nama,
              textInputAction: TextInputAction.next,
            ),
            const VGap(Sp.s4),
            AppTextField(
              label: 'Password',
              hint: 'Minimal 6 karakter',
              icon: Icons.lock_outline_rounded,
              controller: _password,
              obscure: true,
              textInputAction: TextInputAction.next,
              validator: Validators.password,
            ),
            const VGap(Sp.s4),
            AppTextField(
              label: 'Konfirmasi password',
              hint: 'Ulangi password',
              icon: Icons.lock_reset_rounded,
              controller: _confirm,
              obscure: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: Validators.confirmPassword(() => _password.text),
            ),
            const VGap(Sp.s6),
            AppButton(
              label: 'Daftar',
              icon: Icons.person_add_alt_1_rounded,
              loading: _loading,
              expand: true,
              onPressed: _submit,
            ),
            const VGap(Sp.s3),
            AppButton(
              label: 'Sudah punya akun? Masuk',
              variant: AppButtonVariant.ghost,
              expand: true,
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
