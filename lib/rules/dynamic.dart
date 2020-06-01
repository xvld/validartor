import 'package:validartor/base_rule.dart';
import 'package:validartor/validation_exception.dart';

class DynamicValidatorRule implements ValidatorRule {
  DynamicValidatorRule(
      {this.nullable = false, this.additionalValidators = const []});

  bool nullable;
  List<bool Function(dynamic)> additionalValidators;

  @override
  bool validate(value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException('dynamic', 'null');
    } else if (nullable && value == null) {
      return true;
    }

    if (additionalValidators.isNotEmpty &&
        !additionalValidators.fold(
            true, (foldValue, validator) => foldValue && validator(value))) {
      throw ValidationException('Value did not pass custom validator', "",
          value?.toString() ?? 'null');
    }

    return true;
  }
}
