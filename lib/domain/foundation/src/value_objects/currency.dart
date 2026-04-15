/// Immutable representation of an amount in a named game currency.
///
/// The [currencyId] is a plain string key that must be resolved to a display
/// name via a content registry. This keeps the value object game-agnostic.
///
/// Example:
/// ```dart
/// const goldCoins = Currency(currencyId: 'gold', amount: 100);
/// ```
final class Currency {
  const Currency({required this.currencyId, required this.amount})
    : assert(amount >= 0, 'Currency amount must be non-negative');

  /// Content key identifying the currency type (e.g. `'gold'`, `'soul_crystal'`).
  final String currencyId;

  /// Non-negative quantity of this currency.
  final int amount;

  /// Returns a new [Currency] with [amount] increased by [delta].
  /// Throws [ArgumentError] if the result would be negative.
  Currency add(int delta) {
    final result = amount + delta;
    if (result < 0) {
      throw ArgumentError.value(
        delta,
        'delta',
        'Would result in negative amount',
      );
    }
    return Currency(currencyId: currencyId, amount: result);
  }

  /// Returns a new [Currency] with [amount] decreased by [delta].
  /// Throws [ArgumentError] if the result would be negative.
  Currency subtract(int delta) => add(-delta);

  /// Returns `true` if this amount is enough to cover [price].
  /// Both must share the same [currencyId].
  bool canAfford(Currency price) {
    if (currencyId != price.currencyId) {
      throw ArgumentError(
        'Cannot compare currencies of different types: $currencyId vs ${price.currencyId}',
      );
    }
    return amount >= price.amount;
  }

  /// Deserializes a [Currency] from a JSON map produced by [toJson].
  ///
  /// Expected format: `{ "currencyId": "gold", "amount": 100 }`.
  factory Currency.fromJson(Map<String, Object?> json) {
    final currencyId = json['currencyId'];
    final amount = json['amount'];
    if (currencyId is! String || currencyId.isEmpty) {
      throw ArgumentError.value(
        currencyId,
        'json[currencyId]',
        'Expected a non-empty String',
      );
    }
    if (amount is! int || amount < 0) {
      throw ArgumentError.value(
        amount,
        'json[amount]',
        'Expected a non-negative integer',
      );
    }
    return Currency(currencyId: currencyId, amount: amount);
  }

  /// Serializes this [Currency] to a JSON-compatible map.
  Map<String, Object> toJson() => {'currencyId': currencyId, 'amount': amount};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Currency &&
          currencyId == other.currencyId &&
          amount == other.amount);

  @override
  int get hashCode => Object.hash(currencyId, amount);

  @override
  String toString() => 'Currency($currencyId x$amount)';
}
