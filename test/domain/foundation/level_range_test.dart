import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelRange', () {
    const range5to10 = LevelRange(min: 5, max: 10);

    test('contains returns true for levels inside range', () {
      expect(range5to10.contains(5), isTrue);
      expect(range5to10.contains(7), isTrue);
      expect(range5to10.contains(10), isTrue);
    });

    test('contains returns false for levels outside range', () {
      expect(range5to10.contains(4), isFalse);
      expect(range5to10.contains(11), isFalse);
    });

    test('overlaps detects shared levels', () {
      const overlapping = LevelRange(min: 8, max: 15);
      const adjacent = LevelRange(min: 10, max: 12);
      const noOverlap = LevelRange(min: 11, max: 20);

      expect(range5to10.overlaps(overlapping), isTrue);
      expect(range5to10.overlaps(adjacent), isTrue);
      expect(range5to10.overlaps(noOverlap), isFalse);
    });

    test('single constructor creates a range of one level', () {
      const single = LevelRange.single(7);
      expect(single.min, 7);
      expect(single.max, 7);
      expect(single.contains(7), isTrue);
      expect(single.contains(8), isFalse);
    });

    test('equality and hashCode', () {
      const a = LevelRange(min: 1, max: 5);
      const b = LevelRange(min: 1, max: 5);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('toString includes min and max', () {
      expect(range5to10.toString(), contains('5'));
      expect(range5to10.toString(), contains('10'));
    });

    group('serialization', () {
      test('toJson produces expected map', () {
        expect(range5to10.toJson(), {'min': 5, 'max': 10});
      });

      test('fromJson round-trips correctly', () {
        expect(LevelRange.fromJson(range5to10.toJson()), equals(range5to10));
      });

      test('fromJson with non-integer min throws', () {
        expect(
          () => LevelRange.fromJson({'min': '5', 'max': 10}),
          throwsArgumentError,
        );
      });

      test('fromJson with non-integer max throws', () {
        expect(
          () => LevelRange.fromJson({'min': 5, 'max': null}),
          throwsArgumentError,
        );
      });

      test('fromJson with min > max throws (assert/ArgumentError)', () {
        // LevelRange constructor enforces max >= min.
        expect(
          () => LevelRange.fromJson({'min': 10, 'max': 5}),
          throwsA(anything),
        );
      });
    });
  });
}
