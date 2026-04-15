import '../data/repositories/in_memory_hero_repository.dart';
import '../data/repositories/in_memory_inventory_repository.dart';
import '../data/repositories/in_memory_pets_repository.dart';
import '../data/repositories/in_memory_quests_repository.dart';
import '../data/repositories/in_memory_world_repository.dart';
import '../data/services/noop_combat_service.dart';
import '../domain/repositories/hero_repository.dart';
import '../domain/repositories/inventory_repository.dart';
import '../domain/repositories/pets_repository.dart';
import '../domain/repositories/quests_repository.dart';
import '../domain/repositories/world_repository.dart';
import '../domain/services/combat_service.dart';
import 'controllers/combat_controller.dart';
import 'controllers/hero_controller.dart';
import 'controllers/inventory_controller.dart';
import 'controllers/pets_controller.dart';
import 'controllers/quests_controller.dart';
import 'controllers/world_controller.dart';

/// Application-level state composition root.
///
/// Creates and owns all [ChangeNotifier]-based controllers. Each controller
/// receives its dependencies (repositories, services) via constructor injection
/// so that both this class and tests can supply any implementation — including
/// fakes and stubs — without touching business logic.
///
/// Wire this into the widget tree through [AppStateScope] so that screens can
/// read the controllers they need via [AppStateScope.of].
class AppState {
  AppState({
    HeroRepository? heroRepository,
    InventoryRepository? inventoryRepository,
    QuestsRepository? questsRepository,
    PetsRepository? petsRepository,
    WorldRepository? worldRepository,
    CombatService? combatService,
  }) : hero = HeroController(
         heroRepository: heroRepository ?? InMemoryHeroRepository(),
       ),
       inventory = InventoryController(
         inventoryRepository:
             inventoryRepository ?? InMemoryInventoryRepository(),
       ),
       quests = QuestsController(
         questsRepository: questsRepository ?? InMemoryQuestsRepository(),
       ),
       pets = PetsController(
         petsRepository: petsRepository ?? InMemoryPetsRepository(),
       ),
       world = WorldController(
         worldRepository: worldRepository ?? InMemoryWorldRepository(),
       ),
       combat = CombatController(
         combatService: combatService ?? NoopCombatService(),
       );

  final HeroController hero;
  final CombatController combat;
  final InventoryController inventory;
  final QuestsController quests;
  final PetsController pets;
  final WorldController world;

  /// Releases all controller resources.
  ///
  /// Call this when the application is being torn down or in widget tests
  /// during teardown.
  void dispose() {
    hero.dispose();
    combat.dispose();
    inventory.dispose();
    quests.dispose();
    pets.dispose();
    world.dispose();
  }
}
