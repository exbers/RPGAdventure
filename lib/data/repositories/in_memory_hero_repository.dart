import '../../domain/repositories/hero_repository.dart';

/// In-memory stub implementation of [HeroRepository].
///
/// Used by the composition root until a real persistence layer is ready.
/// Replace with a SharedPreferences or file-based implementation in a later
/// task without changing any controller or domain code.
class InMemoryHeroRepository implements HeroRepository {
  // No-op stub — methods will be added alongside HeroModel.
}
