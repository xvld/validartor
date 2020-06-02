import 'package:test/test.dart';
import 'package:validartor/rules/boolean.dart';
import 'package:validartor/validation_exception.dart';

void main() {
  test('Should validate non nullable boolean value correctly', () {
    final validator = BooleanValidatorRule();

    expect(validator.validate(true), true);
    expect(validator.validate(false), false);
    expect(() => validator.validate(null), throwsA(isA<ValidationException>()));
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
    expect(() => validator.validate('a'), throwsA(isA<ValidationException>()));
  });

  test('Should validate overriden values correctly', () {
    final validator = BooleanValidatorRule(
        allowTruthyFalsyValues: true,
        truthyValues: ['yes'],
        falsyValues: ['no']);

    expect(validator.validate('yes'), true);
    expect(validator.validate('no'), false);
    expect(
        () => validator.validate('true'), throwsA(isA<ValidationException>()));
    expect(
        () => validator.validate('false'), throwsA(isA<ValidationException>()));
  });

  test('Should validate expected boolean value correctly', () {
    final validator = BooleanValidatorRule(expected: true);

    expect(validator.validate(true), true);
    expect(
        () => validator.validate(false), throwsA(isA<ValidationException>()));
  });

  test('Should validate truthy expected boolean value correctly', () {
    final validator =
        BooleanValidatorRule(expected: true, allowTruthyFalsyValues: true);

    expect(validator.validate('true'), true);
    expect(
        () => validator.validate('false'), throwsA(isA<ValidationException>()));
  });
}
