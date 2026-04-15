import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InventoryCapacity', () {
    final fiveKg = Weight(5, WeightUnit.kilograms);
    final tenKg = Weight(10, WeightUnit.kilograms);
    final threeKg = Weight(3, WeightUnit.kilograms);

    group('construction', () {
      test('creates an empty capacity with max constraints', () {
        final cap = InventoryCapacity(maxSlots: Quantity(10), maxWeight: tenKg);
        expect(cap.usedSlots, equals(Quantity.zero));
        expect(cap.currentWeight, equals(Weight.zero));
      });

      test(
        'creates unbounded capacity when maxSlots and maxWeight are null',
        () {
          final cap = InventoryCapacity();
          expect(cap.maxSlots, isNull);
          expect(cap.maxWeight, isNull);
          expect(cap.hasSlotSpace, isTrue);
          expect(
            cap.canAcceptWeight(Weight(9999, WeightUnit.kilograms)),
            isTrue,
          );
        },
      );

      test('throws when usedSlots exceeds maxSlots', () {
        expect(
          () =>
              InventoryCapacity(maxSlots: Quantity(5), usedSlots: Quantity(6)),
          throwsArgumentError,
        );
      });

      test('throws when currentWeight exceeds maxWeight', () {
        expect(
          () => InventoryCapacity(maxWeight: fiveKg, currentWeight: tenKg),
          throwsArgumentError,
        );
      });
    });

    group('availableSlots', () {
      test('returns null for unbounded capacity', () {
        expect(InventoryCapacity().availableSlots, isNull);
      });

      test('returns remaining slots', () {
        final cap = InventoryCapacity(
          maxSlots: Quantity(10),
          usedSlots: Quantity(3),
        );
        expect(cap.availableSlots, equals(Quantity(7)));
      });
    });

    group('availableWeight', () {
      test('returns null for unbounded capacity', () {
        expect(InventoryCapacity().availableWeight, isNull);
      });

      test('returns remaining weight headroom', () {
        final cap = InventoryCapacity(maxWeight: tenKg, currentWeight: threeKg);
        expect(cap.availableWeight!.inGrams, equals(7000));
      });
    });

    group('canAcceptWeight', () {
      test('returns true within limit', () {
        final cap = InventoryCapacity(maxWeight: tenKg, currentWeight: fiveKg);
        expect(cap.canAcceptWeight(fiveKg), isTrue);
      });

      test('returns false beyond limit — overflow scenario', () {
        final cap = InventoryCapacity(maxWeight: tenKg, currentWeight: fiveKg);
        expect(cap.canAcceptWeight(tenKg), isFalse);
      });
    });

    group('canAccept', () {
      test('returns false when no slot space', () {
        final cap = InventoryCapacity(
          maxSlots: Quantity(1),
          usedSlots: Quantity(1),
          maxWeight: tenKg,
        );
        expect(cap.canAccept(fiveKg), isFalse);
      });

      test('returns false when weight would overflow', () {
        final cap = InventoryCapacity(
          maxSlots: Quantity(10),
          maxWeight: fiveKg,
          currentWeight: threeKg,
        );
        expect(cap.canAccept(tenKg), isFalse);
      });

      test('returns true when both slots and weight fit', () {
        final cap = InventoryCapacity(
          maxSlots: Quantity(10),
          usedSlots: Quantity(4),
          maxWeight: tenKg,
          currentWeight: threeKg,
        );
        expect(cap.canAccept(fiveKg), isTrue);
      });
    });

    group('addItem', () {
      test('increments slot and weight', () {
        final cap = InventoryCapacity(
          maxSlots: Quantity(10),
          maxWeight: tenKg,
          usedSlots: Quantity(2),
          currentWeight: threeKg,
        );
        final updated = cap.addItem(fiveKg);
        expect(updated.usedSlots, equals(Quantity(3)));
        expect(updated.currentWeight.inGrams, equals(8000));
      });

      test('throws when adding would violate weight limit', () {
        final cap = InventoryCapacity(
          maxSlots: Quantity(10),
          maxWeight: fiveKg,
          currentWeight: threeKg,
        );
        expect(() => cap.addItem(tenKg), throwsArgumentError);
      });

      test('throws when adding would violate slot limit', () {
        final cap = InventoryCapacity(
          maxSlots: Quantity(1),
          usedSlots: Quantity(1),
          maxWeight: tenKg,
        );
        expect(() => cap.addItem(fiveKg), throwsArgumentError);
      });
    });

    group('removeItem', () {
      test('decrements slot and weight', () {
        final cap = InventoryCapacity(
          maxSlots: Quantity(10),
          maxWeight: tenKg,
          usedSlots: Quantity(3),
          currentWeight: threeKg,
        );
        final updated = cap.removeItem(Weight(1, WeightUnit.kilograms));
        expect(updated.usedSlots, equals(Quantity(2)));
        expect(updated.currentWeight.inGrams, equals(2000));
      });

      test('throws when removing more weight than held', () {
        final cap = InventoryCapacity(
          maxWeight: tenKg,
          usedSlots: Quantity(1),
          currentWeight: fiveKg,
        );
        expect(() => cap.removeItem(tenKg), throwsArgumentError);
      });
    });

    group('equality', () {
      test('equal capacities produce same hashCode', () {
        final a = InventoryCapacity(
          maxSlots: Quantity(10),
          maxWeight: tenKg,
          usedSlots: Quantity(3),
          currentWeight: threeKg,
        );
        final b = InventoryCapacity(
          maxSlots: Quantity(10),
          maxWeight: Weight(10, WeightUnit.kilograms),
          usedSlots: Quantity(3),
          currentWeight: Weight(3, WeightUnit.kilograms),
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
