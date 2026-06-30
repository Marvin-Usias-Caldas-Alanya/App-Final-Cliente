import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_clientes/app/app.dart';

void main() {
  testWidgets('App inicia con splash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ConfianzaApp(),
      ),
    );

    expect(find.byType(ConfianzaApp), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
