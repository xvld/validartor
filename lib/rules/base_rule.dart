abstract class ValidatorRule<T> {
  T validate(dynamic value);

  final Type type = T;
}
