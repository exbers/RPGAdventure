import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameDuration', () {
    test('zero constant is zero seconds', () {
      expect(GameDuration.zero.seconds, 0);
      expect(GameDuration.zero.isZero, isTrue);
    });

    test('negative seconds throws ArgumentError', () {
      expect(() => GameDuration(seconds: -1), throwsArgumentError);
    });

    group('factory constructors', () {
      test('fromMinutes converts to seconds', () {
        expect(GameDuration.fromMinutes(5).seconds, 300);
      });

      test('fromMinutes negative throws ArgumentError', () {
        expect(() => GameDuration.fromMinutes(-1), throwsArgumentError);
      });

      test('fromHours converts to seconds', () {
        expect(GameDuration.fromHours(2).seconds, 7200);
      });

      test('fromHours negative throws ArgumentError', () {
        expect(() => GameDuration.fromHours(-1), throwsArgumentError);
      });

      test('fromDays converts to seconds', () {
        expect(GameDuration.fromDays(1).seconds, 86400);
      });

      test('fromDays negative throws ArgumentError', () {
        expect(() => GameDuration.fromDays(-1), throwsArgumentError);
      });
    });

    group('derived getters', () {
      final twoHours = GameDuration(seconds: 7200);

      test('inMinutes', () => expect(twoHours.inMinutes, 120));
      test('inHours', () => expect(twoHours.inHours, 2));
      test('inDays', () => expect(GameDuration(seconds: 172800).inDays, 2));

      test('isZero false for non-zero', () {
        expect(twoHours.isZero, isFalse);
      });
    });

    group('arithmetic', () {
      final oneHour = GameDuration.fromHours(1);
      final thirtyMin = GameDuration.fromMinutes(30);

      test('addition returns sum', () {
        expect((oneHour + thirtyMin).seconds, 5400);
      });

      test('subtraction returns difference', () {
        expect((oneHour - thirtyMin).seconds, 1800);
      });

      test('subtraction to zero clamps to zero', () {
        expect((thirtyMin - oneHour), equals(GameDuration.zero));
      });
    });

    group('comparison operators', () {
      final small = GameDuration(seconds: 10);
      final large = GameDuration(seconds: 100);

      test('greater than', () {
        expect(large > small, isTrue);
        expect(small > large, isFalse);
      });

      test('less than', () {
        expect(small < large, isTrue);
        expect(large < small, isFalse);
      });

      test('greater than or equal', () {
        expect(large >= small, isTrue);
        expect(large >= large, isTrue);
        expect(small >= large, isFalse);
      });

      test('less than or equal', () {
        expect(small <= large, isTrue);
        expect(small <= small, isTrue);
        expect(large <= small, isFalse);
      });

      test('compareTo ordering', () {
        expect(small.compareTo(large), isNegative);
        expect(large.compareTo(small), isPositive);
        expect(small.compareTo(small), isZero);
      });
    });

    group('equality', () {
      test('equal when seconds match', () {
        expect(GameDuration(seconds: 60), equals(GameDuration(seconds: 60)));
        expect(
          GameDuration(seconds: 60).hashCode,
          equals(GameDuration(seconds: 60).hashCode),
        );
      });

      test('not equal for different seconds', () {
        expect(
          GameDuration(seconds: 60),
          isNot(equals(GameDuration(seconds: 61))),
        );
      });
    });

    group('toString', () {
      test('includes seconds', () {
        expect(GameDuration(seconds: 3600).toString(), contains('3600'));
      });
    });

    group('serialization', () {
      test('toJson produces expected map', () {
        expect(GameDuration(seconds: 3600).toJson(), {'seconds': 3600});
      });

      test('fromJson round-trips correctly', () {
        final d = GameDuration(seconds: 7200);
        expect(GameDuration.fromJson(d.toJson()), equals(d));
      });

      test('fromJson with zero is valid', () {
        expect(
          GameDuration.fromJson({'seconds': 0}),
          equals(GameDuration.zero),
        );
      });

      test('fromJson with non-integer seconds throws ArgumentError', () {
        expect(
          () => GameDuration.fromJson({'seconds': '3600'}),
          throwsArgumentError,
        );
        expect(
          () => GameDuration.fromJson({'seconds': null}),
          throwsArgumentError,
        );
      });
    });
  });
}
