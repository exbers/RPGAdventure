import 'validation_issue.dart';

/// Structured result of running the content validation pipeline.
///
/// A report is *valid* when it contains no [IssueSeverity.error] issues.
/// Warnings are allowed in a valid report.
///
/// Use [toLog] to produce a multi-line diagnostic dump suitable for
/// `dart:developer` logging or `debugPrint`.
final class ValidationReport {
  const ValidationReport(this.issues);

  /// Constructs an empty (valid) report.
  const ValidationReport.empty() : issues = const [];

  /// All issues collected during validation. May be empty.
  final List<ValidationIssue> issues;

  /// `true` when no [IssueSeverity.error] issues were recorded.
  bool get isValid => issues.every((i) => i.severity != IssueSeverity.error);

  /// All issues with [IssueSeverity.error] severity.
  List<ValidationIssue> get errors =>
      issues.where((i) => i.severity == IssueSeverity.error).toList();

  /// All issues with [IssueSeverity.warning] severity.
  List<ValidationIssue> get warnings =>
      issues.where((i) => i.severity == IssueSeverity.warning).toList();

  /// Merges this report with [other], returning a new combined report.
  ValidationReport merge(ValidationReport other) =>
      ValidationReport(List.unmodifiable([...issues, ...other.issues]));

  /// Returns a multi-line string suitable for debug logging.
  ///
  /// Includes a header, error count, warning count, and one line per issue.
  String toLog() {
    if (issues.isEmpty) return 'ValidationReport: valid (no issues)';
    final errorCount = errors.length;
    final warnCount = warnings.length;
    final lines = <String>[
      'ValidationReport: $errorCount error(s), $warnCount warning(s)',
    ];
    for (final issue in issues) {
      lines.add('  $issue');
    }
    return lines.join('\n');
  }

  @override
  String toString() => toLog();
}
