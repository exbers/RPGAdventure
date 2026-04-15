import 'validation_issue.dart';

/// Mutable accumulator passed through the validation pipeline.
///
/// [ValidationContext] tracks:
/// - The current *path stack* so each validator can record a precise location
///   for every issue (e.g. `"monsters[2].loot[0].chance"`).
/// - All [ValidationIssue]s collected so far.
///
/// ### Path stack usage
///
/// ```dart
/// context.pushSegment('monsters[2]');
/// context.pushSegment('loot[0]');
/// context.addError('chance must be between 0 and 1');
/// context.popSegment(); // loot[0]
/// context.popSegment(); // monsters[2]
/// ```
///
/// The path `"monsters[2].loot[0]"` is computed automatically.
///
/// Alternatively use [scoped] for automatic push/pop:
///
/// ```dart
/// context.scoped('monsters[2]', () {
///   context.scoped('loot[0]', () {
///     context.addError('chance must be between 0 and 1');
///   });
/// });
/// ```
final class ValidationContext {
  ValidationContext({String root = ''}) {
    if (root.isNotEmpty) _stack.add(root);
  }

  final List<String> _stack = [];
  final List<ValidationIssue> _issues = [];

  /// Current dot/bracket path formed by joining the path stack.
  String get currentPath {
    if (_stack.isEmpty) return '';
    return _stack.join('.');
  }

  /// All issues accumulated so far (unmodifiable view).
  List<ValidationIssue> get issues => List.unmodifiable(_issues);

  // ---------------------------------------------------------------------------
  // Path management
  // ---------------------------------------------------------------------------

  /// Pushes [segment] onto the path stack.
  void pushSegment(String segment) => _stack.add(segment);

  /// Removes the last path segment.
  ///
  /// Does nothing if the stack is empty to prevent underflow errors.
  void popSegment() {
    if (_stack.isNotEmpty) _stack.removeLast();
  }

  /// Runs [fn] with [segment] pushed, then pops it — even if [fn] throws.
  void scoped(String segment, void Function() fn) {
    pushSegment(segment);
    try {
      fn();
    } finally {
      popSegment();
    }
  }

  // ---------------------------------------------------------------------------
  // Issue recording
  // ---------------------------------------------------------------------------

  /// Records an [IssueSeverity.error] at the current path.
  void addError(String message, {String? detail, String? pathOverride}) {
    _issues.add(
      ValidationIssue(
        severity: IssueSeverity.error,
        path: pathOverride ?? currentPath,
        message: message,
        detail: detail,
      ),
    );
  }

  /// Records an [IssueSeverity.warning] at the current path.
  void addWarning(String message, {String? detail, String? pathOverride}) {
    _issues.add(
      ValidationIssue(
        severity: IssueSeverity.warning,
        path: pathOverride ?? currentPath,
        message: message,
        detail: detail,
      ),
    );
  }
}
