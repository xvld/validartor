enum ValidationExceptionType {
  general,
  multi,
  isNull,
  invalidType,
  cannotConvert,
  notAsExpected,
  customValidator,
}

class ValidationException implements Exception {
  ValidationException(this.message, this.expected, this.actual,
      {this.type = ValidationExceptionType.general});

  final dynamic message;
  final ValidationExceptionType type;
  final String expected;
  final String actual;

  factory ValidationException.nullException(Type expected) =>
      ValidationException(
          'Value must not be null', expected?.toString(), 'null',
          type: ValidationExceptionType.isNull);

  factory ValidationException.invalidType(Type expected, Type actual) =>
      ValidationException('Value is not ${expected?.toString()}',
          expected?.toString(), actual?.toString() ?? 'null',
          type: ValidationExceptionType.invalidType);

  factory ValidationException.cannotConvert(String expected, Type actual) =>
      ValidationException(
          'Cannot convert from ${actual?.toString() ?? 'null'} to $expected',
          expected?.toString(),
          actual?.toString() ?? 'null',
          type: ValidationExceptionType.cannotConvert);

  factory ValidationException.notAsExpected(String expected, String actual) =>
      ValidationException('Value is not as expected', expected, actual,
          type: ValidationExceptionType.notAsExpected);

  factory ValidationException.customValidator() =>
      ValidationException('Value did not pass custom validator', '', '',
          type: ValidationExceptionType.customValidator);
}

class MultiValidationException implements Exception {
  MultiValidationException(this.message, this.exceptions);

  final ValidationExceptionType type = ValidationExceptionType.multi;
  final dynamic message;
  List<ValidationException> exceptions;
}
