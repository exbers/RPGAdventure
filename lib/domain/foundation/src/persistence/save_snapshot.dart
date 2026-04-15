/// An immutable, versioned snapshot of game state serialized for storage.
///
/// [SaveSnapshot] is the canonical wire format that flows between
/// [SaveStore] (storage) and [SaveCodec] (domain serialization). It carries
/// only plain Dart values so it can be encoded to JSON or any other format
/// without a Flutter dependency.
///
/// - [schemaVersion] identifies the save-data schema. [SaveMigrator]
///   implementations use this to upgrade old snapshots.
/// - [slotId] is an opaque identifier chosen by the caller (e.g. `'slot_1'`,
///   `'autosave'`). It matches the key used in [SaveStore].
/// - [savedAt] is the UTC timestamp of the moment the snapshot was created.
/// - [payload] holds the serialized domain state as a plain
///   `Map<String, Object?>`. Values must be JSON-serializable primitives
///   (bool, int, double, String, List, Map, null).
final class SaveSnapshot {
  /// Creates a [SaveSnapshot].
  ///
  /// [schemaVersion] must be a non-negative integer.
  /// [slotId] must not be empty.
  /// [payload] is copied shallowly and made unmodifiable.
  SaveSnapshot({
    required this.schemaVersion,
    required this.slotId,
    required this.savedAt,
    required Map<String, Object?> payload,
  }) : payload = Map.unmodifiable(payload) {
    if (schemaVersion < 0) {
      throw ArgumentError.value(
        schemaVersion,
        'schemaVersion',
        'Must be non-negative',
      );
    }
    if (slotId.isEmpty) {
      throw ArgumentError.value(slotId, 'slotId', 'Must not be empty');
    }
  }

  /// The schema version this snapshot was encoded with.
  ///
  /// Increment this whenever the payload structure changes in a
  /// backward-incompatible way and register a migration in [SaveMigrator].
  final int schemaVersion;

  /// Opaque slot identifier. Matches the key used in [SaveStore].
  final String slotId;

  /// UTC timestamp when this snapshot was created.
  final DateTime savedAt;

  /// Serialized domain state. All values are JSON-serializable primitives.
  ///
  /// The map is unmodifiable; create a new [SaveSnapshot] to change the
  /// payload.
  final Map<String, Object?> payload;

  /// Serializes this snapshot to a plain map suitable for JSON encoding.
  ///
  /// The inverse operation is [SaveSnapshot.fromJson].
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'slotId': slotId,
    'savedAt': savedAt.toUtc().toIso8601String(),
    'payload': payload,
  };

  /// Deserializes a [SaveSnapshot] from a map produced by [toJson].
  ///
  /// Throws [FormatException] if required fields are missing or have the
  /// wrong type.
  factory SaveSnapshot.fromJson(Map<String, Object?> json) {
    final schemaVersion = json['schemaVersion'];
    final slotId = json['slotId'];
    final savedAt = json['savedAt'];
    final payload = json['payload'];

    if (schemaVersion is! int) {
      throw const FormatException(
        "SaveSnapshot.fromJson: 'schemaVersion' must be an int",
      );
    }
    if (slotId is! String) {
      throw const FormatException(
        "SaveSnapshot.fromJson: 'slotId' must be a String",
      );
    }
    if (savedAt is! String) {
      throw const FormatException(
        "SaveSnapshot.fromJson: 'savedAt' must be an ISO-8601 String",
      );
    }
    if (payload is! Map<String, Object?>) {
      throw const FormatException(
        "SaveSnapshot.fromJson: 'payload' must be a Map<String, Object?>",
      );
    }

    return SaveSnapshot(
      schemaVersion: schemaVersion,
      slotId: slotId,
      savedAt: DateTime.parse(savedAt).toUtc(),
      payload: payload,
    );
  }

  /// Returns a copy of this snapshot with [payload] replaced by [newPayload]
  /// and [schemaVersion] replaced by [newSchemaVersion].
  ///
  /// Useful inside [SaveMigrator.migrate] to produce the upgraded snapshot.
  SaveSnapshot copyWith({
    int? schemaVersion,
    String? slotId,
    DateTime? savedAt,
    Map<String, Object?>? payload,
  }) => SaveSnapshot(
    schemaVersion: schemaVersion ?? this.schemaVersion,
    slotId: slotId ?? this.slotId,
    savedAt: savedAt ?? this.savedAt,
    payload: payload ?? this.payload,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveSnapshot &&
          schemaVersion == other.schemaVersion &&
          slotId == other.slotId &&
          savedAt == other.savedAt &&
          _payloadEquals(payload, other.payload));

  @override
  int get hashCode => Object.hash(schemaVersion, slotId, savedAt);

  @override
  String toString() => 'SaveSnapshot(slot: $slotId, v$schemaVersion, $savedAt)';

  static bool _payloadEquals(Map<String, Object?> a, Map<String, Object?> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
