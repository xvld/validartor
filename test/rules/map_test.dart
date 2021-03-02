import 'package:test/test.dart';
import 'package:validartor/common/enums.dart';
import 'package:validartor/common/validation_exception.dart';
import 'package:validartor/validartor.dart';

import '../test_utils.dart';

void main() {
  final map = {
    'a': DynamicValidatorRule(nullable: false),
    'b': DynamicValidatorRule(nullable: false)
  };

  final correctMap = {'a': 5, 'b': 10};
  test('Should validate non nullable map value correctly', () {
    final validator = MapValidatorRule(map);

    expect(validator.validate(correctMap), correctMap);
    expect(() => validator.validate(null),
        throwsA(isA<MultiValidationException>()));
  });

  test('Should validate nullable map value correctly', () {
    final validator = MapValidatorRule(map, nullable: true);

    expect(validator.validate(null), null);
  });

  test(
      'Should validate nullable map value correctly and treat null as empty map',
      () {
    final validator =
        MapValidatorRule(map, nullable: true, treatNullAsEmptyMap: true);

    expect(validator.validate(null), {});
  });

  test('Should validate non map value correctly', () {
    final validator = MapValidatorRule(map);

    expect(
        () => validator.validate(1), throwsA(isA<MultiValidationException>()));
  });

  test('Should validate throw according to throw behaviour', () {
    final validator = MapValidatorRule(map);

    expect(
        () => validator.validate(1), throwsA(isA<MultiValidationException>()));
    validator.throwBehaviour = ThrowBehaviour.first;
    expect(() => validator.validate(1), throwsA(isA<ValidationException>()));
  });

  test('Should validate expected fields map correctly', () {
    final validator = MapValidatorRule(map,
        additionalExpectedFieldsMap: {'c': 15},
        throwBehaviour: ThrowBehaviour.first);

    expectValidationException(
        validator, correctMap, ValidationExceptionType.notAsExpected);

    expectValidationException(validator, {...correctMap, 'c': 14},
        ValidationExceptionType.notAsExpected);

    expectValidationException(validator, {...correctMap, 'c': '14'},
        ValidationExceptionType.notAsExpected);

    expect(
        validator.validate({...correctMap, 'c': 15}), {...correctMap, 'c': 15});
  });

  test('Should check for dissalowed keys', () {
    final validator = MapValidatorRule(map,
        disallowedKeys: ['c'], throwBehaviour: ThrowBehaviour.first);

    expectValidationException(validator, {...correctMap, 'c': 14},
        ValidationExceptionType.notAsExpected);

    expect(
        validator.validate({...correctMap, 'd': 15}), {...correctMap, 'd': 15});
  });

  test('Should check extra key behaviour', () {
    final validator = MapValidatorRule(map,
        throwBehaviour: ThrowBehaviour.first,
        extraFieldsBehaviour: MapExtraFieldsBehaviour.error);

    expectValidationException(validator, {...correctMap, 'd': 15},
        ValidationExceptionType.notAsExpected);

    validator.extraFieldsBehaviour = MapExtraFieldsBehaviour.remove;
    expect(validator.validate({...correctMap, 'd': 15}), correctMap);

    validator.extraFieldsBehaviour = MapExtraFieldsBehaviour.keep;
    expect(
        validator.validate({...correctMap, 'd': 15}), {...correctMap, 'd': 15});
  });
}
