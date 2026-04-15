import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MissingIdError', () {
    const error = MissingIdError(
      field: 'loot_table[0].itemId',
      id: 'nonexistent_item',
      idType: 'ItemId',
    );

    test('equality uses all three fields', () {
      const same = MissingIdError(
        field: 'loot_table[0].itemId',
        id: 'nonexistent_item',
        idType: 'ItemId',
      );
      expect(error, equals(same));
      expect(error.hashCode, equals(same.hashCode));
    });

    test('not equal when field differs', () {
      const other = MissingIdError(
        field: 'different_field',
        id: 'nonexistent_item',
        idType: 'ItemId',
      );
      expect(error, isNot(equals(other)));
    });

    test('toString includes all fields', () {
      final s = error.toString();
      expect(s, contains('ItemId'));
      expect(s, contains('nonexistent_item'));
      expect(s, contains('loot_table[0].itemId'));
    });
  });

  group('IdValidationResult', () {
    test('valid result has no errors and isValid is true', () {
      const result = IdValidationResult.valid();
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('result with errors is not valid', () {
      const error = MissingIdError(
        field: 'itemId',
        id: 'ghost_item',
        idType: 'ItemId',
      );
      final result = IdValidationResult([error]);
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(1));
    });

    test('toReport for valid result mentions valid', () {
      expect(const IdValidationResult.valid().toReport(), contains('valid'));
    });

    test('toReport for invalid result includes error count and details', () {
      const error = MissingIdError(
        field: 'zone.monsterId',
        id: 'missing_boss',
        idType: 'MonsterId',
      );
      final report = IdValidationResult([error]).toReport();
      expect(report, contains('1 error'));
      expect(report, contains('MonsterId'));
      expect(report, contains('missing_boss'));
      expect(report, contains('zone.monsterId'));
    });
  });

  group('IdValidator', () {
    test('no errors when all IDs are known', () {
      final validator = IdValidator();
      validator.registerKnown<ItemId>('ItemId', [
        'iron_sword',
        'wooden_shield',
      ]);

      validator.checkId<ItemId>(
        field: 'inventory[0]',
        id: ItemId('iron_sword'),
        idType: 'ItemId',
      );

      final result = validator.finish();
      expect(result.isValid, isTrue);
    });

    test('records error for unknown ID', () {
      final validator = IdValidator();
      validator.registerKnown<ItemId>('ItemId', ['iron_sword']);

      validator.checkId<ItemId>(
        field: 'loot_table[0].itemId',
        id: ItemId('ghost_item'),
        idType: 'ItemId',
      );

      final result = validator.finish();
      expect(result.isValid, isFalse);
      expect(result.errors.first.id, 'ghost_item');
      expect(result.errors.first.field, 'loot_table[0].itemId');
      expect(result.errors.first.idType, 'ItemId');
    });

    test('records error when no registry registered for type', () {
      final validator = IdValidator();
      // No registry for QuestId registered.
      validator.checkId<QuestId>(
        field: 'questId',
        id: QuestId('some_quest'),
        idType: 'QuestId',
      );

      final result = validator.finish();
      expect(result.isValid, isFalse);
      expect(result.errors.first.idType, 'QuestId');
    });

    test('accumulates multiple errors across different types', () {
      final validator = IdValidator()
        ..registerKnown<ItemId>('ItemId', ['item_a'])
        ..registerKnown<ZoneId>('ZoneId', ['zone_1']);

      validator.checkId<ItemId>(
        field: 'field1',
        id: ItemId('item_missing'),
        idType: 'ItemId',
      );
      validator.checkId<ZoneId>(
        field: 'field2',
        id: ZoneId('zone_missing'),
        idType: 'ZoneId',
      );
      validator.checkId<ItemId>(
        field: 'field3',
        id: ItemId('item_a'),
        idType: 'ItemId',
      );

      final result = validator.finish();
      expect(result.isValid, isFalse);
      expect(result.errors, hasLength(2));
    });

    test('checkRaw records error for unknown raw ID', () {
      final validator = IdValidator();
      validator.registerKnown<ItemId>('ItemId', ['iron_sword']);

      validator.checkRaw(
        field: 'recipe.output',
        rawId: 'unknown_item',
        idType: 'ItemId',
      );

      final result = validator.finish();
      expect(result.isValid, isFalse);
      expect(result.errors.first.id, 'unknown_item');
    });

    test('checkRaw passes for known raw ID', () {
      final validator = IdValidator();
      validator.registerKnown<ItemId>('ItemId', ['iron_sword']);

      validator.checkRaw(
        field: 'recipe.output',
        rawId: 'iron_sword',
        idType: 'ItemId',
      );

      expect(validator.finish().isValid, isTrue);
    });

    test('finish returns valid result when no checks performed', () {
      final validator = IdValidator();
      expect(validator.finish().isValid, isTrue);
    });
  });
}
