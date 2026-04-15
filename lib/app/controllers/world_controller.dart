import 'package:flutter/foundation.dart';

import '../../domain/repositories/world_repository.dart';

/// Manages world/town navigation state and delegates data access to
/// [WorldRepository].
///
/// Location unlocking rules, town availability logic, and zone generation
/// belong in domain use cases, not here.
class WorldController extends ChangeNotifier {
  WorldController({required WorldRepository worldRepository})
    : _worldRepository = worldRepository;

  // ignore: unused_field
  final WorldRepository _worldRepository;

  /// Whether world data is being loaded.
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Intent handlers — to be expanded when WorldModel/TownModel are introduced.
  // ---------------------------------------------------------------------------

  /// Loads the world map data (towns, zones, and travel routes).
  Future<void> loadWorld() async {
    _isLoading = true;
    notifyListeners();

    // TODO(world): call repository when WorldModel is ready.
    await Future<void>.delayed(Duration.zero);

    _isLoading = false;
    notifyListeners();
  }
}
