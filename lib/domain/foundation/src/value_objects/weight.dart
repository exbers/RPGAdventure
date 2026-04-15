/// Unit of measurement for in-game weight.
enum WeightUnit {
  /// Kilograms — default SI-adjacent unit used for most items.
  kilograms,

  /// Grams — used for very light items such as reagents.
  grams,
}

/// Immutable representation of a physical weight used for inventory capacity
/// and item load calculations.
///
/// Internally stores the value in grams to allow lossless arithmetic across
/// units. Use [WeightUnit] to express the logical unit that content authors
/// work with.
///
/// Example:
/// ```dart
/// const blade = Weight(15, WeightUnit.kilograms);
/// const reagent = Weight(500, WeightUnit.grams);
/// print(blade.inGrams); // 15000
/// ```
final class Weight {
  /// Creates a [Weight] with the given [amount] expressed in [unit].
  ///
  /// Throws [ArgumentError] if [amount] is negative.
  Weight(this.amount, this.unit) {
    if (amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Weight must be non-negative',
      );
    }
  }

  /// The zero-weight constant.
  static const Weight zero = Weight._raw(0, WeightUnit.kilograms);

  const Weight._raw(this.amount, this.unit);

  /// The numeric amount expressed in [unit].
  final num amount;

  /// The unit [amount] is expressed in.
  final WeightUnit unit;

  /// Returns this weight expressed in grams.
  num get inGrams => switch (unit) {
    WeightUnit.kilograms => amount * 1000,
    WeightUnit.grams => amount,
  };

  /// Returns this weight expressed in kilograms.
  num get inKilograms => switch (unit) {
    WeightUnit.kilograms => amount,
    WeightUnit.grams => amount / 1000,
  };

  /// Returns a new [Weight] that is the sum of this weight and [other].
  /// The result is expressed in grams.
  Weight operator +(Weight other) =>
      Weight(inGrams + other.inGrams, WeightUnit.grams);

  /// Returns a new [Weight] that is this weight minus [other].
  /// Throws [ArgumentError] if the result would be negative.
  Weight operator -(Weight other) {
    final result = inGrams - other.inGrams;
    if (result < 0) {
      throw ArgumentError('Subtraction would result in negative weight');
    }
    return Weight(result, WeightUnit.grams);
  }

  /// Returns `true` when this weight does not exceed [capacity].
  bool fitsWithin(Weight capacity) => inGrams <= capacity.inGrams;

  /// Deserializes a [Weight] from a JSON map produced by [toJson].
  ///
  /// Expected format: `{ "amount": 15, "unit": "kilograms" }`.
  factory Weight.fromJson(Map<String, Object?> json) {
    final amount = json['amount'];
    final unitStr = json['unit'];
    if (amount is! num) {
      throw ArgumentError.value(amount, 'json[amount]', 'Expected a number');
    }
    if (unitStr is! String) {
      throw ArgumentError.value(unitStr, 'json[unit]', 'Expected a string');
    }
    final unit = WeightUnit.values.firstWhere(
      (u) => u.name == unitStr,
      orElse: () => throw ArgumentError.value(
        unitStr,
        'json[unit]',
        'Unknown WeightUnit',
      ),
    );
    return Weight(amount, unit);
  }

  /// Serializes this [Weight] to a JSON-compatible map.
  Map<String, Object> toJson() => {'amount': amount, 'unit': unit.name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Weight && inGrams == other.inGrams);

  @override
  int get hashCode => inGrams.hashCode;

  @override
  String toString() => 'Weight($amount ${unit.name})';
}
