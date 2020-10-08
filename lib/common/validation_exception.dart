enum ValidationExceptionType {
  general,
  multi,
  isNull,
  invalidType,
  cannotConvert,
  notAsExpected,
  customValidator,
}

/// An exception signalling that a validation has failed
///
/// Will be thrown from the [validate] method of [ValidatorRule]
class ValidationException implements Exception {
  ValidationException(this.message, this.expected, this.actual,
      {this.type = ValidationExceptionType.general});

  /// The exception message
  String message;

  /// The exception type
  final ValidationExceptionType type;

  /// The value the validator expected to receive
  final String expected;

  bool _positionSet = false;

  set fieldName(String value) {
    if (!_positionSet) {
      message = 'At position: [${value}] - ${message}';
      _positionSet = true;
    } else {
      message = message.replaceFirst('[', '[$value][');
    }
  }

  /// The actual value it gor
  final String actual;

  /// Shorthand for a null exception
  factory ValidationException.nullException(Type expected) =>
      ValidationException(
          'Value must not be null', expected?.toString(), 'null',
          type: ValidationExceptionType.isNull);

  /// Shorthand for when the types mismatch
  factory ValidationException.invalidType(Type expected, Type actual) =>
      ValidationException('Value is not ${expected?.toString()}',
          expected?.toString(), actual?.toString() ?? 'null',
          type: ValidationExceptionType.invalidType);

  /// Shorthand for when the types cannot be converted
  factory ValidationException.cannotConvert(String expected, Type actual) =>
      ValidationException(
          'Cannot convert from ${actual?.toString() ?? 'null'} to $expected',
          expected?.toString(),
          actual?.toString() ?? 'null',
          type: ValidationExceptionType.cannotConvert);

  /// Shorthand for when the value itself is not as expected in the validator
  factory ValidationException.notAsExpected(String expected, String actual) =>
      ValidationException('Value is not as expected', expected, actual,
          type: ValidationExceptionType.notAsExpected);

  /// Shorthand for when an additional validator fails
  ///
  /// [failedValidatorsIndices] is a list of the indices of the additionalValidators that failed
  factory ValidationException.customValidator(
          {List<int> failedValidatorsIndices = const []}) =>
      ValidationException(
          'Value did not pass custom validator/s',
          'All validators should pass',
          'Validators ${failedValidatorsIndices.join(',')} did not pass',
          type: ValidationExceptionType.customValidator);

  @override
  String toString() {
    return '$message. expected: $expected, actual: $actual.';
  }
}

/// An exception signalling that a validation has failed, with multiple errors
///
/// Will be thrown from the [validate] method of [ValidatorRule] when [ThrowBehaviour] is multi
class MultiValidationException implements Exception {
  MultiValidationException(this.message, {this.exceptions = const []});

  final ValidationExceptionType type = ValidationExceptionType.multi;
  String message;
  List<ValidationException> exceptions;

  bool _positionSet = false;

  set fieldName(String value) {
    if (!_positionSet) {
      message = 'At position: [${value}] - ${message}';
      _positionSet = true;
    } else {
      message.replaceFirst('[', '[$value][');
    }
    exceptions.forEach((e) => e.fieldName = value);
  }

  @override
  String toString() {
    return '$message.\n${exceptions.map((e) => e.toString()).join('\n')}';
  }
}
