import './base_rule.dart';
import '../common/validation_exception.dart';

class NullValidatorRule implements ValidatorRule<Null> {
  NullValidatorRule();

  Type type = Null;

  Null validate(value) {
    if (value != null) {
      throw ValidationException.invalidType(null, value?.runtimeType);
    }

    return null;
  }
}
