import '../value_objects/quantity.dart';

/// Tracks the available stock of a single item in a merchant's inventory.
///
/// [LimitedStock] is immutable. Use [consume] and [restock] to produce updated
/// snapshots after trade operations.
///
/// When [maxQuantity] is `null` the stock is unbounded (i.e. a merchant with
/// infinite supply). [currentQuantity] is still tracked so the economy layer
/// can reason about how many units remain after sales in the same session.
final class LimitedStock {
  /// Creates a [LimitedStock].
  ///
  /// Throws [ArgumentError] if [currentQuantity] exceeds [maxQuantity] (when
  /// [maxQuantity] is not `null`).
  LimitedStock({required this.currentQuantity, this.maxQuantity}) {
    if (maxQuantity != null && currentQuantity.value > maxQuantity!.value) {
      throw ArgumentError(
        'currentQuantity (${currentQuantity.value}) exceeds '
        'maxQuantity (${maxQuantity!.value})',
      );
    }
  }

  /// Units currently available for purchase.
  final Quantity currentQuantity;

  /// Maximum units this stock can hold, or `null` for unbounded.
  final Quantity? maxQuantity;

  /// Returns `true` when there are no units left.
  bool get isEmpty => currentQuantity.isEmpty;

  /// Returns `true` when [units] can be sold.
  bool canSell(int units) => currentQuantity.value >= units;

  /// Returns `true` when the stock is at capacity (or unbounded).
  bool get isFull =>
      maxQuantity == null || currentQuantity.value >= maxQuantity!.value;

  /// Returns a copy with [units] deducted.
  ///
  /// Throws [ArgumentError] if [units] is zero or exceeds [currentQuantity].
  LimitedStock consume(int units) {
    if (units <= 0) {
      throw ArgumentError.value(units, 'units', 'Must be greater than zero');
    }
    if (!canSell(units)) {
      throw ArgumentError(
        'Insufficient stock: requested $units, available ${currentQuantity.value}',
      );
    }
    return LimitedStock(
      currentQuantity: currentQuantity.subtract(units),
      maxQuantity: maxQuantity,
    );
  }

  /// Returns a copy with [units] added, capped at [maxQuantity].
  ///
  /// Throws [ArgumentError] if [units] is zero.
  LimitedStock restock(int units) {
    if (units <= 0) {
      throw ArgumentError.value(units, 'units', 'Must be greater than zero');
    }
    final added = currentQuantity.add(units);
    if (maxQuantity != null && added.value > maxQuantity!.value) {
      return LimitedStock(
        currentQuantity: maxQuantity!,
        maxQuantity: maxQuantity,
      );
    }
    return LimitedStock(currentQuantity: added, maxQuantity: maxQuantity);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LimitedStock &&
          currentQuantity == other.currentQuantity &&
          maxQuantity == other.maxQuantity);

  @override
  int get hashCode => Object.hash(currentQuantity, maxQuantity);

  @override
  String toString() =>
      'LimitedStock(${currentQuantity.value}/${maxQuantity?.value ?? "∞"})';
}
