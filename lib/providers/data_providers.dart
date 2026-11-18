import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/firestore_service.dart';
import '../utils/error_text.dart';

/// Harga acuan dari admin (settings/prices).
class PricesProvider extends ChangeNotifier {
  PricesProvider(this._fs);
  final FirestoreService _fs;
  StreamSubscription<Prices?>? _sub;
  String? _uid;

  Prices prices = Prices.defaults();
  bool loading = true;
  bool usingDefaults = true; // true = dokumen harga belum dibuat admin
  String? error;

  void bind(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _sub = null;
    if (uid == null) {
      prices = Prices.defaults();
      loading = true;
      usingDefaults = true;
      error = null;
      Future.microtask(notifyListeners);
      return;
    }
    loading = true;
    _sub = _fs.pricesStream().listen((p) {
      prices = p ?? Prices.defaults();
      usingDefaults = p == null;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (Object e) {
      loading = false;
      error = ErrorText.generic(e);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Tips ibadah (tips).
class TipsProvider extends ChangeNotifier {
  TipsProvider(this._fs);
  final FirestoreService _fs;
  StreamSubscription<List<Tip>>? _sub;
  String? _uid;

  List<Tip> tips = const [];
  bool loading = true;

  List<Tip> get active => tips.where((t) => t.aktif).toList();

  void bind(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _sub = null;
    if (uid == null) {
      tips = const [];
      loading = true;
      Future.microtask(notifyListeners);
      return;
    }
    _sub = _fs.tipsStream().listen((t) {
      tips = t;
      loading = false;
      notifyListeners();
    }, onError: (Object _) {
      loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

/// Riwayat perhitungan milik user yang login.
class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._fs);
  final FirestoreService _fs;
  StreamSubscription<List<HistoryEntry>>? _sub;
  String? _uid;

  List<HistoryEntry> items = const [];
  bool loading = true;
  String? error;
  String? filter; // null = semua, atau FITRAH/MAAL/QURBAN

  List<HistoryEntry> get filtered =>
      filter == null ? items : items.where((e) => e.type == filter).toList();

  void setFilter(String? f) {
    filter = f;
    notifyListeners();
  }

  void bind(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _sub?.cancel();
    _sub = null;
    if (uid == null) {
      items = const [];
      loading = true;
      error = null;
      filter = null;
      Future.microtask(notifyListeners);
      return;
    }
    loading = true;
    _sub = _fs.historyStream(uid).listen((list) {
      items = list;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (Object e) {
      loading = false;
      error = ErrorText.generic(e);
      notifyListeners();
    });
  }

  /// Mengembalikan null jika sukses, atau pesan error.
  Future<String?> add(
      String type, Map<String, dynamic> input, Map<String, dynamic> result) async {
    final uid = _uid;
    if (uid == null) return 'Sesi login tidak ditemukan';
    try {
      await _fs.addHistory(uid, type, input, result);
      return null;
    } catch (e) {
      return ErrorText.generic(e);
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _fs.deleteHistory(id);
      return null;
    } catch (e) {
      return ErrorText.generic(e);
    }
  }

  Future<String?> deleteAll() async {
    final uid = _uid;
    if (uid == null) return 'Sesi login tidak ditemukan';
    try {
      await _fs.deleteAllHistory(uid);
      return null;
    } catch (e) {
      return ErrorText.generic(e);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
