import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_system.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import 'auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _passFocus = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final err = await context.read<AuthProvider>().login(
      _username.text,
      _password.text,
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
      title: 'Masuk',
      subtitle: 'Assalamualaikum, silakan masuk ke akun Anda.',
      form: Form(
        key: _form,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[ErrorBanner(_error!), const VGap(Sp.s4)],
              AppTextField(
                label: 'Username',
                hint: 'contoh: budi.santoso',
                icon: Icons.person_outline_rounded,
                controller: _username,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passFocus.requestFocus(),
                validator: (v) => Validators.requiredText(v, 'Username'),
              ),
              const VGap(Sp.s4),
              AppTextField(
                label: 'Password',
                hint: 'Masukkan password',
                icon: Icons.lock_outline_rounded,
                controller: _password,
                focusNode: _passFocus,
                obscure: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: (v) => Validators.requiredText(v, 'Password'),
              ),
              const VGap(Sp.s6),
              AppButton(
                label: 'Masuk',
                icon: Icons.login_rounded,
                loading: _loading,
                expand: true,
                onPressed: _submit,
              ),
              const VGap(Sp.s3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Sp.s3),
                decoration: BoxDecoration(
                  color: context.tintBg,
                  borderRadius: Rad.mdR,
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        'Belum punya akun?',
                        style: AppText.sm.c(context.mutedText),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: Sp.s2),
                      ),
                      onPressed: () => context.go('/register'),
                      child: Text(
                        'Daftar',
                        style: AppText.sm.semibold.c(context.tintFg),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
