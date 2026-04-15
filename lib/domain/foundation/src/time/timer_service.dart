import '../value_objects/game_duration.dart';
import 'timer_entry.dart';

/// Manages a collection of countdown timers driven by explicit [tick] calls.
///
/// [TimerService] is intentionally decoupled from any real-time clock or
/// Flutter animation ticker. The caller advances time by calling [tick] with a
/// delta obtained from a [Clock] implementation; this makes behaviour fully
/// deterministic in tests.
///
/// ## Usage
///
/// ```dart
/// final service = TimerService();
/// service.register(TimerEntry(
///   id: 'burn_hero',
///   remaining: GameDuration(seconds: 10),
///   onExpired: (id) => print('$id expired'),
/// ));
///
/// // Each game turn:
/// service.tick(GameDuration(seconds: 3));
/// ```
///
/// ## Thread safety
///
/// Not thread-safe; call from a single game-loop isolate.
final class TimerService {
  final Map<String, TimerEntry> _entries = {};

  /// The number of currently registered (non-expired) timers.
  int get count => _entries.length;

  /// Returns `true` if a timer with [id] is registered.
  bool isRegistered(String id) => _entries.containsKey(id);

  /// Registers [entry].
  ///
  /// If a timer with the same [TimerEntry.id] already exists it is replaced.
  /// Already-expired entries (remaining is zero) are not registered.
  void register(TimerEntry entry) {
    if (entry.isExpired) {
      entry.onExpired(entry.id);
      return;
    }
    _entries[entry.id] = entry;
  }

  /// Removes the timer with [id] without firing the expiry callback.
  ///
  /// Does nothing if no such timer exists.
  void cancel(String id) {
    _entries.remove(id);
  }

  /// Advances all registered timers by [delta] and fires callbacks for any
  /// that expire.
  ///
  /// Expired entries are removed after their callbacks are invoked. Timers
  /// added during a tick callback are processed on the next [tick] call.
  void tick(GameDuration delta) {
    if (delta.isZero) return;

    // Snapshot keys so callbacks can register new timers safely.
    final ids = List<String>.from(_entries.keys);

    for (final id in ids) {
      final entry = _entries[id];
      if (entry == null) continue; // may have been cancelled inside a callback

      if (entry.remaining <= delta) {
        _entries.remove(id);
        entry.onExpired(id);
      } else {
        _entries[id] = entry.withRemaining(entry.remaining - delta);
      }
    }
  }

  /// Returns an unmodifiable snapshot of all active entries (for debugging /
  /// save serialization).
  List<TimerEntry> get entries => List.unmodifiable(_entries.values);
}
