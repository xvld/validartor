import '../common/min_max_validator.dart';
import '../common/additional_validators.dart';
import '../common/null_validator.dart';
import './base_rule.dart';
import '../common/validation_exception.dart';

class NumberValidatorRule
    with NullableValidation<num>, AdditionalValidators, MinMaxExactValidation
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

  @override
  Type type = num;

  @override
  num validate(dynamic value) {
    if (validateNullable(value)) {
      return treatNullAs;
    }

    num convertedValue;

    if (!allowStringValues && !_valueIsNumber(value)) {
      throw ValidationException.invalidType(type, value?.runtimeType as Type);
    } else if (allowStringValues && value is String) {
      try {
        convertedValue = num.parse(value); // set to double to continue
      } catch (_) {
        throw ValidationException.cannotConvert(expected.toString(), type);
      }
    }

    validateMinMaxExact(convertedValue, min, max, expected);

    if (notEqualTo != null && notEqualTo == convertedValue) {
      throw ValidationException.notAsExpected(
          '!=${notEqualTo.toString()}', value.toString());
    }

    if (integer && convertedValue % 1 != 0) {
      throw ValidationException(
          'Value is not an integer', 'int', value.toString(),
          type: ValidationExceptionType.invalidType);
    }

    if (onlyPositive != null && convertedValue < 0) {
      throw ValidationException(
          'Value is not positive or zero', '>=0', value.toString(),
          type: ValidationExceptionType.notAsExpected);
    }

    if (onlyNegative != null && convertedValue > 0) {
      throw ValidationException(
          'Value is not negative or zero', '<=0', value.toString(),
          type: ValidationExceptionType.notAsExpected);
    }

    validateAdditionalValidators(convertedValue);

    return convertedValue;
  }
}
