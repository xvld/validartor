import 'package:validartor/base_rule.dart';

class ArrayValidatorRule<T> implements ValidatorRule<T> {
  ArrayValidatorRule(
      {this.nullable = false,
      this.empty = false,
      this.minLength = 0,
      this.maxLength,
      this.length,
      this.contains,
      this.containsPredicate,
      this.unique = false,
      this.expectedValues,
      this.ordered,
      this.mustContainAllValues,
      this.additionalValidators = const []});

  bool nullable;
  bool empty;
  int minLength;
  int maxLength;
  int length;
  T contains;
  bool Function(T) containsPredicate;
  bool unique;
  List<T> expectedValues;
  bool ordered; // Implies mustContainAllValues=true
  bool mustContainAllValues;

  List<bool Function(dynamic)> additionalValidators;

  @override
  bool validate(value) {
    if (!(value is List)) {
      return false;
    }

    final list = value as List<T>;

    if (!nullable && list == null) {
      return false;
    }

    if (empty && list.isNotEmpty) {
      return false;
    }

    if (length != null && list.length != length) {
      return false;
    }

    if (list.length < minLength) {
      return false;
    }

    if (maxLength != null && list.length > maxLength) {
      return false;
    }

    if (contains != null && list.indexOf(contains) == -1) {
      return false;
    }

    if (containsPredicate != null &&
        list.firstWhere(containsPredicate, orElse: () => null) == null) {
      return false;
    }

    if (unique && Set.from(list).length != list.length) {
      return false;
    }

    if (expectedValues != null) {
      final map = {};
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
            true, (foldValue, validator) => foldValue && validator(list))) {
      return false;
    }

    return true;
  }
}
