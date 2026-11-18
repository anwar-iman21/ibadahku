import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/models.dart';

/// Autentikasi username + password.
/// Firebase Auth butuh email, jadi username diubah menjadi "<username>@ibadahku.app".
class AuthService {
  AuthService(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  static const String emailDomain = 'ibadahku.app';

  static String toEmail(String username) =>
      '${username.trim().toLowerCase()}@$emailDomain';

  Stream<User?> authChanges() => _auth.authStateChanges();

  Future<UserCredential> login(String username, String password) => _auth
      .signInWithEmailAndPassword(email: toEmail(username), password: password);

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw StateError('Sesi login tidak ditemukan');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// Daftar akun baru. Peran SELALU "user".
  Future<AppUser> register({
    required String username,
    required String namaLengkap,
    required String password,
  }) async {
    final uname = username.trim().toLowerCase();
    final cred = await _auth.createUserWithEmailAndPassword(
      email: toEmail(uname),
      password: password,
    );
    final user = cred.user!;
    try {
      await _db.collection('users').doc(user.uid).set({
        'username': uname,
        'namaLengkap': namaLengkap.trim(),
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Batalkan akun Auth agar tidak ada akun "setengah jadi".
      try {
        await user.delete();
      } catch (_) {}
      rethrow;
    }
    return AppUser(
      uid: user.uid,
      username: uname,
      namaLengkap: namaLengkap.trim(),
    );
  }

  Future<void> logout() => _auth.signOut();
}
