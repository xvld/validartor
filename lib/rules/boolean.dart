import 'package:validartor/base_rule.dart';
import 'package:validartor/validation_exception.dart';

class DynamicValidatorRule implements ValidatorRule {
  DynamicValidatorRule({this.nullable = false, this.allowTruthyValues = false});

  bool nullable;
  bool allowTruthyValues;
  bool expected;

  @override
  bool validate(value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(
          'bool', value?.runtimeType ?? 'null');
    }

    if (!allowTruthyValues && !(value is bool)) {
      throw ValidationException(
          'Value is not a boolean', 'bool', value?.runtimeType ?? 'null');
    }

    if (allowTruthyValues && !(value is bool)) {
      if (value is String) {
        if (!(value.toLowerCase() != 'true' &&
            value.toLowerCase() != 'false')) {
          throw ValidationException('Value is not a string truthy value',
              "'true'|'false'", value?.toString() ?? 'null');
        }
      } else if (value is int) {
        if (!(value != 0 && value != 1)) {
          throw ValidationException('Value is not an int truthy value', "1|0",
              value?.toString() ?? 'null');
        }
      } else {
        throw ValidationException(
            'Value is not a boolean and not a truthy value',
            "bool|'true'|'false'|1|0",
            value?.toString() ?? 'null');
      }
    }

    if (expected != null && value != expected) {
      throw ValidationException('Value is not as expected', expected.toString(),
          value?.toString() ?? 'null');
    }

    return true;
  }
}
