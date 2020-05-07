library validator;

abstract class ValidatorRule<T> {
  bool validate(dynamic value);
}
