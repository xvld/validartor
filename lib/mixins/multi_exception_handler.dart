import './enums.dart';
import '../common/validation_exception.dart';

/// Allows handling exceptions and deciding whether to throw [MultiValidationException] or [ValidationException]
///
/// Adds a [ThrowBehaviour] parameter to the class, with default [ThrowBehaviour.multi]
/// This class should wrap the [ValidationException] throw statements, to aggregate all errors in a validator instead of throwing on first failure
mixin MultiExceptionHandler {
  /// The desired throw behaviour of the [handleException] function
  ThrowBehaviour throwBehaviour = ThrowBehaviour.multi;
  MultiValidationException multiValidationException;

  void initExceptionHandler(String message) {
    multiValidationException =
        MultiValidationException(message, exceptions: []);
  }

  /// Handles an exception
  ///
  /// Returns the [MultiValidationException] with the exception added
  /// Throws [ValidationException] if [throwBehaviour] is [ThrowBehaviour.first]
  MultiValidationException handleException(ValidationException exception) {
    if (throwBehaviour == ThrowBehaviour.first) {
      throw exception;
    }

    multiValidationException.exceptions.add(exception);
    return multiValidationException;
  }

  void throwMultiValidationExceptionIfExists() {
    if (multiValidationException != null &&
        multiValidationException.exceptions.isNotEmpty) {
      throw multiValidationException;
    }
  }
}
