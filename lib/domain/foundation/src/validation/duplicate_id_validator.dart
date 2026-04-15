import 'content_validator.dart';
import 'validation_context.dart';

/// Checks a flat list of raw ID strings for duplicates.
///
/// Records an [IssueSeverity.error] for every ID that appears more than once,
/// using the first occurrence's index to locate it.
///
/// ```dart
/// final validator = DuplicateIdValidator(listName: 'monsters');
/// final report = validator.run(['goblin', 'orc', 'goblin']);
/// // => error at "monsters[2]": duplicate id "goblin"
/// ```
final class DuplicateIdValidator extends ContentValidator<List<String>> {
  /// Creates a [DuplicateIdValidator].
  ///
  /// [listName] is used as the top-level path segment (e.g. `"monsters"`).
  const DuplicateIdValidator({required this.listName});

  /// Label used to build the path in error messages (e.g. `"monsters"`).
  final String listName;

  @override
  void validate(List<String> ids, ValidationContext context) {
    final seen = <String, int>{}; // id -> first-seen index
    for (var i = 0; i < ids.length; i++) {
      final id = ids[i];
      if (seen.containsKey(id)) {
        context.addError(
          'duplicate id "$id"',
          pathOverride: '$listName[$i]',
          detail: 'first seen at $listName[${seen[id]}]',
        );
      } else {
        seen[id] = i;
      }
    }
  }
}
