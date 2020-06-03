import 'package:validartor/base_rule.dart';
import 'package:validartor/validation_exception.dart';

class NullValidatorRule implements ValidatorRule<Null> {
  NullValidatorRule();

  @override
  Type type = Null;

  @override
  Null validate(value) {
    if (value != null) {
      throw ValidationException('Value is not null', 'null', value.runtimeType);
    }

    return null;
  }
}
