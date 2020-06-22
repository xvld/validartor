import '../common/min_max_validator.dart';
import '../common/additional_validators.dart';
import '../common/null_validator.dart';
import './base_rule.dart';
import '../common/validation_exception.dart';

class NumberValidatorRule
    with NullValidator<num>, AdditionalValidators, MinMaxValidator
    implements ValidatorRule<num> {
  NumberValidatorRule(
      {bool nullable = false,
      this.allowStringValues = false,
      this.integer = false,
      this.expected,
      this.notEqualTo,
      this.min = double.negativeInfinity,
      this.max = double.infinity,
      this.onlyPositive = false,
      this.onlyNegative = false,
      List<bool Function(dynamic)> additionalValidators = const [],
      num treatNullAs}) {
    this.nullable = nullable;
    this.treatNullAs = treatNullAs;
    this.additionalValidators = additionalValidators;
  }

  bool allowStringValues; // Sanitizer

  bool integer;

  num expected;
  num notEqualTo;

  num min;
  num max;

  bool onlyPositive;
  bool onlyNegative;

  bool _valueIsNumber(dynamic value) => value is num;

  Type type = num;

  num validate(value) {
    if (validateNullable(value)) {
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

    validateMinMaxExact(value, min, max, expected);

    if (notEqualTo != null && notEqualTo == value) {
      throw ValidationException('Value is not as expected',
          "!=${notEqualTo.toString()}", value.toString());
    }

    if (integer && value % 1 != 0) {
      throw ValidationException(
          'Value is not an integer', 'int', value.toString());
    }

    if (onlyPositive != null && value < 0) {
      throw ValidationException(
          'Value is not positive or zero', ">=0", value.toString());
    }

    if (onlyNegative != null && value > 0) {
      throw ValidationException(
          'Value is not negative or zero', "<=0", value.toString());
    }

    validateAdditionalValidators(value);

    return value;
  }
}
