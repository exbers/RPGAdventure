import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/core.dart';

void main() {
  group('ValidationResult', () {
    test('valid() constructor produces a valid result', () {
      const result = ValidationResult.valid();

      expect(result.isValid, isTrue);
      expect(result.hasErrors, isFalse);
      expect(result.failures, isEmpty);
    });

    test('empty failures list is valid', () {
      const result = ValidationResult([]);

      expect(result.isValid, isTrue);
    });

    test('single failure marks result as invalid', () {
      const result = ValidationResult([
        ValidationFailure(message: 'Name is required', field: 'name'),
      ]);

      expect(result.isValid, isFalse);
      expect(result.hasErrors, isTrue);
      expect(result.failures, hasLength(1));
    });

    test('multiple failures are all preserved', () {
      const result = ValidationResult([
        ValidationFailure(message: 'Name is required', field: 'name'),
        ValidationFailure(message: 'Value must be positive', field: 'value'),
      ]);

      expect(result.failures, hasLength(2));
    });

    test('merge combines failures from two results', () {
      const a = ValidationResult([ValidationFailure(message: 'Error A')]);
      const b = ValidationResult([
        ValidationFailure(message: 'Error B'),
        ValidationFailure(message: 'Error C'),
      ]);

      final merged = a.merge(b);

      expect(merged.failures, hasLength(3));
      expect(
        merged.failures.map((f) => f.message),
        containsAll(['Error A', 'Error B', 'Error C']),
      );
    });

    test('merge of two valid results is still valid', () {
      const a = ValidationResult.valid();
      const b = ValidationResult.valid();

      expect(a.merge(b).isValid, isTrue);
    });

    test('merge of valid and invalid results is invalid', () {
      const valid = ValidationResult.valid();
      const invalid = ValidationResult([
        ValidationFailure(message: 'Bad input'),
      ]);

      expect(valid.merge(invalid).isValid, isFalse);
      expect(invalid.merge(valid).isValid, isFalse);
    });

    test('formatMessages joins messages with newline by default', () {
      const result = ValidationResult([
        ValidationFailure(message: 'Error A'),
        ValidationFailure(message: 'Error B'),
      ]);

      expect(result.formatMessages(), 'Error A\nError B');
    });

    test('formatMessages respects custom separator', () {
      const result = ValidationResult([
        ValidationFailure(message: 'Error A'),
        ValidationFailure(message: 'Error B'),
      ]);

      expect(result.formatMessages(separator: '; '), 'Error A; Error B');
    });

    test('formatMessages on valid result returns empty string', () {
      const result = ValidationResult.valid();

      expect(result.formatMessages(), '');
    });

    test('toString is descriptive', () {
      expect(const ValidationResult.valid().toString(), contains('valid'));
      expect(
        const ValidationResult([ValidationFailure(message: 'x')]).toString(),
        contains('error'),
      );
    });
  });

  group('ValidationResult — item validation scenario', () {
    // Simulates validating a game item without crashing the app.
    ValidationResult validateItem({required String name, required int value}) {
      return ValidationResult([
        if (name.trim().isEmpty)
          const ValidationFailure(
            message: 'Item name cannot be empty',
            field: 'name',
          ),
        if (value < 0)
          const ValidationFailure(
            message: 'Item value cannot be negative',
            field: 'value',
          ),
      ]);
    }

    test('valid item passes validation', () {
      final result = validateItem(name: 'Sword', value: 10);

      expect(result.isValid, isTrue);
    });

    test('empty item name fails validation with appropriate message', () {
      final result = validateItem(name: '', value: 5);

      expect(result.isValid, isFalse);
      expect(result.failures.first.field, 'name');
    });

    test('negative value fails validation', () {
      final result = validateItem(name: 'Gem', value: -1);

      expect(result.isValid, isFalse);
      expect(result.failures.first.field, 'value');
    });

    test('multiple invalid fields produce multiple failures', () {
      final result = validateItem(name: '', value: -5);

      expect(result.failures, hasLength(2));
    });
  });

  group('ValidationResult — quest validation scenario', () {
    ValidationResult validateQuest({
      required String title,
      required int rewardGold,
    }) {
      return ValidationResult([
        if (title.trim().isEmpty)
          const ValidationFailure(
            message: 'Quest title cannot be empty',
            field: 'title',
          ),
        if (rewardGold < 0)
          const ValidationFailure(
            message: 'Reward cannot be negative',
            field: 'rewardGold',
          ),
      ]);
    }

    test('invalid quest does not throw — returns failures', () {
      expect(() => validateQuest(title: '', rewardGold: -100), returnsNormally);

      final result = validateQuest(title: '', rewardGold: -100);
      expect(result.isValid, isFalse);
      expect(result.failures, hasLength(2));
    });
  });
}
