import 'package:flutter/foundation.dart';

import '../../domain/repositories/hero_repository.dart';

/// Manages hero state and delegates persistence to [HeroRepository].
///
/// Business rules and stat calculations must never live here — they belong in
/// domain use cases that this controller calls. Widgets listen to this notifier
/// and forward user intents as method calls.
class HeroController extends ChangeNotifier {
  HeroController({required HeroRepository heroRepository})
    : _heroRepository = heroRepository;

  // ignore: unused_field
  final HeroRepository _heroRepository;

  /// Whether an async operation is in progress.
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Intent handlers — to be expanded when HeroModel is introduced.
  // ---------------------------------------------------------------------------

  /// Signals the controller to begin loading hero data.
  ///
  /// Placeholder: will delegate to a use case once hero models exist.
  Future<void> loadHero() async {
    _isLoading = true;
    notifyListeners();

    // TODO(hero): call use case / repository when HeroModel is ready.
    await Future<void>.delayed(Duration.zero);

    _isLoading = false;
    notifyListeners();
  }
}
