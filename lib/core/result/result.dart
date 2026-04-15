import 'package:flutter_application_1/core/errors/game_failure.dart';

/// A discriminated union that represents the outcome of an operation that can
/// either succeed with a value of type [T] or fail with a [GameFailure].
///
/// Use exhaustive `switch` (Dart 3 sealed classes) to handle both branches:
///
/// ```dart
/// switch (result) {
///   case Success(:final value):
///     // use value
///   case Failure(:final failure):
///     // handle failure.message / log failure.detail
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Returns `true` when this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns `true` when this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// Returns the success value, or `null` if this is a [Failure].
  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    Failure() => null,
  };

  /// Returns the failure, or `null` if this is a [Success].
  GameFailure? get failureOrNull => switch (this) {
    Success() => null,
    Failure(:final failure) => failure,
  };

  /// Transforms a [Success] value with [transform]; passes [Failure] through.
  Result<U> map<U>(U Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Failure(:final failure) => Failure(failure),
  };

  /// Chains operations that themselves return a [Result]; passes [Failure]
  /// through without invoking [transform].
  Result<U> flatMap<U>(Result<U> Function(T value) transform) => switch (this) {
    Success(:final value) => transform(value),
    Failure(:final failure) => Failure(failure),
  };
}

/// Successful outcome carrying a value of type [T].
final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  String toString() => 'Success($value)';
}

/// Failed outcome carrying a [GameFailure] that describes what went wrong.
final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final GameFailure failure;

  @override
  String toString() => 'Failure(${failure.message})';
}
