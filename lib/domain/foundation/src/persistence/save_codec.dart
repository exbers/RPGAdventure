/// Bidirectional serializer between a domain type [T] and a plain-map payload.
///
/// A [SaveCodec] decouples domain objects from the raw storage format used
/// by [SaveSnapshot.payload]. Implement one codec per major domain aggregate
/// (e.g. `HeroStateCodec`, `WorldStateCodec`).
///
/// The codec operates on `Map<String, Object?>` so that snapshots stay
/// JSON-serializable across storage backends. Do not reference Flutter
/// widgets, assets, or platform APIs in a codec implementation.
///
/// Example:
/// ```dart
/// class HeroCodec implements SaveCodec<HeroState> {
///   @override
///   Map<String, Object?> encode(HeroState state) => {
///     'name': state.name,
///     'level': state.level,
///   };
///
///   @override
///   HeroState decode(Map<String, Object?> map) =>
///       HeroState(name: map['name'] as String, level: map['level'] as int);
/// }
/// ```
abstract interface class SaveCodec<T> {
  /// Converts [value] into a JSON-serializable map.
  ///
  /// All values in the returned map must be plain JSON primitives:
  /// bool, int, double, String, List, Map, or null.
  Map<String, Object?> encode(T value);

  /// Reconstructs a [T] from [map].
  ///
  /// [map] was previously produced by [encode] (possibly after migration).
  /// Throws [FormatException] when required keys are missing or have the
  /// wrong type.
  T decode(Map<String, Object?> map);
}
