import 'package:validartor/common/enums.dart';
import 'package:validartor/validation_exception.dart';

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
