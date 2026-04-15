import 'package:flutter/material.dart';

import '../features/combat/presentation/combat_screen.dart';
import '../features/crafting/presentation/crafting_screen.dart';
import '../features/dungeon/presentation/dungeon_screen.dart';
import '../features/event_log/presentation/event_log_screen.dart';
import '../features/hero_creation/presentation/hero_creation_screen.dart';
import '../features/hero_sheet/presentation/hero_sheet_screen.dart';
import '../features/inventory/presentation/inventory_screen.dart';
import '../features/main_menu/presentation/main_menu_screen.dart';
import '../features/pets/presentation/pets_screen.dart';
import '../features/quests/presentation/quests_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stash/presentation/stash_screen.dart';
import '../features/town/presentation/town_screen.dart';
import '../features/world_map/presentation/world_map_screen.dart';
import '../features/zone/presentation/zone_screen.dart';
import 'app_routes.dart';
import 'app_state.dart';
import 'app_state_scope.dart';
import 'game_theme.dart';

/// Root widget of the application.
///
/// Owns the [AppState] lifecycle: creates the composition root in [initState]
/// and disposes it in [dispose]. Wraps the whole widget tree with
/// [AppStateScope] so every screen can access controllers without passing them
/// manually through constructors.
class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      appState: _appState,
      child: MaterialApp(
        title: 'RPG Adventure',
        debugShowCheckedModeBanner: false,
        theme: GameTheme.light,
        darkTheme: GameTheme.dark,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.mainMenu,
        routes: {
          AppRoutes.mainMenu: (_) => const MainMenuScreen(),
          AppRoutes.heroCreation: (_) => const HeroCreationScreen(),
          AppRoutes.worldMap: (_) => const WorldMapScreen(),
          AppRoutes.town: (_) => const TownScreen(),
          AppRoutes.zone: (_) => const ZoneScreen(),
          AppRoutes.combat: (_) => const CombatScreen(),
          AppRoutes.heroSheet: (_) => const HeroSheetScreen(),
          AppRoutes.inventory: (_) => const InventoryScreen(),
          AppRoutes.stash: (_) => const StashScreen(),
          AppRoutes.crafting: (_) => const CraftingScreen(),
          AppRoutes.quests: (_) => const QuestsScreen(),
          AppRoutes.pets: (_) => const PetsScreen(),
          AppRoutes.dungeon: (_) => const DungeonScreen(),
          AppRoutes.settings: (_) => const SettingsScreen(),
          AppRoutes.eventLog: (_) => const EventLogScreen(),
        },
      ),
    );
  }
}
