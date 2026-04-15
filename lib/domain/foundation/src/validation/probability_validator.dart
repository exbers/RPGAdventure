import 'content_validator.dart';
import 'validation_context.dart';

/// Input model for [ProbabilityValidator].
///
/// [groups] is a list of named probability groups. Each group contains a set
/// of chance values (as `double`) that the validator will check individually
/// and, if [groupSumMustNotExceedOne] is set, as a collective sum.
///
/// Example — validating a loot table's drop chances:
/// ```dart
/// final input = ProbabilityValidatorInput(
///   groups: [
///     ProbabilityGroup(
///       path: 'monsters[0].loot',
///       chances: [0.4, 0.3, 0.4], // sum exceeds 1.0 => error
///     ),
///   ],
/// );
/// ```
final class ProbabilityValidatorInput {
  const ProbabilityValidatorInput({required this.groups});

  final List<ProbabilityGroup> groups;
}

/// One group of chance values to validate.
final class ProbabilityGroup {
  const ProbabilityGroup({
    required this.path,
    required this.chances,
    this.groupSumMustNotExceedOne = true,
  });

  /// Path prefix for individual chance paths (e.g. `"monsters[0].loot"`).
  final String path;

  /// The chance values (expected in `[0, 1]`).
  final List<double> chances;

  /// When `true` (default) the validator also checks that the sum of all
  /// chances in this group does not exceed `1.0`.
  ///
  /// Set to `false` for independent drop chances where overlap is intentional.
  final bool groupSumMustNotExceedOne;
}

/// Validates probability / chance values in content definitions.
///
/// Checks:
/// 1. Every individual chance is in `[0.0, 1.0]`.
/// 2. The sum of all chances in a group does not exceed `1.0` (when enabled).
final class ProbabilityValidator
    extends ContentValidator<ProbabilityValidatorInput> {
  const ProbabilityValidator();

  /// Tolerance for floating-point sum comparison.
  static const double _epsilon = 1e-9;

  @override
  void validate(ProbabilityValidatorInput input, ValidationContext context) {
    for (final group in input.groups) {
      var sum = 0.0;
      for (var i = 0; i < group.chances.length; i++) {
        final chance = group.chances[i];
        final chancePath = '${group.path}[$i].chance';
        if (chance < 0.0) {
          context.addError(
            'chance $chance must be >= 0',
            pathOverride: chancePath,
          );
        } else if (chance > 1.0) {
          context.addError(
            'chance $chance must be <= 1.0',
            pathOverride: chancePath,
          );
        }
        sum += chance;
      }
      if (group.groupSumMustNotExceedOne && sum > 1.0 + _epsilon) {
        context.addError(
          'sum of chances $sum exceeds 1.0',
          pathOverride: group.path,
          detail: 'total=${sum.toStringAsFixed(6)}',
        );
      }
    }
  }
}
