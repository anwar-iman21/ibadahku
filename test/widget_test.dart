import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ibadahku/main.dart' as app;
import 'package:ibadahku/screens/user/information_screen.dart';
import 'package:ibadahku/widgets/history_tile.dart';

void main() {
  testWidgets('shows a useful error when Firebase is not configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: app.FirebaseStartupError(message: 'Firebase is not configured'),
      ),
    );

    expect(find.text('Gagal memulai aplikasi'), findsOneWidget);
  });

  testWidgets('shows zakat and qurban guidance', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InformationScreen(section: InformationSection.guide),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Panduan ibadah'), findsOneWidget);
    expect(find.text('Zakat fitrah'), findsOneWidget);
    expect(find.text('Zakat maal'), findsOneWidget);
    expect(find.text('Qurban'), findsOneWidget);
  });

  testWidgets('FAQ no longer offers PDF export instructions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InformationScreen(section: InformationSection.help),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bagaimana mengekspor riwayat?'), findsNothing);
    expect(find.textContaining('Ekspor PDF'), findsNothing);
    expect(
      find.text('Saya lupa password, apakah reset bisa dikirim?'),
      findsNothing,
    );
  });

  testWidgets('categories load the JPG matching their type', (
    WidgetTester tester,
  ) async {
    const images = {
      'ZAKAT': 'assets/icons/kakulator-zakat.jpg',
      'FITRAH': 'assets/icons/zakat fitrah.jpg',
      'MAAL': 'assets/icons/zakat-mal.jpg',
      'QURBAN': 'assets/icons/kalkulator-qurban.jpg',
    };

    for (final entry in images.entries) {
      await tester.pumpWidget(
        MaterialApp(home: historyIcon(entry.key, size: 52)),
      );

      expect(find.byType(ClipOval), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(
        image.image,
        isA<AssetImage>().having(
          (asset) => asset.assetName,
          'asset path',
          entry.value,
        ),
      );
    }
  });
}
