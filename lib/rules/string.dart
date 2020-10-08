import '../mixins/min_max_validator.dart';
import './base_rule.dart';
import '../mixins/additional_validators.dart';
import '../mixins/null_validator.dart';
import '../common/validation_exception.dart';

enum InputTrimType { left, right, both, all, none }
enum InputType { alphabetic, numeric, alphaNumeric, lowerCase, upperCase }

class StringValidatorRule
    with NullableValidation<String>, AdditionalValidators, MinMaxExactValidation
    implements ValidatorRule<String> {
  StringValidatorRule(
      {bool nullable = false,
      String treatNullAs,
      this.acceptEmpty = true,
      this.inputTrim = InputTrimType.none,
      this.length,
      this.minLength,
      this.maxLength,
      this.pattern,
      this.mustContain,
      this.inputTypes = const [],
      this.ignoredCharsInInputTypeChecks = const [],
      this.allowedValues = const [],
      List<bool Function(dynamic)> additionalValidators = const []}) {
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

  @override
  Type type = String;

  static final Map<InputType, RegExp> _inputTypeToRegExp = {
    InputType.alphabetic: RegExp(r'[A-Za-z\s]*'),
    InputType.alphaNumeric: RegExp(r'[\w\s]*'),
    InputType.numeric: RegExp(r'^-?[0-9]\d*(\.\d+)?$'),
    InputType.lowerCase: RegExp(r'[a-z\d\s]*'),
    InputType.upperCase: RegExp(r'[A-Z\d\s]*')
  };

  @override
  String validate(dynamic value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(type);
    } else if (nullable && value == null) {
      return treatNullAs;
    }

    if (!(value is String)) {
      throw ValidationException.invalidType(type, value.runtimeType as Type);
    }

    String convertedValue = value as String;

    if (inputTrim != InputTrimType.none) {
      switch (inputTrim) {
        case InputTrimType.both:
          convertedValue = convertedValue.trim();
          break;
        case InputTrimType.left:
          convertedValue = convertedValue.trimLeft();
          break;
        case InputTrimType.right:
          convertedValue = convertedValue.trimRight();
          break;
        case InputTrimType.all:
          convertedValue =
              convertedValue.replaceAll(RegExp(r'\s+\b|\b\s|\s|\b'), '');
          break;
        default:
      }
    }

    if (!acceptEmpty && convertedValue.isEmpty) {
      throw ValidationException(
          'Value is empty', '""', value?.runtimeType as String ?? 'null');
    }

    validateMinMaxExact(convertedValue.length, minLength, maxLength, length,
        checkedValueName: 'String length');

    if (inputTypes.isNotEmpty) {}

    validateAdditionalValidators(value);

    return convertedValue;
  }
}
