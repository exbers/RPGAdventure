import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app/game_app.dart';

void main() {
  testWidgets('shows the main menu actions', (tester) async {
    await tester.pumpWidget(const GameApp());

    expect(find.text('Project Space O'), findsOneWidget);
    expect(find.text('Нова гра'), findsOneWidget);
    expect(find.text('Продовжити'), findsOneWidget);
    expect(find.text('Налаштування'), findsOneWidget);
    expect(find.text('Про гру'), findsOneWidget);
  });

  testWidgets('keeps continue disabled until save data exists', (tester) async {
    await tester.pumpWidget(const GameApp());

    final continueButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Продовжити'),
        matching: find.byType(OutlinedButton),
      ),
    );

    expect(continueButton.onPressed, isNull);
  });

  testWidgets('new game action gives prototype feedback', (tester) async {
    await tester.pumpWidget(const GameApp());

    await tester.tap(find.text('Нова гра'));
    await tester.pump();

    expect(find.text('Нова кампанія ще не готова.'), findsOneWidget);
  });
}
