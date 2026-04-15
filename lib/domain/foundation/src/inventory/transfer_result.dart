/// The outcome of an inventory transfer operation.
///
/// Use [TransferResult] as the return value of any operation that moves items
/// between inventories or between an inventory and a trade partner. The sealed
/// hierarchy makes exhaustive handling mandatory at call sites.
///
/// ## Design intent
///
/// - Game-agnostic: failure reasons use an enum rather than hard-coded strings.
/// - UI receives a [TransferResult] and decides how to surface the failure;
///   it never mutates inventory state directly.
///
/// Example:
/// ```dart
/// final result = inventory.transfer(item, destination);
/// switch (result) {
///   case TransferSuccess(:final movedQuantity):
///     // update UI to reflect movedQuantity
///   case TransferFailure(:final reason):
///     // show error based on reason
/// }
/// ```
sealed class TransferResult {
  const TransferResult();
}

/// Transfer completed. [movedQuantity] is the number of units that moved.
final class TransferSuccess extends TransferResult {
  const TransferSuccess({required this.movedQuantity});

  /// How many units were successfully transferred.
  final int movedQuantity;

  @override
  String toString() => 'TransferSuccess(movedQuantity: $movedQuantity)';
}

/// Transfer could not complete. [reason] identifies the cause.
///
/// [partialQuantity] is non-null when a partial transfer occurred before the
/// failure (e.g. the destination filled up mid-way). A value of `0` or `null`
/// means nothing moved.
final class TransferFailure extends TransferResult {
  const TransferFailure({required this.reason, this.partialQuantity});

  /// Why the transfer failed.
  final TransferFailureReason reason;

  /// Units moved before the failure, or `null` / `0` if nothing moved.
  final int? partialQuantity;

  @override
  String toString() =>
      'TransferFailure(reason: $reason, partial: $partialQuantity)';
}

/// Enumeration of reasons a transfer can fail.
///
/// Keep this list game-agnostic. Game-specific causes should be encoded in
/// adapter-level error types that wrap or extend this enum.
enum TransferFailureReason {
  /// The destination inventory has no free slots.
  destinationFull,

  /// Adding the item would exceed the destination's weight limit.
  weightLimitExceeded,

  /// The source does not contain enough units to fulfil the request.
  insufficientQuantity,

  /// The item is locked and cannot be moved (e.g. equipped, quest item).
  itemLocked,

  /// Source and destination are the same inventory.
  sameInventory,

  /// The item ID was not found in the source inventory.
  itemNotFound,

  /// A generic or unclassified failure. Use sparingly; prefer specific values.
  unknown,
}
