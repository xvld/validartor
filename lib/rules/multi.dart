import 'package:validartor/common/enums.dart';
import 'package:validartor/common/multi_exception_handler.dart';

import './base_rule.dart';
import '../common/validation_exception.dart';

class MultiValidatorRule with MultiExceptionHandler implements ValidatorRule {
  MultiValidatorRule(this.rules,
      {ThrowBehaviour throwBehaviour = ThrowBehaviour.multi}) {
    this.throwBehaviour = throwBehaviour;
  }

  List<ValidatorRule> rules;

  Type type = dynamic;

  dynamic validate(value) {
    dynamic pass;
    initExceptionHandler('Multi validator failed');

    if (rules == null || rules.isEmpty) {
      throw handleException(ValidationException('No validators',
          rules.map((rule) => rule?.runtimeType).join(','), value));
    }

    for (ValidatorRule rule in rules) {
      try {
        pass = rule.validate(value);
        break;
      } on ValidationException catch (e) {
        handleException(e);
      }
    }

    if (pass == null) {
      throwMultiValidationExceptionIfExists();
    }

    return pass;
  }
}
