import 'package:validartor/base_rule.dart';
import 'package:validartor/validation_exception.dart';

enum InputTrimType { left, right, both, all, none }
enum InputType { alphabetic, numeric, alphaNumeric, lowerCase, upperCase }

class StringValidatorRule implements ValidatorRule<String> {
  StringValidatorRule(
      {this.nullable = false,
      this.treatNullAs = null,
      this.acceptEmpty = true,
      this.inputTrim = InputTrimType.none,
      this.length = double.infinity,
      this.minLength = double.negativeInfinity,
      this.maxLength = double.infinity,
      this.pattern,
      this.mustContain,
      this.inputTypes = const [],
      this.ignoredCharsInInputTypeChecks = const [],
      this.allowedValues = const []});

  bool nullable;
  String treatNullAs; // Sanitizer
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
      throw ValidationException.nullException(
          type.toString(), value?.runtimeType ?? 'null');
    } else if (nullable && value == null) {
      return treatNullAs;
    }

    if (!(value is String)) {
      throw ValidationException('Value is not a string', type.toString(),
          value?.runtimeType ?? 'null');
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

    if (length != null && stringValue.length != length) {
      throw ValidationException('String length does not match',
          length.toString(), stringValue.length.toString());
    }

    if (stringValue.length < minLength) {
      throw ValidationException('String length does not match', '>= $minLength',
          stringValue.length.toString());
    }

    if (maxLength != null && stringValue.length > maxLength) {
      throw ValidationException('String length does not match', '<= $maxLength',
          stringValue.length.toString());
    }

    if (inputTypes.isNotEmpty) {}

    return value;
  }
}
