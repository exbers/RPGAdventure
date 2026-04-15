import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/core.dart';

void main() {
  group('Result — Success branch', () {
    test('isSuccess is true, isFailure is false', () {
      const result = Success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
    });

    test('valueOrNull returns the value', () {
      const result = Success('hero');

      expect(result.valueOrNull, 'hero');
    });

    test('failureOrNull returns null', () {
      const result = Success(true);

      expect(result.failureOrNull, isNull);
    });

    test('map transforms the value', () {
      const result = Success(3);
      final mapped = result.map((v) => v * 2);

      expect(mapped, isA<Success<int>>());
      expect((mapped as Success<int>).value, 6);
    });

    test('flatMap chains to another Success', () {
      const result = Success(10);
      final chained = result.flatMap((v) => Success(v + 5));

      expect((chained as Success<int>).value, 15);
    });

    test('flatMap chains to a Failure', () {
      const result = Success(10);
      final chained = result.flatMap<int>(
        (_) => const Failure(ValidationFailure(message: 'too large')),
      );

      expect(chained, isA<Failure<int>>());
    });

    test('toString contains Success label', () {
      expect(const Success(7).toString(), contains('Success'));
    });
  });

  group('Result — Failure branch', () {
    const failure = ValidationFailure(message: 'Name is required');

    test('isFailure is true, isSuccess is false', () {
      const result = Failure<int>(failure);

      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('valueOrNull returns null', () {
      const result = Failure<String>(failure);

      expect(result.valueOrNull, isNull);
    });

    test('failureOrNull returns the failure', () {
      const result = Failure<String>(failure);

      expect(result.failureOrNull, same(failure));
    });

    test('map passes Failure through without calling transform', () {
      var called = false;
      const result = Failure<int>(failure);
      final mapped = result.map((v) {
        called = true;
        return v * 2;
      });

      expect(called, isFalse);
      expect(mapped, isA<Failure<int>>());
    });

    test('flatMap passes Failure through without calling transform', () {
      var called = false;
      const result = Failure<int>(failure);
      final chained = result.flatMap<int>((v) {
        called = true;
        return Success(v);
      });

      expect(called, isFalse);
      expect(chained, isA<Failure<int>>());
    });

    test('toString contains Failure label and message', () {
      const result = Failure<void>(failure);
      final str = result.toString();

      expect(str, contains('Failure'));
      expect(str, contains('Name is required'));
    });
  });

  group('Result — exhaustive switch', () {
    test('switch handles both branches without default', () {
      Result<int> makeResult(bool succeed) => succeed
          ? const Success(1)
          : const Failure(CombatFailure(message: 'err'));

      String label(Result<int> r) => switch (r) {
        Success(:final value) => 'ok:$value',
        Failure(:final failure) => 'fail:${failure.message}',
      };

      expect(label(makeResult(true)), 'ok:1');
      expect(label(makeResult(false)), 'fail:err');
    });
  });
}
