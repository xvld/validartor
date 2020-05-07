import 'package:validator/base_rule.dart';

class MapValidatorRule implements ValidatorRule {
  MapValidatorRule(
    this.map, {
    this.nullable = false,
  });

  final Map<String, ValidatorRule> map;
  bool nullable;
  bool ignoreAdditionalFields;

  @override
  bool validate(value) {
    if (!(value is List)) {
      return false;
    }
  }
}
