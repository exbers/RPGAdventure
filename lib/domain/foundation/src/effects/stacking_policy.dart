/// Describes how a [StatusEffect] behaves when applied multiple times to the
/// same target.
///
/// Example:
/// ```dart
/// const bleed = StackingPolicy.independent();       // each stack ticks separately
/// const burn = StackingPolicy.refresh();            // resets the timer
/// const venom = StackingPolicy.stackMagnitude(5);  // up to 5 stacks
/// const blessing = StackingPolicy.highestOnly();   // only the strongest applies
/// ```
sealed class StackingPolicy {
  const StackingPolicy();

  /// Each application runs its own timer and magnitude independently.
  ///
  /// Suitable for DoT effects like bleeding where every hit adds a new stack.
  const factory StackingPolicy.independent() = _IndependentPolicy;

  /// A new application restarts the duration of the existing stack.
  ///
  /// The magnitude stays the same; only the countdown resets.
  const factory StackingPolicy.refresh() = _RefreshPolicy;

  /// Each new application adds magnitude up to [maxStacks].
  ///
  /// When [maxStacks] is reached, the oldest or weakest stack is replaced
  /// (resolution is left to the effect resolver).
  const factory StackingPolicy.stackMagnitude(int maxStacks) =
      _StackMagnitudePolicy;

  /// Only the application with the highest magnitude is active at any time.
  ///
  /// Suitable for blessing or armour-buff effects where duplicates are wasted.
  const factory StackingPolicy.highestOnly() = _HighestOnlyPolicy;

  /// Serializes to a JSON-compatible map.
  Map<String, Object?> toJson();

  /// Deserializes from a JSON map produced by [toJson].
  factory StackingPolicy.fromJson(Map<String, Object?> json) {
    final type = json['type'];
    return switch (type) {
      'independent' => const StackingPolicy.independent(),
      'refresh' => const StackingPolicy.refresh(),
      'stackMagnitude' => StackingPolicy.stackMagnitude(
        json['maxStacks'] as int,
      ),
      'highestOnly' => const StackingPolicy.highestOnly(),
      _ => throw ArgumentError.value(
        type,
        'json[type]',
        'Unknown StackingPolicy type',
      ),
    };
  }
}

final class _IndependentPolicy extends StackingPolicy {
  const _IndependentPolicy();

  @override
  Map<String, Object?> toJson() => {'type': 'independent'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _IndependentPolicy;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StackingPolicy.independent()';
}

final class _RefreshPolicy extends StackingPolicy {
  const _RefreshPolicy();

  @override
  Map<String, Object?> toJson() => {'type': 'refresh'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _RefreshPolicy;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StackingPolicy.refresh()';
}

final class _StackMagnitudePolicy extends StackingPolicy {
  const _StackMagnitudePolicy(this.maxStacks);

  /// Maximum number of independent magnitude stacks allowed.
  final int maxStacks;

  @override
  Map<String, Object?> toJson() => {
    'type': 'stackMagnitude',
    'maxStacks': maxStacks,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _StackMagnitudePolicy && maxStacks == other.maxStacks);

  @override
  int get hashCode => Object.hash('_StackMagnitudePolicy', maxStacks);

  @override
  String toString() => 'StackingPolicy.stackMagnitude($maxStacks)';
}

final class _HighestOnlyPolicy extends StackingPolicy {
  const _HighestOnlyPolicy();

  @override
  Map<String, Object?> toJson() => {'type': 'highestOnly'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _HighestOnlyPolicy;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'StackingPolicy.highestOnly()';
}
