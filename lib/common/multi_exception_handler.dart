import './enums.dart';
import '../common/validation_exception.dart';

mixin MultiExceptionHandler {
  ThrowBehaviour throwBehaviour = ThrowBehaviour.multi;

  handleException(MultiValidationException multiValidationException,
      ValidationException exception) {
    if (throwBehaviour == ThrowBehaviour.first) {
      throw exception;
    }

    multiValidationException.exceptions.add(exception);
    return multiValidationException;
  }
}
