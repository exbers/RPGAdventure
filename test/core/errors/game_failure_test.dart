import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/errors/game_failure.dart';

void main() {
  group('GameFailure subtypes', () {
    test('ValidationFailure stores message, detail and field', () {
      const failure = ValidationFailure(
        message: 'Name is required',
        detail: 'field "name" was empty',
        field: 'name',
      );

      expect(failure.message, 'Name is required');
      expect(failure.detail, 'field "name" was empty');
      expect(failure.field, 'name');
    });

    test('ValidationFailure with no detail or field', () {
      const failure = ValidationFailure(message: 'Invalid value');

      expect(failure.detail, isNull);
      expect(failure.field, isNull);
    });

    test('PersistenceFailure stores message and detail', () {
      const failure = PersistenceFailure(
        message: 'Save failed',
        detail: 'IOException: disk full',
      );

      expect(failure.message, 'Save failed');
      expect(failure.detail, 'IOException: disk full');
    });

    test('CombatFailure stores message', () {
      const failure = CombatFailure(message: 'Invalid combat action');

      expect(failure.message, 'Invalid combat action');
      expect(failure.detail, isNull);
    });

    test('EconomyFailure stores message and detail', () {
      const failure = EconomyFailure(
        message: 'Insufficient funds',
        detail: 'needed 100 gold, had 50',
      );

      expect(failure.message, 'Insufficient funds');
      expect(failure.detail, 'needed 100 gold, had 50');
    });

    test('toString includes type and message', () {
      const failure = CombatFailure(message: 'Out of health');
      final str = failure.toString();

      expect(str, contains('CombatFailure'));
      expect(str, contains('Out of health'));
    });

    test('toString includes detail when present', () {
      const failure = PersistenceFailure(
        message: 'Load failed',
        detail: 'corrupt file',
      );
      final str = failure.toString();

      expect(str, contains('corrupt file'));
    });

    test('exhaustive switch covers all GameFailure subtypes', () {
      // This verifies that the sealed hierarchy is complete by switching over
      // a value of each subtype without a default branch.
      String classify(GameFailure f) => switch (f) {
        ValidationFailure() => 'validation',
        PersistenceFailure() => 'persistence',
        CombatFailure() => 'combat',
        EconomyFailure() => 'economy',
      };

      expect(classify(const ValidationFailure(message: 'x')), 'validation');
      expect(classify(const PersistenceFailure(message: 'x')), 'persistence');
      expect(classify(const CombatFailure(message: 'x')), 'combat');
      expect(classify(const EconomyFailure(message: 'x')), 'economy');
    });
  });
}
