import 'package:flutter/foundation.dart';

import '../../domain/services/combat_service.dart';

/// Manages combat encounter state and delegates turn resolution to [CombatService].
///
/// All damage formulas, status effects, and turn order logic belong in
/// [CombatService] implementations, not here.
class CombatController extends ChangeNotifier {
  CombatController({required CombatService combatService})
    : _combatService = combatService;

  // ignore: unused_field
  final CombatService _combatService;

  /// Whether a combat encounter is currently active.
  bool get isInCombat => _isInCombat;
  bool _isInCombat = false;

  // ---------------------------------------------------------------------------
  // Intent handlers
  // ---------------------------------------------------------------------------

  /// Starts a new combat encounter.
  ///
  /// Placeholder: will accept enemy data and delegate to [CombatService].
  void startCombat() {
    _isInCombat = true;
    notifyListeners();
  }

  /// Ends the current combat encounter.
  void endCombat() {
    _isInCombat = false;
    notifyListeners();
  }
}
