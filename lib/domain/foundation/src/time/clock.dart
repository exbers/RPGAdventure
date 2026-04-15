import '../value_objects/game_duration.dart';

/// Abstract interface for a game-time clock.
///
/// Separating real wall-clock time from game-time calculations allows:
/// - deterministic tests via [FakeClock],
/// - offline-time catch-up logic in [GameTimeCalculator],
/// - future replacement with server-authoritative time.
///
/// No Flutter dependency — usable in pure-Dart unit tests.
abstract interface class Clock {
  /// The current game-time tick expressed as a [GameDuration] since an
  /// arbitrary epoch (e.g., the start of the play session or Unix epoch).
  GameDuration get currentTime;

  /// How much game time has elapsed since [since].
  ///
  /// Returns [GameDuration.zero] if [since] is in the future (clock went
  /// backwards — defensive behaviour).
  GameDuration elapsedSince(GameDuration since);
}
