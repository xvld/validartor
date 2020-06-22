import '../common/validation_exception.dart';

mixin AdditionalValidators {
  List<bool Function(dynamic)> additionalValidators = [];

  validateAdditionalValidators(dynamic value) {
    List<num> failedValidators = [];

    if (additionalValidators.isNotEmpty &&
        !additionalValidators.fold(true, (foldValue, validator) {
          bool validatorResult = false;
          try {
            validatorResult = validator(value);
          } catch (e) {
            print('Additional validator threw an exception $e');
          }

          if (validatorResult == false) {
            failedValidators.add(additionalValidators.indexOf(validator));
          }

          return foldValue && validatorResult;
        })) {
      throw ValidationException.customValidator(
          failedValidatorsIndices: failedValidators);
    }
  }
}
