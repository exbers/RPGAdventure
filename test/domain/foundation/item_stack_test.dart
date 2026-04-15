import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final swordId = ItemId('iron_sword');
  final shieldId = ItemId('wooden_shield');

  group('ItemStack', () {
    group('construction', () {
      test('creates a stack with given itemId and quantity', () {
        final stack = ItemStack(itemId: swordId, quantity: Quantity(5));
        expect(stack.itemId, equals(swordId));
        expect(stack.quantity, equals(Quantity(5)));
        expect(stack.metadata, isEmpty);
      });

      test('stores metadata as unmodifiable map', () {
        final stack = ItemStack(
          itemId: swordId,
          quantity: Quantity(1),
          metadata: {'quality': 'rare'},
        );
        expect(stack.metadata['quality'], equals('rare'));
        expect(
          () => (stack.metadata as dynamic)['quality'] = 'common',
          throwsUnsupportedError,
        );
      });

      test('throws when quantity is zero', () {
        expect(
          () => ItemStack(itemId: swordId, quantity: Quantity.zero),
          throwsArgumentError,
        );
      });
    });

    group('canMergeWith', () {
      test('returns true for same itemId and empty metadata', () {
        final a = ItemStack(itemId: swordId, quantity: Quantity(3));
        final b = ItemStack(itemId: swordId, quantity: Quantity(2));
        expect(a.canMergeWith(b), isTrue);
      });

      test('returns false for different itemIds', () {
        final a = ItemStack(itemId: swordId, quantity: Quantity(1));
        final b = ItemStack(itemId: shieldId, quantity: Quantity(1));
        expect(a.canMergeWith(b), isFalse);
      });

      test('returns true when metadata is identical', () {
        final a = ItemStack(
          itemId: swordId,
          quantity: Quantity(2),
          metadata: {'quality': 'rare'},
        );
        final b = ItemStack(
          itemId: swordId,
          quantity: Quantity(1),
          metadata: {'quality': 'rare'},
        );
        expect(a.canMergeWith(b), isTrue);
      });

      test('returns false when metadata differs', () {
        final a = ItemStack(
          itemId: swordId,
          quantity: Quantity(2),
          metadata: {'quality': 'rare'},
        );
        final b = ItemStack(
          itemId: swordId,
          quantity: Quantity(1),
          metadata: {'quality': 'common'},
        );
        expect(a.canMergeWith(b), isFalse);
      });
    });

    group('mergeWith', () {
      test('merges quantities of compatible stacks', () {
        final a = ItemStack(itemId: swordId, quantity: Quantity(3));
        final b = ItemStack(itemId: swordId, quantity: Quantity(7));
        final merged = a.mergeWith(b);
        expect(merged.quantity, equals(Quantity(10)));
        expect(merged.itemId, equals(swordId));
      });

      test('throws when stacks are incompatible', () {
        final a = ItemStack(itemId: swordId, quantity: Quantity(1));
        final b = ItemStack(itemId: shieldId, quantity: Quantity(1));
        expect(() => a.mergeWith(b), throwsArgumentError);
      });

      test('merged stack preserves metadata', () {
        final a = ItemStack(
          itemId: swordId,
          quantity: Quantity(1),
          metadata: {'tier': 1},
        );
        final b = ItemStack(
          itemId: swordId,
          quantity: Quantity(2),
          metadata: {'tier': 1},
        );
        final merged = a.mergeWith(b);
        expect(merged.metadata['tier'], equals(1));
      });
    });

    group('split', () {
      test('splits less-than-full amount', () {
        final stack = ItemStack(itemId: swordId, quantity: Quantity(10));
        final (:taken, :remaining) = stack.split(4);
        expect(taken.quantity, equals(Quantity(4)));
        expect(remaining, isNotNull);
        expect(remaining!.quantity, equals(Quantity(6)));
      });

      test('split full stack returns null remaining', () {
        final stack = ItemStack(itemId: swordId, quantity: Quantity(5));
        final (:taken, :remaining) = stack.split(5);
        expect(taken.quantity, equals(Quantity(5)));
        expect(remaining, isNull);
      });

      test('split preserves metadata on both parts', () {
        final stack = ItemStack(
          itemId: swordId,
          quantity: Quantity(6),
          metadata: {'quality': 'epic'},
        );
        final (:taken, :remaining) = stack.split(2);
        expect(taken.metadata['quality'], equals('epic'));
        expect(remaining!.metadata['quality'], equals('epic'));
      });

      test('throws when amount is zero', () {
        final stack = ItemStack(itemId: swordId, quantity: Quantity(5));
        expect(() => stack.split(0), throwsArgumentError);
      });

      test('throws when amount exceeds quantity', () {
        final stack = ItemStack(itemId: swordId, quantity: Quantity(3));
        expect(() => stack.split(10), throwsArgumentError);
      });
    });

    group('equality', () {
      test('equal stacks have same hashCode', () {
        final a = ItemStack(
          itemId: swordId,
          quantity: Quantity(5),
          metadata: {'quality': 'rare'},
        );
        final b = ItemStack(
          itemId: ItemId('iron_sword'),
          quantity: Quantity(5),
          metadata: {'quality': 'rare'},
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });
    });
  });
}
