import '../../../../core/errors/game_failure.dart' show ValidationFailure;
import 'content_validator.dart';
import 'validation_context.dart';
import 'validation_report.dart';

/// Composes multiple [ContentValidator]s into a single pass.
///
/// Each validator in the pipeline receives the same [ValidationContext]. All
/// validators run regardless of earlier failures so the caller receives a
/// complete picture of all problems in one pass.
///
/// ### Typed pipeline
///
/// All validators in one pipeline must accept the same content type [T]. For
/// heterogeneous content, create a pipeline per content kind and merge their
/// reports with [ValidationReport.merge].
///
/// ```dart
/// final pipeline = ValidationPipeline<List<Map<String, Object?>>>([
///   SchemaValidator().adapt(schemaInput),
///   RangeValidator().adapt(rangeInput),
/// ]);
/// final report = pipeline.run(entries);
/// if (!report.isValid) {
///   debugPrint(report.toLog());
/// }
/// ```
///
/// ### Integration with FND-005 [ValidationFailure]
///
/// Use [toValidationFailure] to convert a failed report into a [ValidationFailure]
/// that can be returned from domain methods or surfaced in the error model:
///
/// ```dart
/// if (!report.isValid) {
///   return Result.failure(report.toValidationFailure('Monster content invalid'));
/// }
/// ```
final class ValidationPipeline<T> {
  /// Creates a pipeline from an ordered list of [validators].
  const ValidationPipeline(this.validators);

  /// The ordered validators to run.
  final List<ContentValidator<T>> validators;

  /// Runs all validators against [content] and returns a [ValidationReport].
  ///
  /// Errors from earlier validators do not stop later validators. The returned
  /// report contains the union of all issues.
  ValidationReport run(T content, {String root = ''}) {
    final context = ValidationContext(root: root);
    for (final validator in validators) {
      validator.validate(content, context);
    }
    return ValidationReport(List.unmodifiable(context.issues));
  }
}

/// Extension that converts a [ValidationReport] to a [ValidationFailure].
extension ValidationReportFailureExtension on ValidationReport {
  /// Returns a [ValidationFailure] whose [detail] contains the full [toLog]
  /// output.
  ///
  /// Useful when a domain method must surface content errors through the
  /// [GameFailure] hierarchy.
  ValidationFailure toValidationFailure(String message) =>
      ValidationFailure(message: message, detail: toLog());
}
