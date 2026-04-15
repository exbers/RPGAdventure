import '../value_objects/game_duration.dart';
import 'clock.dart';

/// Converts raw clock readings into useful game-time values.
///
/// [GameTimeCalculator] is the bridge between the low-level [Clock] interface
/// and higher-level gameplay concepts (offline catch-up, turn budgets, etc.).
/// It intentionally contains no Flutter dependency so it can be unit-tested
/// with a [FakeClock].
///
/// Example:
/// ```dart
/// final clock = FakeClock(initial: GameDuration(seconds: 1000));
/// final calc = GameTimeCalculator(clock: clock);
///
/// final savedAt = GameDuration(seconds: 900);
/// print(calc.offlineTime(lastSavedAt: savedAt)); // GameDuration(100s)
/// ```
final class GameTimeCalculator {
  /// Creates a [GameTimeCalculator] backed by [clock].
  const GameTimeCalculator({required this.clock});

  /// The clock used for all calculations.
  final Clock clock;

  /// How much game time has passed since [lastSavedAt].
  ///
  /// Useful for offline catch-up: show the player what happened while the app
  /// was closed.
  GameDuration offlineTime({required GameDuration lastSavedAt}) =>
      clock.elapsedSince(lastSavedAt);

  /// Splits [totalTime] into whole turns of [turnDuration] plus a remainder.
  ///
  /// Returns a record `(turns: int, remainder: GameDuration)`.
  ///
  /// Example: 70s total, 30s per turn → 2 turns, 10s remainder.
  ({int turns, GameDuration remainder}) splitIntoTurns({
    required GameDuration totalTime,
    required GameDuration turnDuration,
  }) {
    if (turnDuration.isZero) {
      throw ArgumentError.value(
        turnDuration,
        'turnDuration',
        'turnDuration must be greater than zero',
      );
    }
    final turns = totalTime.seconds ~/ turnDuration.seconds;
    final remainderSeconds = totalTime.seconds % turnDuration.seconds;
    return (turns: turns, remainder: GameDuration(seconds: remainderSeconds));
  }

  /// Returns the current clock time.
  GameDuration get now => clock.currentTime;
}
