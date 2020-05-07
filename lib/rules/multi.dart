import 'package:validator/base_rule.dart';
import 'package:validator/validation_exception.dart';

class MultiValidatorRule implements ValidatorRule {
  MultiValidatorRule(this.rules);

  List<ValidatorRule> rules;

  @override
  bool validate(value) {
    bool pass = false;
    List<ValidationException> exceptions;
    for (ValidatorRule rule in rules) {
      try {
        pass = rule.validate(value);
      } on ValidationException catch (e) {
        exceptions.add(e);
      }
    }

    if (pass == false) {
      throw MultiValidationException(
          'Value did not match any of the rules given', exceptions);
    }

    return pass;
  }
}
