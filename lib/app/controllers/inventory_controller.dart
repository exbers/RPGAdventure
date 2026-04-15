import 'package:flutter/foundation.dart';

import '../../domain/repositories/inventory_repository.dart';

/// Manages the hero's carried inventory and delegates persistence to
/// [InventoryRepository].
///
/// Item stacking, capacity checks, and transfer rules belong in domain use
/// cases, not here.
class InventoryController extends ChangeNotifier {
  InventoryController({required InventoryRepository inventoryRepository})
    : _inventoryRepository = inventoryRepository;

  // ignore: unused_field
  final InventoryRepository _inventoryRepository;

  /// Whether an async inventory operation is in progress.
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Intent handlers — to be expanded when ItemModel is introduced.
  // ---------------------------------------------------------------------------

  /// Loads the current inventory contents.
  Future<void> loadInventory() async {
    _isLoading = true;
    notifyListeners();

    // TODO(inventory): call repository when ItemModel is ready.
    await Future<void>.delayed(Duration.zero);

    _isLoading = false;
    notifyListeners();
  }
}
