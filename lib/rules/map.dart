import '../mixins/min_max_validator.dart';

import './base_rule.dart';
import '../mixins/additional_validators.dart';
import '../common/enums.dart';
import '../mixins/multi_exception_handler.dart';
import '../mixins/null_validator.dart';
import '../common/validation_exception.dart';

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

  bool checkBlacklistForKey(String key) {
    final isDisallowed = disallowedKeys.contains(key);
    if (isDisallowed) {
      handleException(ValidationException('Map contains disallowed key/s',
          'Not in [${disallowedKeys.join(',')}]', key));
    }
    return isDisallowed;
  }

  @override
  Map<String, dynamic> validate(dynamic value) {
    initExceptionHandler('Map validation failed');

    try {
      if (validateNullable(value)) {
        return treatNullAs;
      }
    } on ValidationException catch (e) {
      throw handleException(e);
    }

    if (!(value is Map)) {
      throw handleException(ValidationException('Value is not a Map',
          type.toString(), value?.runtimeType?.toString() ?? 'null'));
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

    final checkExtraFieldsBehaviour = (String key) {
      switch (extraFieldsBehaviour) {
        case MapExtraFieldsBehaviour.error:
          handleException(ValidationException('Map contains key $key',
              'To not contain $key', value.toString()));
          break;
        case MapExtraFieldsBehaviour.remove:
          keysToRemove.add(key);
          break;
        case MapExtraFieldsBehaviour.keep:
        default:
      }
    };

    convertedValue.forEach((String key, dynamic mapValue) {
      bool keyFound = false;

      if (expectedFieldsMap != null) {
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

        checkBlacklistForKey(key);

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
          checkExtraFieldsBehaviour(key);
        }
      } else if (allowedKeys.isNotEmpty) {
        checkBlacklistForKey(key);

        if (!keyFound && allowedKeys.contains(key)) {
          keyFound = true;
        }

        if (!keyFound) {
          checkExtraFieldsBehaviour(key);
        }
      } else {
        checkBlacklistForKey(key);
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

class MapValidatorRule extends BasicMapValidatorRule
    implements ValidatorRule<Map<String, dynamic>> {
  MapValidatorRule(this.validationMap,
      {bool nullable = false,
      MapExtraFieldsBehaviour extraFieldsBehaviour =
          MapExtraFieldsBehaviour.keep,
      List<String> blacklistedKeys = const [],
      Map<String, dynamic> additionalExpectedFieldsMap,
      ThrowBehaviour throwBehaviour = ThrowBehaviour.multi})
      : super(
          throwBehaviour: throwBehaviour,
          expectedFieldsMap: additionalExpectedFieldsMap,
          nullable: nullable,
          extraFieldsBehaviour: extraFieldsBehaviour,
          disallowedKeys: blacklistedKeys,
        );

  // TODO: see combinations and throw errors on invalid prop combinations

  final Map<String, ValidatorRule> validationMap;

  void withAdditionalExactFields(
      Map<String, dynamic> additionalExpectedFieldsMap) {
    expectedFieldsMap = additionalExpectedFieldsMap;
  }

  @override
  Type type = Map;

  @override
  Map<String, dynamic> validate(value) {
    initExceptionHandler('Map validation failed');

    if (!nullable && value == null) {
      throw handleException(ValidationException.nullException(type));
    } else if (nullable && value == null) {
      return value;
    }

    if (!(value is Map)) {
      throw handleException(ValidationException('Value is not a Map',
          type.toString(), value?.runtimeType?.toString() ?? 'null'));
    }

    validationMap.forEach((key, validator) {
      try {
        if (!checkBlacklistForKey(key)) {
          validator.validate(value[key]);
        }
      } on ValidationException catch (exception) {
        handleException(exception, fieldName: key);
      } on MultiValidationException catch (multiException) {
        handleMultiException(multiException, fieldName: key);
      }
    });

    throwMultiValidationExceptionIfExists();

    return value;
  }
}
