import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // On native platforms Firebase can load options from its platform config.
    // For web, provide Firebase options via the generated FlutterFire config.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirestoreService.configureOffline();
    final prefs = await SharedPreferences.getInstance();
    runApp(IbadahKuApp(prefs: prefs));
  } catch (e) {
    runApp(FirebaseStartupError(message: e.toString()));
  }
}

/// Tampil bila Firebase gagal diinisialisasi (mis. firebase_options salah).
class FirebaseStartupError extends StatelessWidget {
  const FirebaseStartupError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                const Text('Gagal memulai aplikasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  'Periksa koneksi internet dan konfigurasi Firebase '
                  '(jalankan "flutterfire configure").\n\n$message',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}