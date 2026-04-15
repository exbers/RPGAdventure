import 'save_snapshot.dart';

/// Upgrades a [SaveSnapshot] payload from an older schema version.
///
/// When the payload structure changes in a backward-incompatible way,
/// increment [SaveSnapshot.schemaVersion] and register a [SaveMigrator]
/// implementation that converts the old format to the new one.
///
/// A [SaveMigrator] must be stateless and deterministic — given the same
/// input it always produces the same output. It operates only on plain maps
/// (`Map<String, Object?>`) so it can run without any Flutter or platform
/// dependency.
///
/// ## Versioning convention
///
/// - [migrationVersion] is the *target* schema version this migrator produces.
/// - A migrator with [migrationVersion] == 2 upgrades version-1 snapshots to
///   version-2 snapshots.
/// - Chain migrators in ascending [migrationVersion] order to migrate across
///   multiple versions.
///
/// Example:
/// ```dart
/// class V1ToV2HeroMigrator implements SaveMigrator {
///   @override
///   int get migrationVersion => 2;
///
///   @override
///   SaveSnapshot migrate(SaveSnapshot snapshot) {
///     final newPayload = Map<String, Object?>.of(snapshot.payload);
///     // 'xp' was renamed to 'experience' in v2.
///     newPayload['experience'] = newPayload.remove('xp') ?? 0;
///     return snapshot.copyWith(
///       schemaVersion: migrationVersion,
///       payload: newPayload,
///     );
///   }
/// }
/// ```
abstract interface class SaveMigrator {
  /// The schema version this migrator targets (i.e. produces as output).
  int get migrationVersion;

  /// Upgrades [snapshot] to [migrationVersion].
  ///
  /// The caller guarantees that [snapshot.schemaVersion] ==
  /// [migrationVersion] - 1 before calling this method.
  ///
  /// The returned snapshot must have [schemaVersion] == [migrationVersion].
  SaveSnapshot migrate(SaveSnapshot snapshot);
}

/// Applies a chain of [SaveMigrator]s to bring a [SaveSnapshot] up to date.
///
/// Migrators are applied in ascending [SaveMigrator.migrationVersion] order.
/// Any migrator whose [migrationVersion] is less than or equal to
/// [snapshot.schemaVersion] is skipped.
///
/// Throws [ArgumentError] when [migrators] contains duplicate target versions.
final class MigrationChain {
  /// Creates a [MigrationChain] from [migrators].
  ///
  /// [migrators] may be provided in any order; they are sorted internally.
  MigrationChain(List<SaveMigrator> migrators)
    : _migrators = _sorted(migrators);

  final List<SaveMigrator> _migrators;

  /// Applies all relevant migrators to [snapshot] and returns the result.
  ///
  /// Returns [snapshot] unchanged when it is already at or beyond the latest
  /// migrator version.
  SaveSnapshot apply(SaveSnapshot snapshot) {
    var current = snapshot;
    for (final migrator in _migrators) {
      if (migrator.migrationVersion <= current.schemaVersion) continue;
      current = migrator.migrate(current);
    }
    return current;
  }

  /// The target version produced by the last migrator in the chain.
  ///
  /// Returns -1 when the chain is empty.
  int get latestVersion =>
      _migrators.isEmpty ? -1 : _migrators.last.migrationVersion;

  static List<SaveMigrator> _sorted(List<SaveMigrator> migrators) {
    final seen = <int>{};
    for (final m in migrators) {
      if (!seen.add(m.migrationVersion)) {
        throw ArgumentError(
          'Duplicate migrationVersion ${m.migrationVersion} in MigrationChain',
        );
      }
    }
    return List.of(migrators)
      ..sort((a, b) => a.migrationVersion.compareTo(b.migrationVersion));
  }
}
