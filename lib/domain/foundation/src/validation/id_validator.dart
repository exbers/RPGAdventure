import '../ids/entity_id.dart';
import 'id_validation_result.dart';

/// Validates that every ID reference in a content document resolves to a known
/// entry in the corresponding registry.
///
/// Usage:
/// ```dart
/// final validator = IdValidator();
/// validator.registerKnown<ItemId>('ItemId', {'iron_sword', 'wooden_shield'});
///
/// validator.checkId<ItemId>(
///   field: 'loot_table[0].itemId',
///   id: ItemId('iron_sword'),
///   idType: 'ItemId',
/// );
///
/// final result = validator.finish();
/// if (!result.isValid) debugPrint(result.toReport());
/// ```
///
/// [IdValidator] is stateful and single-use. Create a new instance per
/// validation pass.
final class IdValidator {
  final Map<String, Set<String>> _registries = {};
  final List<MissingIdError> _errors = [];

  /// Registers a set of known raw ID values for the given [idType] label.
  ///
  /// Call this before [checkId] for the same type.
  void registerKnown<T extends EntityId>(
    String idType,
    Iterable<String> knownValues,
  ) {
    _registries[idType] = Set.unmodifiable(knownValues);
  }

  /// Checks whether [id] is present in the registered set for [idType].
  ///
  /// Records a [MissingIdError] when the ID is absent or no registry was
  /// registered for [idType].
  void checkId<T extends EntityId>({
    required String field,
    required T id,
    required String idType,
  }) {
    final known = _registries[idType];
    if (known == null || !known.contains(id.value)) {
      _errors.add(MissingIdError(field: field, id: id.value, idType: idType));
    }
  }

  /// Convenience overload that checks a raw string ID without constructing
  /// a typed [EntityId].
  ///
  /// Use this when the caller has already validated the raw string and only
  /// needs to confirm the reference exists.
  void checkRaw({
    required String field,
    required String rawId,
    required String idType,
  }) {
    final known = _registries[idType];
    if (known == null || !known.contains(rawId)) {
      _errors.add(MissingIdError(field: field, id: rawId, idType: idType));
    }
  }

  /// Returns the aggregated [IdValidationResult] and resets internal state.
  ///
  /// After calling [finish] the validator should be discarded.
  IdValidationResult finish() => IdValidationResult(List.unmodifiable(_errors));
}
