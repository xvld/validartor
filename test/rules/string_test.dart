import 'package:test/test.dart';
import 'package:validartor/common/validation_exception.dart';
import 'package:validartor/validartor.dart';

import '../test_utils.dart';

void main() {
  final emptyString = '';
  final testString = 'string';

  test('Should validate non nullable string value correctly', () {
    final validator = StringValidatorRule();

    expect(validator.validate(testString), testString);
    expect(validator.validate(emptyString), emptyString);

    expectValidationException(validator, null, ValidationExceptionType.isNull);
  });

  test('Should validate nullable string value correctly', () {
    final validator = StringValidatorRule(nullable: true);

    expect(validator.validate(null), null);
  });

  test('Should validate nullable string with treatNullAs value correctly', () {
    final validator =
        StringValidatorRule(nullable: true, treatNullAs: testString);

    expect(validator.validate(null), testString);
  });

  test('Should reject non string value', () {
    final validator = StringValidatorRule();

    expectValidationException(
        validator, true, ValidationExceptionType.invalidType);

    expectValidationException(
        validator, 1, ValidationExceptionType.invalidType);

    expectValidationException(
        validator, [], ValidationExceptionType.invalidType);

    expectValidationException(
        validator, {}, ValidationExceptionType.invalidType);
  });

  test('Should stringify string value correctly', () {
    final validator = StringValidatorRule(stringifyInput: true);

    expect(validator.validate(true), 'true');
    expect(validator.validate(1), '1');
    expect(validator.validate([]), '[]');
    expect(validator.validate({}), '{}');
  });

  test('Should validate empty string value correctly with & without input trim',
      () {
    final emptyStringWithSpaces = '   ';
    final validator = StringValidatorRule(acceptEmpty: false);

    expect(validator.validate(emptyStringWithSpaces), emptyStringWithSpaces);

    expectValidationException(
        validator, emptyString, ValidationExceptionType.notAsExpected);

    validator.inputTrim = InputTrimType.all;

    expectValidationException(validator, emptyStringWithSpaces,
        ValidationExceptionType.notAsExpected);
  });

  test('Should trim value correctly', () {
    final stringWithSpaces = ' $testString $testString ';

    final validator = StringValidatorRule(inputTrim: InputTrimType.all);

    expect(validator.validate(stringWithSpaces), '$testString$testString');
    validator.inputTrim = InputTrimType.both;
    expect(validator.validate(stringWithSpaces), '$testString $testString');
    validator.inputTrim = InputTrimType.left;
    expect(validator.validate(stringWithSpaces), '$testString $testString ');
    validator.inputTrim = InputTrimType.right;
    expect(validator.validate(stringWithSpaces), ' $testString $testString');
  });

  test('Should check must contain value correctly', () {
    final validator = StringValidatorRule(mustContain: 'str');

    expect(validator.validate(testString), testString);
    expectValidationException(validator, testString.replaceAll('str', 'abc'),
        ValidationExceptionType.notAsExpected);
  });

  test('Should check allowed values correctly', () {
    final validator =
        StringValidatorRule(allowedValues: [testString, testString + 'abc']);

    expect(validator.validate(testString), testString);
    expect(validator.validate(testString + 'abc'), testString + 'abc');

    expectValidationException(validator, testString.replaceAll('str', 'abc'),
        ValidationExceptionType.notAsExpected);
  });

  test('Should check length value correctly without inputTrim', () {
    final lengthTestString = ' abc def ';
    final validator = StringValidatorRule(length: 9);

    expect(validator.validate(lengthTestString), lengthTestString);
    expectValidationException(
        validator, testString, ValidationExceptionType.notAsExpected);

    validator.length = null;
    validator.minLength = 8;
    expect(validator.validate(lengthTestString), lengthTestString);
    expectValidationException(
        validator, testString, ValidationExceptionType.notAsExpected);

    validator.minLength = null;
    validator.maxLength = 8;
    expect(validator.validate(testString), testString);
    expectValidationException(
        validator, lengthTestString, ValidationExceptionType.notAsExpected);

    validator.minLength = 6;
    expect(validator.validate('123456'), '123456');
    expectValidationException(
        validator, testString, ValidationExceptionType.notAsExpected);

    expectValidationException(
        validator, lengthTestString, ValidationExceptionType.notAsExpected);
  });

  test('Should check length value correctly with inputTrim', () {
    final lengthTestString = ' abc def ';
    final validator =
        StringValidatorRule(length: 9, inputTrim: InputTrimType.all);

    expectValidationException(
        validator, lengthTestString, ValidationExceptionType.notAsExpected);

    validator.length = 6;
    expect(validator.validate(lengthTestString), 'abcdef');
  });
}
