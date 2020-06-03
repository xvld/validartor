library validator;

abstract class ValidatorRule<T> {
  T validate(dynamic value);

  Type type = T;
}
