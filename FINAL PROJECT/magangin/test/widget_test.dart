
import 'package:flutter_test/flutter_test.dart';

import 'package:magangin/main.dart';

void main() {
  testWidgets('Magangin menampilkan halaman awal', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(const MaganginApp());

    expect(find.text('Magangin'), findsOneWidget);
    expect(find.text('Selamat Datang di Magangin!'), findsOneWidget);
    expect(find.text('Persiapan aplikasi...'), findsOneWidget);
  });
}
