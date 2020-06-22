import '../common/validation_exception.dart';

/// Allows handling nullable values
///
/// Adds a [validateNullable] which should be used at the start of the [validate] function inside of a [ValidatorRule]
/// Validates if the value given is nullable and null
///
/// Usage:
/// if (validateNullable(value)) {
///     return treatNullAs;
/// }

mixin NullableValidation<T> {
  /// Whether value can be null or not
  bool nullable;

  /// What to return if [nullable] is true and value is null
  T treatNullAs = null;

  /// Validates if a value is nullable and null
  ///
  /// Returns [true] if value can be nullable and null
  /// Returns [false] if value can be nullable and is not null
  /// Throws [ValidationException] if valus cannot be nullable and is null
  validateNullable(dynamic value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(T);
    } else if (nullable && value == null) {
      return true;
    }
    return false;
  }
}
