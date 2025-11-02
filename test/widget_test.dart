import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyeto_estimados/main.dart'; // 👈 importa tu proyecto

void main() {
  testWidgets('Prueba de interfaz de ubicación', (WidgetTester tester) async {
    print('Iniciando prueba de interfaz de ubicación...');

    // Construir la app
    await tester.pumpWidget(const MyApp());
    print('Aplicación construida correctamente');

    // Validar que aparece la pantalla de ubicación
    expect(find.text('Ubicación del proyecto'), findsOneWidget);
    print('✓ Título "Ubicación del proyecto" encontrado');

    expect(find.text('Usar mi ubicación actual'), findsOneWidget);
    print('✓ Botón "Usar mi ubicación actual" encontrado');

    expect(find.text('Confirmar Ubicación'), findsOneWidget);
    print('✓ Botón "Confirmar Ubicación" encontrado');

    // Simular tap en botón
    await tester.tap(find.text('Usar mi ubicación actual'));
    await tester.pump();
    print('✓ Botón "Usar mi ubicación actual" presionado');
  });

  testWidgets('Prueba de búsqueda de ubicación', (WidgetTester tester) async {
    print('Iniciando prueba de búsqueda...');

    await tester.pumpWidget(const MyApp());

    // Escribir en el TextField
    await tester.enterText(find.byType(TextField), 'Av. Principal');
    await tester.pump();

    print('✓ Texto ingresado en el campo de búsqueda');
    expect(find.text('Av. Principal'), findsOneWidget);

    print('Prueba de búsqueda completada ✅');
  });
}
