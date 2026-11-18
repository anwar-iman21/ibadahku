import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;

DateTime? _ts(dynamic v) => v is Timestamp ? v.toDate() : null;

double _num(dynamic v, double fallback) => v is num ? v.toDouble() : fallback;

/// Data pengguna (users/{uid}).
class AppUser {
  const AppUser({
    required this.uid,
    required this.username,
    this.namaLengkap = '',
    this.role = 'user',
    this.createdAt,
  });

  final String uid;
  final String username;
  final String namaLengkap;
  final String role;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin';
  String get displayName => namaLengkap.isNotEmpty ? namaLengkap : username;

  AppUser copyWith({String? namaLengkap}) => AppUser(
    uid: uid,
    username: username,
    namaLengkap: namaLengkap ?? this.namaLengkap,
    role: role,
    createdAt: createdAt,
  );

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return AppUser(
      uid: d.id,
      username: (m['username'] ?? '') as String,
      namaLengkap: (m['namaLengkap'] ?? '') as String,
      role: (m['role'] ?? 'user') as String,
      createdAt: _ts(m['createdAt']),
    );
  }

  /// Cadangan bila dokumen profil belum bisa dibaca (mis. jaringan buruk).
  factory AppUser.fallback(User u) =>
      AppUser(uid: u.uid, username: (u.email ?? '').split('@').first);
}

/// Harga acuan (settings/prices) yang diatur admin.
class Prices {
  const Prices({
    required this.goldPerGram,
    required this.silverPerGram,
    required this.riceMedium,
    required this.ricePremium,
    required this.riceSuper,
    required this.kambing,
    required this.domba,
    required this.sapi,
    required this.kerbau,
    required this.unta,
    this.updatedAt,
  });

  final double goldPerGram;
  final double silverPerGram;
  final double riceMedium;
  final double ricePremium;
  final double riceSuper;
  final double kambing;
  final double domba;
  final double sapi;
  final double kerbau;
  final double unta;
  final DateTime? updatedAt;

  /// Nilai awal (ASUMSI). Admin wajib memperbaruinya sesuai harga terkini.
  factory Prices.defaults() => const Prices(
    goldPerGram: 2300000,
    silverPerGram: 25000,
    riceMedium: 13000,
    ricePremium: 15500,
    riceSuper: 18000,
    kambing: 3000000,
    domba: 2800000,
    sapi: 22000000,
    kerbau: 25000000,
    unta: 40000000,
  );

  factory Prices.fromMap(Map<String, dynamic> m) {
    final d = Prices.defaults();
    return Prices(
      goldPerGram: _num(m['goldPerGram'], d.goldPerGram),
      silverPerGram: _num(m['silverPerGram'], d.silverPerGram),
      riceMedium: _num(m['riceMedium'], d.riceMedium),
      ricePremium: _num(m['ricePremium'], d.ricePremium),
      riceSuper: _num(m['riceSuper'], d.riceSuper),
      kambing: _num(m['kambing'], d.kambing),
      domba: _num(m['domba'], d.domba),
      sapi: _num(m['sapi'], d.sapi),
      kerbau: _num(m['kerbau'], d.kerbau),
      unta: _num(m['unta'], d.unta),
      updatedAt: _ts(m['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'goldPerGram': goldPerGram,
    'silverPerGram': silverPerGram,
    'riceMedium': riceMedium,
    'ricePremium': ricePremium,
    'riceSuper': riceSuper,
    'kambing': kambing,
    'domba': domba,
    'sapi': sapi,
    'kerbau': kerbau,
    'unta': unta,
  };
}

/// Tips / info ibadah (tips/{id}).
class Tip {
  const Tip({
    required this.id,
    required this.judul,
    required this.isi,
    required this.aktif,
    this.createdAt,
  });
  final String id;
  final String judul;
  final String isi;
  final bool aktif;
  final DateTime? createdAt;

  factory Tip.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return Tip(
      id: d.id,
      judul: (m['judul'] ?? '') as String,
      isi: (m['isi'] ?? '') as String,
      aktif: (m['aktif'] ?? true) as bool,
      createdAt: _ts(m['createdAt']),
    );
  }
}

/// Riwayat perhitungan (history/{id}).
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.uid,
    required this.type,
    required this.input,
    required this.result,
    required this.createdAt,
  });

  final String id;
  final String uid;
  final String type; // FITRAH | MAAL | QURBAN
  final Map<String, dynamic> input;
  final Map<String, dynamic> result;
  final DateTime createdAt;

  String get title {
    switch (type) {
      case 'FITRAH':
        return 'Zakat Fitrah';
      case 'MAAL':
        return 'Zakat Maal';
      default:
        return 'Kalkulator Qurban';
    }
  }

  String get nominalText => (result['nominalText'] ?? '-') as String;
  String get status => (result['status'] ?? '') as String;
  String get ringkasan => (result['ringkasan'] ?? '') as String;

  factory HistoryEntry.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return HistoryEntry(
      id: d.id,
      uid: (m['uid'] ?? '') as String,
      type: (m['type'] ?? '') as String,
      input: Map<String, dynamic>.from((m['input'] ?? {}) as Map),
      result: Map<String, dynamic>.from((m['result'] ?? {}) as Map),
      createdAt: _ts(m['createdAt']) ?? DateTime.now(),
    );
  }
}

class AdminStats {
  const AdminStats({
    required this.users,
    required this.history,
    required this.fitrah,
    required this.maal,
    required this.qurban,
  });
  final int users;
  final int history;
  final int fitrah;
  final int maal;
  final int qurban;
}
