import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Weight', () {
    test('zero constant is zero grams', () {
      expect(Weight.zero.inGrams, 0);
      expect(Weight.zero.inKilograms, 0);
    });

    test('negative amount throws ArgumentError', () {
      expect(() => Weight(-1, WeightUnit.kilograms), throwsArgumentError);
    });

    group('unit conversion', () {
      test('kilograms to grams', () {
        final w = Weight(5, WeightUnit.kilograms);
        expect(w.inGrams, 5000);
        expect(w.inKilograms, 5);
      });

      test('grams stays in grams', () {
        final w = Weight(500, WeightUnit.grams);
        expect(w.inGrams, 500);
        expect(w.inKilograms, 0.5);
      });
    });

    group('arithmetic', () {
      test('addition returns sum in grams', () {
        final a = Weight(1, WeightUnit.kilograms);
        final b = Weight(500, WeightUnit.grams);
        final sum = a + b;
        expect(sum.inGrams, 1500);
        expect(sum.unit, WeightUnit.grams);
      });

      test('subtraction returns difference in grams', () {
        final a = Weight(2, WeightUnit.kilograms);
        final b = Weight(500, WeightUnit.grams);
        final diff = a - b;
        expect(diff.inGrams, 1500);
      });

      test('subtraction below zero throws ArgumentError', () {
        final a = Weight(100, WeightUnit.grams);
        final b = Weight(1, WeightUnit.kilograms);
        expect(() => a - b, throwsArgumentError);
      });
    });

    group('fitsWithin', () {
      test('returns true when weight <= capacity', () {
        final cargo = Weight(5, WeightUnit.kilograms);
        final capacity = Weight(10, WeightUnit.kilograms);
        expect(cargo.fitsWithin(capacity), isTrue);
      });

      test('returns true at exact capacity', () {
        final cargo = Weight(10, WeightUnit.kilograms);
        final capacity = Weight(10, WeightUnit.kilograms);
        expect(cargo.fitsWithin(capacity), isTrue);
      });

      test('returns false when weight > capacity', () {
        final cargo = Weight(11, WeightUnit.kilograms);
        final capacity = Weight(10, WeightUnit.kilograms);
        expect(cargo.fitsWithin(capacity), isFalse);
      });
    });

    group('equality', () {
      test('equal when inGrams is the same regardless of unit', () {
        final a = Weight(1, WeightUnit.kilograms);
        final b = Weight(1000, WeightUnit.grams);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal for different weights', () {
        expect(
          Weight(1, WeightUnit.kilograms),
          isNot(equals(Weight(2, WeightUnit.kilograms))),
        );
      });
    });

    group('toString', () {
      test('includes amount and unit name', () {
        final w = Weight(15, WeightUnit.kilograms);
        expect(w.toString(), contains('15'));
        expect(w.toString(), contains('kilograms'));
      });
    });

    group('serialization', () {
      test('toJson produces expected map', () {
        final w = Weight(15, WeightUnit.kilograms);
        expect(w.toJson(), {'amount': 15, 'unit': 'kilograms'});
      });

      test('fromJson round-trips kilograms', () {
        final w = Weight(15, WeightUnit.kilograms);
        expect(Weight.fromJson(w.toJson()), equals(w));
      });

      test('fromJson round-trips grams', () {
        final w = Weight(500, WeightUnit.grams);
        expect(Weight.fromJson(w.toJson()), equals(w));
      });

      test('fromJson with unknown unit throws ArgumentError', () {
        expect(
          () => Weight.fromJson({'amount': 5, 'unit': 'pounds'}),
          throwsArgumentError,
        );
      });

      test('fromJson with non-numeric amount throws ArgumentError', () {
        expect(
          () => Weight.fromJson({'amount': 'heavy', 'unit': 'kilograms'}),
          throwsArgumentError,
        );
      });

      test('fromJson with non-string unit throws ArgumentError', () {
        expect(
          () => Weight.fromJson({'amount': 5, 'unit': 1}),
          throwsArgumentError,
        );
      });
    });
  });
}
