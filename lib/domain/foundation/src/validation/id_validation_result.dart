/// Describes a single missing-ID problem found during content validation.
final class MissingIdError {
  const MissingIdError({
    required this.field,
    required this.id,
    required this.idType,
  });

  /// The JSON path or field name where the reference was found
  /// (e.g. `'loot_table[0].itemId'`).
  final String field;

  /// The raw ID value that could not be resolved.
  final String id;

  /// A human-readable label for the ID type (e.g. `'ItemId'`, `'QuestId'`).
  final String idType;

  @override
  String toString() => 'MissingIdError($idType "$id" at $field)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissingIdError &&
          field == other.field &&
          id == other.id &&
          idType == other.idType);

  @override
  int get hashCode => Object.hash(field, id, idType);
}

/// Aggregated result of running [IdValidator] over a content document.
///
/// A result with no errors is considered valid.
final class IdValidationResult {
  const IdValidationResult(this.errors);

  /// Constructs a valid (error-free) result.
  const IdValidationResult.valid() : errors = const [];

  /// All missing-ID problems found. Empty when validation passed.
  final List<MissingIdError> errors;

  /// Returns `true` when no missing-ID errors were found.
  bool get isValid => errors.isEmpty;

  /// Returns a multi-line report suitable for debug logging.
  String toReport() {
    if (isValid) return 'IdValidationResult: valid';
    final lines = <String>['IdValidationResult: ${errors.length} error(s)'];
    for (final e in errors) {
      lines.add('  - ${e.idType} "${e.id}" at ${e.field}');
    }
    return lines.join('\n');
  }
}
