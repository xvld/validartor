import '../common/enums.dart';
import '../mixins/multi_exception_handler.dart';

import './base_rule.dart';
import '../common/validation_exception.dart';

class MultiValidatorRule
    with MultiExceptionHandler
    implements ValidatorRule<dynamic> {
  MultiValidatorRule(this.rules,
      {ThrowBehaviour throwBehaviour = ThrowBehaviour.multi}) {
    this.throwBehaviour = throwBehaviour;
  }

  List<ValidatorRule> rules;

  @override
  Type type = dynamic;

  @override
  dynamic validate(dynamic value) {
    dynamic valueToReturn;
    initValidationExceptionHandler('Multi validator failed');

    if (rules == null || rules.isEmpty) {
      throw handleException(ValidationException('No validators',
          rules.map((rule) => rule?.runtimeType).join(','), value?.toString()));
    }

    for (ValidatorRule rule in rules) {
      try {
        valueToReturn = rule.validate(value);
        break;
      } on ValidationException catch (e) {
        handleException(e);
      }
    }

    return valueToReturn == null
        ? valueToReturn
        : throwMultiValidationExceptionIfExists();
  }
}
