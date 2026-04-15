/// Describes how a numeric stat is modified by a [StatusEffect].
///
/// The three variants cover the most common RPG modifier patterns:
///
/// - [ModifierKind.additive] — flat bonus or penalty added to the stat.
/// - [ModifierKind.multiplicative] — percentage multiplier (e.g. 1.25 = +25%).
/// - [ModifierKind.override] — replace the stat outright (e.g. pin speed to 0).
///
/// Resolution order (when multiple modifiers apply to the same stat) is
/// intentionally left to the caller so this contract stays engine-agnostic.
enum ModifierKind {
  /// Adds [Modifier.value] to the base stat.
  additive,

  /// Multiplies the base stat by [Modifier.value].
  multiplicative,

  /// Replaces the stat with [Modifier.value], ignoring all other modifiers.
  override,
}

/// An immutable numeric modifier that can be applied to any game stat.
///
/// Example:
/// ```dart
/// const poisonPenalty = Modifier(kind: ModifierKind.additive, value: -5.0);
/// const haste = Modifier(kind: ModifierKind.multiplicative, value: 1.5);
/// const rooted = Modifier(kind: ModifierKind.override, value: 0.0);
/// ```
final class Modifier {
  /// Creates a [Modifier] with the given [kind] and numeric [value].
  const Modifier({required this.kind, required this.value});

  /// How this modifier interacts with the base stat.
  final ModifierKind kind;

  /// The numeric operand for the modifier.
  final double value;

  /// Serializes to a JSON-compatible map.
  Map<String, Object> toJson() => {'kind': kind.name, 'value': value};

  /// Deserializes from a JSON map produced by [toJson].
  factory Modifier.fromJson(Map<String, Object?> json) {
    final kindRaw = json['kind'];
    if (kindRaw is! String) {
      throw ArgumentError.value(kindRaw, 'json[kind]', 'Expected a String');
    }
    final kind = ModifierKind.values.firstWhere(
      (k) => k.name == kindRaw,
      orElse: () => throw ArgumentError.value(
        kindRaw,
        'json[kind]',
        'Unknown ModifierKind',
      ),
    );
    final valueRaw = json['value'];
    if (valueRaw is! num) {
      throw ArgumentError.value(valueRaw, 'json[value]', 'Expected a number');
    }
    return Modifier(kind: kind, value: valueRaw.toDouble());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Modifier && kind == other.kind && value == other.value);

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'Modifier($kind, $value)';
}
