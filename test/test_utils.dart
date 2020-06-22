import 'package:test/test.dart';
import 'package:validartor/common/validation_exception.dart';
import 'package:validartor/rules/base_rule.dart';

expectValidationException(
    ValidatorRule validator, dynamic value, ValidationExceptionType type) {
  try {
    validator.validate(value);
  } catch (e) {
    expect(e, isA<ValidationException>());
    expect((e as ValidationException).type, equals(type));
  }
}
