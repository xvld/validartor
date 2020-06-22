import './base_rule.dart';
import '../common/null_validator.dart';
import '../common/validation_exception.dart';

class BooleanValidatorRule
    with NullValidator<bool>
    implements ValidatorRule<bool> {
  BooleanValidatorRule(
      {bool nullable = false,
      bool treatNullAsFalse = false,
      this.allowTruthyFalsyValues = false,
      this.expected,
      this.truthyValues = defaultTruthyValues,
      this.falsyValues = defaultFalsyValues}) {
    this.nullable = nullable;
    this.treatNullAs = treatNullAsFalse ? false : null;
  }

  bool allowTruthyFalsyValues; // Sanitizer
  bool expected;
  List<dynamic> truthyValues;
  List<dynamic> falsyValues;

  static const List<dynamic> defaultTruthyValues = ['true', 1];
  static const List<dynamic> defaultFalsyValues = ['false', 0];

  final Type type = bool;

  bool validate(dynamic value) {
    if (validateNullable(value)) {
      return treatNullAs;
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
