/// Immutable representation of a game-time duration used for effect timers,
/// restock schedules, quest deadlines, and travel times.
///
/// [GameDuration] is expressed in whole game-time seconds and is intentionally
/// independent of wall-clock time or Flutter animations. A deterministic clock
/// interface (added in SDK-005) will drive game-time progression.
///
/// Example:
/// ```dart
/// const oneHour = GameDuration(seconds: 3600);
/// const fiveMinutes = GameDuration.fromMinutes(5);
/// print(oneHour > fiveMinutes); // true
/// ```
final class GameDuration implements Comparable<GameDuration> {
  /// Creates a [GameDuration] from a whole number of game-time [seconds].
  ///
  /// Throws [ArgumentError] if [seconds] is negative.
  GameDuration({required this.seconds}) {
    if (seconds < 0) {
      throw ArgumentError.value(
        seconds,
        'seconds',
        'GameDuration must be non-negative',
      );
    }
  }

  /// The zero-duration constant.
  static const GameDuration zero = GameDuration._raw(seconds: 0);

  const GameDuration._raw({required this.seconds});

  /// Creates a [GameDuration] from whole [minutes].
  factory GameDuration.fromMinutes(int minutes) =>
      GameDuration(seconds: minutes * 60);

  /// Creates a [GameDuration] from whole [hours].
  factory GameDuration.fromHours(int hours) =>
      GameDuration(seconds: hours * 3600);

  /// Creates a [GameDuration] from whole [days] (each day is 86400 seconds).
  factory GameDuration.fromDays(int days) =>
      GameDuration(seconds: days * 86400);

  /// Total game-time seconds.
  final int seconds;

  /// Whole game-time minutes (floor division).
  int get inMinutes => seconds ~/ 60;

  /// Whole game-time hours (floor division).
  int get inHours => seconds ~/ 3600;

  /// Whole game-time days (floor division, 86400 s per day).
  int get inDays => seconds ~/ 86400;

  /// Returns `true` when this duration is zero.
  bool get isZero => seconds == 0;

  /// Returns a new [GameDuration] that is the sum of this and [other].
  GameDuration operator +(GameDuration other) =>
      GameDuration(seconds: seconds + other.seconds);

  /// Returns a new [GameDuration] that is this minus [other].
  /// Returns [GameDuration.zero] if [other] exceeds this duration.
  GameDuration operator -(GameDuration other) {
    final result = seconds - other.seconds;
    return result <= 0 ? GameDuration.zero : GameDuration(seconds: result);
  }

  /// Returns `true` when this duration is greater than [other].
  bool operator >(GameDuration other) => seconds > other.seconds;

  /// Returns `true` when this duration is less than [other].
  bool operator <(GameDuration other) => seconds < other.seconds;

  /// Returns `true` when this duration is greater than or equal to [other].
  bool operator >=(GameDuration other) => seconds >= other.seconds;

  /// Returns `true` when this duration is less than or equal to [other].
  bool operator <=(GameDuration other) => seconds <= other.seconds;

  @override
  int compareTo(GameDuration other) => seconds.compareTo(other.seconds);

  /// Deserializes a [GameDuration] from a JSON map produced by [toJson].
  ///
  /// Expected format: `{ "seconds": 3600 }`.
  factory GameDuration.fromJson(Map<String, Object?> json) {
    final s = json['seconds'];
    if (s is! int) {
      throw ArgumentError.value(s, 'json[seconds]', 'Expected an integer');
    }
    return GameDuration(seconds: s);
  }

  /// Serializes this [GameDuration] to a JSON-compatible map.
  Map<String, Object> toJson() => {'seconds': seconds};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameDuration && seconds == other.seconds);

  @override
  int get hashCode => seconds.hashCode;

  @override
  String toString() => 'GameDuration(${seconds}s)';
}
