import './base_rule.dart';

import '../mixins/min_max_validator.dart';
import '../mixins/additional_validators.dart';
import '../mixins/multi_exception_handler.dart';
import '../mixins/null_validator.dart';

import '../common/validation_exception.dart';
import '../common/enums.dart';

class BasicMapValidatorRule
    with
        MultiExceptionHandler,
        NullableValidation<Map<String, dynamic>>,
        AdditionalValidators,
        MinMaxExactValidation
    implements ValidatorRule<Map<String, dynamic>> {
  BasicMapValidatorRule(
      {this.expectedFieldsMap,
      bool nullable = false,
      bool treatNullAsEmptyMap = false,
      List<bool Function(dynamic)> additionalValidators = const [],
      this.extraFieldsBehaviour = MapExtraFieldsBehaviour.keep,
      this.disallowedKeys = const [],
      this.allowedKeys = const [],
      this.minNumOfKeys,
      this.maxNumOfKeys,
      ThrowBehaviour throwBehaviour = ThrowBehaviour.multi}) {
    this.nullable = nullable;
    this.throwBehaviour = throwBehaviour;
    this.additionalValidators = additionalValidators;

    treatNullAs = treatNullAsEmptyMap ? <String, dynamic>{} : null;
  }

  Map<String, dynamic> expectedFieldsMap;
  MapExtraFieldsBehaviour extraFieldsBehaviour; // Sanitizer

  List<String> allowedKeys;
  List<String> disallowedKeys;
  num minNumOfKeys;
  num maxNumOfKeys;

  @override
  Type type = Map;

  bool checkDisallowedListForKey(String key) {
    final isDisallowed = disallowedKeys.contains(key);
    if (isDisallowed) {
      handleException(ValidationException('Map contains disallowed key/s',
          'Not in [${disallowedKeys.join(',')}]', key,
          type: ValidationExceptionType.notAsExpected));
    }
    return isDisallowed;
  }

  String checkExtraFieldsBehaviour(String key, dynamic value) {
    switch (extraFieldsBehaviour) {
      case MapExtraFieldsBehaviour.error:
        handleException(ValidationException(
            'Map contains key $key', 'To not contain $key', value.toString(),
            type: ValidationExceptionType.notAsExpected));
        break;
      case MapExtraFieldsBehaviour.remove:
        return key;
        break;
      case MapExtraFieldsBehaviour.keep:
      default:
    }
    return null;
  }

  @override
  Map<String, dynamic> validate(dynamic value) {
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

    final valueKeys = convertedValue.keys;
    List<String> keysToRemove = [];

    try {
      validateMinMaxExact(valueKeys.length, minNumOfKeys, maxNumOfKeys, null,
          checkedValueName: 'Map keys');
    } on ValidationException catch (e) {
      handleException(e);
    }

    final expectedKeysMissing = expectedFieldsMap.keys
        .where((expectedKey) => !convertedValue.containsKey(expectedKey));

    if (expectedKeysMissing.isNotEmpty) {
      expectedKeysMissing.forEach((expectedKeyMissing) {
        handleException(ValidationException(
            'Value is missing a key $expectedKeyMissing',
            expectedKeyMissing,
            expectedKeyMissing?.toString()));
      });
    }

    convertedValue.forEach((String key, dynamic mapValue) {
      bool keyFound = false;

      if (expectedFieldsMap != null) {
        if (checkDisallowedListForKey(key)) {
          return;
        }

        if (expectedFieldsMap.containsKey(key) &&
            expectedFieldsMap[key] != mapValue) {
          handleException(ValidationException(
              'Value at $key is not as expected',
              expectedFieldsMap[key]?.toString(),
              mapValue?.toString()));
        } else if (expectedFieldsMap.containsKey(key) &&
            expectedFieldsMap[key] == mapValue) {
          keyFound = true;
        }

        if (!keyFound && allowedKeys.isNotEmpty && allowedKeys.contains(key)) {
          keyFound = true;
        }

        if (!keyFound) {
          if (checkExtraFieldsBehaviour(key, value) != null) {
            keysToRemove.add(key);
          }
        }
      } else if (allowedKeys.isNotEmpty) {
        if (checkDisallowedListForKey(key)) {
          return;
        }

        if (!keyFound && allowedKeys.contains(key)) {
          keyFound = true;
        }

        if (!keyFound) {
          if (checkExtraFieldsBehaviour(key, value) != null) {
            keysToRemove.add(key);
          }
        }
      } else {
        checkDisallowedListForKey(key);
      }
    });

    try {
      validateAdditionalValidators(value);
    } on ValidationException catch (e) {
      handleException(e);
    }

    throwMultiValidationExceptionIfExists();

    keysToRemove.forEach(convertedValue.remove);
    return convertedValue;
  }
}
