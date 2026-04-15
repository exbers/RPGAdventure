/// Severity level of a [ValidationIssue].
enum IssueSeverity {
  /// A hard error that makes the content entry unusable.
  error,

  /// A warning that the content entry may behave unexpectedly.
  warning,
}

/// A single problem found during content validation.
///
/// Every issue carries a [path] that locates the problematic entry
/// inside the content document (e.g. `"monsters[3].loot[2].chance"`).
final class ValidationIssue {
  const ValidationIssue({
    required this.severity,
    required this.path,
    required this.message,
    this.detail,
  });

  /// How serious this issue is.
  final IssueSeverity severity;

  /// Dot/bracket notation path to the content entry that has the problem
  /// (e.g. `"monsters[3].loot[2].chance"`).
  final String path;

  /// Short, human-readable description of the problem.
  final String message;

  /// Optional additional context for diagnostic logging only.
  final String? detail;

  @override
  String toString() {
    final tag = severity.name.toUpperCase();
    final suffix = detail != null ? ' ($detail)' : '';
    return '[$tag] $path: $message$suffix';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ValidationIssue &&
          severity == other.severity &&
          path == other.path &&
          message == other.message &&
          detail == other.detail);

  @override
  int get hashCode => Object.hash(severity, path, message, detail);
}
