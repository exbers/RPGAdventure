import 'save_snapshot.dart';

/// Abstract storage adapter for save slots.
///
/// [SaveStore] is responsible only for reading, writing, deleting, and listing
/// raw [SaveSnapshot] objects. It knows nothing about domain types or game
/// rules — that responsibility belongs to [SaveCodec] and [SaveMigrator].
///
/// Swap implementations freely without touching any domain logic:
/// - Use [InMemorySaveStore] in unit tests (no platform channels).
/// - Use a file-based or shared-preferences adapter in production.
///
/// All methods are async to accommodate I/O-bound storage backends.
abstract interface class SaveStore {
  /// Reads the snapshot stored in [slotId].
  ///
  /// Returns `null` when no snapshot exists for the given slot.
  /// Throws [PersistenceFailure] (from the persistence library) on I/O errors.
  Future<SaveSnapshot?> read(String slotId);

  /// Persists [snapshot] under [snapshot.slotId].
  ///
  /// Overwrites any existing snapshot for that slot.
  /// Throws [PersistenceFailure] on I/O errors.
  Future<void> write(SaveSnapshot snapshot);

  /// Removes the snapshot stored in [slotId].
  ///
  /// Does nothing when the slot does not exist.
  /// Throws [PersistenceFailure] on I/O errors.
  Future<void> delete(String slotId);

  /// Returns the IDs of all occupied slots, in no guaranteed order.
  ///
  /// Throws [PersistenceFailure] on I/O errors.
  Future<List<String>> listSlots();
}
