import 'save_snapshot.dart';

/// Decides whether a backup copy should be created before overwriting a slot.
///
/// Implement this interface to define game-specific backup strategies
/// without coupling backup logic to the [SaveStore] implementation or to
/// domain rules.
///
/// The policy is consulted synchronously before each [SaveStore.write] call.
/// It receives the about-to-be-written [incoming] snapshot and the
/// [existing] snapshot currently in the store (or `null` when the slot is
/// empty).
///
/// Built-in policies:
/// - [NeverBackupPolicy] — always returns `false` (backups disabled).
/// - [AlwaysBackupPolicy] — always returns `true`.
/// - [EveryNthWriteBackupPolicy] — backs up every N writes per slot.
///
/// Example:
/// ```dart
/// class OnLevelUpBackupPolicy implements SaveBackupPolicy {
///   @override
///   bool shouldBackup({
///     required SaveSnapshot incoming,
///     required SaveSnapshot? existing,
///   }) {
///     if (existing == null) return false;
///     final oldLevel = existing.payload['level'] as int? ?? 0;
///     final newLevel = incoming.payload['level'] as int? ?? 0;
///     return newLevel > oldLevel;
///   }
/// }
/// ```
abstract interface class SaveBackupPolicy {
  /// Returns `true` when a backup should be created for [incoming].
  ///
  /// [existing] is the snapshot currently stored in the slot, or `null` if
  /// the slot is empty. Implementations must not throw.
  bool shouldBackup({
    required SaveSnapshot incoming,
    required SaveSnapshot? existing,
  });
}

/// A [SaveBackupPolicy] that never requests a backup.
///
/// Use this in tests or when backups are handled by an external mechanism
/// (e.g. cloud sync).
final class NeverBackupPolicy implements SaveBackupPolicy {
  /// Creates a [NeverBackupPolicy].
  const NeverBackupPolicy();

  @override
  bool shouldBackup({
    required SaveSnapshot incoming,
    required SaveSnapshot? existing,
  }) => false;
}

/// A [SaveBackupPolicy] that always requests a backup.
///
/// Useful during development to inspect historical saves.
final class AlwaysBackupPolicy implements SaveBackupPolicy {
  /// Creates an [AlwaysBackupPolicy].
  const AlwaysBackupPolicy();

  @override
  bool shouldBackup({
    required SaveSnapshot incoming,
    required SaveSnapshot? existing,
  }) => true;
}

/// A [SaveBackupPolicy] that requests a backup every [interval] writes per
/// slot.
///
/// The write counter is reset when the [EveryNthWriteBackupPolicy] object is
/// recreated (e.g. after app restart). For persistent counters, use a custom
/// policy backed by a [SaveStore].
final class EveryNthWriteBackupPolicy implements SaveBackupPolicy {
  /// Creates an [EveryNthWriteBackupPolicy] with a positive [interval].
  ///
  /// Throws [ArgumentError] if [interval] is not a positive integer.
  EveryNthWriteBackupPolicy({required this.interval}) {
    if (interval <= 0) {
      throw ArgumentError.value(
        interval,
        'interval',
        'Must be a positive integer',
      );
    }
  }

  /// Number of writes between backups for each slot.
  final int interval;

  final Map<String, int> _writeCounts = {};

  @override
  bool shouldBackup({
    required SaveSnapshot incoming,
    required SaveSnapshot? existing,
  }) {
    final count = (_writeCounts[incoming.slotId] ?? 0) + 1;
    _writeCounts[incoming.slotId] = count;
    return count % interval == 0;
  }
}
