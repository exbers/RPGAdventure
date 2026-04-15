import '../value_objects/quantity.dart';
import '../value_objects/weight.dart';

/// Tracks the slot and weight constraints of an inventory or cargo hold.
///
/// Both slot-based and weight-based limits are optional. When a limit is
/// `null` it is treated as unbounded. This allows the same contract to
/// represent a simple unlimited bag, a weight-only haversack, or a fully
/// constrained cargo bay.
///
/// All mutating operations return new instances; the class is immutable.
final class InventoryCapacity {
  /// Creates an [InventoryCapacity].
  ///
  /// [maxSlots] and [maxWeight] are the upper bounds. Pass `null` for
  /// unbounded dimensions.
  ///
  /// [usedSlots] and [currentWeight] describe the current load. They default
  /// to zero when omitted.
  ///
  /// Throws [ArgumentError] if current values exceed their respective maxima.
  InventoryCapacity({
    this.maxSlots,
    this.maxWeight,
    Quantity? usedSlots,
    Weight? currentWeight,
  }) : usedSlots = usedSlots ?? Quantity.zero,
       currentWeight = currentWeight ?? Weight.zero {
    final effectiveUsedSlots = this.usedSlots;
    final effectiveWeight = this.currentWeight;

    if (maxSlots != null && effectiveUsedSlots.value > maxSlots!.value) {
      throw ArgumentError(
        'usedSlots (${effectiveUsedSlots.value}) exceeds maxSlots '
        '(${maxSlots!.value})',
      );
    }
    if (maxWeight != null && !effectiveWeight.fitsWithin(maxWeight!)) {
      throw ArgumentError('currentWeight exceeds maxWeight');
    }
  }

  /// Maximum number of distinct item stacks/instances allowed.
  ///
  /// `null` means unbounded.
  final Quantity? maxSlots;

  /// Maximum total weight allowed.
  ///
  /// `null` means unbounded.
  final Weight? maxWeight;

  /// Number of slots currently occupied.
  final Quantity usedSlots;

  /// Combined weight of items currently held.
  final Weight currentWeight;

  /// Number of free slots remaining, or `null` when slots are unbounded.
  Quantity? get availableSlots => maxSlots?.subtract(usedSlots.value);

  /// Remaining weight headroom, or `null` when weight is unbounded.
  Weight? get availableWeight =>
      maxWeight == null ? null : maxWeight! - currentWeight;

  /// Returns `true` when at least one more slot can be occupied.
  bool get hasSlotSpace =>
      maxSlots == null || usedSlots.value < maxSlots!.value;

  /// Returns `true` when [weight] additional weight can be added.
  bool canAcceptWeight(Weight weight) =>
      maxWeight == null || (currentWeight + weight).fitsWithin(maxWeight!);

  /// Returns `true` when both a new slot and [weight] can be accommodated.
  bool canAccept(Weight weight) => hasSlotSpace && canAcceptWeight(weight);

  /// Returns a copy reflecting the addition of one slot and [addedWeight].
  ///
  /// Throws [ArgumentError] if the updated capacity would violate constraints.
  InventoryCapacity addItem(Weight addedWeight) => InventoryCapacity(
    maxSlots: maxSlots,
    maxWeight: maxWeight,
    usedSlots: usedSlots.add(1),
    currentWeight: currentWeight + addedWeight,
  );

  /// Returns a copy reflecting the removal of one slot and [removedWeight].
  ///
  /// Throws [ArgumentError] if [removedWeight] exceeds [currentWeight].
  InventoryCapacity removeItem(Weight removedWeight) => InventoryCapacity(
    maxSlots: maxSlots,
    maxWeight: maxWeight,
    usedSlots: usedSlots.value > 0 ? usedSlots.subtract(1) : Quantity.zero,
    currentWeight: currentWeight - removedWeight,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryCapacity &&
          maxSlots == other.maxSlots &&
          maxWeight == other.maxWeight &&
          usedSlots == other.usedSlots &&
          currentWeight == other.currentWeight);

  @override
  int get hashCode =>
      Object.hash(maxSlots, maxWeight, usedSlots, currentWeight);

  @override
  String toString() =>
      'InventoryCapacity(slots: ${usedSlots.value}/${maxSlots?.value ?? "∞"}, '
      'weight: ${currentWeight.inGrams}g/${maxWeight?.inGrams ?? "∞"}g)';
}
