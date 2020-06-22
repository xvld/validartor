import 'package:validartor/common/min_max_validator.dart';

import './base_rule.dart';
import '../common/additional_validators.dart';
import '../common/enums.dart';
import '../common/multi_exception_handler.dart';
import '../common/null_validator.dart';
import '../common/validation_exception.dart';

class BasicMapValidatorRule
    with
        MultiExceptionHandler,
        NullValidator<Map<String, dynamic>>,
        AdditionalValidators,
        MinMaxValidator
    implements ValidatorRule<Map<String, dynamic>> {
  BasicMapValidatorRule(
      {this.expectedFieldsMap = null,
      nullable = false,
      treatNullAsEmptyMap = false,
      additionalValidators = const [],
      this.extraFieldsBehaviour = MapExtraFieldsBehaviour.keep,
      this.blacklistedKeys = const [],
      this.allowedKeys = const [],
      this.minNumOfKeys = 0,
      this.maxNumOfKeys = double.infinity,
      ThrowBehaviour throwBehaviour = ThrowBehaviour.multi}) {
    this.nullable = nullable;
    this.treatNullAs = treatNullAsEmptyMap ? {} : null;
    this.throwBehaviour = throwBehaviour;
    this.additionalValidators = additionalValidators;
  }

  Map<String, dynamic> expectedFieldsMap;
  MapExtraFieldsBehaviour extraFieldsBehaviour; // Sanitizer

  List<String> allowedKeys;
  List<String> blacklistedKeys;
  num minNumOfKeys;
  num maxNumOfKeys;

  Type type = Map;

  Map<String, dynamic> validate(value) {
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

    final valueMap = Map.from(value).cast<String, dynamic>();
    final valueKeys = valueMap.keys;
    List<String> keysToRemove = [];

    try {
      validateMinMaxExact(valueKeys.length, minNumOfKeys, maxNumOfKeys, null,
          checkedValueName: 'Map keys');
    } on ValidationException catch (e) {
      handleException(e);
    }

    final checkBlacklistForKey = (String key) {
      if (blacklistedKeys.contains(key)) {
        handleException(ValidationException('Map contains blacklisted key/s',
            'Not in ${blacklistedKeys.join(',')}', value.toString()));
      }
    };

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

    valueMap.forEach((key, mapValue) {
      bool keyFound = false;

      if (expectedFieldsMap != null) {
        final expectedKeysMissing = expectedFieldsMap.keys
            .where((expectedKey) => !valueMap.containsKey(expectedKey));

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
              expectedFieldsMap[key],
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

    keysToRemove.forEach(valueMap.remove);
    return valueMap;
  }
}

class MapValidatorRule extends BasicMapValidatorRule
    implements ValidatorRule<Map<String, dynamic>> {
  MapValidatorRule(this.validationMap,
      {bool nullable = false,
      MapExtraFieldsBehaviour extraFieldsBehaviour =
          MapExtraFieldsBehaviour.keep,
      List<String> blacklistedKeys = const [],
      Map<String, dynamic> additionalExpectedFieldsMap = null,
      ThrowBehaviour throwBehaviour = ThrowBehaviour.multi})
      : super(
          throwBehaviour: throwBehaviour,
          expectedFieldsMap: additionalExpectedFieldsMap,
          nullable: nullable,
          extraFieldsBehaviour: extraFieldsBehaviour,
          blacklistedKeys: blacklistedKeys,
        );

  // TODO: see combinations and throw errors on invalid prop combinations

  final Map<String, ValidatorRule> validationMap;

  void withAdditionalExactFields(
      Map<String, dynamic> additionalExpectedFieldsMap) {
    expectedFieldsMap = additionalExpectedFieldsMap;
  }

  Type type = Map;

  @override
  Map<String, dynamic> validate(value) {
    try {
      super.validate(value);
    } on MultiValidationException catch (_) {}

    if (!(value is Map<String, ValidatorRule>)) {
      // return false;
    }

    if (!(value is Map<String, dynamic>)) {
      // return false;
    }

    validationMap.forEach((key, validator) {
      validator.validate(value[key]);
    });

    throwMultiValidationExceptionIfExists();

    return value;
  }
}
