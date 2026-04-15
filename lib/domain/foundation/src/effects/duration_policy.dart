import '../value_objects/game_duration.dart';

/// Specifies how long a [StatusEffect] remains active.
///
/// All variants are pure-Dart value objects with no Flutter dependency.
///
/// Example:
/// ```dart
/// const forever = DurationPolicy.permanent();
/// const brief = DurationPolicy.timed(GameDuration(seconds: 30));
/// const threeTurns = DurationPolicy.nTurns(3);
/// const untilHealed = DurationPolicy.untilCondition('hp_full');
/// ```
sealed class DurationPolicy {
  const DurationPolicy();

  /// The effect never expires on its own.
  const factory DurationPolicy.permanent() = _PermanentPolicy;

  /// The effect expires after the given [duration] of game time has elapsed.
  const factory DurationPolicy.timed(GameDuration duration) = _TimedPolicy;

  /// The effect expires after [turns] combat or game turns have passed.
  const factory DurationPolicy.nTurns(int turns) = _NTurnsPolicy;

  /// The effect expires when [conditionId] becomes true.
  ///
  /// [conditionId] is an opaque string evaluated by the game engine; the SDK
  /// does not interpret it.
  const factory DurationPolicy.untilCondition(String conditionId) =
      _UntilConditionPolicy;

  /// Serializes to a JSON-compatible map.
  Map<String, Object?> toJson();

  /// Deserializes from a JSON map produced by [toJson].
  factory DurationPolicy.fromJson(Map<String, Object?> json) {
    final type = json['type'];
    return switch (type) {
      'permanent' => const DurationPolicy.permanent(),
      'timed' => DurationPolicy.timed(
        GameDuration.fromJson(json['duration'] as Map<String, Object?>),
      ),
      'nTurns' => DurationPolicy.nTurns(json['turns'] as int),
      'untilCondition' => DurationPolicy.untilCondition(
        json['conditionId'] as String,
      ),
      _ => throw ArgumentError.value(
        type,
        'json[type]',
        'Unknown DurationPolicy type',
      ),
    };
  }
}

/// Effect that never expires unless explicitly removed.
final class _PermanentPolicy extends DurationPolicy {
  const _PermanentPolicy();

  @override
  Map<String, Object?> toJson() => {'type': 'permanent'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _PermanentPolicy;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'DurationPolicy.permanent()';
}

/// Effect that expires after a fixed amount of game time.
final class _TimedPolicy extends DurationPolicy {
  const _TimedPolicy(this.duration);

  /// How long the effect lasts in game time.
  final GameDuration duration;

  @override
  Map<String, Object?> toJson() => {
    'type': 'timed',
    'duration': duration.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _TimedPolicy && duration == other.duration);

  @override
  int get hashCode => Object.hash('_TimedPolicy', duration);

  @override
  String toString() => 'DurationPolicy.timed($duration)';
}

/// Effect that expires after a fixed number of turns.
final class _NTurnsPolicy extends DurationPolicy {
  const _NTurnsPolicy(this.turns);

  /// How many turns remain.
  final int turns;

  @override
  Map<String, Object?> toJson() => {'type': 'nTurns', 'turns': turns};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _NTurnsPolicy && turns == other.turns);

  @override
  int get hashCode => Object.hash('_NTurnsPolicy', turns);

  @override
  String toString() => 'DurationPolicy.nTurns($turns)';
}

/// Effect that expires when a named condition becomes true.
final class _UntilConditionPolicy extends DurationPolicy {
  const _UntilConditionPolicy(this.conditionId);

  /// The opaque condition identifier evaluated by the game engine.
  final String conditionId;

  @override
  Map<String, Object?> toJson() => {
    'type': 'untilCondition',
    'conditionId': conditionId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _UntilConditionPolicy && conditionId == other.conditionId);

  @override
  int get hashCode => Object.hash('_UntilConditionPolicy', conditionId);

  @override
  String toString() => 'DurationPolicy.untilCondition($conditionId)';
}
