import 'package:test/test.dart';
import 'package:validartor/common/enums.dart';
import 'package:validartor/rules/map.dart';
import 'package:validartor/validation_exception.dart';

void main() {
  const map = {"a": "a", "b": 2, "c": null, "d": true};
  test('Should validate non nullable map value correctly', () {
    final validator = BasicMapValidatorRule();

    expect(validator.validate(map), map);
    expect(() => validator.validate(null),
        throwsA(isA<MultiValidationException>()));
    validator.throwBehaviour = ThrowBehaviour.first;
    expect(() => validator.validate(null), throwsA(isA<ValidationException>()));
  });

  test('Should validate nullable map value correctly', () {
    final validator = BasicMapValidatorRule(nullable: true);

    expect(validator.validate(null), null);
  });

  test('Should validate non map value correctly', () {
    final validator = BasicMapValidatorRule();

    expect(
        () => validator.validate(1), throwsA(isA<MultiValidationException>()));
  });

  test('Should validate minNumOfKeys map value correctly', () {
    final validator = BasicMapValidatorRule(minNumOfKeys: 1);
    expect(validator.validate(map), map);

    validator.minNumOfKeys = 5;
    expect(() => validator.validate(map),
        throwsA(isA<MultiValidationException>()));
  });

  test('Should validate maxNumOfKeys map value correctly', () {
    final validator = BasicMapValidatorRule(maxNumOfKeys: 5);
    expect(validator.validate(map), map);

    validator.maxNumOfKeys = 3;
    expect(() => validator.validate(map),
        throwsA(isA<MultiValidationException>()));
  });

  test('Should validate blacklistedKeys map value correctly', () {
    final validator = BasicMapValidatorRule(blacklistedKeys: ["e"]);
    expect(validator.validate(map), map);

    validator.blacklistedKeys = ["a"];
    expect(() => validator.validate(map),
        throwsA(isA<MultiValidationException>()));
  });

  test('Should validate expected map and keys', () {
    Map expectedMap = Map.from(map).cast<String, dynamic>();
    Map expectedMapWithExtra = Map.from(map).cast<String, dynamic>();
    expectedMapWithExtra['e'] = 'e';

    final validator = BasicMapValidatorRule(expectedFieldsMap: expectedMap);
    final validator2 =
        BasicMapValidatorRule(expectedFieldsMap: expectedMapWithExtra);
    expect(validator.validate(map), map);
    expect(() => validator2.validate(map),
        throwsA(isA<MultiValidationException>()));

    expectedMap.remove("a");
    expect(validator.validate(map), map);

    validator.extraFieldsBehaviour = MapExtraFieldsBehaviour.remove;
    expect(validator.validate(map), expectedMap);

    validator.extraFieldsBehaviour = MapExtraFieldsBehaviour.error;
    expect(() => validator.validate(map),
        throwsA(isA<MultiValidationException>()));

    validator.allowedKeys = ['a'];
    expect(validator.validate(map), map);
  });
}
