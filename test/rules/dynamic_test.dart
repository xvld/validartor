import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validator/rules/dynamic.dart';
import 'package:validator/validation_exception.dart';

void main() {
  test('validates non nullable dynamic value correctly', () {
    final validator = DynamicValidatorRule();

    expect(validator.validate(5), true);
    expect(() => validator.validate(null), throwsA(isA<ValidationException>()));
  });

  test('validates nullable dynamic value correctly', () {
    final validator = DynamicValidatorRule()..nullable = true;

    expect(validator.validate(5), true);
    expect(validator.validate(null), true);
  });

  test('validates additional validators correctly', () {
    final validator =
        DynamicValidatorRule(additionalValidators: [(value) => value is int]);

    expect(validator.validate(5), true);
    expect(() => validator.validate('string'),
        throwsA(isA<ValidationException>()));
  });
}
