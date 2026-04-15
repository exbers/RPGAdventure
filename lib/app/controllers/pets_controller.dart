import 'package:flutter/foundation.dart';

import '../../domain/repositories/pets_repository.dart';

/// Manages pet companion state and delegates persistence to [PetsRepository].
///
/// Pet leveling, bonding mechanics, and ability formulas belong in domain use
/// cases, not here.
class PetsController extends ChangeNotifier {
  PetsController({required PetsRepository petsRepository})
    : _petsRepository = petsRepository;

  // ignore: unused_field
  final PetsRepository _petsRepository;

  /// Whether an async pet operation is in progress.
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Intent handlers — to be expanded when PetModel is introduced.
  // ---------------------------------------------------------------------------

  /// Loads the list of the hero's active pets.
  Future<void> loadPets() async {
    _isLoading = true;
    notifyListeners();

    // TODO(pets): call repository when PetModel is ready.
    await Future<void>.delayed(Duration.zero);

    _isLoading = false;
    notifyListeners();
  }
}
