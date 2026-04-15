import '../ids/entity_id.dart';
import '../value_objects/quantity.dart';

/// A stackable group of identical item definitions.
///
/// An [ItemStack] represents N copies of the same item definition identified by
/// [itemId]. It does not track per-instance state such as durability; use
/// [ItemInstance] for non-stackable or uniquely-stateful items.
///
/// [metadata] holds optional key-value payload (e.g. enchantment tier,
/// quality grade) that is shared across the whole stack. It must be
/// game-agnostic at the contract level — concrete values are defined by game
/// content.
///
/// All mutating operations return new instances to preserve immutability.
final class ItemStack {
  /// Creates an [ItemStack] for [itemId] with [quantity].
  ///
  /// [metadata] defaults to an empty map when omitted.
  /// Throws [ArgumentError] if [quantity] is zero.
  ItemStack({
    required this.itemId,
    required this.quantity,
    Map<String, Object?>? metadata,
  }) : metadata = metadata != null
           ? Map.unmodifiable(metadata)
           : const <String, Object?>{} {
    if (quantity.isEmpty) {
      throw ArgumentError('ItemStack quantity must be greater than zero');
    }
  }

  /// The content definition this stack refers to.
  final EntityId itemId;

  /// How many units are in this stack.
  final Quantity quantity;

  /// Optional shared key-value payload (e.g. `{'quality': 'rare'}`).
  ///
  /// The map is unmodifiable. Replace the whole stack to change metadata.
  final Map<String, Object?> metadata;

  /// Returns `true` when [other] can be merged into this stack.
  ///
  /// Two stacks are mergeable when they share the same [itemId] and identical
  /// [metadata] maps.
  bool canMergeWith(ItemStack other) {
    if (itemId != other.itemId) return false;
    if (metadata.length != other.metadata.length) return false;
    for (final entry in metadata.entries) {
      if (other.metadata[entry.key] != entry.value) return false;
    }
    return true;
  }

  /// Returns a new stack combining this stack's quantity with [other].
  ///
  /// Throws [ArgumentError] if the stacks are not mergeable (see
  /// [canMergeWith]).
  ItemStack mergeWith(ItemStack other) {
    if (!canMergeWith(other)) {
      throw ArgumentError(
        'Cannot merge stacks with different itemId or metadata',
      );
    }
    return ItemStack(
      itemId: itemId,
      quantity: quantity.add(other.quantity.value),
      metadata: metadata.isEmpty ? null : Map.of(metadata),
    );
  }

  /// Splits [amount] units off this stack.
  ///
  /// Returns a record `(taken, remaining)` where:
  /// - `taken` is a new stack with [amount] units and the same metadata.
  /// - `remaining` is `null` when [amount] equals this stack's quantity
  ///   (the whole stack was taken).
  ///
  /// Throws [ArgumentError] if [amount] is zero or exceeds [quantity].
  ({ItemStack taken, ItemStack? remaining}) split(int amount) {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be greater than zero');
    }
    if (amount > quantity.value) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Cannot split more than the stack contains (${quantity.value})',
      );
    }
    final taken = ItemStack(
      itemId: itemId,
      quantity: Quantity(amount),
      metadata: metadata.isEmpty ? null : Map.of(metadata),
    );
    if (amount == quantity.value) {
      return (taken: taken, remaining: null);
    }
    final remaining = ItemStack(
      itemId: itemId,
      quantity: quantity.subtract(amount),
      metadata: metadata.isEmpty ? null : Map.of(metadata),
    );
    return (taken: taken, remaining: remaining);
  }

  /// Returns a copy with [quantity] replaced by [newQuantity].
  ItemStack withQuantity(Quantity newQuantity) => ItemStack(
    itemId: itemId,
    quantity: newQuantity,
    metadata: Map.of(metadata),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemStack &&
          itemId == other.itemId &&
          quantity == other.quantity &&
          _mapsEqual(metadata, other.metadata));

  @override
  int get hashCode => Object.hash(
    itemId,
    quantity,
    Object.hashAll(metadata.entries.map((e) => Object.hash(e.key, e.value))),
  );

  @override
  String toString() => 'ItemStack($itemId x${quantity.value})';

  static bool _mapsEqual(Map<String, Object?> a, Map<String, Object?> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
