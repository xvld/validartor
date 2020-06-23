import './base_rule.dart';
import '../common/validation_exception.dart';

class NullValidatorRule implements ValidatorRule<Null> {
  NullValidatorRule();

  @override
  Type type = Null;

  @override
  Null validate(dynamic value) {
    if (value != null) {
      throw ValidationException.invalidType(null, value?.runtimeType as Type);
    }

    return null;
  }
}
