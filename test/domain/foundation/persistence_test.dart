import 'package:flutter_application_1/domain/foundation/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers / fakes shared across groups
// ---------------------------------------------------------------------------

/// Minimal payload used in snapshot construction tests.
Map<String, Object?> _payload({int level = 1, String name = 'Hero'}) => {
  'level': level,
  'name': name,
};

/// A fixed reference timestamp for deterministic tests.
final _epoch = DateTime.utc(2024, 1, 1);

SaveSnapshot _snapshot({
  int schemaVersion = 1,
  String slotId = 'slot_1',
  DateTime? savedAt,
  Map<String, Object?>? payload,
}) => SaveSnapshot(
  schemaVersion: schemaVersion,
  slotId: slotId,
  savedAt: savedAt ?? _epoch,
  payload: payload ?? _payload(),
);

// ---------------------------------------------------------------------------
// Fake SaveCodec for testing
// ---------------------------------------------------------------------------

/// Simple codec that serializes a ({String name, int level}) record.
class _RecordCodec implements SaveCodec<({String name, int level})> {
  const _RecordCodec();

  @override
  Map<String, Object?> encode(({String name, int level}) value) => {
    'name': value.name,
    'level': value.level,
  };

  @override
  ({String name, int level}) decode(Map<String, Object?> map) {
    final name = map['name'];
    final level = map['level'];
    if (name is! String || level is! int) {
      throw const FormatException('Invalid payload for _RecordCodec');
    }
    return (name: name, level: level);
  }
}

// ---------------------------------------------------------------------------
// Fake SaveMigrator for testing
// ---------------------------------------------------------------------------

/// Renames 'xp' to 'experience' (simulates a v1→v2 schema change).
class _V1ToV2Migrator implements SaveMigrator {
  const _V1ToV2Migrator();

  @override
  int get migrationVersion => 2;

  @override
  SaveSnapshot migrate(SaveSnapshot snapshot) {
    final newPayload = Map<String, Object?>.of(snapshot.payload);
    newPayload['experience'] = newPayload.remove('xp') ?? 0;
    return snapshot.copyWith(schemaVersion: 2, payload: newPayload);
  }
}

/// Adds a 'class' field (simulates a v2→v3 schema change).
class _V2ToV3Migrator implements SaveMigrator {
  const _V2ToV3Migrator();

  @override
  int get migrationVersion => 3;

