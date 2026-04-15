import 'package:flutter_application_1/core/errors/game_failure.dart';

/// Aggregates zero or more [ValidationFailure]s produced when validating a
/// single game object (item, quest, hero stats, …).
///
/// Usage:
/// ```dart
/// final result = ValidationResult([
///   if (item.name.isEmpty)
///     const ValidationFailure(message: 'Name is required', field: 'name'),
///   if (item.value < 0)
///     const ValidationFailure(message: 'Value cannot be negative', field: 'value'),
/// ]);
///
/// if (result.isValid) { /* proceed */ }
/// ```
final class ValidationResult {
  const ValidationResult(this.failures);

  /// Convenience constructor for a result with no failures (always valid).
  const ValidationResult.valid() : failures = const [];

  /// All [ValidationFailure]s collected during validation.
  final List<ValidationFailure> failures;

  /// `true` when there are no failures.
  bool get isValid => failures.isEmpty;

  /// `true` when at least one failure was collected.
  bool get hasErrors => failures.isNotEmpty;

  /// Returns a new [ValidationResult] that combines the failures of this
  /// result and [other].
  ValidationResult merge(ValidationResult other) =>
      ValidationResult([...failures, ...other.failures]);

  /// Returns all user-facing messages joined by [separator].
  String formatMessages({String separator = '\n'}) =>
      failures.map((f) => f.message).join(separator);

  @override
  String toString() => isValid
      ? 'ValidationResult(valid)'
      : 'ValidationResult(${failures.length} error(s))';
}
