import 'package:validartor/validation_exception.dart';
import 'package:validartor/base_rule.dart';

class EnumValidatorRule implements ValidatorRule {
  EnumValidatorRule({this.nullable = false, List<String> values = const []})
      : this.values = values.map((value) => value.split('.').last);

  bool nullable;
  List<String> values;

  List<bool Function(dynamic)> additionalValidators;

  @override
  bool validate(value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(
          'bool', value?.runtimeType ?? 'null');
    }

    if (!(value is String)) {
      throw ValidationException(
          'Value is not a string', 'String', value?.runtimeType ?? 'null');
    }

    if (values.isNotEmpty && !values.contains(value)) {
      throw ValidationException('Value is not part of enum',
          'one of: ${values.toString()}', value.toString() ?? 'null');
    }

    return true;
  }
}
