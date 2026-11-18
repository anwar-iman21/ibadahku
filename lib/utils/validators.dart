/// Validasi input form (pesan dalam bahasa Indonesia).
class Validators {
  Validators._();

  static final RegExp _usernameRe = RegExp(r'^[a-z0-9._]{4,20}$');

  static String? username(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Username wajib diisi';
    if (s.length < 4) return 'Username minimal 4 karakter';
    if (s.length > 20) return 'Username maksimal 20 karakter';
    if (!_usernameRe.hasMatch(s)) {
      return 'Hanya huruf kecil, angka, titik, dan underscore';
    }
    return null;
  }

  static String? password(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Password wajib diisi';
    if (s.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) =>
      (v) {
        if ((v ?? '').isEmpty) return 'Konfirmasi password wajib diisi';
        if (v != original()) return 'Konfirmasi password tidak sama';
        return null;
      };

  static String? requiredText(String? v, String label) =>
      (v ?? '').trim().isEmpty ? '$label wajib diisi' : null;
}
