import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app/controllers/combat_controller.dart';
import 'package:flutter_application_1/domain/services/combat_service.dart';

// ---------------------------------------------------------------------------
// Fake service — no I/O, no BuildContext required.
// ---------------------------------------------------------------------------

class _FakeCombatService implements CombatService {}

void main() {
  group('CombatController', () {
    test('initial isInCombat is false', () {
      final controller = CombatController(combatService: _FakeCombatService());
      expect(controller.isInCombat, isFalse);
      controller.dispose();
    });

    test('startCombat sets isInCombat to true and notifies listeners', () {
      final controller = CombatController(combatService: _FakeCombatService());

      var notified = false;
      controller.addListener(() => notified = true);

      controller.startCombat();

      expect(controller.isInCombat, isTrue);
      expect(notified, isTrue);

      controller.dispose();
    });

    test('endCombat sets isInCombat to false and notifies listeners', () {
      final controller = CombatController(combatService: _FakeCombatService());

      controller.startCombat();

      var notified = false;
      controller.addListener(() => notified = true);

      controller.endCombat();

      expect(controller.isInCombat, isFalse);
      expect(notified, isTrue);

      controller.dispose();
    });

    test('can be instantiated and disposed without a widget tree', () {
      final controller = CombatController(combatService: _FakeCombatService());
      expect(controller, isNotNull);
      controller.dispose();
    });
  });
}
