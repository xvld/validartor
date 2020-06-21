enum ValidationExceptionType { general }

class ValidationException implements Exception {
  ValidationException(this.message, this.expected, this.actual,
      {this.type = ValidationExceptionType.general});

  final dynamic message;
  final ValidationExceptionType type;
  final String expected;
  final String actual;

  factory ValidationException.nullException(String expected, String actual) {
    return ValidationException('Value must not be null', expected, actual);
  }
}

class MultiValidationException implements Exception {
  MultiValidationException(this.message, this.exceptions);

  final dynamic message;
  List<ValidationException> exceptions;
}
