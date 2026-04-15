import 'package:flutter/foundation.dart';

import '../../domain/repositories/quests_repository.dart';

/// Manages the quest log state and delegates persistence to [QuestsRepository].
///
/// Quest completion checks, reward calculations, and progression triggers
/// belong in domain use cases, not here.
class QuestsController extends ChangeNotifier {
  QuestsController({required QuestsRepository questsRepository})
    : _questsRepository = questsRepository;

  // ignore: unused_field
  final QuestsRepository _questsRepository;

  /// Whether an async quest operation is in progress.
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // Intent handlers — to be expanded when QuestModel is introduced.
  // ---------------------------------------------------------------------------

  /// Loads active and completed quests.
  Future<void> loadQuests() async {
    _isLoading = true;
    notifyListeners();

    // TODO(quests): call repository when QuestModel is ready.
    await Future<void>.delayed(Duration.zero);

    _isLoading = false;
    notifyListeners();
  }
}
