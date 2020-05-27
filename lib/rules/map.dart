import 'package:validartor/base_rule.dart';

class MapValidatorRule implements ValidatorRule {
  MapValidatorRule(
    this.validationMap, {
    this.nullable = false,
    this.strict = false
  });

  final Map<String, ValidatorRule> validationMap;
  bool nullable;
  bool ignoreAdditionalFields;
  bool strict;

  @override
  bool validate(value) {
    if (!(value is Map<String, ValidatorRule>)) {
      return false;
    }

    if (!(value is Map<String, dynamic>)) {
      return false;
    }

    validationMap.forEach((key, validator) {
      validator.validate(value[key]);
    });

    if (strict && validationMap.keys.any((element) => !validationMap.keys.contains(element))) {
    }


    return true;
  }
}
