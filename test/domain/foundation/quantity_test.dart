import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Quantity', () {
    test('zero constant has value 0 and isEmpty', () {
      expect(Quantity.zero.value, 0);
      expect(Quantity.zero.isEmpty, isTrue);
      expect(Quantity.zero.isNotEmpty, isFalse);
    });

    test('non-zero quantity is not empty', () {
      final q = Quantity(5);
      expect(q.isEmpty, isFalse);
      expect(q.isNotEmpty, isTrue);
    });

    test('negative value throws ArgumentError', () {
      expect(() => Quantity(-1), throwsArgumentError);
    });

    test('add increases value', () {
      expect(Quantity(3).add(2), equals(Quantity(5)));
    });

    test('add with negative amount throws ArgumentError', () {
      expect(() => Quantity(5).add(-1), throwsArgumentError);
    });

    test('subtract decreases value', () {
      expect(Quantity(5).subtract(3), equals(Quantity(2)));
    });

    test('subtract to zero returns Quantity.zero', () {
      expect(Quantity(3).subtract(3), equals(Quantity.zero));
    });

    test('subtract past zero clamps to zero', () {
      expect(Quantity(3).subtract(10), equals(Quantity.zero));
    });

    test('subtract with negative amount throws ArgumentError', () {
      expect(() => Quantity(5).subtract(-1), throwsArgumentError);
    });

    test('canFulfill returns true when sufficient', () {
      expect(Quantity(10).canFulfill(Quantity(5)), isTrue);
      expect(Quantity(5).canFulfill(Quantity(5)), isTrue);
    });

    test('canFulfill returns false when insufficient', () {
      expect(Quantity(4).canFulfill(Quantity(5)), isFalse);
    });

    test('equality and hashCode', () {
      expect(Quantity(7), equals(Quantity(7)));
      expect(Quantity(7).hashCode, equals(Quantity(7).hashCode));
      expect(Quantity(7), isNot(equals(Quantity(8))));
    });

    group('serialization', () {
      test('toJson returns the integer value', () {
        expect(Quantity(42).toJson(), 42);
      });

      test('fromJson round-trips correctly', () {
        final q = Quantity(99);
        expect(Quantity.fromJson(q.toJson()), equals(q));
      });

      test('fromJson with non-integer throws ArgumentError', () {
        expect(() => Quantity.fromJson('5'), throwsArgumentError);
        expect(() => Quantity.fromJson(null), throwsArgumentError);
      });

      test('fromJson with negative value throws ArgumentError', () {
        expect(() => Quantity.fromJson(-1), throwsArgumentError);
      });
    });
  });
}
