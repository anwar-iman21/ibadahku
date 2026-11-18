import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/error_text.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._auth, this._fs) {
    _sub = _auth.authChanges().listen(_onAuth);
  }

  final AuthService _auth;
  final FirestoreService _fs;
  late final StreamSubscription<User?> _sub;

  // Splash minimal tampil sebentar agar animasinya terlihat.
  final Future<void> _minSplash = Future<void>.delayed(
    const Duration(milliseconds: 1800),
  );

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  bool _manual = false; // true saat login/register sedang diproses
  bool _first = true;

  bool get isAdmin => user?.isAdmin ?? false;
  String? get uid => status == AuthStatus.signedIn ? user?.uid : null;

  Future<void> _onAuth(User? u) async {
    if (_manual) return;
    if (u == null) {
      if (_first) await _minSplash;
      _first = false;
      user = null;
      status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }
    final profile = await _loadProfile(u);
    if (_first) await _minSplash;
    _first = false;
    user = profile;
    status = AuthStatus.signedIn;
    notifyListeners();
  }

  Future<AppUser> _loadProfile(User u) async {
    for (var i = 0; i < 3; i++) {
      try {
        final p = await _fs.getUser(u.uid);
        if (p != null) return p;
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    return AppUser.fallback(u);
  }

  /// Mengembalikan null jika sukses, atau pesan error.
  Future<String?> login(String username, String password) async {
    _manual = true;
    try {
      final cred = await _auth.login(username, password);
      user = await _loadProfile(cred.user!);
      _first = false;
      status = AuthStatus.signedIn;
      notifyListeners();
      return null;
    } catch (e) {
      return ErrorText.generic(e);
    } finally {
      _manual = false;
    }
  }

  Future<String?> register({
    required String username,
    required String namaLengkap,
    required String password,
  }) async {
    _manual = true;
    try {
      user = await _auth.register(
        username: username,
        namaLengkap: namaLengkap,
        password: password,
      );
      _first = false;
      status = AuthStatus.signedIn;
      notifyListeners();
      return null;
    } catch (e) {
      return ErrorText.generic(e);
    } finally {
      _manual = false;
    }
  }

  Future<String?> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _auth.changePassword(currentPassword, newPassword);
      return null;
    } catch (e) {
      if (e is StateError) return e.message.toString();
      if (e is FirebaseAuthException &&
          (e.code == 'wrong-password' || e.code == 'invalid-credential')) {
        return 'Password saat ini tidak sesuai';
      }
      return ErrorText.generic(e);
    }
  }

  Future<String?> updateProfile(String namaLengkap) async {
    final current = user;
    if (current == null) return 'Sesi login tidak ditemukan';
    try {
      await _fs.updateUserProfile(current.uid, namaLengkap);
      user = current.copyWith(namaLengkap: namaLengkap.trim());
      notifyListeners();
      return null;
    } catch (e) {
      return ErrorText.generic(e);
    }
  }

  Future<void> logout() => _auth.logout();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
