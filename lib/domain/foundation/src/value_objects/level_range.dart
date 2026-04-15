/// An inclusive range of integer levels used for zone difficulty, loot scaling,
/// quest prerequisites, and spawn conditions.
///
/// Both [min] and [max] are inclusive. [min] must be >= 1 and <= [max].
final class LevelRange {
  const LevelRange({required this.min, required this.max})
    : assert(min >= 1, 'min must be at least 1'),
      assert(max >= min, 'max must be >= min');

  /// A range that covers a single level.
  const LevelRange.single(int level) : this(min: level, max: level);

  /// The lowest level in this range (inclusive).
  final int min;

  /// The highest level in this range (inclusive).
  final int max;

  /// Returns `true` when [level] falls within [min]..[max].
  bool contains(int level) => level >= min && level <= max;

  /// Returns `true` when this range and [other] share at least one level.
  bool overlaps(LevelRange other) => min <= other.max && max >= other.min;

  /// Deserializes a [LevelRange] from a JSON map produced by [toJson].
  ///
  /// Expected format: `{ "min": 5, "max": 10 }`.
  factory LevelRange.fromJson(Map<String, Object?> json) {
    final min = json['min'];
    final max = json['max'];
    if (min is! int) {
      throw ArgumentError.value(min, 'json[min]', 'Expected an integer');
    }
    if (max is! int) {
      throw ArgumentError.value(max, 'json[max]', 'Expected an integer');
    }
    return LevelRange(min: min, max: max);
  }

  /// Serializes this [LevelRange] to a JSON-compatible map.
  Map<String, Object> toJson() => {'min': min, 'max': max};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelRange && min == other.min && max == other.max);

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'LevelRange($min..$max)';
}
