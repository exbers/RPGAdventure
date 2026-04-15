/// Sealed hierarchy of domain failures used across the RPG Adventure app.
///
/// - [message] is safe to surface in the UI (user-facing text).
/// - [detail] carries internal context intended for logging only; never show
///   it directly to players.
sealed class GameFailure {
  const GameFailure({required this.message, this.detail});

  /// Human-readable description suitable for display in the UI.
  final String message;

  /// Optional internal detail for diagnostic logging (not shown to the user).
  final String? detail;

  @override
  String toString() =>
      '$runtimeType(message: $message'
      '${detail != null ? ', detail: $detail' : ''})';
}

/// Failure produced when a game object (item, quest, character, …) fails
/// business-rule validation.
final class ValidationFailure extends GameFailure {
  const ValidationFailure({required super.message, super.detail, this.field});

  /// Optional name of the field or property that triggered the failure.
  final String? field;
}

/// Failure produced during save or load operations (file I/O, serialisation, …).
final class PersistenceFailure extends GameFailure {
  const PersistenceFailure({required super.message, super.detail});
}

/// Failure produced during combat resolution (invalid action, illegal state, …).
final class CombatFailure extends GameFailure {
  const CombatFailure({required super.message, super.detail});
}

/// Failure produced during economy operations (insufficient funds, price
/// calculation errors, trade rule violations, …).
final class EconomyFailure extends GameFailure {
  const EconomyFailure({required super.message, super.detail});
}
