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
        NullValidator<List<T>>,
        AdditionalValidators,
        MinMaxValidator
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
      this.elementRule = null,
      ThrowBehaviour throwBehaviour = ThrowBehaviour.multi}) {
    this.nullable = nullable;
    this.treatNullAs = treatNullAsEmptyList ? [] : null;
    this.throwBehaviour = throwBehaviour;
    this.additionalValidators = additionalValidators;
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

  Type type = List;

  List<T> validate(value) {
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

    final list = value as List<T>;

    if (!allowEmpty && list.isEmpty) {
      throw handleException(ValidationException(
          'List cannot be empty', 'list.length > 0', list.length.toString()));
    }

    validateMinMaxExact(list.length, minLength, maxLength, length,
        checkedValueName: 'List length');

    if (mustContain != null && list.indexOf(mustContain) == -1) {
      handleException(ValidationException(
          'List does not contain expected value',
          '$mustContain',
          list.join(',')));
    }

    if (mustContainPredicate != null &&
        list.firstWhere(mustContainPredicate, orElse: () => null) == null) {
      handleException(ValidationException(
          'List does not contain expected value with predicate',
          'predicate given',
          list.join(',')));
    }

    if (unique && Set.from(list).length != list.length) {
      handleException(ValidationException('List contains non-unique values',
          Set.from(list).join(','), list.join(',')));
    }

    if (expectedValues != null) {
      final map = {};
      // WILL NOT WORK, ['a', 'a'] expected = ['a']
      if (mustContainAllValues && expectedValues.length != list.length) {
        return false;
      }

      for (int i = 0; i < list.length; i++) {
        if (ordered) {
          if (expectedValues[i] != list[i]) {
            return false;
          }
        } else if (expectedValues.contains(list[i]) && mustContainAllValues) {
          map[list[i]] = true;
        } else if (!expectedValues.contains(list[i])) {
          return false;
        }
      }

      if (mustContainAllValues && map.keys.length != expectedValues.length) {
        return false;
      }
    }

    try {
      validateAdditionalValidators(value);
    } on ValidationException catch (e) {
      handleException(e);
    }

    throwMultiValidationExceptionIfExists();
    return list;
  }
}
