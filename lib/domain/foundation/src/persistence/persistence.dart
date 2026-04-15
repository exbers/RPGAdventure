/// Persistence contracts for the Game Foundation SDK (SDK-004).
///
/// This barrel re-exports every public symbol in the persistence subsystem.
/// Consumers of the foundation library should import only
/// `foundation.dart`; this file is an internal sub-barrel.
///
/// Public types:
/// - [SaveSnapshot] — immutable, versioned snapshot of serialized game state.
/// - [SaveStore] — abstract storage adapter (read / write / delete / list).
/// - [SaveCodec] — bidirectional codec between a domain type and a map.
/// - [SaveMigrator] — single-version payload upgrader.
/// - [MigrationChain] — chains multiple migrators in version order.
/// - [SaveBackupPolicy] — decides when to create backup copies.
/// - [NeverBackupPolicy] — built-in policy: never backup.
/// - [AlwaysBackupPolicy] — built-in policy: always backup.
/// - [EveryNthWriteBackupPolicy] — built-in policy: every N writes.
/// - [InMemorySaveStore] — test-only in-memory store (no platform channels).
/// - [PersistenceFailure] — sealed failure hierarchy.
/// - [StorageWriteFailure], [StorageReadFailure], [SlotNotFoundFailure],
///   [SnapshotCorruptedFailure], [MigrationFailure], [CodecFailure].
library;

export 'in_memory_save_store.dart';
export 'persistence_failure.dart';
export 'save_backup_policy.dart';
export 'save_codec.dart';
export 'save_migrator.dart';
export 'save_snapshot.dart';
export 'save_store.dart';
