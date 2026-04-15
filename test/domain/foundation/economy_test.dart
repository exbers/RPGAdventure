import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final potionId = ItemId('health_potion');
  const goldBase = Currency(currencyId: 'gold', amount: 10);

  group('PriceQuote', () {
    test('resolvedPrice equals basePrice when no modifier is set', () {
      final quote = PriceQuote(itemId: potionId, basePrice: goldBase);
      expect(quote.resolvedPrice, equals(goldBase));
    });

    test('resolvedPrice applies modifier callback', () {
      final quote = PriceQuote(
        itemId: potionId,
        basePrice: goldBase,
        modifier: (_, base) =>
            Currency(currencyId: base.currencyId, amount: base.amount * 2),
      );
      expect(quote.resolvedPrice.amount, equals(20));
    });

    test('modifier receives correct itemId and basePrice', () {
      EntityId? capturedId;
      Currency? capturedBase;

      PriceQuote(
        itemId: potionId,
        basePrice: goldBase,
        modifier: (id, base) {
          capturedId = id;
          capturedBase = base;
          return base;
        },
      ).resolvedPrice;

      expect(capturedId, equals(potionId));
      expect(capturedBase, equals(goldBase));
    });
  });

  group('BuyRequest', () {
    test('creates request with correct fields', () {
      final req = BuyRequest(
        itemId: potionId,
        quantity: Quantity(3),
        agreedPrice: goldBase,
      );
      expect(req.itemId, equals(potionId));
      expect(req.quantity, equals(Quantity(3)));
      expect(req.agreedPrice, equals(goldBase));
    });

    test('totalCost is quantity × agreedPrice', () {
      final req = BuyRequest(
        itemId: potionId,
        quantity: Quantity(5),
        agreedPrice: goldBase,
      );
      expect(req.totalCost.amount, equals(50));
      expect(req.totalCost.currencyId, equals('gold'));
    });

    test('throws when quantity is zero', () {
      expect(
        () => BuyRequest(
          itemId: potionId,
          quantity: Quantity.zero,
          agreedPrice: goldBase,
        ),
        throwsArgumentError,
      );
    });
  });

  group('SellRequest', () {
    test('totalProceeds is quantity × agreedPrice', () {
      final req = SellRequest(
        itemId: potionId,
        quantity: Quantity(4),
        agreedPrice: goldBase,
      );
      expect(req.totalProceeds.amount, equals(40));
    });

    test('throws when quantity is zero', () {
      expect(
        () => SellRequest(
          itemId: potionId,
          quantity: Quantity.zero,
          agreedPrice: goldBase,
        ),
        throwsArgumentError,
      );
    });
  });

  group('LimitedStock', () {
    test('creates stock with given values', () {
      final stock = LimitedStock(
        currentQuantity: Quantity(5),
        maxQuantity: Quantity(20),
      );
      expect(stock.currentQuantity, equals(Quantity(5)));
      expect(stock.maxQuantity, equals(Quantity(20)));
      expect(stock.isEmpty, isFalse);
      expect(stock.isFull, isFalse);
    });

    test('isEmpty returns true when currentQuantity is zero', () {
      final stock = LimitedStock(
        currentQuantity: Quantity.zero,
        maxQuantity: Quantity(10),
      );
      expect(stock.isEmpty, isTrue);
    });

    test('isFull returns true when at max', () {
      final stock = LimitedStock(
        currentQuantity: Quantity(10),
        maxQuantity: Quantity(10),
      );
      expect(stock.isFull, isTrue);
    });

    test('throws when currentQuantity exceeds maxQuantity', () {
      expect(
        () => LimitedStock(
          currentQuantity: Quantity(15),
          maxQuantity: Quantity(10),
        ),
        throwsArgumentError,
      );
    });

    group('consume', () {
      test('deducts sold units', () {
        final stock = LimitedStock(
          currentQuantity: Quantity(10),
          maxQuantity: Quantity(20),
        );
        final after = stock.consume(3);
        expect(after.currentQuantity, equals(Quantity(7)));
      });

      test('throws when consuming more than available', () {
        final stock = LimitedStock(
          currentQuantity: Quantity(5),
          maxQuantity: Quantity(20),
        );
        expect(() => stock.consume(10), throwsArgumentError);
      });

      test('throws when units is zero', () {
        final stock = LimitedStock(
          currentQuantity: Quantity(5),
          maxQuantity: Quantity(20),
        );
        expect(() => stock.consume(0), throwsArgumentError);
      });
    });

    group('restock', () {
      test('adds units up to max', () {
        final stock = LimitedStock(
          currentQuantity: Quantity(5),
          maxQuantity: Quantity(10),
        );
        final after = stock.restock(3);
        expect(after.currentQuantity, equals(Quantity(8)));
      });

      test('caps restock at maxQuantity', () {
        final stock = LimitedStock(
          currentQuantity: Quantity(8),
          maxQuantity: Quantity(10),
        );
        final after = stock.restock(100);
        expect(after.currentQuantity, equals(Quantity(10)));
      });

      test('throws when units is zero', () {
        final stock = LimitedStock(
          currentQuantity: Quantity(5),
          maxQuantity: Quantity(20),
        );
        expect(() => stock.restock(0), throwsArgumentError);
      });

      test('unbounded stock grows without cap', () {
        final stock = LimitedStock(currentQuantity: Quantity(5));
        final after = stock.restock(1000);
        expect(after.currentQuantity, equals(Quantity(1005)));
        expect(after.isFull, isTrue); // unbounded is always "full"
      });
    });
  });

  group('RestockSchedule', () {
    test('creates schedule with interval and amount', () {
      final schedule = RestockSchedule(
        interval: GameDuration.fromDays(1),
        restockAmount: Quantity(20),
      );
      expect(schedule.restockAmount, equals(Quantity(20)));
    });

    test('throws when restockAmount is zero', () {
      expect(
        () => RestockSchedule(
          interval: GameDuration.fromDays(1),
          restockAmount: Quantity.zero,
        ),
        throwsArgumentError,
      );
    });

    test('apply increases stock by restockAmount', () {
      final schedule = RestockSchedule(
        interval: GameDuration.fromDays(1),
        restockAmount: Quantity(5),
      );
      final stock = LimitedStock(
        currentQuantity: Quantity(3),
        maxQuantity: Quantity(20),
      );
      final after = schedule.apply(stock);
      expect(after.currentQuantity, equals(Quantity(8)));
    });

    test('apply caps at maxQuantity', () {
      final schedule = RestockSchedule(
        interval: GameDuration.fromDays(1),
        restockAmount: Quantity(50),
      );
      final stock = LimitedStock(
        currentQuantity: Quantity(8),
        maxQuantity: Quantity(10),
      );
      final after = schedule.apply(stock);
      expect(after.currentQuantity, equals(Quantity(10)));
    });
  });
}
