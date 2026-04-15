/// Immutable non-negative integer quantity used for item stacks, capacities,
/// and similar countable amounts.
///
/// Distinct from [Currency] because quantities are unit-less counts that do not
/// carry a currency type.
final class Quantity {
  /// Creates a [Quantity] with the given [value].
  ///
  /// Throws [ArgumentError] if [value] is negative.
  Quantity(this.value) {
    if (value < 0) {
      throw ArgumentError.value(
        value,
        'value',
        'Quantity must be non-negative',
      );
    }
  }

  const Quantity._raw(this.value);

  /// The zero quantity constant.
  static const Quantity zero = Quantity._raw(0);

  /// The raw count.
  final int value;

  /// Returns `true` when this quantity is zero.
  bool get isEmpty => value == 0;

  /// Returns `true` when this quantity is greater than zero.
  bool get isNotEmpty => value > 0;

  /// Returns a new [Quantity] increased by [amount].
  ///
  /// Throws [ArgumentError] if [amount] is negative.
  Quantity add(int amount) {
    if (amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Use subtract to decrease quantity',
      );
    }
    return Quantity(value + amount);
  }

  /// Returns a new [Quantity] decreased by [amount].
  /// Returns [Quantity.zero] if [amount] exceeds the current value.
  ///
  /// Throws [ArgumentError] if [amount] is negative.
  Quantity subtract(int amount) {
    if (amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'amount must be non-negative',
      );
    }
    final result = value - amount;
    return result <= 0 ? Quantity.zero : Quantity(result);
  }

  /// Returns `true` if this quantity can supply [requested] units.
  bool canFulfill(Quantity requested) => value >= requested.value;

  /// Deserializes a [Quantity] from a plain JSON integer produced by [toJson].
  factory Quantity.fromJson(Object? json) {
    if (json is! int) {
      throw ArgumentError.value(
        json,
        'json',
        'Expected an integer for Quantity',
      );
    }
    return Quantity(json);
  }

  /// Serializes this [Quantity] to a plain JSON integer.
  int toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Quantity && value == other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Quantity($value)';
}
