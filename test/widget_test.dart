import 'package:flutter_test/flutter_test.dart';

import 'package:app1/main.dart';

void main() {
  testWidgets('Halaman utama menampilkan daftar menu', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Kantin Bu Sari'), findsOneWidget);
    expect(find.text('Menu Hari Ini'), findsOneWidget);
    expect(find.text('Nasi Goreng Spesial'), findsOneWidget);
  });

  testWidgets('Filter kategori Minuman menyembunyikan makanan', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Minuman'));
    await tester.pumpAndSettle();

    expect(find.text('Nasi Goreng Spesial'), findsNothing);
    expect(find.text('Es Teh Manis'), findsOneWidget);
  });
}
