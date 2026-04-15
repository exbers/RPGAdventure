/// Centralized route name constants for the whole application.
///
/// Use these constants with [Navigator.pushNamed] and [MaterialApp.routes]
/// instead of inline strings so that typos are caught at compile time.
abstract final class AppRoutes {
  AppRoutes._();

  /// Main menu – the initial screen of the application.
  static const String mainMenu = '/';

  /// Hero creation – first step of starting a new game.
  static const String heroCreation = '/hero-creation';

  /// World map – top-level view of all reachable locations.
  static const String worldMap = '/world-map';

  /// Town – a specific town hub for trading, quests, and services.
  static const String town = '/town';

  /// Zone – an outdoor exploration zone outside towns.
  static const String zone = '/zone';

  /// Combat – turn-based battle screen.
  static const String combat = '/combat';

  /// Hero sheet – stats, skills, and progression overview.
  static const String heroSheet = '/hero-sheet';

  /// Inventory – items carried by the hero.
  static const String inventory = '/inventory';

  /// Stash – long-term item storage.
  static const String stash = '/stash';

  /// Crafting – combine materials into new items.
  static const String crafting = '/crafting';

  /// Quests – active and completed quest log.
  static const String quests = '/quests';

  /// Pets – companion management screen.
  static const String pets = '/pets';

  /// Dungeon – procedural dungeon exploration.
  static const String dungeon = '/dungeon';

  /// Settings – audio, language, and display preferences.
  static const String settings = '/settings';

  /// Event log – chronological journal of game events.
  static const String eventLog = '/event-log';
}
