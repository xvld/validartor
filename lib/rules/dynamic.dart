import './base_rule.dart';
import '../common/null_validator.dart';
import '../common/additional_validators.dart';

class DynamicValidatorRule
    with NullValidator<dynamic>, AdditionalValidators
    implements ValidatorRule<dynamic> {
  DynamicValidatorRule(
      {bool nullable = false,
      List<bool Function(dynamic)> additionalValidators = const []}) {
    this.nullable = nullable;
    this.additionalValidators = additionalValidators;
  }

  Type type = dynamic;

  dynamic validate(value) {
    if (validateNullable(value)) {
      return treatNullAs;
    }

    validateAdditionalValidators(value);

    return value;
  }
}
