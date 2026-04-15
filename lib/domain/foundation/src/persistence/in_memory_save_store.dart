import 'persistence_failure.dart';
import 'save_snapshot.dart';
import 'save_store.dart';

/// A [SaveStore] that keeps snapshots in a plain Dart [Map].
///
/// Intended exclusively for unit tests. No platform channels, no I/O.
///
/// [InMemorySaveStore] can be pre-seeded via the constructor to test loading
/// existing saves:
///
/// ```dart
/// final store = InMemorySaveStore(
///   initial: {'slot_1': existingSnapshot},
/// );
/// ```
///
/// Optionally inject [readErrorSlots] or [writeErrorSlots] to simulate
/// storage failures for specific slot IDs:
///
/// ```dart
/// final failingStore = InMemorySaveStore(
///   readErrorSlots: {'slot_corrupt'},
/// );
/// ```
final class InMemorySaveStore implements SaveStore {
  /// Creates an [InMemorySaveStore].
  ///
  /// [initial] seeds the store with existing snapshots.
  /// [readErrorSlots] causes [read] to throw [StorageReadFailure] for
  ///   those slot IDs.
  /// [writeErrorSlots] causes [write] to throw [StorageWriteFailure] for
  ///   those slot IDs.
  InMemorySaveStore({
    Map<String, SaveSnapshot>? initial,
    Set<String> readErrorSlots = const {},
    Set<String> writeErrorSlots = const {},
  }) : _data = initial != null ? Map.of(initial) : {},
       _readErrorSlots = Set.of(readErrorSlots),
       _writeErrorSlots = Set.of(writeErrorSlots);

  final Map<String, SaveSnapshot> _data;
  final Set<String> _readErrorSlots;
  final Set<String> _writeErrorSlots;

  /// Returns an unmodifiable view of the internal store.
  ///
  /// Use this in tests to assert the final state without going through [read].
  Map<String, SaveSnapshot> get snapshots => Map.unmodifiable(_data);

  @override
  Future<SaveSnapshot?> read(String slotId) async {
    if (_readErrorSlots.contains(slotId)) {
      throw StorageReadFailure(
        slotId: slotId,
        message: 'Simulated read failure for slot $slotId',
      );
    }
    return _data[slotId];
  }

  @override
  Future<void> write(SaveSnapshot snapshot) async {
    if (_writeErrorSlots.contains(snapshot.slotId)) {
      throw StorageWriteFailure(
        message: 'Simulated write failure for slot ${snapshot.slotId}',
      );
    }
    _data[snapshot.slotId] = snapshot;
  }

  @override
  Future<void> delete(String slotId) async {
    _data.remove(slotId);
  }

  @override
  Future<List<String>> listSlots() async => List.of(_data.keys);

  /// Removes all snapshots from the store.
  ///
  /// Convenience method for test teardown — not part of [SaveStore].
  void clear() => _data.clear();
}
