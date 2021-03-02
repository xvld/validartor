import './base_rule.dart';
import './basic_map.dart';

import '../common/enums.dart';
import '../common/validation_exception.dart';

class MapValidatorRule extends BasicMapValidatorRule
    implements ValidatorRule<Map<String, dynamic>> {
  MapValidatorRule(this.validationMap,
      {bool nullable = false,
      MapExtraFieldsBehaviour extraFieldsBehaviour =
          MapExtraFieldsBehaviour.keep,
      List<String> disallowedKeys = const [],
      Map<String, dynamic> additionalExpectedFieldsMap = const {},
      bool treatNullAsEmptyMap = false,
      ThrowBehaviour throwBehaviour = ThrowBehaviour.multi})
      : super(
            throwBehaviour: throwBehaviour,
            expectedFieldsMap: additionalExpectedFieldsMap,
            nullable: nullable,
            extraFieldsBehaviour: extraFieldsBehaviour,
            disallowedKeys: disallowedKeys,
            treatNullAsEmptyMap: treatNullAsEmptyMap) {
    assert(validationMap.keys
        .toList()
        .every((key) => !disallowedKeys.contains(key)));
    assert(expectedFieldsMap?.keys
            ?.toList()
            ?.every((key) => !disallowedKeys.contains(key)) ??
        true);
  }

  final Map<String, ValidatorRule> validationMap;

  @override
  Type type = Map;

  @override
  Map<String, dynamic> validate(value) {
    initValidationExceptionHandler('Map validation failed');

    try {
      if (validateNullable(value)) {
        return treatNullAs;
      }
    } on ValidationException catch (e) {
      throw handleException(e);
    }

    if (!(value is Map)) {
      throw handleException(
          ValidationException.invalidType(type, value.runtimeType));
    }

    final convertedValue =
        Map<dynamic, dynamic>.from(value as Map<dynamic, dynamic>)
            .cast<String, dynamic>();

    List<String> keysToRemove = [];

    final expectedKeysMissing = [
      ...expectedFieldsMap.keys,
      ...validationMap.keys
    ].where((expectedKey) => !convertedValue.containsKey(expectedKey));

    if (expectedKeysMissing.isNotEmpty) {
      expectedKeysMissing.forEach((expectedKeyMissing) {
        handleException(ValidationException(
            'Value is missing a key $expectedKeyMissing',
            expectedKeyMissing,
            expectedKeyMissing?.toString(),
            type: ValidationExceptionType.notAsExpected));
      });
    }

    convertedValue.forEach((key, internalValue) {
      if (checkDisallowedListForKey(key)) {
        return;
      }

      final validator = validationMap[key];

      if (validator == null) {
        if (expectedFieldsMap[key] != null &&
            (expectedFieldsMap[key].runtimeType != internalValue.runtimeType ||
                expectedFieldsMap[key] != internalValue)) {
          handleException(ValidationException.notAsExpected(
              expectedFieldsMap[key]?.toString(), internalValue?.toString()));
        } else if (checkExtraFieldsBehaviour(key, internalValue) != null) {
          keysToRemove.add(key);
        }

        return;
      }

      try {
        validator.validate(convertedValue[key]);
      } on ValidationException catch (exception) {
        handleException(exception, fieldName: key);
      } on MultiValidationException catch (multiException) {
        handleMultiException(multiException, fieldName: key);
      }
    });

    throwMultiValidationExceptionIfExists();

    keysToRemove.forEach(convertedValue.remove);

    return convertedValue;
  }
}
