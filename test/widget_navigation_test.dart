import 'package:flutter_test/flutter_test.dart';
import 'package:skillshub/main.dart';

void main() {
  testWidgets('Home screen buttons exist', (WidgetTester tester) async {
    await tester.pumpWidget(const SkillHubApp());

    expect(find.text('Kelola Peserta'), findsOneWidget);
    expect(find.text('Kelola Kelas'), findsOneWidget);
    expect(find.text('Tambah Pendaftaran'), findsOneWidget);
    expect(find.text('List Pendaftaran'), findsOneWidget);

    // Tap Kelola Peserta and verify navigation pushes a new route
    await tester.tap(find.text('Kelola Peserta'));
    await tester.pumpAndSettle();

    // Should find the title "Daftar Peserta" (from PesertaListScreen)
    expect(find.text('Daftar Peserta'), findsOneWidget);
  });
}