  @override
  SaveSnapshot migrate(SaveSnapshot snapshot) {
    final newPayload = Map<String, Object?>.of(snapshot.payload);
    newPayload.putIfAbsent('class', () => 'warrior');
    return snapshot.copyWith(schemaVersion: 3, payload: newPayload);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  group('SaveSnapshot', () {
    group('construction', () {
      test('creates snapshot with valid arguments', () {
        final snap = _snapshot();
        expect(snap.schemaVersion, 1);
        expect(snap.slotId, 'slot_1');
        expect(snap.savedAt, _epoch);
        expect(snap.payload['level'], 1);
      });

      test('payload is unmodifiable', () {
        final snap = _snapshot();
        expect(
          () => (snap.payload as dynamic)['level'] = 99,
          throwsUnsupportedError,
        );
      });

      test('throws on negative schemaVersion', () {
        expect(() => _snapshot(schemaVersion: -1), throwsArgumentError);
      });

      test('throws on empty slotId', () {
        expect(() => _snapshot(slotId: ''), throwsArgumentError);
      });
    });

    group('toJson / fromJson round-trip', () {
      test('encodes and decodes all fields correctly', () {
        final original = _snapshot(
          schemaVersion: 3,
          slotId: 'autosave',
          savedAt: DateTime.utc(2025, 6, 15, 12, 0, 0),
          payload: {'gold': 500, 'name': 'Aldric'},
        );
        final json = original.toJson();
        final decoded = SaveSnapshot.fromJson(json);

        expect(decoded.schemaVersion, original.schemaVersion);
        expect(decoded.slotId, original.slotId);
        expect(decoded.savedAt, original.savedAt);
        expect(decoded.payload, equals(original.payload));
      });

      test('savedAt is preserved as UTC', () {
        final snap = _snapshot(savedAt: DateTime.utc(2025, 3, 10, 8, 30));
        final decoded = SaveSnapshot.fromJson(snap.toJson());
        expect(decoded.savedAt.isUtc, isTrue);
        expect(decoded.savedAt, snap.savedAt);
      });

      test('fromJson throws FormatException on missing schemaVersion', () {
        expect(
          () => SaveSnapshot.fromJson({
            'slotId': 'slot_1',
            'savedAt': _epoch.toIso8601String(),
            'payload': <String, Object?>{},
          }),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromJson throws FormatException on missing slotId', () {
        expect(
          () => SaveSnapshot.fromJson({
            'schemaVersion': 1,
            'savedAt': _epoch.toIso8601String(),
            'payload': <String, Object?>{},
          }),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromJson throws FormatException on invalid savedAt', () {
        expect(
          () => SaveSnapshot.fromJson({
            'schemaVersion': 1,
            'slotId': 'slot_1',
            'savedAt': 12345,
            'payload': <String, Object?>{},
          }),
          throwsA(isA<FormatException>()),
        );
      });

      test('fromJson throws FormatException on wrong payload type', () {
        expect(
          () => SaveSnapshot.fromJson({
            'schemaVersion': 1,
            'slotId': 'slot_1',
            'savedAt': _epoch.toIso8601String(),
            'payload': 'not a map',
          }),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('copyWith', () {
      test('copies with replaced schemaVersion', () {
        final snap = _snapshot(schemaVersion: 1);
        final updated = snap.copyWith(schemaVersion: 2);
        expect(updated.schemaVersion, 2);
        expect(updated.slotId, snap.slotId);
        expect(updated.payload, equals(snap.payload));
      });

      test('copies with replaced payload', () {
        final snap = _snapshot();
        final newPayload = {'gold': 999};
        final updated = snap.copyWith(payload: newPayload);
        expect(updated.payload['gold'], 999);
        expect(updated.schemaVersion, snap.schemaVersion);
      });
    });

    group('equality', () {
      test('two snapshots with identical fields are equal', () {
        final a = _snapshot();
        final b = _snapshot();
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different slotIds are not equal', () {
        final a = _snapshot(slotId: 'slot_1');
        final b = _snapshot(slotId: 'slot_2');
        expect(a, isNot(equals(b)));
      });
    });
  });

  // =========================================================================
  group('InMemorySaveStore', () {
    late InMemorySaveStore store;

    setUp(() => store = InMemorySaveStore());

    group('write and read', () {
      test('read returns null for an empty slot', () async {
        final result = await store.read('slot_1');
        expect(result, isNull);
      });

      test('written snapshot can be read back', () async {
        final snap = _snapshot(slotId: 'slot_1');
        await store.write(snap);
        final result = await store.read('slot_1');
        expect(result, equals(snap));
      });

      test('overwriting a slot replaces the previous snapshot', () async {
        final first = _snapshot(slotId: 'slot_1', schemaVersion: 1);
        final second = _snapshot(slotId: 'slot_1', schemaVersion: 2);
        await store.write(first);
        await store.write(second);
        final result = await store.read('slot_1');
        expect(result!.schemaVersion, 2);
      });
    });

    group('delete', () {
      test('deleted slot returns null on subsequent read', () async {
        await store.write(_snapshot(slotId: 'slot_1'));
        await store.delete('slot_1');
        expect(await store.read('slot_1'), isNull);
      });

      test('deleting a non-existent slot does not throw', () async {
        await expectLater(store.delete('missing'), completes);
      });
    });

    group('listSlots', () {
      test('returns empty list when store is empty', () async {
        expect(await store.listSlots(), isEmpty);
      });

      test('returns all written slot IDs', () async {
        await store.write(_snapshot(slotId: 'slot_1'));
        await store.write(_snapshot(slotId: 'slot_2'));
        final slots = await store.listSlots();
        expect(slots, containsAll(['slot_1', 'slot_2']));
        expect(slots.length, 2);
      });

      test('deleted slot is removed from list', () async {
        await store.write(_snapshot(slotId: 'slot_1'));
        await store.write(_snapshot(slotId: 'slot_2'));
        await store.delete('slot_1');
        expect(await store.listSlots(), equals(['slot_2']));
      });
    });

    group('pre-seeded store', () {
      test('initial snapshots are readable', () async {
        final snap = _snapshot(slotId: 'autosave');
        final seeded = InMemorySaveStore(initial: {'autosave': snap});
        expect(await seeded.read('autosave'), equals(snap));
      });
    });

    group('simulated failures', () {
      test('read throws StorageReadFailure for error slot', () async {
        final failing = InMemorySaveStore(readErrorSlots: {'corrupt'});
        await expectLater(
          failing.read('corrupt'),
          throwsA(isA<StorageReadFailure>()),
        );
      });

      test('write throws StorageWriteFailure for error slot', () async {
        final failing = InMemorySaveStore(writeErrorSlots: {'locked'});
        final snap = _snapshot(slotId: 'locked');
        await expectLater(
          failing.write(snap),
          throwsA(isA<StorageWriteFailure>()),
        );
      });
    });

    group('clear', () {
      test('clear removes all snapshots', () async {
        await store.write(_snapshot(slotId: 'slot_1'));
        await store.write(_snapshot(slotId: 'slot_2'));
        store.clear();
        expect(await store.listSlots(), isEmpty);
      });
    });
  });

  // =========================================================================
  group('SaveCodec', () {
    const codec = _RecordCodec();

    test('encodes a record to a map', () {
      final map = codec.encode((name: 'Aldric', level: 5));
      expect(map['name'], 'Aldric');
      expect(map['level'], 5);
    });

    test('decodes a map back to a record', () {
      final record = codec.decode({'name': 'Rina', 'level': 10});
      expect(record.name, 'Rina');
      expect(record.level, 10);
    });

    test('encode → decode round-trip preserves values', () {
      const original = (name: 'Thorin', level: 7);
      final decoded = codec.decode(codec.encode(original));
      expect(decoded.name, original.name);
      expect(decoded.level, original.level);
    });

    test('decode throws FormatException on invalid map', () {
      expect(
        () => codec.decode({'name': 123, 'level': 'high'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  // =========================================================================
  group('SaveMigrator', () {
    const v1ToV2 = _V1ToV2Migrator();
    const v2ToV3 = _V2ToV3Migrator();

    test('migrator returns target version', () {
      expect(v1ToV2.migrationVersion, 2);
      expect(v2ToV3.migrationVersion, 3);
    });

    test('V1ToV2 renames xp to experience', () {
      final v1Snapshot = _snapshot(
        schemaVersion: 1,
        payload: {'xp': 100, 'name': 'Hero'},
      );
      final v2Snapshot = v1ToV2.migrate(v1Snapshot);
      expect(v2Snapshot.schemaVersion, 2);
      expect(v2Snapshot.payload.containsKey('xp'), isFalse);
      expect(v2Snapshot.payload['experience'], 100);
    });

    test('V2ToV3 adds default class field', () {
      final v2Snapshot = _snapshot(
        schemaVersion: 2,
        payload: {'experience': 100, 'name': 'Hero'},
      );
      final v3Snapshot = v2ToV3.migrate(v2Snapshot);
      expect(v3Snapshot.schemaVersion, 3);
      expect(v3Snapshot.payload['class'], 'warrior');
    });
  });

  // =========================================================================
  group('MigrationChain', () {
    test('applies migrators in ascending version order', () {
      final chain = MigrationChain([_V2ToV3Migrator(), _V1ToV2Migrator()]);
      final v1Snapshot = _snapshot(
        schemaVersion: 1,
        payload: {'xp': 50, 'name': 'Kira'},
      );
      final result = chain.apply(v1Snapshot);
      expect(result.schemaVersion, 3);
      expect(result.payload['experience'], 50);
      expect(result.payload['class'], 'warrior');
      expect(result.payload.containsKey('xp'), isFalse);
    });

    test('skips migrators already at or below current version', () {
      final chain = MigrationChain([_V1ToV2Migrator(), _V2ToV3Migrator()]);
      final v2Snapshot = _snapshot(
        schemaVersion: 2,
        payload: {'experience': 80, 'name': 'Rex'},
      );
      final result = chain.apply(v2Snapshot);
      // Only V2→V3 should apply.
      expect(result.schemaVersion, 3);
      expect(result.payload['class'], 'warrior');
    });

    test('returns snapshot unchanged when already at latest version', () {
      final chain = MigrationChain([_V1ToV2Migrator()]);
      final snap = _snapshot(schemaVersion: 2);
      final result = chain.apply(snap);
      expect(result, equals(snap));
    });

    test('empty chain returns snapshot unchanged', () {
      final chain = MigrationChain([]);
      final snap = _snapshot(schemaVersion: 5);
      expect(chain.apply(snap), equals(snap));
    });

    test('latestVersion returns -1 for empty chain', () {
      expect(MigrationChain([]).latestVersion, -1);
    });

    test('latestVersion matches highest migrator target', () {
      final chain = MigrationChain([_V1ToV2Migrator(), _V2ToV3Migrator()]);
      expect(chain.latestVersion, 3);
    });

    test('throws ArgumentError on duplicate migrationVersion', () {
      expect(
        () => MigrationChain([_V1ToV2Migrator(), _V1ToV2Migrator()]),
        throwsArgumentError,
      );
    });
  });

  // =========================================================================
  group('SaveBackupPolicy', () {
    final incoming = _snapshot(slotId: 'slot_1', schemaVersion: 2);
    final existing = _snapshot(slotId: 'slot_1', schemaVersion: 1);

    group('NeverBackupPolicy', () {
      const policy = NeverBackupPolicy();

      test('always returns false', () {
        expect(
          policy.shouldBackup(incoming: incoming, existing: existing),
          isFalse,
        );
        expect(
          policy.shouldBackup(incoming: incoming, existing: null),
          isFalse,
        );
      });
    });

    group('AlwaysBackupPolicy', () {
      const policy = AlwaysBackupPolicy();

      test('always returns true', () {
        expect(
          policy.shouldBackup(incoming: incoming, existing: existing),
          isTrue,
        );
        expect(policy.shouldBackup(incoming: incoming, existing: null), isTrue);
      });
    });

    group('EveryNthWriteBackupPolicy', () {
      test('throws on non-positive interval', () {
        expect(
          () => EveryNthWriteBackupPolicy(interval: 0),
          throwsArgumentError,
        );
        expect(
          () => EveryNthWriteBackupPolicy(interval: -1),
          throwsArgumentError,
        );
      });

      test('returns true exactly every N writes for the same slot', () {
        final policy = EveryNthWriteBackupPolicy(interval: 3);
        final snap = _snapshot(slotId: 'slot_1');

        // Write 1: count=1 → 1%3 != 0 → false
        expect(policy.shouldBackup(incoming: snap, existing: null), isFalse);
        // Write 2: count=2 → false
        expect(policy.shouldBackup(incoming: snap, existing: snap), isFalse);
        // Write 3: count=3 → 3%3==0 → true
        expect(policy.shouldBackup(incoming: snap, existing: snap), isTrue);
        // Write 4: count=4 → false
        expect(policy.shouldBackup(incoming: snap, existing: snap), isFalse);
        // Write 6: count=6 → true
        expect(policy.shouldBackup(incoming: snap, existing: snap), isFalse);
        expect(policy.shouldBackup(incoming: snap, existing: snap), isTrue);
      });

      test('tracks counters independently per slot', () {
        final policy = EveryNthWriteBackupPolicy(interval: 2);
        final snapA = _snapshot(slotId: 'slot_a');
        final snapB = _snapshot(slotId: 'slot_b');

        // slot_a write 1 → false
        expect(policy.shouldBackup(incoming: snapA, existing: null), isFalse);
        // slot_b write 1 → false
        expect(policy.shouldBackup(incoming: snapB, existing: null), isFalse);
        // slot_a write 2 → true (count=2)
        expect(policy.shouldBackup(incoming: snapA, existing: snapA), isTrue);
        // slot_b write 2 → true (count=2, independent)
        expect(policy.shouldBackup(incoming: snapB, existing: snapB), isTrue);
      });
    });
  });

  // =========================================================================
  group('PersistenceFailure', () {
    test('StorageWriteFailure is a PersistenceFailure', () {
      expect(
        const StorageWriteFailure(message: 'disk full'),
        isA<PersistenceFailure>(),
      );
    });

    test('StorageReadFailure carries slotId', () {
      const failure = StorageReadFailure(slotId: 'slot_1', message: 'io err');
      expect(failure.slotId, 'slot_1');
      expect(failure.message, 'io err');
    });

    test('SlotNotFoundFailure carries slotId', () {
      const failure = SlotNotFoundFailure(slotId: 'missing_slot');
      expect(failure.slotId, 'missing_slot');
    });

    test('SnapshotCorruptedFailure carries slotId and optional cause', () {
      final cause = FormatException('bad JSON');
      final failure = SnapshotCorruptedFailure(slotId: 'slot_2', cause: cause);
      expect(failure.slotId, 'slot_2');
      expect(failure.cause, cause);
    });

    test('MigrationFailure carries fromVersion and toVersion', () {
      const failure = MigrationFailure(fromVersion: 1, toVersion: 3);
      expect(failure.fromVersion, 1);
      expect(failure.toVersion, 3);
    });

    test('CodecFailure is throwable and catchable as PersistenceFailure', () {
      Object? caught;
      try {
        throw const CodecFailure(message: 'encode error');
      } on PersistenceFailure catch (e) {
        caught = e;
      }
      expect(caught, isA<CodecFailure>());
    });

    test('toString includes runtimeType and message', () {
      const failure = StorageWriteFailure(message: 'out of space');
      expect(failure.toString(), contains('StorageWriteFailure'));
      expect(failure.toString(), contains('out of space'));
    });

    test('toString without message includes only runtimeType', () {
      const failure = SlotNotFoundFailure(slotId: 'x');
      expect(failure.toString(), contains('SlotNotFoundFailure'));
    });
  });
}
