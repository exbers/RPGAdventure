import '../ids/entity_id.dart';
import '../value_objects/currency.dart';
import '../value_objects/quantity.dart';

/// A request from the player to purchase items from a merchant or shop.
///
/// The [agreedPrice] is the [PriceQuote.resolvedPrice] that the player
/// accepted. Comparing it against the live resolved price at settlement lets
/// the game detect price-staleness (e.g. the player held the buy screen open
/// while standing changed).
final class BuyRequest {
  /// Creates a [BuyRequest].
  ///
  /// Throws [ArgumentError] if [quantity] is zero.
  BuyRequest({
    required this.itemId,
    required this.quantity,
    required this.agreedPrice,
  }) {
    if (quantity.isEmpty) {
      throw ArgumentError('BuyRequest quantity must be greater than zero');
    }
  }

  /// The item definition being purchased.
  final EntityId itemId;

  /// Number of units the player wants to buy.
  final Quantity quantity;

  /// The price-per-unit the player agreed to when opening the trade screen.
  final Currency agreedPrice;

  /// Convenience: total cost = [agreedPrice] × [quantity].
  Currency get totalCost => Currency(
    currencyId: agreedPrice.currencyId,
    amount: agreedPrice.amount * quantity.value,
  );

  @override
  String toString() => 'BuyRequest($itemId x${quantity.value} @ $agreedPrice)';
}

/// A request from the player to sell items to a merchant or shop.
final class SellRequest {
  /// Creates a [SellRequest].
  ///
  /// Throws [ArgumentError] if [quantity] is zero.
  SellRequest({
    required this.itemId,
    required this.quantity,
    required this.agreedPrice,
  }) {
    if (quantity.isEmpty) {
      throw ArgumentError('SellRequest quantity must be greater than zero');
    }
  }

  /// The item definition being sold.
  final EntityId itemId;

  /// Number of units the player wants to sell.
  final Quantity quantity;

  /// The price-per-unit the player agreed to when opening the trade screen.
  final Currency agreedPrice;

  /// Convenience: total proceeds = [agreedPrice] × [quantity].
  Currency get totalProceeds => Currency(
    currencyId: agreedPrice.currencyId,
    amount: agreedPrice.amount * quantity.value,
  );

  @override
  String toString() => 'SellRequest($itemId x${quantity.value} @ $agreedPrice)';
}
