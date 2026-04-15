import '../value_objects/game_duration.dart';
import 'clock.dart';

/// A [Clock] implementation backed by the real wall clock.
///
/// Uses [DateTime.now()] and converts UTC milliseconds to game-time seconds
/// (1 wall-clock second = 1 game-time second by default; the game engine can
/// apply a time-scale multiplier on top of this via [GameTimeCalculator]).
///
/// This class is a thin adapter and carries no game logic. Tests should use
/// [FakeClock] instead.
final class SystemClock implements Clock {
  /// Creates a [SystemClock] with an optional [epochOffset].
  ///
  /// [epochOffset] is subtracted from the current UTC milliseconds so that
  /// [currentTime] starts near zero when the session begins. Pass
  /// `DateTime.now().millisecondsSinceEpoch` at application start if you want
  /// a session-relative clock.
  const SystemClock({this.epochOffsetMs = 0});

  /// Milliseconds to subtract from the raw UTC timestamp.
  final int epochOffsetMs;

  @override
  GameDuration get currentTime {
    final ms = DateTime.now().millisecondsSinceEpoch - epochOffsetMs;
    // Clamp to zero in case of clock skew or negative offset.
    final seconds = ms < 0 ? 0 : ms ~/ 1000;
    return GameDuration(seconds: seconds);
  }

  @override
  GameDuration elapsedSince(GameDuration since) {
    final now = currentTime;
    return now > since ? now - since : GameDuration.zero;
  }
}
