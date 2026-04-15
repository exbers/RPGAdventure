import 'validation_context.dart';
import 'validation_report.dart';

/// Contract for a single validation step inside the content validation pipeline.
///
/// Implement this to add new content checks. Each validator receives a shared
/// [ValidationContext] that carries the path stack and the issue accumulator.
///
/// ```dart
/// class MyValidator extends ContentValidator<MyContentModel> {
///   @override
///   void validate(MyContentModel content, ValidationContext context) {
///     if (content.value < 0) {
///       context.addError('value must not be negative');
///     }
///   }
/// }
/// ```
///
/// Validators should be stateless — all mutable state lives in [ValidationContext].
abstract class ContentValidator<T> {
  const ContentValidator();

  /// Validates [content] and records any issues in [context].
  ///
  /// Do not throw; record problems via [ValidationContext.addError] or
  /// [ValidationContext.addWarning] instead so the pipeline continues past
  /// the first problem.
  void validate(T content, ValidationContext context);

  /// Convenience method: run this validator alone and get a [ValidationReport].
  ///
  /// Useful for unit-testing a single validator in isolation.
  ValidationReport run(T content, {String root = ''}) {
    final context = ValidationContext(root: root);
    validate(content, context);
    return ValidationReport(List.unmodifiable(context.issues));
  }
}
