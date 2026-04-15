import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app/app_state.dart';

void main() {
  group('AppState', () {
    test('can be created with default in-memory dependencies', () {
      final state = AppState();

      expect(state.hero, isNotNull);
      expect(state.combat, isNotNull);
      expect(state.inventory, isNotNull);
      expect(state.quests, isNotNull);
      expect(state.pets, isNotNull);
      expect(state.world, isNotNull);

      state.dispose();
    });

    test('dispose does not throw', () {
      final state = AppState();
      expect(state.dispose, returnsNormally);
    });
  });
}
