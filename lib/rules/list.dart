import 'package:validartor/base_rule.dart';
import 'package:validartor/common/enums.dart';
import 'package:validartor/common/multi_exception_handler.dart';

import '../validation_exception.dart';

class ListValidatorRule<T>
    with MultiExceptionHandler
    implements ValidatorRule<List<T>> {
  ListValidatorRule(
      {this.nullable = false,
      this.allowEmpty = false,
      this.treatNullAsEmptyList = false,
      this.minLength = 0,
      this.maxLength = double.infinity,
      this.length,
      this.mustContain,
      this.mustContainPredicate,
      this.unique = false,
      this.expectedValues,
      this.ordered,
      this.mustContainAllValues,
      this.additionalValidators = const [],
      this.elementRule = null,
      ThrowBehaviour throwBehaviour = ThrowBehaviour.multi}) {
    throwBehaviour = throwBehaviour;
  }

  bool nullable;
  bool allowEmpty;
  bool treatNullAsEmptyList;

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

  List<bool Function(dynamic)> additionalValidators;

  Type type = List;

  List<T> validate(value) {
    MultiValidationException multiValidationException =
        MultiValidationException('List validation failed', []);

    if (!nullable && value == null) {
      throw handleException(
          multiValidationException,
          ValidationException.nullException(
              type.toString(), value?.runtimeType ?? 'null'));
    } else if (nullable && value == null) {
      return treatNullAsEmptyList ? [] : value;
    }

    if (!(value is List)) {
      throw handleException(
          multiValidationException,
          ValidationException('Value is not a Map', type.toString(),
              value?.runtimeType ?? 'null'));
    }

    final list = value as List<T>;

    if (!allowEmpty && list.isEmpty) {
      throw handleException(
          multiValidationException,
          ValidationException('List cannot be empty', 'list.length > 0',
              list.length.toString()));
    }

    if (length != null && list.length != length) {
      handleException(
          multiValidationException,
          ValidationException('List length does not match expected length',
              'list.length == $length', list.length.toString()));
    }

    if (list.length < minLength) {
      handleException(
          multiValidationException,
          ValidationException('List length is below minLength', '>= $minLength',
              list.length.toString()));
    }

    if (maxLength != null && list.length > maxLength) {
      handleException(
          multiValidationException,
          ValidationException('List length exceeds maxLength', '<= $maxLength',
              list.length.toString()));
    }

    if (mustContain != null && list.indexOf(mustContain) == -1) {
      handleException(
          multiValidationException,
          ValidationException('List does not contain expected value',
              '$mustContain', list.join(',')));
    }

    if (mustContainPredicate != null &&
        list.firstWhere(mustContainPredicate, orElse: () => null) == null) {
      handleException(
          multiValidationException,
          ValidationException(
              'List does not contain expected value with predicate',
              'predicate given',
              list.join(',')));
    }

    if (unique && Set.from(list).length != list.length) {
      handleException(
          multiValidationException,
          ValidationException('List contains non-unique values',
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

    if (additionalValidators.isNotEmpty &&
        !additionalValidators.fold(
            true, (foldValue, validator) => foldValue && validator(value))) {
      throw ValidationException(
          'Value did not pass custom validator', "", value?.toString());
    }

    if (multiValidationException.exceptions.isNotEmpty) {
      throw multiValidationException;
    }

    return list;
  }
}
