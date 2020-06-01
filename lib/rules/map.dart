import 'package:validartor/base_rule.dart';

class MapValidatorRule implements ValidatorRule {
  MapValidatorRule(this.validationMap,
      {this.nullable = false,
      this.strict = false,
      this.blacklistedKeys = const [],
      this.keys,
      this.minNumOfKeys,
      this.maxNumOfKeys});

  // TODO: see combinations and throw errors on invalid prop combinations

  final Map<String, ValidatorRule> validationMap;
  bool nullable;
  bool ignoreAdditionalFields;
  bool strict;

  List<String> keys;
  List<String> blacklistedKeys;
  num minNumOfKeys;
  num maxNumOfKeys;

  factory MapValidatorRule.simple(
          {keys, strict, blacklistedKeys, minNumOfKeys, maxNumOfKeys}) =>
      MapValidatorRule(null,
          keys: keys,
          strict: strict,
          blacklistedKeys: blacklistedKeys,
          minNumOfKeys: minNumOfKeys,
          maxNumOfKeys: maxNumOfKeys);

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

    if (strict &&
        validationMap.keys
            .any((element) => !validationMap.keys.contains(element))) {}

    return true;
  }
}
