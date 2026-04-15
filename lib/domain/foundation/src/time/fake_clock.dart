import '../value_objects/game_duration.dart';
import 'clock.dart';

/// A deterministic [Clock] implementation for use in unit tests.
///
/// Time only advances when [advance] or [set] is called explicitly; there is no
/// wall-clock dependency.
///
/// Example:
/// ```dart
/// final clock = FakeClock(initial: GameDuration(seconds: 0));
/// clock.advance(GameDuration(seconds: 10));
/// expect(clock.currentTime, GameDuration(seconds: 10));
/// ```
final class FakeClock implements Clock {
  /// Creates a [FakeClock] starting at [initial] (defaults to zero).
  FakeClock({GameDuration? initial}) : _current = initial ?? GameDuration.zero;

  GameDuration _current;

  @override
  GameDuration get currentTime => _current;

  @override
  GameDuration elapsedSince(GameDuration since) =>
      _current > since ? _current - since : GameDuration.zero;

  /// Advances the clock by [delta].
  void advance(GameDuration delta) {
    _current = _current + delta;
  }

  /// Sets the clock to an absolute [time].
  void set(GameDuration time) {
    _current = time;
  }
}
