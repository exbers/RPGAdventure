import 'entity_id.dart';

/// Stable ID for an item definition in content data.
///
/// Item IDs appear in inventory snapshots, loot tables, recipe ingredients, and
/// save files. They must not encode display names — use a content registry to
/// resolve display names from IDs at presentation time.
final class ItemId extends EntityId {
  ItemId(super.value);

  /// Deserializes an [ItemId] from a plain JSON string.
  factory ItemId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(json, 'json', 'Expected a String for ItemId');
    }
    return ItemId(json);
  }
}

/// Stable ID for a monster definition in content data.
final class MonsterId extends EntityId {
  MonsterId(super.value);

  /// Deserializes a [MonsterId] from a plain JSON string.
  factory MonsterId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(
        json,
        'json',
        'Expected a String for MonsterId',
      );
    }
    return MonsterId(json);
  }
}

/// Stable ID for a quest definition in content data.
final class QuestId extends EntityId {
  QuestId(super.value);

  /// Deserializes a [QuestId] from a plain JSON string.
  factory QuestId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(json, 'json', 'Expected a String for QuestId');
    }
    return QuestId(json);
  }
}

/// Stable ID for a zone definition in content data.
final class ZoneId extends EntityId {
  ZoneId(super.value);

  /// Deserializes a [ZoneId] from a plain JSON string.
  factory ZoneId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(json, 'json', 'Expected a String for ZoneId');
    }
    return ZoneId(json);
  }
}

/// Stable ID for a town definition in content data.
final class TownId extends EntityId {
  TownId(super.value);

  /// Deserializes a [TownId] from a plain JSON string.
  factory TownId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(json, 'json', 'Expected a String for TownId');
    }
    return TownId(json);
  }
}

/// Stable ID for a crafting recipe definition in content data.
final class RecipeId extends EntityId {
  RecipeId(super.value);

  /// Deserializes a [RecipeId] from a plain JSON string.
  factory RecipeId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(json, 'json', 'Expected a String for RecipeId');
    }
    return RecipeId(json);
  }
}

/// Stable ID for a pet definition in content data.
final class PetId extends EntityId {
  PetId(super.value);

  /// Deserializes a [PetId] from a plain JSON string.
  factory PetId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(json, 'json', 'Expected a String for PetId');
    }
    return PetId(json);
  }
}

/// Stable ID for a faction definition in content data.
final class FactionId extends EntityId {
  FactionId(super.value);

  /// Deserializes a [FactionId] from a plain JSON string.
  factory FactionId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(
        json,
        'json',
        'Expected a String for FactionId',
      );
    }
    return FactionId(json);
  }
}

/// Stable ID for a skill definition in content data.
final class SkillId extends EntityId {
  SkillId(super.value);

  /// Deserializes a [SkillId] from a plain JSON string.
  factory SkillId.fromJson(Object? json) {
    if (json is! String) {
      throw ArgumentError.value(json, 'json', 'Expected a String for SkillId');
    }
    return SkillId(json);
  }
}
