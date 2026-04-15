import '../value_objects/game_duration.dart';
import '../value_objects/quantity.dart';
import 'limited_stock.dart';

/// Describes how and when a merchant's [LimitedStock] is replenished.
///
/// [RestockSchedule] is intentionally decoupled from real-time clocks. The
/// game adapter is responsible for deciding when a restock fires (e.g. each
/// in-game day, each real-time hour). The schedule only defines the *amount*
/// and *interval* so the domain stays deterministic and testable.
///
/// Example usage:
/// ```dart
/// final schedule = RestockSchedule(
///   interval: GameDuration.fromDays(1),
///   restockAmount: Quantity(20),
/// );
///
/// // When the adapter decides enough time has passed:
/// final updatedStock = schedule.apply(currentStock);
/// ```
final class RestockSchedule {
  /// Creates a [RestockSchedule].
  ///
  /// [restockAmount] must be greater than zero.
  RestockSchedule({required this.interval, required this.restockAmount}) {
    if (restockAmount.isEmpty) {
      throw ArgumentError(
        'RestockSchedule restockAmount must be greater than zero',
      );
    }
  }

  /// How much game-time must pass between restock events.
  final GameDuration interval;

  /// Units added to stock on each restock event.
  ///
  /// [LimitedStock.restock] will cap the result at the stock's [LimitedStock.maxQuantity].
  final Quantity restockAmount;

  /// Applies one restock event to [stock] and returns the updated [LimitedStock].
  LimitedStock apply(LimitedStock stock) => stock.restock(restockAmount.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestockSchedule &&
          interval == other.interval &&
          restockAmount == other.restockAmount);

  @override
  int get hashCode => Object.hash(interval, restockAmount);

  @override
  String toString() =>
      'RestockSchedule(every $interval, +${restockAmount.value} units)';
}
