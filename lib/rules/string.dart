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
      this.stringifyInput = false,
      this.acceptEmpty = true,
      this.inputTrim = InputTrimType.none,
      this.length,
      this.minLength,
      this.maxLength,
      this.mustContain,
      this.allowedPatterns = const [],
      this.allowedInputTypes = const [],
      this.allowedValues = const [],
      List<bool Function(dynamic)> additionalValidators = const []}) {
    this.nullable = nullable;
    this.treatNullAs = treatNullAs;
    this.additionalValidators = additionalValidators;
  }

  bool stringifyInput;
  bool acceptEmpty;
  InputTrimType inputTrim; // Sanitizer

  num length;
  num minLength;
  num maxLength;

  String mustContain;

  List<InputType> allowedInputTypes;
  List<RegExp> allowedPatterns;

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

  void _validateInputTypes(String convertedValue) {
    List<InputType> failedInputTypeValidators = <InputType>[];
    List<RegExp> failedPatternValidators = <RegExp>[];

    final anyInputTypesPassed = !allowedInputTypes.any((allowedInputType) {
      if (!_inputTypeToRegExp[allowedInputType].hasMatch(convertedValue)) {
        failedInputTypeValidators.add(allowedInputType);
        return false;
      }

      return true;
    });

    bool additionalAllowedPatternsPassed = false;

    if (allowedPatterns.isNotEmpty) {
      additionalAllowedPatternsPassed = allowedPatterns.any((allowedPattern) {
        if (!allowedPattern.hasMatch(convertedValue)) {
          failedPatternValidators.add(allowedPattern);
          return false;
        }

        return true;
      });
    }

    if (!anyInputTypesPassed && !additionalAllowedPatternsPassed) {
      final List<String> failedInputs = [
        ...failedPatternValidators.map((f) => f.pattern),
        ...failedInputTypeValidators.map((f) => f.toString())
      ];

      throw ValidationException(
          'Value did not pass any custom input types or pattern validation',
          'At least one input type validation or pattern should pass',
          'Input types validations ${failedInputs.join(',')} did not pass',
          type: ValidationExceptionType.customValidator);
    }
  }

  String _trimInput(String convertedValue) {
    switch (inputTrim) {
      case InputTrimType.both:
        return convertedValue.trim();
        break;
      case InputTrimType.left:
        return convertedValue.trimLeft();
        break;
      case InputTrimType.right:
        return convertedValue.trimRight();
        break;
      case InputTrimType.all:
        return convertedValue.replaceAll(RegExp(r'\s+\b|\b\s|\s|\b'), '');
        break;
      default:
        return convertedValue;
    }
  }

  @override
  String validate(dynamic value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(type);
    } else if (nullable && value == null) {
      return treatNullAs;
    }
    String convertedValue;

    if (!(value is String) && !stringifyInput) {
      throw ValidationException.invalidType(type, value.runtimeType as Type);
    } else if (!(value is String) && stringifyInput) {
      convertedValue = value.toString();
    } else {
      convertedValue = value as String;
    }

    if (inputTrim != InputTrimType.none) {
      convertedValue = _trimInput(convertedValue);
    }

    if (!acceptEmpty && convertedValue.isEmpty) {
      throw ValidationException.notAsExpected('Non empty string', '');
    }

    if (mustContain != null && !convertedValue.contains(mustContain)) {
      throw ValidationException.notAsExpected(
          'Must contain $mustContain', convertedValue);
    }

    if (allowedValues.isNotEmpty &&
        !allowedValues.any((allowedValue) => convertedValue == allowedValue)) {
      throw ValidationException.notAsExpected(
          'Value must be one of ${allowedValues.join(',')}', convertedValue);
    }

    validateMinMaxExact(convertedValue.length, minLength, maxLength, length,
        checkedValueName: 'String length');

    if (allowedInputTypes.isNotEmpty) {
      _validateInputTypes(convertedValue);
    }

    validateAdditionalValidators(value);

    return convertedValue;
  }
}
