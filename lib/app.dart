import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'design_system/design_system.dart';
import 'providers/auth_provider.dart';
import 'providers/data_providers.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

class IbadahKuApp extends StatefulWidget {
  const IbadahKuApp({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<IbadahKuApp> createState() => _IbadahKuAppState();
}

class _IbadahKuAppState extends State<IbadahKuApp> {
  late final FirestoreService _fs;
  late final AuthService _authService;
  late final AuthProvider _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final db = FirebaseFirestore.instance;
    _fs = FirestoreService(db);
    _authService = AuthService(FirebaseAuth.instance, db);
    _auth = AuthProvider(_authService, _fs);
    _router = buildRouter(_auth);
  }

  @override
  void dispose() {
    _auth.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>.value(value: _fs),
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProxyProvider<AuthProvider, PricesProvider>(
          create: (_) => PricesProvider(_fs),
          update: (_, auth, p) => p!..bind(auth.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TipsProvider>(
          create: (_) => TipsProvider(_fs),
          update: (_, auth, p) => p!..bind(auth.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, HistoryProvider>(
          create: (_) => HistoryProvider(_fs),
          update: (_, auth, p) => p!..bind(auth.uid),
        ),
      ],
      child: MaterialApp.router(
        title: 'IbadahKu',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: AppTheme.light,
        routerConfig: _router,
        locale: const Locale('id'),
        supportedLocales: const [Locale('id'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
      ),
    );
  }
}
