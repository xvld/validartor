import 'package:validartor/common/min_max_validator.dart';

import './base_rule.dart';
import '../common/null_validator.dart';
import '../common/multi_exception_handler.dart';
import '../common/additional_validators.dart';
import '../common/enums.dart';
import '../common/validation_exception.dart';

class ListValidatorRule<T extends dynamic>
    with
        MultiExceptionHandler,
        NullableValidation<List<T>>,
        AdditionalValidators,
        MinMaxExactValidation
    implements ValidatorRule<List<T>> {
  ListValidatorRule(
      {bool nullable = false,
      bool treatNullAsEmptyList = false,
      this.allowEmpty = true,
      this.minLength = 0,
      this.maxLength = double.infinity,
      this.length,
      this.mustContain,
      this.mustContainPredicate,
      this.unique = false,
      this.expectedValues,
      this.ordered,
      this.mustContainAllValues,
      List<bool Function(dynamic)> additionalValidators = const [],
      this.elementRule,
      ThrowBehaviour throwBehaviour = ThrowBehaviour.multi}) {
    this.nullable = nullable;
    this.throwBehaviour = throwBehaviour;
    this.additionalValidators = additionalValidators;

    treatNullAs = treatNullAsEmptyList ? [] : null;
  }

  bool allowEmpty;

  num minLength;
  num maxLength;
  num length;

  T mustContain;
  bool Function(T) mustContainPredicate;

  bool unique;
  List<T> expectedValues;
  bool ordered; // Implies mustContainAllValues=true
  bool mustContainAllValues;

  ValidatorRule elementRule;

  @override
  Type type = List;

  @override
  List<T> validate(dynamic value) {
    initExceptionHandler('List validation failed');

    try {
      if (validateNullable(value)) {
        return treatNullAs;
      }
    } on ValidationException catch (e) {
      throw handleException(e);
    }

    if (!(value is List)) {
      throw handleException(ValidationException(
          'Value is not a Map', type.toString(), value?.runtimeType ?? 'null'));
    }

    final convertedValue = value as List<T>;

    if (!allowEmpty && convertedValue.isEmpty) {
      throw handleException(ValidationException('List cannot be empty',
          'list.length > 0', convertedValue.length.toString()));
    }

    validateMinMaxExact(convertedValue.length, minLength, maxLength, length,
        checkedValueName: 'List length');

    if (mustContain != null && convertedValue.contains(mustContain)) {
      handleException(ValidationException(
          'List does not contain expected value',
          '$mustContain',
          convertedValue.join(',')));
    }

    if (mustContainPredicate != null &&
        convertedValue.firstWhere(mustContainPredicate, orElse: () => null) ==
            null) {
      handleException(ValidationException(
          'List does not contain expected value with predicate',
          'predicate given',
          convertedValue.join(',')));
    }

    if (unique &&
        Set<dynamic>.from(convertedValue).length != convertedValue.length) {
      handleException(ValidationException(
          'List contains non-unique values',
          Set<dynamic>.from(convertedValue).join(','),
          convertedValue.join(',')));
    }

    if (expectedValues != null) {
      final map = <T, bool>{};
      // WILL NOT WORK, ['a', 'a'] expected = ['a']
      if (mustContainAllValues &&
          expectedValues.length != convertedValue.length) {
        handleException(ValidationException('List does not contain all values',
            expectedValues.join(','), convertedValue.join(',')));
      }

      for (int i = 0; i < convertedValue.length; i++) {
        if (ordered) {
          if (expectedValues[i] != convertedValue[i]) {
            handleException(ValidationException('List is not ordered',
                expectedValues[i]?.toString(), convertedValue[i]?.toString()));
          }
        } else if (expectedValues.contains(convertedValue[i]) &&
            mustContainAllValues) {
          map[convertedValue[i]] = true;
        } else if (!expectedValues.contains(convertedValue[i])) {
          handleException(ValidationException(
              'List does not contain expected value',
              '!=${convertedValue[i]}',
              convertedValue.join(',')));
        }
      }

      if (mustContainAllValues && map.keys.length != expectedValues.length) {
        handleException(ValidationException('List does not contain all values',
            expectedValues.join(','), convertedValue.join(',')));
      }
    }

    try {
      validateAdditionalValidators(value);
    } on ValidationException catch (e) {
      handleException(e);
    }

    throwMultiValidationExceptionIfExists();
    return convertedValue;
  }
}
