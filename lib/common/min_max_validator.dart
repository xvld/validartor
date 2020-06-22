import 'package:validartor/common/validation_exception.dart';

mixin MinMaxExactValidation {
  validateMinMaxExact(num value, num min, num max, num expected,
      {String checkedValueName = 'Value'}) {
    if (expected != null && expected != value) {
      throw ValidationException('$checkedValueName is not as expected',
          expected.toString(), value.toString());
    }

    if (value < min) {
      throw ValidationException('$checkedValueName is lower than min',
          ">=${min.toString()}", value.toString());
    }

    if (value > max) {
      throw ValidationException('$checkedValueName is higher than max',
          "<=${max.toString()}", value.toString());
    }
  }
}
