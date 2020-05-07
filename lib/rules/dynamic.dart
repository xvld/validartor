import 'package:validator/base_rule.dart';
import 'package:validator/validation_exception.dart';

class DynamicValidatorRule implements ValidatorRule {
  DynamicValidatorRule(
      {this.nullable = false, this.additionalValidators = const []});

  bool nullable;
  List<bool Function(dynamic)> additionalValidators;

  @override
  bool validate(value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException('dynamic', 'null');
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
