import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app/game_app.dart';

void main() {
  testWidgets('shows the main menu actions', (tester) async {
    await tester.pumpWidget(const GameApp());

    expect(find.text('RPG Adventure'), findsOneWidget);
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

  testWidgets('tapping Нова гра navigates to hero creation screen', (
    tester,
  ) async {
    await tester.pumpWidget(const GameApp());

    await tester.tap(find.text('Нова гра'));
    await tester.pumpAndSettle();

    expect(find.text('Створення героя'), findsOneWidget);
    // Main menu title should no longer be visible after navigation.
    expect(find.text('Нова гра'), findsNothing);
  });

  testWidgets('hero creation screen has a back button to return to main menu', (
    tester,
  ) async {
    await tester.pumpWidget(const GameApp());

    await tester.tap(find.text('Нова гра'));
    await tester.pumpAndSettle();

    // The AppBar back button should be present.
    final backButton = find.byTooltip('Back');
    expect(backButton, findsOneWidget);

    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.text('Нова гра'), findsOneWidget);
  });
}
