import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EntityId equality', () {
    test('same type and same value are equal', () {
      final a = ItemId('iron_sword');
      final b = ItemId('iron_sword');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('same value but different types are not equal', () {
      final item = ItemId('iron_sword');
      final monster = MonsterId('iron_sword');
      // ignore: unrelated_type_equality_checks
      expect(item == monster, isFalse);
    });

    test('different values are not equal', () {
      final a = ItemId('iron_sword');
      final b = ItemId('wooden_shield');
      expect(a, isNot(equals(b)));
    });

    test('toString includes type name and value', () {
      final id = QuestId('kill_ten_rats');
      expect(id.toString(), contains('QuestId'));
      expect(id.toString(), contains('kill_ten_rats'));
    });
  });

  group('EntityId validation', () {
    test('empty value throws ArgumentError', () {
      expect(() => ItemId(''), throwsArgumentError);
    });

    test('non-empty value is accepted', () {
      expect(() => ItemId('x'), returnsNormally);
    });
  });

  group('Typed ID constructors', () {
    test('all typed IDs expose their value', () {
      expect(ItemId('i').value, 'i');
      expect(MonsterId('m').value, 'm');
      expect(QuestId('q').value, 'q');
      expect(ZoneId('z').value, 'z');
      expect(TownId('t').value, 't');
      expect(RecipeId('r').value, 'r');
      expect(PetId('p').value, 'p');
      expect(FactionId('f').value, 'f');
      expect(SkillId('s').value, 's');
    });
  });

  group('EntityId serialization', () {
    test('toJson returns the raw string value', () {
      expect(ItemId('iron_sword').toJson(), 'iron_sword');
      expect(QuestId('kill_ten_rats').toJson(), 'kill_ten_rats');
    });

    test('ItemId.fromJson round-trips correctly', () {
      final id = ItemId('iron_sword');
      expect(ItemId.fromJson(id.toJson()), equals(id));
    });

    test('MonsterId.fromJson round-trips correctly', () {
      final id = MonsterId('goblin');
      expect(MonsterId.fromJson(id.toJson()), equals(id));
    });

    test('QuestId.fromJson round-trips correctly', () {
      final id = QuestId('kill_ten_rats');
      expect(QuestId.fromJson(id.toJson()), equals(id));
    });

    test('ZoneId.fromJson round-trips correctly', () {
      final id = ZoneId('dark_forest');
      expect(ZoneId.fromJson(id.toJson()), equals(id));
    });

    test('TownId.fromJson round-trips correctly', () {
      final id = TownId('starter_town');
      expect(TownId.fromJson(id.toJson()), equals(id));
    });

    test('RecipeId.fromJson round-trips correctly', () {
      final id = RecipeId('iron_ingot');
      expect(RecipeId.fromJson(id.toJson()), equals(id));
    });

    test('PetId.fromJson round-trips correctly', () {
      final id = PetId('wolf_pup');
      expect(PetId.fromJson(id.toJson()), equals(id));
    });

    test('FactionId.fromJson round-trips correctly', () {
      final id = FactionId('merchants_guild');
      expect(FactionId.fromJson(id.toJson()), equals(id));
    });

    test('SkillId.fromJson round-trips correctly', () {
      final id = SkillId('swordsmanship');
      expect(SkillId.fromJson(id.toJson()), equals(id));
    });

    test('fromJson with non-String throws ArgumentError', () {
      expect(() => ItemId.fromJson(42), throwsArgumentError);
      expect(() => ItemId.fromJson(null), throwsArgumentError);
    });
  });
}
