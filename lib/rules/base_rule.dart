/// Base ValidatorRule class
///
/// All validator rules must implement this class in order to work together
/// Can be implemented to write your own validator
abstract class ValidatorRule<T> {
  /// Validates the value, and returns the value converted to [T] and optionally sanitized
  ///
  /// Throws a [ValidationException] or an [MultiValidationException] depending on the validator configuration
  T validate(dynamic value);

  /// This specific validator's type - [T], against which runtime type checks will be performed
  final Type type = T;
}
