import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app/controllers/hero_controller.dart';
import 'package:flutter_application_1/domain/repositories/hero_repository.dart';

// ---------------------------------------------------------------------------
// Fake repository — no I/O, no BuildContext required.
// ---------------------------------------------------------------------------

class _FakeHeroRepository implements HeroRepository {}

void main() {
  group('HeroController', () {
    test('initial isLoading is false', () {
      final controller = HeroController(heroRepository: _FakeHeroRepository());
      expect(controller.isLoading, isFalse);
      controller.dispose();
    });

    test(
      'isLoading becomes true during loadHero and false afterwards',
      () async {
        final controller = HeroController(
          heroRepository: _FakeHeroRepository(),
        );

        final states = <bool>[];
        controller.addListener(() => states.add(controller.isLoading));

        await controller.loadHero();

        // Expect at minimum: [true, false] — loading started then completed.
        expect(states, containsAllInOrder([true, false]));
        expect(controller.isLoading, isFalse);

        controller.dispose();
      },
    );

    test('can be instantiated and disposed without a widget tree', () {
      // Verifies the core acceptance criterion: domain logic is testable
      // without Flutter widgets.
      final controller = HeroController(heroRepository: _FakeHeroRepository());
      expect(controller, isNotNull);
      controller.dispose();
    });
  });
}
