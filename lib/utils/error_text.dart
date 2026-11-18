import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mengubah error Firebase menjadi pesan ramah berbahasa Indonesia.
class ErrorText {
  ErrorText._();

  static String auth(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Username sudah digunakan';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-email':
        return 'Username atau password salah';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan';
      case 'weak-password':
        return 'Password terlalu lemah, gunakan minimal 6 karakter';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi';
      case 'requires-recent-login':
        return 'Demi keamanan, keluar lalu masuk kembali sebelum mengubah password';
      case 'invalid-user-token':
      case 'user-token-expired':
        return 'Sesi berakhir. Silakan masuk kembali';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringan Anda';
      case 'operation-not-allowed':
        return 'Login Email/Password belum diaktifkan di Firebase Console';
      default:
        return 'Terjadi kesalahan (${e.code}). Coba lagi';
    }
  }

  static String generic(Object e) {
    if (e is FirebaseAuthException) return auth(e);
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Akses ditolak. Periksa Security Rules Firestore';
        case 'unavailable':
        case 'network-request-failed':
          return 'Tidak ada koneksi internet. Periksa jaringan Anda';
        default:
          return 'Terjadi kesalahan (${e.code}). Coba lagi';
      }
    }
    return 'Terjadi kesalahan. Coba lagi';
  }
}
