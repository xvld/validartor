import 'package:validartor/base_rule.dart';
import 'package:validartor/validation_exception.dart';

class MultiValidatorRule implements ValidatorRule {
  MultiValidatorRule(this.rules);

  List<ValidatorRule> rules;

  Type type = dynamic;

  @override
  dynamic validate(value) {
    dynamic pass;
    List<ValidationException> exceptions = [];

    for (ValidatorRule rule in rules) {
      try {
        pass = rule.validate(value);
        break;
      } on ValidationException catch (e) {
        exceptions.add(e);
      }
    }

    if (exceptions.isNotEmpty && pass == null) {
      throw MultiValidationException(
          'Value did not match any of the rules given', exceptions);
    }

    return pass;
  }
}
