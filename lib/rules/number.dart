import 'package:validartor/base_rule.dart';
import 'package:validartor/validation_exception.dart';

class NumberValidatorRule implements ValidatorRule<num> {
  NumberValidatorRule(
      {this.nullable = false,
      this.allowStringValues = false,
      this.integer = false,
      this.expected,
      this.notEqualTo,
      this.min = double.negativeInfinity,
      this.max = double.infinity,
      this.onlyPositive = false,
      this.onlyNegative = false,
      this.additionalValidators = const [],
      this.treatNullAs});

  bool nullable;
  num treatNullAs; // Sanitizer
  bool allowStringValues; // Sanitizer

  bool integer;

  num expected;
  num notEqualTo;

  num min;
  num max;

  bool onlyPositive;
  bool onlyNegative;

  List<bool Function(num)> additionalValidators;

  bool _valueIsNumber(dynamic value) => value is num;

  @override
  Type type = num;

  @override
  num validate(value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(
          type.toString(), value?.runtimeType ?? 'null');
    } else if (nullable && value == null) {
      return treatNullAs;
    }

    if (!allowStringValues && !_valueIsNumber(value)) {
      throw ValidationException('Value is not a number', type.toString(),
          value?.runtimeType ?? 'null');
    } else if (allowStringValues && value is String) {
      try {
        value = num.parse(value); // set to double to continue
      } catch (_) {
        throw ValidationException(
            'Value is a string that isnt parsable to a number',
            expected.toString(),
            value.toString());
      }
    }

    if (expected != null && expected != value) {
      throw ValidationException(
          'Value is not as expected', expected.toString(), value.toString());
    }

    if (notEqualTo != null && notEqualTo == value) {
      throw ValidationException('Value is not as expected',
          "!=${notEqualTo.toString()}", value.toString());
    }

    if (integer && value % 1 != 0) {
      throw ValidationException(
          'Value is not an integer', 'int', value.toString());
    }

    if (value < min) {
      throw ValidationException(
          'Value is lower than min', ">=${min.toString()}", value.toString());
    }

    if (value > max) {
      throw ValidationException(
          'Value is higher than max', "<=${max.toString()}", value.toString());
    }

    if (onlyPositive != null && value < 0) {
      throw ValidationException(
          'Value is not positive or zero', ">=0", value.toString());
    }

    if (onlyNegative != null && value > 0) {
      throw ValidationException(
          'Value is not negative or zero', "<=0", value.toString());
    }

    if (additionalValidators.isNotEmpty &&
        !additionalValidators.fold(
            true, (foldValue, validator) => foldValue && validator(value))) {
      throw ValidationException('Value did not pass custom validator', "",
          value?.toString() ?? 'null');
    }

    return value;
  }
}
