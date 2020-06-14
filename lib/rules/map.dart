import 'package:validartor/base_rule.dart';
import 'package:validartor/common/enums.dart';

import '../validation_exception.dart';

class BasicMapValidatorRule implements ValidatorRule<Map<String, dynamic>> {
  BasicMapValidatorRule(
      {this.expectedFieldsMap = null,
      this.nullable = false,
      this.extraFieldsBehaviour = MapExtraFieldsBehaviour.keep,
      this.blacklistedKeys = const [],
      this.allowedKeys = const [],
      this.minNumOfKeys = 0,
      this.maxNumOfKeys = double.infinity,
      this.throwBehaviour = ThrowBehaviour.multi});

  Map<String, dynamic> expectedFieldsMap;
  bool nullable;
  MapExtraFieldsBehaviour extraFieldsBehaviour; // Sanitizer
  ThrowBehaviour throwBehaviour;

  List<String> allowedKeys;
  List<String> blacklistedKeys;
  num minNumOfKeys;
  num maxNumOfKeys;

  @override
  Type type = Map;

  handleException(MultiValidationException multiValidationException,
      ValidationException exception) {
    if (throwBehaviour == ThrowBehaviour.first) {
      throw exception;
    }

    multiValidationException.exceptions.add(exception);
    return multiValidationException;
  }

  @override
  Map<String, dynamic> validate(value) {
    MultiValidationException multiValidationException =
        MultiValidationException('Map validation failed', []);

    if (!nullable && value == null) {
      throw handleException(
          multiValidationException,
          ValidationException.nullException(
              type.toString(), value?.runtimeType?.toString() ?? 'null'));
    } else if (nullable && value == null) {
      return value;
    }

    if (!(value is Map)) {
      throw handleException(
          multiValidationException,
          ValidationException('Value is not a Map', type.toString(),
              value?.runtimeType?.toString() ?? 'null'));
    }

    final valueMap = Map.from(value).cast<String, dynamic>();
    final valueKeys = valueMap.keys;
    List<String> keysToRemove = [];

    if (valueKeys.length > maxNumOfKeys) {
      handleException(
          multiValidationException,
          ValidationException('Map keys exceed maxNumOfKeys',
              '<= $maxNumOfKeys', valueKeys.length.toString()));
    }

    if (valueKeys.length < minNumOfKeys) {
      handleException(
          multiValidationException,
          ValidationException('Map keys below minNumOfKeys', '>= $minNumOfKeys',
              valueKeys.length.toString()));
    }

    final checkBlacklistForKey = (String key) {
      if (blacklistedKeys.contains(key)) {
        return handleException(
            multiValidationException,
            ValidationException('Map contains blacklisted key/s',
                'Not in ${blacklistedKeys.join(',')}', value.toString()));
      }
    };

    final checkExtraFieldsBehaviour = (String key) {
      switch (extraFieldsBehaviour) {
        case MapExtraFieldsBehaviour.error:
          handleException(
              multiValidationException,
              ValidationException('Map contains key $key',
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
            handleException(
                multiValidationException,
                ValidationException(
                    'Value is missing a key $expectedKeyMissing',
                    expectedKeyMissing,
                    expectedKeyMissing?.toString()));
          });
        }

        checkBlacklistForKey(key);

        if (expectedFieldsMap.containsKey(key) &&
            expectedFieldsMap[key] != mapValue) {
          handleException(
              multiValidationException,
              ValidationException('Value at $key is not as expected',
                  expectedFieldsMap[key], mapValue?.toString()));
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

    if (multiValidationException.exceptions.isNotEmpty) {
      throw multiValidationException;
    }

    keysToRemove.forEach(valueMap.remove);
    return valueMap;
  }
}

class MapValidatorRule extends BasicMapValidatorRule
    implements ValidatorRule<Map<String, dynamic>> {
  MapValidatorRule(
    this.validationMap, {
    bool nullable = false,
    MapExtraFieldsBehaviour extraFieldsBehaviour = MapExtraFieldsBehaviour.keep,
    List<String> blacklistedKeys = const [],
    num minNumOfKeys,
    num maxNumOfKeys = double.infinity,
    Map<String, dynamic> additionalExpectedFieldsMap = null,
  }) : super(
          expectedFieldsMap: additionalExpectedFieldsMap,
          nullable: nullable,
          extraFieldsBehaviour: extraFieldsBehaviour,
          blacklistedKeys: blacklistedKeys,
          minNumOfKeys: minNumOfKeys,
          maxNumOfKeys: maxNumOfKeys,
        );

  // TODO: see combinations and throw errors on invalid prop combinations

  final Map<String, ValidatorRule> validationMap;

  @override
  Type type = Map;

  @override
  Map<String, dynamic> validate(value) {
    if (!(value is Map<String, ValidatorRule>)) {
      // return false;
    }

    if (!(value is Map<String, dynamic>)) {
      // return false;
    }

    validationMap.forEach((key, validator) {
      validator.validate(value[key]);
    });

    return value;
  }
}
