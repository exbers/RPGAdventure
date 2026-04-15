import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/domain/foundation/foundation.dart';

void main() {
  group('TimerService — deterministic tick', () {
    late TimerService service;

    setUp(() {
      service = TimerService();
    });

    test('count starts at zero', () {
      expect(service.count, equals(0));
    });

    test('register adds an entry', () {
      service.register(
        TimerEntry(
          id: 'a',
          remaining: GameDuration(seconds: 10),
          onExpired: (_) {},
        ),
      );
      expect(service.count, equals(1));
      expect(service.isRegistered('a'), isTrue);
    });

    test('register with zero remaining fires callback immediately', () {
      var fired = false;
      service.register(
        TimerEntry(
          id: 'instant',
          remaining: GameDuration.zero,
          onExpired: (_) => fired = true,
        ),
      );
      expect(fired, isTrue);
      expect(service.count, equals(0));
    });

    test('tick does not expire timers before their time', () {
      service.register(
        TimerEntry(
          id: 'slow',
          remaining: GameDuration(seconds: 20),
          onExpired: (_) => fail('Should not expire yet'),
        ),
      );
      service.tick(GameDuration(seconds: 5));
      expect(service.count, equals(1));
    });

    test('tick decrements remaining time', () {
      service.register(
        TimerEntry(
          id: 'decrement',
          remaining: GameDuration(seconds: 20),
          onExpired: (_) {},
        ),
      );
      service.tick(GameDuration(seconds: 7));
      final entry = service.entries.first;
      expect(entry.remaining, equals(GameDuration(seconds: 13)));
    });

    test('tick fires callback exactly at expiry and removes entry', () {
      var firedCount = 0;
      service.register(
        TimerEntry(
          id: 'exact',
          remaining: GameDuration(seconds: 10),
          onExpired: (_) => firedCount++,
        ),
      );
      service.tick(GameDuration(seconds: 10));
      expect(firedCount, equals(1));
      expect(service.count, equals(0));
    });

    test('tick fires callback when delta exceeds remaining', () {
      var firedCount = 0;
      service.register(
        TimerEntry(
          id: 'over',
          remaining: GameDuration(seconds: 5),
          onExpired: (_) => firedCount++,
        ),
      );
      service.tick(GameDuration(seconds: 100));
      expect(firedCount, equals(1));
      expect(service.count, equals(0));
    });

    test('tick fires correct id in callback', () {
      String? expiredId;
      service.register(
        TimerEntry(
          id: 'myTimer',
          remaining: GameDuration(seconds: 3),
          onExpired: (id) => expiredId = id,
        ),
      );
      service.tick(GameDuration(seconds: 3));
      expect(expiredId, equals('myTimer'));
    });

    test('multiple timers — only expired ones are removed', () {
      service.register(
        TimerEntry(
          id: 'short',
          remaining: GameDuration(seconds: 5),
          onExpired: (_) {},
        ),
      );
      service.register(
        TimerEntry(
          id: 'long',
          remaining: GameDuration(seconds: 20),
          onExpired: (_) => fail('Should not fire'),
        ),
      );
      service.tick(GameDuration(seconds: 5));
      expect(service.count, equals(1));
      expect(service.isRegistered('long'), isTrue);
    });

    test('cancel removes timer without firing callback', () {
      var fired = false;
      service.register(
        TimerEntry(
          id: 'cancel_me',
          remaining: GameDuration(seconds: 10),
          onExpired: (_) => fired = true,
        ),
      );
      service.cancel('cancel_me');
      service.tick(GameDuration(seconds: 10));
      expect(fired, isFalse);
      expect(service.count, equals(0));
    });

    test('registering duplicate id replaces existing', () {
      var firstFired = false;
      service.register(
        TimerEntry(
          id: 'dup',
          remaining: GameDuration(seconds: 10),
          onExpired: (_) => firstFired = true,
        ),
      );
      service.register(
        TimerEntry(
          id: 'dup',
          remaining: GameDuration(seconds: 50),
          onExpired: (_) {},
        ),
      );
      service.tick(GameDuration(seconds: 10));
      // first should not have fired — it was replaced
      expect(firstFired, isFalse);
      expect(service.count, equals(1));
    });

    test('zero delta tick is a no-op', () {
      service.register(
        TimerEntry(
          id: 'nodelta',
          remaining: GameDuration(seconds: 5),
          onExpired: (_) => fail('Should not expire'),
        ),
      );
      service.tick(GameDuration.zero);
      expect(service.count, equals(1));
    });

    test('entries snapshot is unmodifiable', () {
      service.register(
        TimerEntry(
          id: 'snap',
          remaining: GameDuration(seconds: 10),
          onExpired: (_) {},
        ),
      );
      final snapshot = service.entries;
      expect(
        () => (snapshot as dynamic).add(snapshot.first),
        throwsUnsupportedError,
      );
    });
  });

  group('TimerService — duration expiry chain', () {
    test('three sequential ticks expire timer at correct step', () {
      final service = TimerService();
      var fired = false;
      service.register(
        TimerEntry(
          id: 'seq',
          remaining: GameDuration(seconds: 9),
          onExpired: (_) => fired = true,
        ),
      );
      service.tick(GameDuration(seconds: 3)); // 6 remaining
      expect(fired, isFalse);
      service.tick(GameDuration(seconds: 3)); // 3 remaining
      expect(fired, isFalse);
      service.tick(GameDuration(seconds: 3)); // 0 → fires
      expect(fired, isTrue);
    });
  });
}
