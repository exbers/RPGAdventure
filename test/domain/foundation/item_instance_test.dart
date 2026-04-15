import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final swordId = ItemId('iron_sword');

  group('ItemInstance', () {
    group('construction', () {
      test('creates an instance with required fields', () {
        final instance = ItemInstance(instanceId: 'inst-1', itemId: swordId);
        expect(instance.instanceId, equals('inst-1'));
        expect(instance.itemId, equals(swordId));
        expect(instance.durability, isNull);
        expect(instance.modifiers, isEmpty);
      });

      test('accepts valid durability values', () {
        expect(
          ItemInstance(
            instanceId: 'i',
            itemId: swordId,
            durability: 0.0,
          ).durability,
          equals(0.0),
        );
        expect(
          ItemInstance(
            instanceId: 'i',
            itemId: swordId,
            durability: 1.0,
          ).durability,
          equals(1.0),
        );
        expect(
          ItemInstance(
            instanceId: 'i',
            itemId: swordId,
            durability: 0.5,
          ).durability,
          equals(0.5),
        );
      });

      test('throws when instanceId is empty', () {
        expect(
          () => ItemInstance(instanceId: '', itemId: swordId),
          throwsArgumentError,
        );
      });

      test('throws when durability is negative', () {
        expect(
          () =>
              ItemInstance(instanceId: 'i', itemId: swordId, durability: -0.1),
          throwsArgumentError,
        );
      });

      test('throws when durability exceeds 1.0', () {
        expect(
          () => ItemInstance(instanceId: 'i', itemId: swordId, durability: 1.1),
          throwsArgumentError,
        );
      });
    });

    group('isBroken', () {
      test('returns true when durability is 0.0', () {
        final instance = ItemInstance(
          instanceId: 'i',
          itemId: swordId,
          durability: 0.0,
        );
        expect(instance.isBroken, isTrue);
      });

      test('returns false when durability is null', () {
        final instance = ItemInstance(instanceId: 'i', itemId: swordId);
        expect(instance.isBroken, isFalse);
      });

      test('returns false when durability is positive', () {
        final instance = ItemInstance(
          instanceId: 'i',
          itemId: swordId,
          durability: 0.5,
        );
        expect(instance.isBroken, isFalse);
      });
    });

    group('withDurability', () {
      test('returns copy with updated durability', () {
        final original = ItemInstance(
          instanceId: 'i',
          itemId: swordId,
          durability: 1.0,
        );
        final worn = original.withDurability(0.3);
        expect(worn.durability, equals(0.3));
        expect(original.durability, equals(1.0)); // original unchanged
      });
    });

    group('withModifiers', () {
      test('merges new modifiers over existing', () {
        final base = ItemInstance(
          instanceId: 'i',
          itemId: swordId,
          modifiers: {'attack': 5},
        );
        final enchanted = base.withModifiers({'attack': 10, 'speed': 2});
        expect(enchanted.modifiers['attack'], equals(10));
        expect(enchanted.modifiers['speed'], equals(2));
        expect(base.modifiers['attack'], equals(5)); // original unchanged
      });
    });

    group('equality', () {
      test('equal instances produce same hashCode', () {
        final a = ItemInstance(
          instanceId: 'inst-1',
          itemId: swordId,
          durability: 0.8,
        );
        final b = ItemInstance(
          instanceId: 'inst-1',
          itemId: ItemId('iron_sword'),
          durability: 0.8,
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('instances with different instanceIds are not equal', () {
        final a = ItemInstance(instanceId: 'inst-1', itemId: swordId);
        final b = ItemInstance(instanceId: 'inst-2', itemId: swordId);
        expect(a, isNot(equals(b)));
      });
    });
  });
}
