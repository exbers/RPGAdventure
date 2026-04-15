/// Sealed class hierarchy for persistence-layer failures.
///
/// Use pattern matching to handle specific failure kinds without catching
/// untyped exceptions:
///
/// ```dart
/// try {
///   await store.write(snapshot);
/// } on PersistenceFailure catch (failure) {
///   switch (failure) {
///     case StorageWriteFailure(:final cause):
///       log('write error: $cause');
///     case StorageReadFailure(:final slotId):
///       log('cannot read slot $slotId');
///     case SlotNotFoundFailure(:final slotId):
///       log('slot $slotId is empty');
///     case SnapshotCorruptedFailure(:final slotId):
///       log('snapshot $slotId is corrupted');
///     case MigrationFailure(:final fromVersion, :final toVersion):
///       log('migration $fromVersion→$toVersion failed');
///     case CodecFailure(:final cause):
///       log('codec error: $cause');
///   }
/// }
/// ```
sealed class PersistenceFailure implements Exception {
  /// Creates a [PersistenceFailure] with an optional human-readable [message].
  const PersistenceFailure({this.message});

  /// Optional human-readable description of what went wrong.
  final String? message;

  @override
  String toString() {
    final label = runtimeType;
    return message != null ? '$label: $message' : '$label';
  }
}

/// Thrown when a write operation to the underlying storage fails.
///
/// [cause] is the original exception raised by the storage backend, if any.
final class StorageWriteFailure extends PersistenceFailure {
  /// Creates a [StorageWriteFailure].
  const StorageWriteFailure({this.cause, super.message});

  /// The root-cause exception from the storage layer, if available.
  final Object? cause;
}

/// Thrown when a read operation from the underlying storage fails.
///
/// [slotId] identifies the slot that could not be read.
/// [cause] is the original exception raised by the storage backend, if any.
final class StorageReadFailure extends PersistenceFailure {
  /// Creates a [StorageReadFailure].
  const StorageReadFailure({required this.slotId, this.cause, super.message});

  /// The slot that could not be read.
  final String slotId;

  /// The root-cause exception from the storage layer, if available.
  final Object? cause;
}

/// Thrown when a read is attempted on a slot that does not exist.
///
/// Differs from [StorageReadFailure] in that the slot is definitively absent,
/// not unreadable due to an I/O error.
final class SlotNotFoundFailure extends PersistenceFailure {
  /// Creates a [SlotNotFoundFailure] for [slotId].
  const SlotNotFoundFailure({required this.slotId, super.message});

  /// The slot that was requested but not found.
  final String slotId;
}

/// Thrown when a snapshot cannot be deserialized because its data is corrupt.
///
/// [slotId] identifies the affected slot.
/// [cause] is the deserialization exception, if available.
final class SnapshotCorruptedFailure extends PersistenceFailure {
  /// Creates a [SnapshotCorruptedFailure].
  const SnapshotCorruptedFailure({
    required this.slotId,
    this.cause,
    super.message,
  });

  /// The slot whose data is corrupted.
  final String slotId;

  /// The deserialization error, if available.
  final Object? cause;
}

/// Thrown when a [SaveMigrator] (or [MigrationChain]) cannot upgrade a
/// snapshot to the required schema version.
///
/// [fromVersion] is the snapshot's current schema version.
/// [toVersion] is the schema version that was requested.
final class MigrationFailure extends PersistenceFailure {
  /// Creates a [MigrationFailure].
  const MigrationFailure({
    required this.fromVersion,
    required this.toVersion,
    this.cause,
    super.message,
  });

  /// Schema version the snapshot was at before the attempted migration.
  final int fromVersion;

  /// Schema version that was needed.
  final int toVersion;

  /// The root-cause exception from the migrator, if available.
  final Object? cause;
}

/// Thrown when a [SaveCodec] fails to encode or decode a domain value.
///
/// [cause] is the underlying [FormatException] or other error.
final class CodecFailure extends PersistenceFailure {
  /// Creates a [CodecFailure].
  const CodecFailure({this.cause, super.message});

  /// The root-cause error from the codec, if available.
  final Object? cause;
}
