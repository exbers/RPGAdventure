import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currency', () {
    const gold100 = Currency(currencyId: 'gold', amount: 100);
    const gold50 = Currency(currencyId: 'gold', amount: 50);

    test('equality uses currencyId and amount', () {
      expect(gold100, equals(const Currency(currencyId: 'gold', amount: 100)));
      expect(gold100, isNot(equals(gold50)));
    });

    test('add increases amount', () {
      expect(gold50.add(50), equals(gold100));
    });

    test('subtract decreases amount', () {
      expect(gold100.subtract(50), equals(gold50));
    });

    test('subtract to zero is allowed', () {
      expect(
        gold50.subtract(50),
        equals(const Currency(currencyId: 'gold', amount: 0)),
      );
    });

    test('add with negative delta throws', () {
      expect(() => gold50.add(-60), throwsArgumentError);
    });

    test('subtract below zero throws', () {
      expect(() => gold50.subtract(60), throwsArgumentError);
    });

    test('canAfford returns true when amount >= price', () {
      expect(gold100.canAfford(gold50), isTrue);
      expect(gold100.canAfford(gold100), isTrue);
    });

    test('canAfford returns false when amount < price', () {
      expect(gold50.canAfford(gold100), isFalse);
    });

    test('canAfford throws ArgumentError for mismatched currencyId', () {
      const silver = Currency(currencyId: 'silver', amount: 10);
      expect(() => gold100.canAfford(silver), throwsArgumentError);
    });

    test('toString includes currencyId and amount', () {
      expect(gold100.toString(), contains('gold'));
      expect(gold100.toString(), contains('100'));
    });

    group('serialization', () {
      test('toJson produces expected map', () {
        expect(gold100.toJson(), {'currencyId': 'gold', 'amount': 100});
      });

      test('fromJson round-trips correctly', () {
        expect(Currency.fromJson(gold100.toJson()), equals(gold100));
      });

      test('fromJson with missing currencyId throws', () {
        expect(() => Currency.fromJson({'amount': 50}), throwsArgumentError);
      });

      test('fromJson with empty currencyId throws', () {
        expect(
          () => Currency.fromJson({'currencyId': '', 'amount': 50}),
          throwsArgumentError,
        );
      });

      test('fromJson with negative amount throws', () {
        expect(
          () => Currency.fromJson({'currencyId': 'gold', 'amount': -1}),
          throwsArgumentError,
        );
      });

      test('fromJson with non-integer amount throws', () {
        expect(
          () => Currency.fromJson({'currencyId': 'gold', 'amount': '100'}),
          throwsArgumentError,
        );
      });
    });
  });
}
