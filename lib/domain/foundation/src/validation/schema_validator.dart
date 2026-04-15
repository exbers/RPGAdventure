import 'content_validator.dart';
import 'validation_context.dart';

/// Describes the schema of a content list to validate.
final class ContentSchema {
  const ContentSchema({
    required this.listName,
    required this.requiredFields,
    this.idField = 'id',
  });

  /// Top-level list label used in path output (e.g. `"monsters"`).
  final String listName;

  /// Field names that must be present and non-null in every entry.
  final List<String> requiredFields;

  /// The field that acts as the primary identifier (default `"id"`).
  ///
  /// An absent or empty [idField] is always an error and is checked
  /// separately from [requiredFields].
  final String idField;
}

/// Input model for [SchemaValidator].
final class SchemaValidatorInput {
  const SchemaValidatorInput({required this.schema, required this.entries});

  final ContentSchema schema;
  final List<Map<String, Object?>> entries;
}

/// Validates that every content entry satisfies its schema.
///
/// Checks:
/// 1. The [ContentSchema.idField] is present and non-empty.
/// 2. All [ContentSchema.requiredFields] are present and non-null.
///
/// Field presence only; type and range checks belong in [RangeValidator] or
/// custom [ContentValidator] subclasses.
final class SchemaValidator extends ContentValidator<SchemaValidatorInput> {
  const SchemaValidator();

  @override
  void validate(SchemaValidatorInput input, ValidationContext context) {
    final schema = input.schema;
    for (var i = 0; i < input.entries.length; i++) {
      final entry = input.entries[i];
      final entryPath = '${schema.listName}[$i]';

      // Check primary ID field.
      final rawId = entry[schema.idField];
      if (rawId == null || rawId.toString().isEmpty) {
        context.addError(
          'missing or empty "${schema.idField}"',
          pathOverride: '$entryPath.${schema.idField}',
        );
      }

      // Check all required fields.
      for (final field in schema.requiredFields) {
        if (field == schema.idField) continue; // already checked above
        if (!entry.containsKey(field) || entry[field] == null) {
          context.addError(
            'missing required field "$field"',
            pathOverride: '$entryPath.$field',
          );
        }
      }
    }
  }
}
