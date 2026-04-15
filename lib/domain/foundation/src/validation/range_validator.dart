import 'content_validator.dart';
import 'validation_context.dart';

/// A numeric field to check inside [RangeValidatorInput].
final class NumericFieldCheck {
  const NumericFieldCheck({
    required this.field,
    this.min,
    this.max,
    this.allowNegative = true,
  });

  /// Name of the field in the content entry map (e.g. `"attack"`).
  final String field;

  /// Optional inclusive minimum value.
  final num? min;

  /// Optional inclusive maximum value.
  final num? max;

  /// When `false`, any negative value triggers an error regardless of [min].
  ///
  /// This is a convenience shortcut for `min: 0`.
  final bool allowNegative;
}

/// Input model for [RangeValidator].
final class RangeValidatorInput {
  const RangeValidatorInput({
    required this.listName,
    required this.entries,
    required this.checks,
  });

  /// Top-level list label used in path output (e.g. `"monsters"`).
  final String listName;

  /// Ordered list of content entries (raw `Map<String, Object?>`).
  final List<Map<String, Object?>> entries;

  /// Numeric range constraints to enforce on each entry.
  final List<NumericFieldCheck> checks;
}

/// Validates numeric fields against allowed ranges.
///
/// Typical use: catching negative stats (HP, attack, defense) or out-of-range
/// level values in content definitions.
///
/// ```dart
/// final validator = RangeValidator();
/// final input = RangeValidatorInput(
///   listName: 'monsters',
///   entries: [{'id': 'goblin', 'hp': -5, 'attack': 3}],
///   checks: [
///     NumericFieldCheck(field: 'hp', allowNegative: false),
///     NumericFieldCheck(field: 'attack', min: 0, max: 9999),
///   ],
/// );
/// final report = validator.run(input);
/// // => error at "monsters[0].hp": value -5 must not be negative
/// ```
final class RangeValidator extends ContentValidator<RangeValidatorInput> {
  const RangeValidator();

  @override
  void validate(RangeValidatorInput input, ValidationContext context) {
    for (var i = 0; i < input.entries.length; i++) {
      final entry = input.entries[i];
      final entryPath = '${input.listName}[$i]';
      for (final check in input.checks) {
        final rawValue = entry[check.field];
        if (rawValue == null) continue; // absence is checked by SchemaValidator
        if (rawValue is! num) {
          context.addError(
            'field "${check.field}" must be a number, got ${rawValue.runtimeType}',
            pathOverride: '$entryPath.${check.field}',
          );
          continue;
        }
        final value = rawValue;
        if (!check.allowNegative && value < 0) {
          context.addError(
            'value $value must not be negative',
            pathOverride: '$entryPath.${check.field}',
          );
          continue;
        }
        if (check.min != null && value < check.min!) {
          context.addError(
            'value $value is below minimum ${check.min}',
            pathOverride: '$entryPath.${check.field}',
          );
        }
        if (check.max != null && value > check.max!) {
          context.addError(
            'value $value exceeds maximum ${check.max}',
            pathOverride: '$entryPath.${check.field}',
          );
        }
      }
    }
  }
}
