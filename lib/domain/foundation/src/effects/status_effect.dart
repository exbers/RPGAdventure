import '../ids/entity_id.dart';
import 'duration_policy.dart';
import 'effect_target.dart';
import 'modifier.dart';
import 'stacking_policy.dart';

/// An immutable descriptor for a status effect that can be applied to any
/// game entity.
///
/// [StatusEffect] describes *what* an effect does (modifier, target, stacking,
/// duration) but does not hold runtime state such as remaining duration or
/// current stack count. Runtime state belongs to an effect instance managed by
/// [TimerService] or the game engine.
///
/// The [id] uses [EntityId] so the same ID infrastructure used for items,
/// quests, and skills identifies effects consistently in save data and logs.
///
/// Example:
/// ```dart
/// final poison = StatusEffect(
///   id: SkillId('poison'),
///   target: EffectTarget.hero,
///   modifier: Modifier(kind: ModifierKind.additive, value: -3.0),
///   durationPolicy: DurationPolicy.timed(GameDuration(seconds: 30)),
///   stackingPolicy: StackingPolicy.independent(),
/// );
/// ```
final class StatusEffect {
  /// Creates an immutable [StatusEffect].
  const StatusEffect({
    required this.id,
    required this.target,
    required this.modifier,
    required this.durationPolicy,
    required this.stackingPolicy,
  });

  /// Stable identifier for this effect definition.
  ///
  /// Use [SkillId] for skill-derived effects or another [EntityId] subtype
  /// for item-sourced or pet-sourced effects.
  final EntityId id;

  /// Which entity category this effect is applied to.
  final EffectTarget target;

  /// How the effect modifies a numeric stat.
  final Modifier modifier;

  /// When (or if) the effect expires.
  final DurationPolicy durationPolicy;

  /// How duplicate applications of this effect are resolved.
  final StackingPolicy stackingPolicy;

  /// Serializes to a JSON-compatible map.
  Map<String, Object?> toJson() => {
    'id': id.toJson(),
    'target': target.name,
    'modifier': modifier.toJson(),
    'durationPolicy': durationPolicy.toJson(),
    'stackingPolicy': stackingPolicy.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatusEffect &&
          id == other.id &&
          target == other.target &&
          modifier == other.modifier &&
          durationPolicy == other.durationPolicy &&
          stackingPolicy == other.stackingPolicy);

  @override
  int get hashCode =>
      Object.hash(id, target, modifier, durationPolicy, stackingPolicy);

  @override
  String toString() =>
      'StatusEffect(id: $id, target: $target, modifier: $modifier, '
      'durationPolicy: $durationPolicy, stackingPolicy: $stackingPolicy)';
}
