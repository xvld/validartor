import 'package:test/test.dart';
import 'package:validartor/rules/boolean.dart';
import 'package:validartor/common/validation_exception.dart';

import '../test_utils.dart';

void main() {
  test('Should validate non nullable boolean value correctly', () {
    final validator = BooleanValidatorRule();

    expect(validator.validate(true), true);
    expect(validator.validate(false), false);
    expectValidationException(validator, null, ValidationExceptionType.isNull);
  });

  test('Should validate nullable boolean value correctly', () {
    final validator = BooleanValidatorRule(nullable: true);

    expect(validator.validate(true), true);
    expect(validator.validate(null), null);
  });

  test('Should validate nullable boolean value correctly as false', () {
    final validator =
        BooleanValidatorRule(nullable: true, treatNullAsFalse: true);

    expect(validator.validate(true), true);
    expect(validator.validate(null), false);
  });

  test('Should validate truthy values correctly', () {
    final validator = BooleanValidatorRule(allowTruthyFalsyValues: true);

    expect(validator.validate('true'), true);
    expect(validator.validate('false'), false);
    expect(validator.validate(1), true);
    expect(validator.validate(0), false);
    expectValidationException(
        validator, 'a', ValidationExceptionType.cannotConvert);
  });

  test('Should validate overriden values correctly', () {
    final validator = BooleanValidatorRule(
        allowTruthyFalsyValues: true,
        truthyValues: ['yes'],
        falsyValues: ['no']);

    expect(validator.validate('yes'), true);
    expect(validator.validate('no'), false);
    expectValidationException(
        validator, 'true', ValidationExceptionType.cannotConvert);
    expectValidationException(
        validator, 0, ValidationExceptionType.cannotConvert);
  });

  test('Should validate expected boolean value correctly', () {
    final validator = BooleanValidatorRule(expected: true);

    expect(validator.validate(true), true);
    expectValidationException(
        validator, false, ValidationExceptionType.notAsExpected);
  });

  test('Should validate truthy expected boolean value correctly', () {
    final validator =
        BooleanValidatorRule(expected: true, allowTruthyFalsyValues: true);

    expect(validator.validate('true'), true);
    expectValidationException(
        validator, 'false', ValidationExceptionType.notAsExpected);
  });
}
