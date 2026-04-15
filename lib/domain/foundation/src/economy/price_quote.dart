import '../ids/entity_id.dart';
import '../value_objects/currency.dart';

/// A modifier callback applied to a base price before presenting it to the
/// player.
///
/// Implementations live in game adapters. Examples: faction reputation
/// discount, merchant skill bonus, supply-and-demand scaling.
///
/// Receives the [itemId] being priced and the [basePrice] and returns the
/// final [Currency] amount. The returned currency must share the same
/// [Currency.currencyId] as [basePrice].
typedef PriceModifier = Currency Function(EntityId itemId, Currency basePrice);

/// A price quote for a single item definition.
///
/// [PriceQuote] is immutable and game-agnostic. The [basePrice] is the
/// content-defined value; [resolvedPrice] applies any [modifier] callback
/// supplied by the game layer.
///
/// The modifier is intentionally kept as a callback so that pricing logic
/// (reputation discounts, dynamic supply) lives in adapters rather than the
/// contract itself.
final class PriceQuote {
  /// Creates a [PriceQuote].
  ///
  /// [modifier] defaults to identity (base price unchanged) when omitted.
  const PriceQuote({
    required this.itemId,
    required this.basePrice,
    this.modifier,
  });

  /// The item this quote applies to.
  final EntityId itemId;

  /// The content-defined starting price.
  final Currency basePrice;

  /// Optional adapter-supplied modifier. When `null`, [resolvedPrice] equals
  /// [basePrice].
  final PriceModifier? modifier;

  /// Returns the final price after applying [modifier].
  ///
  /// The modifier is called at most once per access; the result is not cached.
  Currency get resolvedPrice =>
      modifier == null ? basePrice : modifier!(itemId, basePrice);

  @override
  String toString() =>
      'PriceQuote($itemId, base: $basePrice, resolved: $resolvedPrice)';
}
