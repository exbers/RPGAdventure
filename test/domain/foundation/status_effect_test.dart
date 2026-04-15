import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/domain/foundation/foundation.dart';

void main() {
  group('Modifier', () {
    test('equality based on kind and value', () {
      const a = Modifier(kind: ModifierKind.additive, value: -3.0);
      const b = Modifier(kind: ModifierKind.additive, value: -3.0);
      const c = Modifier(kind: ModifierKind.multiplicative, value: 1.5);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toJson / fromJson round-trip', () {
      const original = Modifier(kind: ModifierKind.override, value: 0.0);
      final json = original.toJson();
      final restored = Modifier.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson rejects unknown kind', () {
      expect(
        () => Modifier.fromJson({'kind': 'unknown', 'value': 1.0}),
        throwsArgumentError,
      );
    });
  });

  group('DurationPolicy', () {
    test('permanent serializes and deserializes', () {
      const p = DurationPolicy.permanent();
      final json = p.toJson();
      expect(json['type'], equals('permanent'));
      final restored = DurationPolicy.fromJson(json);
      expect(restored, isA<DurationPolicy>());
    });

    test('timed serializes with duration', () {
      final p = DurationPolicy.timed(GameDuration(seconds: 30));
      final json = p.toJson();
      expect(json['type'], equals('timed'));
      final restored = DurationPolicy.fromJson(json);
      expect(restored, equals(p));
    });

    test('nTurns serializes turns count', () {
      const p = DurationPolicy.nTurns(5);
      final json = p.toJson();
      expect(json['turns'], equals(5));
      final restored = DurationPolicy.fromJson(json);
      expect(restored, equals(p));
    });

    test('untilCondition serializes conditionId', () {
      const p = DurationPolicy.untilCondition('hp_full');
      final json = p.toJson();
      expect(json['conditionId'], equals('hp_full'));
      final restored = DurationPolicy.fromJson(json);
      expect(restored, equals(p));
    });

    test('fromJson rejects unknown type', () {
      expect(
        () => DurationPolicy.fromJson({'type': 'bogus'}),
        throwsArgumentError,
      );
    });
  });

  group('StackingPolicy', () {
    test('independent serializes and deserializes', () {
      const p = StackingPolicy.independent();
      final restored = StackingPolicy.fromJson(p.toJson());
      expect(restored, isA<StackingPolicy>());
      expect(restored.toJson()['type'], equals('independent'));
    });

    test('refresh round-trips', () {
      const p = StackingPolicy.refresh();
      final restored = StackingPolicy.fromJson(p.toJson());
      expect(restored.toJson()['type'], equals('refresh'));
    });

    test('stackMagnitude preserves maxStacks', () {
      const p = StackingPolicy.stackMagnitude(5);
      final json = p.toJson();
      expect(json['maxStacks'], equals(5));
      final restored = StackingPolicy.fromJson(json);
      expect(restored, equals(p));
    });

    test('highestOnly round-trips', () {
      const p = StackingPolicy.highestOnly();
      final restored = StackingPolicy.fromJson(p.toJson());
      expect(restored.toJson()['type'], equals('highestOnly'));
    });

    test('fromJson rejects unknown type', () {
      expect(
        () => StackingPolicy.fromJson({'type': 'invalid'}),
        throwsArgumentError,
      );
    });
  });

  group('StatusEffect', () {
    StatusEffect buildEffect({
      EffectTarget target = EffectTarget.hero,
      ModifierKind kind = ModifierKind.additive,
      double value = -5.0,
      DurationPolicy? duration,
      StackingPolicy? stacking,
    }) {
      return StatusEffect(
        id: SkillId('poison'),
        target: target,
        modifier: Modifier(kind: kind, value: value),
        durationPolicy:
            duration ?? DurationPolicy.timed(GameDuration(seconds: 30)),
        stackingPolicy: stacking ?? const StackingPolicy.independent(),
      );
    }

    test('equality when all fields match', () {
      final a = buildEffect();
      final b = buildEffect();
      expect(a, equals(b));
    });

    test('inequality when target differs', () {
      final a = buildEffect(target: EffectTarget.hero);
      final b = buildEffect(target: EffectTarget.enemy);
      expect(a, isNot(equals(b)));
    });

    test('toJson includes all required keys', () {
      final effect = buildEffect();
      final json = effect.toJson();
      expect(json.containsKey('id'), isTrue);
      expect(json.containsKey('target'), isTrue);
      expect(json.containsKey('modifier'), isTrue);
      expect(json.containsKey('durationPolicy'), isTrue);
      expect(json.containsKey('stackingPolicy'), isTrue);
    });

    test('effect for all EffectTarget variants is constructable', () {
      for (final target in EffectTarget.values) {
        final effect = buildEffect(target: target);
        expect(effect.target, equals(target));
      }
    });
  });

  group('EffectTarget', () {
    test('all expected variants present', () {
      final names = EffectTarget.values.map((e) => e.name).toSet();
      expect(names, containsAll({'hero', 'enemy', 'item', 'pet', 'buff'}));
    });
  });
}
