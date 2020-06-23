import './base_rule.dart';
import '../common/null_validator.dart';
import '../common/additional_validators.dart';

class DynamicValidatorRule
    with NullableValidation<dynamic>, AdditionalValidators
    implements ValidatorRule<dynamic> {
  DynamicValidatorRule(
      {bool nullable = false,
      List<bool Function(dynamic)> additionalValidators = const []}) {
    this.nullable = nullable;
    this.additionalValidators = additionalValidators;
  }

  @override
  Type type = dynamic;

  @override
  dynamic validate(dynamic value) {
    if (validateNullable(value)) {
      return treatNullAs;
    }

    validateAdditionalValidators(value);

    return value;
  }
}
