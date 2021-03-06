import './base_rule.dart';
import '../mixins/null_validator.dart';
import '../common/validation_exception.dart';

class BooleanValidatorRule
    with NullableValidation<bool>
    implements ValidatorRule<bool> {
  BooleanValidatorRule(
      {bool nullable = false,
      bool treatNullAsFalse = false,
      this.allowTruthyFalsyValues = false,
      this.expected,
      this.truthyValues = defaultTruthyValues,
      this.falsyValues = defaultFalsyValues}) {
    this.nullable = nullable;
    treatNullAs = treatNullAsFalse ? false : null;
  }

  bool allowTruthyFalsyValues; // Sanitizer
  bool expected;
  List<dynamic> truthyValues;
  List<dynamic> falsyValues;

  static const List defaultTruthyValues = <dynamic>['true', 1];
  static const List defaultFalsyValues = <dynamic>['false', 0];

  @override
  final Type type = bool;

  @override
  bool validate(dynamic value) {
    if (validateNullable(value)) {
      return treatNullAs;
    }

    if (!allowTruthyFalsyValues && !(value is bool)) {
      throw ValidationException.invalidType(type, value.runtimeType as Type);
    }

    bool convertedValue;

    if (value is bool) {
      convertedValue = value;
    }

    if (allowTruthyFalsyValues && !(value is bool)) {
      final notOneTruthyValuePassed = !truthyValues.any((dynamic truthyValue) {
        if ((truthyValue.runtimeType == value.runtimeType &&
            truthyValue == value)) {
          convertedValue = true;
          return true;
        }
        return false;
      });

      final notOneFalsyValuePassed = !falsyValues.any((dynamic falsyValue) {
        if ((falsyValue.runtimeType == value.runtimeType &&
            falsyValue == value)) {
          convertedValue = false;
          return true;
        }
        return false;
      });

      if (notOneTruthyValuePassed && notOneFalsyValuePassed) {
        throw ValidationException.cannotConvert(
            (<dynamic>[]..addAll(truthyValues)..addAll(falsyValues)).join('|'),
            value.runtimeType as Type);
      }
    }

    if (expected != null && convertedValue != expected) {
      throw ValidationException.notAsExpected(
          expected.toString(), value.toString());
    }

    return convertedValue;
  }
}
