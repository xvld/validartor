import 'package:validator/base_rule.dart';
import 'package:validator/validation_exception.dart';

class NullValidatorRule implements ValidatorRule {
  NullValidatorRule();

  @override
  bool validate(value) {
    if (value != null) {
      throw ValidationException('Value is not null', 'null', value.runtimeType);
    }

    return true;
  }
}
