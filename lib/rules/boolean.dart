import 'package:validartor/base_rule.dart';
import 'package:validartor/validation_exception.dart';

class BooleanValidatorRule implements ValidatorRule<bool> {
  BooleanValidatorRule(
      {this.nullable = false,
      this.allowTruthyFalsyValues = false,
      this.expected,
      this.treatNullAsFalse = false,
      this.truthyValues = defaultTruthyValues,
      this.falsyValues = defaultFalsyValues});

  bool nullable;
  bool allowTruthyFalsyValues; // Sanitizer
  bool expected;
  bool treatNullAsFalse; // Sanitizer
  List<dynamic> truthyValues;
  List<dynamic> falsyValues;

  static const List<dynamic> defaultTruthyValues = ['true', 1];
  static const List<dynamic> defaultFalsyValues = ['false', 0];

  Type type = bool;

  bool validate(dynamic value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(type);
    } else if (nullable && value == null) {
      return treatNullAsFalse ? false : null;
    }

    if (!allowTruthyFalsyValues && !(value is bool)) {
      throw ValidationException.invalidType(type, value.runtimeType);
    }

    if (allowTruthyFalsyValues && !(value is bool)) {
      final notOneTruthyValuePassed = !truthyValues.any((truthyValue) {
        if ((truthyValue.runtimeType == value.runtimeType &&
            truthyValue == value)) {
          value = true;
          return true;
        }
        return false;
      });

      final notOneFalsyValuePassed = !falsyValues.any((falsyValue) {
        if ((falsyValue.runtimeType == value.runtimeType &&
            falsyValue == value)) {
          value = false;
          return true;
        }
        return false;
      });

      if (notOneTruthyValuePassed && notOneFalsyValuePassed) {
        throw ValidationException.cannotConvert(
            (<dynamic>[]..addAll(truthyValues)..addAll(falsyValues)).join('|'),
            value);
      }
    }

    if (expected != null && value != expected) {
      throw ValidationException.notAsExpected(
          expected.toString(), value.toString());
    }

    return value;
  }
}
