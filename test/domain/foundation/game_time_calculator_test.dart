import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/domain/foundation/foundation.dart';

void main() {
  group('GameTimeCalculator', () {
    FakeClock clock(int seconds) =>
        FakeClock(initial: GameDuration(seconds: seconds));

    test('now returns current clock time', () {
      final calc = GameTimeCalculator(clock: clock(500));
      expect(calc.now, equals(GameDuration(seconds: 500)));
    });

    test('offlineTime returns elapsed since lastSavedAt', () {
      final c = clock(1000);
      final calc = GameTimeCalculator(clock: c);
      final offline = calc.offlineTime(lastSavedAt: GameDuration(seconds: 700));
      expect(offline, equals(GameDuration(seconds: 300)));
    });

    test('offlineTime returns zero when saved in the future', () {
      final c = clock(100);
      final calc = GameTimeCalculator(clock: c);
      final offline = calc.offlineTime(lastSavedAt: GameDuration(seconds: 500));
      expect(offline, equals(GameDuration.zero));
    });

    test('splitIntoTurns divides evenly', () {
      final calc = GameTimeCalculator(clock: clock(0));
      final result = calc.splitIntoTurns(
        totalTime: GameDuration(seconds: 60),
        turnDuration: GameDuration(seconds: 20),
      );
      expect(result.turns, equals(3));
      expect(result.remainder, equals(GameDuration.zero));
    });

    test('splitIntoTurns calculates remainder', () {
      final calc = GameTimeCalculator(clock: clock(0));
      final result = calc.splitIntoTurns(
        totalTime: GameDuration(seconds: 70),
        turnDuration: GameDuration(seconds: 30),
      );
      expect(result.turns, equals(2));
      expect(result.remainder, equals(GameDuration(seconds: 10)));
    });

    test('splitIntoTurns with zero total returns zero turns', () {
      final calc = GameTimeCalculator(clock: clock(0));
      final result = calc.splitIntoTurns(
        totalTime: GameDuration.zero,
        turnDuration: GameDuration(seconds: 10),
      );
      expect(result.turns, equals(0));
      expect(result.remainder, equals(GameDuration.zero));
    });

    test('splitIntoTurns throws on zero turnDuration', () {
      final calc = GameTimeCalculator(clock: clock(0));
      expect(
        () => calc.splitIntoTurns(
          totalTime: GameDuration(seconds: 60),
          turnDuration: GameDuration.zero,
        ),
        throwsArgumentError,
      );
    });

    test('clock advances are reflected in subsequent now calls', () {
      final c = FakeClock();
      final calc = GameTimeCalculator(clock: c);
      c.advance(GameDuration(seconds: 50));
      expect(calc.now, equals(GameDuration(seconds: 50)));
    });
  });
}
