/// Generic, strongly-typed entity identifier.
///
/// Use this as the base for all content-reference IDs in the SDK. IDs are
/// plain strings internally so they round-trip cleanly through JSON save data.
/// Subclasses narrow the type so the compiler prevents mixing, e.g., passing
/// an [ItemId] where a [QuestId] is expected.
///
/// IDs are intentionally game-agnostic: they carry no display name, no asset
/// path, and no route reference.
///
/// Example:
/// ```dart
/// final sword = ItemId('iron_sword');
/// final quest = QuestId('kill_ten_rats');
/// ```
abstract class EntityId {
  /// Creates an [EntityId] with the given [value].
  ///
  /// Throws [ArgumentError] if [value] is empty.
  EntityId(this.value) {
    if (value.isEmpty) {
      throw ArgumentError.value(value, 'value', 'EntityId must not be empty');
    }
  }

  /// The raw string value used in save data and content files.
  final String value;

  /// Serializes this ID to a plain JSON string.
  ///
  /// Use the typed `fromJson` factory on concrete subclasses to deserialize.
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityId &&
          runtimeType == other.runtimeType &&
          value == other.value);

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => '$runtimeType($value)';
}
