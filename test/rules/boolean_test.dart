import 'package:test/test.dart';
import 'package:validartor/rules/boolean.dart';
import 'package:validartor/validation_exception.dart';

void main() {
  test('Should validate non nullable boolean value correctly', () {
    final validator = BooleanValidatorRule();

    expect(validator.validate(true), true);
    expect(() => validator.validate(null), throwsA(isA<ValidationException>()));
  });

  test('Should validate nullable boolean value correctly', () {
    final validator = BooleanValidatorRule(nullable: true);

    expect(validator.validate(true), true);
    expect(validator.validate(null), true);
  });

  test('Should validate truthy values correctly', () {
    final validator = BooleanValidatorRule(allowTruthyValues: true);

    expect(validator.validate('true'), true);
    expect(validator.validate('false'), true);
    expect(validator.validate(1), true);
    expect(validator.validate(0), true);
    expect(() => validator.validate('a'), throwsA(isA<ValidationException>()));
  });

  test('Should validate expected boolean value correctly', () {
    final validator = BooleanValidatorRule(expected: true);

    expect(validator.validate(true), true);
    expect(
        () => validator.validate(false), throwsA(isA<ValidationException>()));
  });

  test('Should validate truthy expected boolean value correctly', () {
    final validator =
        BooleanValidatorRule(expected: true, allowTruthyValues: true);

    expect(validator.validate('true'), true);
    expect(
        () => validator.validate('false'), throwsA(isA<ValidationException>()));
  });
}
