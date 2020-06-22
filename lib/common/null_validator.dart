import '../common/validation_exception.dart';

mixin NullValidator<T> {
  bool nullable;
  T treatNullAs = null;

  validateNullable(dynamic value) {
    if (!nullable && value == null) {
      throw ValidationException.nullException(T);
    } else if (nullable && value == null) {
      return treatNullAs;
    }
  }
}
