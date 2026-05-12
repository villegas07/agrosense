import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrosense/main.dart';

void main() {
  testWidgets('AgroSense smoke test — la app arranca sin errores',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AgroSenseApp()),
    );

    // Mientras carga los datos del sensor se muestra el indicador de progreso.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Después de que el provider emita datos, la pantalla principal se muestra.
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('AgroSense'), findsOneWidget);
  });
}
