import '../value_objects/game_duration.dart';

/// A registered countdown entry managed by [TimerService].
///
/// [TimerEntry] is immutable; [TimerService] replaces entries on each tick
/// rather than mutating them, making game-state snapshots straightforward.
final class TimerEntry {
  /// Creates an active [TimerEntry].
  ///
  /// [id] — caller-supplied unique identifier (e.g. an effect instance UUID or
  /// a string key).
  /// [remaining] — how much game time is left before expiry.
  /// [onExpired] — called exactly once when [remaining] reaches zero.
  const TimerEntry({
    required this.id,
    required this.remaining,
    required this.onExpired,
  });

  /// Caller-supplied identifier; must be unique within a [TimerService].
  final String id;

  /// Game time remaining before this timer expires.
  final GameDuration remaining;

  /// Callback invoked by [TimerService.tick] when the timer expires.
  ///
  /// The callback receives the timer [id] so a single handler can manage
  /// multiple timers.
  final void Function(String id) onExpired;

  /// Returns a copy with the given [remaining] duration.
  TimerEntry withRemaining(GameDuration remaining) =>
      TimerEntry(id: id, remaining: remaining, onExpired: onExpired);

  /// Whether this timer has already expired.
  bool get isExpired => remaining.isZero;

  @override
  String toString() => 'TimerEntry(id: $id, remaining: $remaining)';
}
