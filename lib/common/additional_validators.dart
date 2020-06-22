import '../common/validation_exception.dart';

/// Allows adding additional validators to the ValidatorRule
///
/// Should be used inside validate(dynamic value) function
mixin AdditionalValidators {
  /// The list of additional validators to check against
  List<bool Function(dynamic)> additionalValidators = [];

  /// Validates the values against the additional validators provided
  ///
  /// If any error should occur in a custom validator, it will count as a failure
  /// Throws a [ValidationException] if any of the validators fail
  validateAdditionalValidators(dynamic value) {
    List<int> failedValidators = [];

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
