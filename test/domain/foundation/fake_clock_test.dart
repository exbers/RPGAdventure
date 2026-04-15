import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/domain/foundation/foundation.dart';

void main() {
  group('FakeClock', () {
    test('starts at zero by default', () {
      final clock = FakeClock();
      expect(clock.currentTime, equals(GameDuration.zero));
    });

    test('starts at provided initial time', () {
      final clock = FakeClock(initial: GameDuration(seconds: 100));
      expect(clock.currentTime, equals(GameDuration(seconds: 100)));
    });

    test('advance increases currentTime', () {
      final clock = FakeClock();
      clock.advance(GameDuration(seconds: 30));
      expect(clock.currentTime, equals(GameDuration(seconds: 30)));
    });

    test('multiple advances accumulate', () {
      final clock = FakeClock();
      clock.advance(GameDuration(seconds: 10));
      clock.advance(GameDuration(seconds: 20));
      clock.advance(GameDuration(seconds: 5));
      expect(clock.currentTime, equals(GameDuration(seconds: 35)));
    });

    test('set replaces currentTime', () {
      final clock = FakeClock(initial: GameDuration(seconds: 100));
      clock.set(GameDuration(seconds: 42));
      expect(clock.currentTime, equals(GameDuration(seconds: 42)));
    });

    test('elapsedSince returns difference', () {
      final clock = FakeClock(initial: GameDuration(seconds: 50));
      final elapsed = clock.elapsedSince(GameDuration(seconds: 30));
      expect(elapsed, equals(GameDuration(seconds: 20)));
    });

    test('elapsedSince returns zero when since is in the future', () {
      final clock = FakeClock(initial: GameDuration(seconds: 10));
      final elapsed = clock.elapsedSince(GameDuration(seconds: 50));
      expect(elapsed, equals(GameDuration.zero));
    });
  });
}
