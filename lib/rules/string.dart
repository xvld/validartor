import 'package:validartor/common/min_max_validator.dart';

import './base_rule.dart';
import '../common/additional_validators.dart';
import '../common/null_validator.dart';
import '../common/validation_exception.dart';

enum InputTrimType { left, right, both, all, none }
enum InputType { alphabetic, numeric, alphaNumeric, lowerCase, upperCase }

class StringValidatorRule
    with NullableValidation<String>, AdditionalValidators, MinMaxExactValidation
    implements ValidatorRule<String> {
  StringValidatorRule(
      {nullable = false,
      treatNullAs = null,
      this.acceptEmpty = true,
      this.inputTrim = InputTrimType.none,
      this.length = double.infinity,
      this.minLength = double.negativeInfinity,
      this.maxLength = double.infinity,
      this.pattern,
      this.mustContain,
      this.inputTypes = const [],
      this.ignoredCharsInInputTypeChecks = const [],
      this.allowedValues = const [],
      List<bool Function(dynamic)> additionalValidators}) {
    this.nullable = nullable;
    this.treatNullAs = treatNullAs;
    this.additionalValidators = additionalValidators;
  }

  bool acceptEmpty;
  InputTrimType inputTrim; // Sanitizer

  num length;
  num minLength;
  num maxLength;

  String pattern;
  String mustContain;

  List<InputType> inputTypes;

  List<String> ignoredCharsInInputTypeChecks;

  List<String> allowedValues;

  Type type = String;

  static Map<InputType, RegExp> _inputTypeToRegExp = {
    InputType.alphabetic: RegExp(r"[A-Za-z\s]*"),
    InputType.alphaNumeric: RegExp(r"[\w\s]*"),
    InputType.numeric: RegExp(r"^-?[0-9]\d*(\.\d+)?$"),
    InputType.lowerCase: RegExp(r"[a-z\d\s]*"),
    InputType.upperCase: RegExp(r"[A-Z\d\s]*")
  };

  String validate(value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(type);
    } else if (nullable && value == null) {
      return treatNullAs;
    }

    if (!(value is String)) {
      throw ValidationException.invalidType(type, value.runtimeType);
    }

    String stringValue = value;

    if (inputTrim != InputTrimType.none) {
      switch (inputTrim) {
        case InputTrimType.both:
          stringValue = stringValue.trim();
          break;
        case InputTrimType.left:
          stringValue = stringValue.trimLeft();
          break;
        case InputTrimType.right:
          stringValue = stringValue.trimRight();
          break;
        case InputTrimType.all:
          stringValue =
              stringValue.replaceAll(new RegExp(r"\s+\b|\b\s|\s|\b"), "");
          break;
        default:
      }
    }

    if (!acceptEmpty && stringValue.isEmpty) {
      throw ValidationException(
          'Value is empty', '""', value?.runtimeType ?? 'null');
    }

    validateMinMaxExact(stringValue.length, minLength, maxLength, length,
        checkedValueName: 'String length');

    if (inputTypes.isNotEmpty) {}

    validateAdditionalValidators(value);

    return value;
  }
}
