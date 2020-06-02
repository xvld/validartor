library validator;

abstract class ValidatorRule<T> {
  T validate(dynamic value);
}
