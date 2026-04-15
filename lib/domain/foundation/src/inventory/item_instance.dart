import '../ids/entity_id.dart';

/// A unique instance of a non-stackable or uniquely-stateful item.
///
/// Unlike [ItemStack], an [ItemInstance] tracks per-item state. Use this for
/// equipment, tools, or any item with individual properties such as durability
/// or applied modifiers.
///
/// [instanceId] is a caller-managed unique string (e.g. a UUID or sequential
/// counter) used to locate this instance inside an inventory.
///
/// [modifiers] is an unmodifiable map of game-agnostic modifier keys to
/// numeric values (e.g. `{'attack_bonus': 5}`). Interpretation is left to game
/// adapters.
final class ItemInstance {
  /// Creates an [ItemInstance].
  ///
  /// [durability] must be `null` or a value in the range `[0.0, 1.0]` where
  /// `1.0` represents perfect condition and `0.0` represents broken/unusable.
  ///
  /// Throws [ArgumentError] if [instanceId] is empty or [durability] is out of
  /// range.
  ItemInstance({
    required this.instanceId,
    required this.itemId,
    this.durability,
    Map<String, num>? modifiers,
  }) : modifiers = modifiers != null
           ? Map.unmodifiable(modifiers)
           : const <String, num>{} {
    if (instanceId.isEmpty) {
      throw ArgumentError.value(
        instanceId,
        'instanceId',
        'ItemInstance instanceId must not be empty',
      );
    }
    final d = durability;
    if (d != null && (d < 0.0 || d > 1.0)) {
      throw ArgumentError.value(
        d,
        'durability',
        'Durability must be in the range [0.0, 1.0]',
      );
    }
  }

  /// Caller-managed unique identifier for this specific item instance.
  final String instanceId;

  /// The content definition this instance is based on.
  final EntityId itemId;

  /// Current durability in the range `[0.0, 1.0]`, or `null` if the item
  /// type does not track durability.
  final double? durability;

  /// Game-agnostic modifier map (e.g. `{'attack_bonus': 5, 'weight_mod': -2}`).
  ///
  /// The map is unmodifiable. Use [withModifiers] or [withDurability] to
  /// produce updated copies.
  final Map<String, num> modifiers;

  /// Returns `true` when [durability] is `0.0`.
  bool get isBroken => durability != null && durability! <= 0.0;

  /// Returns a copy of this instance with [newDurability].
  ///
  /// Throws [ArgumentError] if [newDurability] is out of the `[0.0, 1.0]`
  /// range.
  ItemInstance withDurability(double newDurability) => ItemInstance(
    instanceId: instanceId,
    itemId: itemId,
    durability: newDurability,
    modifiers: Map.of(modifiers),
  );

  /// Returns a copy of this instance with [newModifiers] merged over the
  /// existing [modifiers].
  ItemInstance withModifiers(Map<String, num> newModifiers) => ItemInstance(
    instanceId: instanceId,
    itemId: itemId,
    durability: durability,
    modifiers: {...modifiers, ...newModifiers},
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemInstance &&
          instanceId == other.instanceId &&
          itemId == other.itemId &&
          durability == other.durability &&
          _mapsEqual(modifiers, other.modifiers));

  @override
  int get hashCode => Object.hashAll([
    instanceId,
    itemId,
    durability,
    ...modifiers.entries.map((e) => Object.hash(e.key, e.value)),
  ]);

  @override
  String toString() => 'ItemInstance($instanceId, $itemId)';

  static bool _mapsEqual(Map<String, num> a, Map<String, num> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
