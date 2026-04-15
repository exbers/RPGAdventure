import 'content_validator.dart';
import 'validation_context.dart';

/// Input model for [ReferenceValidator].
///
/// [references] is a list of entries to validate. Each entry is a map that
/// must supply an `id` field and optionally other reference fields. Callers
/// describe which fields to check using [ReferenceCheck].
///
/// Example — validating that every monster's zone reference is known:
/// ```dart
/// final input = ReferenceValidatorInput(
///   listName: 'monsters',
///   references: [
///     {'id': 'goblin', 'zoneId': 'forest'},
///   ],
///   checks: [
///     ReferenceCheck(field: 'zoneId', knownIds: {'forest', 'dungeon'}),
///   ],
/// );
/// ```
final class ReferenceValidatorInput {
  const ReferenceValidatorInput({
    required this.listName,
    required this.references,
    required this.checks,
  });

  /// Top-level list label used in path output (e.g. `"monsters"`).
  final String listName;

  /// Ordered list of entries to validate; each entry is a raw `Map<String,
  /// Object?>` representation of a content record.
  final List<Map<String, Object?>> references;

  /// Validation rules: for each [ReferenceCheck], the validator checks that
  /// the field value exists in [ReferenceCheck.knownIds].
  final List<ReferenceCheck> checks;
}

/// Describes one reference field to check against a set of known IDs.
final class ReferenceCheck {
  const ReferenceCheck({required this.field, required this.knownIds});

  /// The field name inside the entry map (e.g. `"zoneId"`).
  final String field;

  /// The set of valid raw ID values for this field.
  final Set<String> knownIds;
}

/// Validates that cross-content references resolve to known IDs.
///
/// For every entry in [ReferenceValidatorInput.references] the validator checks
/// each [ReferenceCheck.field]:
/// - If the field is absent, records an error (missing required reference).
/// - If the field value is not in [ReferenceCheck.knownIds], records an error.
final class ReferenceValidator
    extends ContentValidator<ReferenceValidatorInput> {
  const ReferenceValidator();

  @override
  void validate(ReferenceValidatorInput input, ValidationContext context) {
    for (var i = 0; i < input.references.length; i++) {
      final entry = input.references[i];
      final entryPath = '${input.listName}[$i]';
      for (final check in input.checks) {
        final rawValue = entry[check.field];
        if (rawValue == null) {
          context.addError(
            'missing required reference field "${check.field}"',
            pathOverride: '$entryPath.${check.field}',
          );
        } else {
          final value = rawValue.toString();
          if (!check.knownIds.contains(value)) {
            context.addError(
              'unknown reference "$value"',
              pathOverride: '$entryPath.${check.field}',
              detail: 'not found in known IDs for "${check.field}"',
            );
          }
        }
      }
    }
  }
}
