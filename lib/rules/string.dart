import 'package:validartor/base_rule.dart';
import 'package:validartor/validation_exception.dart';

enum InputRemoveSpaces { left, right, both, all, none }
enum InputType { alphabetic, numeric, alphaNumeric, lowerCase, upperCase }

class StringValidatorRule implements ValidatorRule<String> {
  StringValidatorRule(
      {this.nullable = false,
      this.acceptEmpty = true,
      this.inputTrim = InputRemoveSpaces.none,
      this.length = double.infinity,
      this.minLength = double.negativeInfinity,
      this.maxLength = double.infinity,
      this.pattern,
      this.contains,
      this.inputTypes = const [],
      this.ignoredCharsInInputTypeChecks = const [],
      this.allowedValues = const []});

  bool nullable;
  bool acceptEmpty;
  InputRemoveSpaces inputTrim;

  num length;
  num minLength;
  num maxLength;

  String pattern;
  String contains;

  List<InputType> inputTypes;

  List<String> ignoredCharsInInputTypeChecks;

  List<String> allowedValues;

  @override
  Type type = String;

  @override
  String validate(value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(
          type.toString(), value?.runtimeType ?? 'null');
    }

    return value;
  }
}
