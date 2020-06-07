# vali*dart*or ✅

An easy to use and extendable input validator library written in pure dart, with no extra dependencies

Inspired by [fastest-validator](https://github.com/icebob/fastest-validator) for nodeJs by [icebob](https://github.com/icebob).

### **This repository is still a WIP**

## Proposed Usage

```dart
final mapValidator = MapValidatorRule({
  "id" : NumberValidatorRule(integer: true, allowStringValues: true),
  "someNullFieldThatShouldntBeReturned": NullValidatorRule(),
  "someNullFieldThatShouldntBeReturnedShorthand": null,
  "exactValue": "value",
  "admin": BooleanValidatorRule(nullable: true, treatNullAsFalse: true, allowTruthyFalsyValues: true),
  "extra": DynamicValidatorRule(nullable: true, additionalValidators: [(value) => value != 'undefined']),
  "age": NumberValidatorRule(integer: true, allowStringValues: true, onlyPositive: true,),
  "userType": StringValidatorRule(nullable: true, treatNullAs: "normal", allowedValues: UserType.values),
  "stringList": ListValidatorRule<String>(),
  "stringOrBoolOrNumber": MultiValidatorRule([StringValidatorRule(), NumberValidatorRule(), BooleanValidatorRule()]),
  "dynamicList": ListValidatorRule<dynamic>(rule: MultiValidatorRule([StringValidatorRule(), NumberValidatorRule()])),
  "someDynamicMapThatWeDontCareALotAbout": MapValidatorRule.simple(blacklistedKeys: ["admin"]),
  "nestedObject": MapValidatorRule({
    "id" : NumberValidatorRule(integer: true, allowStringValues: true),
    ...
  })
})

// validatedMap will hold the output, sanitized

try {
  final validatedMap = mapValidator.validate({
    "id" : 1,
    "someNullFieldThatShouldntBeReturned": null,
    "exactValue": "value",
    "admin": true,
    "extra": "any value",
    "age": 25,
    "userType": "normal",
    "stringList": ["a", "b"],
    "stringOrBoolOrNumber": true,
    "dynamicList": [1, "a", 2, "b"],
    "someDynamicMapThatWeDontCareALotAbout": {
      "a": "b"
    },
    "nestedObject": {
      "id": 1
    }
  })
} on MultiValidationException catch (e) {
  // Handle multiple objects mismatch
}

try {
  // Can also be used to validate only one value
  ListValidatorRule<String>().validate("1")
} on ValidationException catch (e) {
  // Handle single validation exception
}

```

## Roadmap

- [ ] Basic validation rules:
  - [x] boolean
  - [x] dynamic (any value)
  - [x] number
  - [x] null
  - [ ] string **WIP**
- [ ] Advanced validation rules:
  - [x] Multi
  - [ ] List **WIP**
  - [ ] Map **WIP**
- [ ] Exact validation rule ({"a": "b"}) without rule shorthand
- [ ] Allow creation of schemas for validation
- [ ] 0.1.0
- [ ] Tests and complete coverage
- [ ] Readme and usage
- [ ] Publish 🎉

## Rules

### Dynamic (Any value)

| Property               | Default | Type                           | Description                   | Sanitizer                                |
| ---------------------- | ------- | ------------------------------ | ----------------------------- | ---------------------------------------- |
| `nullable`             | `false` | `bool`                         | Whether the value can be null | ❌                                       |
| `additionalValidators` | `[]`    | `List<bool Function(dynamic)>` | Additional validators to run  | ❌/✅ (Depending on your implementation) |

### Null

A shorthand validator to ensure null value

### Boolean

| Property                 | Default        | Type            | Description                                                                                                            | Sanitizer                          |
| ------------------------ | -------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `nullable`               | `false`        | `bool`          | Whether the value can be null                                                                                          | ❌                                 |
| `treatNullAsFalse`       | `false`        | `bool`          | Whether null values will be treated as false                                                                           | ✅                                 |
| `allowTruthyFalsyValues` | `false`        | `bool`          | if `true`, allows for truthy and falsy values according to `truthyValues` and `falsyValues` parameters, or the default | ✅                                 |
| `expected`               | `null`         | `bool`          | The expected value.                                                                                                    | ❌                                 |
| `truthyValues`           | `['true', 1]`  | `List<dynamic>` | The values that are acceptable for `true` checks                                                                       | ✅ (With `allowTruthyFalsyValues`) |
| `falsyValues`            | `['false', 0]` | `List<dynamic>` | The values that are acceptable for `false` checks                                                                      | ✅ (With `allowTruthyFalsyValues`) |

### Number

| Property               | Default                   | Type                       | Description                                                         | Sanitizer                                |
| ---------------------- | ------------------------- | -------------------------- | ------------------------------------------------------------------- | ---------------------------------------- |
| `nullable`             | `false`                   | `bool`                     | Whether the value can be null                                       | ❌                                       |
| `treatNullAs`          | `null`                    | `num`                      | What should be returned if there is a null value                    | ✅                                       |
| `allowStringValues`    | `false`                   | `bool`                     | if `true`, allows for numbers as strings and will try to parse them | ✅                                       |
| `integer`              | `false`                   | `bool`                     | Whether number must be an integer                                   | ❌                                       |
| `expected`             | `null`                    | `num`                      | The expected value.                                                 | ❌                                       |
| `notEqualTo`           | `null`                    | `num`                      | The expected value should not be.                                   | ❌                                       |
| `min`                  | `double.negativeInfinity` | `num`                      | The value must be >= min.                                           | ❌                                       |
| `max`                  | `double.infinity`         | `num`                      | The value must be <= max.                                           | ❌                                       |
| `onlyPositive`         | `false`                   | `bool`                     | Whether number must be positive (or 0)                              | ❌                                       |
| `onlyNegative`         | `false`                   | `bool`                     | Whether number must be negative (or 0)                              | ❌                                       |
| `additionalValidators` | `[]`                      | `List<bool Function(num)>` | Additional validators to run                                        | ❌/✅ (Depending on your implementation) |
