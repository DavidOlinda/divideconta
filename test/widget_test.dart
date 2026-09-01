import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:divideconta/main.dart';

void main() {
  testWidgets('botão Calcular começa desabilitado', (tester) async {
    await tester.pumpWidget(const DivideContaApp());

    final botao = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(botao.onPressed, isNull);
  });

  testWidgets(
    'preenchendo dados válidos habilita o botão e calcula corretamente',
    (tester) async {
      await tester.pumpWidget(const DivideContaApp());

      await tester.enterText(find.byType(TextField).at(0), '100');
      await tester.enterText(find.byType(TextField).at(1), '4');
      await tester.enterText(find.byType(TextField).at(2), '10');
      await tester.pumpAndSettle();

      final botao = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(botao.onPressed, isNotNull);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // comissão = 100 * 10% = 10 | total = 110 | por pessoa = 27,50
      expect(find.textContaining('27,50'), findsOneWidget);
    },
  );

  testWidgets('quantidade de pessoas zero mantém o botão desabilitado', (
    tester,
  ) async {
    await tester.pumpWidget(const DivideContaApp());

    await tester.enterText(find.byType(TextField).at(0), '100');
    await tester.enterText(find.byType(TextField).at(1), '0');
    await tester.enterText(find.byType(TextField).at(2), '10');
    await tester.pumpAndSettle();

    final botao = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(botao.onPressed, isNull);
    expect(find.text('Informe pelo menos 1 pessoa'), findsOneWidget);
  });
}
