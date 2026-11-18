import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class FirestoreService {
  FirestoreService(this._db);
  final FirebaseFirestore _db;

  /// Aktifkan cache offline. Di platform yang tidak mendukung, diabaikan dengan aman.
  static void configureOffline() {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('Cache offline Firestore tidak tersedia: $e');
    }
  }

  // ---------------- users ----------------
  Future<AppUser?> getUser(String uid) async {
    final d = await _db.collection('users').doc(uid).get();
    return d.exists ? AppUser.fromDoc(d) : null;
  }

  Future<void> updateUserProfile(String uid, String namaLengkap) => _db
      .collection('users')
      .doc(uid)
      .update({'namaLengkap': namaLengkap.trim()});

  Stream<List<AppUser>> usersStream() => _db
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(AppUser.fromDoc).toList());

  // ---------------- settings/prices ----------------
  DocumentReference<Map<String, dynamic>> get _pricesDoc =>
      _db.collection('settings').doc('prices');

  /// Emit null bila dokumen harga belum dibuat.
  Stream<Prices?> pricesStream() => _pricesDoc.snapshots().map((s) {
    final data = s.data();
    return (s.exists && data != null) ? Prices.fromMap(data) : null;
  });

  Future<void> savePrices(Prices p) => _pricesDoc.set({
    ...p.toMap(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  // ---------------- tips ----------------
  Stream<List<Tip>> tipsStream() => _db
      .collection('tips')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Tip.fromDoc).toList());

  Future<void> addTip(String judul, String isi, bool aktif) =>
      _db.collection('tips').add({
        'judul': judul,
        'isi': isi,
        'aktif': aktif,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> updateTip(String id, String judul, String isi, bool aktif) => _db
      .collection('tips')
      .doc(id)
      .update({'judul': judul, 'isi': isi, 'aktif': aktif});

  Future<void> deleteTip(String id) => _db.collection('tips').doc(id).delete();

  // ---------------- history ----------------
  /// Diurutkan di sisi aplikasi agar tidak perlu membuat index komposit.
  Stream<List<HistoryEntry>> historyStream(String uid) => _db
      .collection('history')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list =
            s.docs.map(HistoryEntry.fromDoc).toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  /// Simpan riwayat. Bila sinyal buruk, tulisan tetap antre di cache lokal.
  Future<void> addHistory(
    String uid,
    String type,
    Map<String, dynamic> input,
    Map<String, dynamic> result,
  ) async {
    final write = _db.collection('history').add({
      'uid': uid,
      'type': type,
      'input': input,
      'result': result,
      'createdAt': FieldValue.serverTimestamp(),
    });
    try {
      await write.timeout(const Duration(seconds: 10));
    } on TimeoutException {
      // Tetap tersimpan lokal dan akan tersinkron saat online.
    }
  }

  Future<void> deleteHistory(String id) =>
      _db.collection('history').doc(id).delete();

  Future<void> deleteAllHistory(String uid) async {
    final snap =
        await _db.collection('history').where('uid', isEqualTo: uid).get();
    final docs = snap.docs;
    for (var i = 0; i < docs.length; i += 400) {
      final batch = _db.batch();
      for (final d in docs.skip(i).take(400)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }

  // ---------------- statistik admin ----------------
  Future<int> _count(Query<Map<String, dynamic>> q) async {
    try {
      final r = await q.count().get();
      return r.count ?? 0;
    } catch (_) {
      // Cadangan bila aggregation tidak didukung platform.
      final s = await q.get();
      return s.size;
    }
  }

  Future<AdminStats> stats() async {
    final h = _db.collection('history');
    final r = await Future.wait<int>([
      _count(_db.collection('users')),
      _count(h),
      _count(h.where('type', isEqualTo: 'FITRAH')),
      _count(h.where('type', isEqualTo: 'MAAL')),
      _count(h.where('type', isEqualTo: 'QURBAN')),
    ]);
    return AdminStats(
      users: r[0],
      history: r[1],
      fitrah: r[2],
      maal: r[3],
      qurban: r[4],
    );
  }
}
