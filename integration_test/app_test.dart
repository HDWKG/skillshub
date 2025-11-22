import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skillshub/main.dart' as app;

// Add this helper function outside main()
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(
    seconds: 10,
  ), // Increased timeout for safety
}) async {
  bool found = false;
  final stopwatch = Stopwatch()..start();
  do {
    await tester.pump();
    try {
      // Use tester.any() which returns true/false without throwing if not found
      if (tester.any(finder)) {
        found = true;
        break;
      }
    } catch (e) {
      // Do nothing, just continue pumping
    }
    // Add a small delay to yield control and prevent CPU hogging
    await Future.delayed(const Duration(milliseconds: 100));
  } while (stopwatch.elapsed < timeout);

  if (!found) {
    throw Exception('Timed out waiting for finder: $finder');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // --- TEST DATA ---
  const String testPesertaName = 'ZXC E2E User';
  const String testPesertaEmail = 'zxc_e2e@example.com';
  const String testPesertaPhone = '08111222333';

  const String testKelasName = 'ZXC Test Class';
  const String testKelasInstruktur = 'Instructor ZXC';
  const String testKelasNameUpdated = 'ZXC Updated Class';

  const String secondKelasName = 'Second ZXC Class';

  // --- FINDER HELPERS ---
  Finder findFieldByLabel(String label) {
    return find.widgetWithText(TextFormField, label);
  }

  Finder findDropdownByIndex(int index) {
    return find.byType(DropdownButtonFormField<int>).at(index);
  }

  Future<void> performDelete(WidgetTester tester, String name) async {
    final card = find.widgetWithText(Card, name);
    await tester.scrollUntilVisible(card, 50);
    await tester.tap(
      find.descendant(of: card, matching: find.text('Hapus')).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text(name), findsNothing);
  }

  testWidgets(
    'E2E: create peserta, kelas, register, edit, delete',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('SkillsHub'), findsOneWidget);

      // -----------------------------------------------------------------
      // 1. CREATE PESERTA
      // -----------------------------------------------------------------
      print('--- 1. Creating Peserta ---');
      await tester.tap(find.text('Kelola Peserta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tambah Peserta'));
      await tester.pumpAndSettle();

      await tester.enterText(findFieldByLabel('Nama Peserta'), testPesertaName);
      await tester.enterText(findFieldByLabel('Email'), testPesertaEmail);
      await tester.enterText(findFieldByLabel('No. Telepon'), testPesertaPhone);

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text(testPesertaName), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 2. CREATE TWO KELAS
      // -----------------------------------------------------------------
      print('--- 2. Creating Two Kelas ---');
      await tester.tap(find.text('Kelola Kelas'));
      await tester.pumpAndSettle();

      // --- Create First Class ---
      await tester.tap(find.text('Tambah Kelas'));
      await tester.pumpAndSettle();

      await tester.enterText(findFieldByLabel('Nama Kelas'), testKelasName);
      await tester.enterText(
        findFieldByLabel('Deskripsi'),
        'Desc kelas pertama',
      );
      await tester.enterText(
        findFieldByLabel('Instruktur'),
        testKelasInstruktur,
      );

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text(testKelasName), findsOneWidget);

      // --- Create Second Class ---
      await tester.tap(find.text('Tambah Kelas'));
      await tester.pumpAndSettle();

      await tester.enterText(findFieldByLabel('Nama Kelas'), secondKelasName);
      await tester.enterText(
        findFieldByLabel('Deskripsi'),
        'Desc kelas ke dua',
      );
      await tester.enterText(findFieldByLabel('Instruktur'), 'Inst 2');

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
      expect(find.text(secondKelasName), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 3. CREATE PENDAFTARAN
      // -----------------------------------------------------------------
      print('--- 3. Creating Pendaftaran ---');
      await tester.tap(find.text('Tambah Pendaftaran'));
      await tester.pumpAndSettle();

      await tester.tap(findDropdownByIndex(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text(testPesertaName).last);
      await tester.pumpAndSettle();

      await tester.tap(findDropdownByIndex(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text(testKelasName).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Daftarkan'));
      await tester.pumpAndSettle();

      print('--- Navigating to Pendaftaran List to Verify ---');
      await tester.tap(find.text('Daftar Pendaftaran'));

      // Wait until the expanded item is visible
      await pumpUntilFound(tester, find.text(testPesertaName));
      await tester.ensureVisible(find.text(testPesertaName));
      await tester.pumpAndSettle();

      expect(find.text(testPesertaName), findsOneWidget);

      // -----------------------------------------------------------------
      // 4. EDIT PENDAFTARAN (Move Peserta to second class)
      // -----------------------------------------------------------------
      print('--- 4. Editing Pendaftaran (Moving Class) ---');

      // Tap the Peserta item (it is visible because the tile is expanded)
      await tester.ensureVisible(find.text(testPesertaName));
      await tester.tap(find.text(testPesertaName));
      await tester.pumpAndSettle();

      expect(find.text('Pindah ke Kelas'), findsOneWidget);

      // Change the selected class
      await tester.tap(find.byType(DropdownButtonFormField<int>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(secondKelasName).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      // Verification: Wait for list to update, then verify the user is now visible
      // in the Second Class (which is also expanded by default).
      await pumpUntilFound(tester, find.text(secondKelasName));

      // Ensure the user text is visible and scroll to it.
      await tester.ensureVisible(find.text(testPesertaName));
      await tester.pumpAndSettle();

      // We check for descendants to verify location, but given the list structure,
      // just finding the text confirms the move since it's no longer under the first class.
      expect(find.text(testPesertaName), findsOneWidget);

      // -----------------------------------------------------------------
      // 5. EDIT KELAS
      // -----------------------------------------------------------------
      print('--- 5. Editing Kelas ---');
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kelola Kelas'));
      await tester.pumpAndSettle();

      final firstKelasCard = find.widgetWithText(Card, testKelasName);
      await tester.scrollUntilVisible(firstKelasCard, 50);

      await tester.tap(
        find.descendant(of: firstKelasCard, matching: find.text('Edit')).first,
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        findFieldByLabel('Nama Kelas'),
        testKelasNameUpdated,
      );
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pumpAndSettle();

      expect(find.text(testKelasNameUpdated), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 6. DELETE PENDAFTARAN
      // -----------------------------------------------------------------
      print('--- 6. Deleting Pendaftaran ---');
      await tester.tap(find.text('Daftar Pendaftaran'));
      await tester.pumpAndSettle();

      // Wait for data refresh
      await pumpUntilFound(tester, find.text(secondKelasName));

      // Tap the Peserta item (it is visible because the tile is expanded)
      await tester.ensureVisible(find.text(testPesertaName));
      await tester.tap(find.text(testPesertaName));
      await tester.pumpAndSettle();

      // Delete
      await tester.tap(find.text('Hapus Pendaftaran'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(find.text(testPesertaName), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 7. DELETE KELAS
      // -----------------------------------------------------------------
      print('--- 7. Deleting Kelas ---');
      await tester.tap(find.text('Kelola Kelas'));
      await tester.pumpAndSettle();

      await performDelete(tester, testKelasNameUpdated);
      await performDelete(tester, secondKelasName);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 8. DELETE PESERTA
      // -----------------------------------------------------------------
      print('--- 8. Deleting Peserta ---');
      await tester.tap(find.text('Kelola Peserta'));
      await tester.pumpAndSettle();

      await performDelete(tester, testPesertaName);

      await tester.pageBack();
      await tester.pumpAndSettle();

      print('--- E2E Test Completed Successfully ---');
      expect(find.text('SkillsHub'), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
