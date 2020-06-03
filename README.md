# vali*dart*or

An easy to user and extendable input validator library in pure dart

Inspired by [fastest-validator](https://github.com/icebob/fastest-validator) for nodeJs by [icebob](https://github.com/icebob).

**This repository is still a WIP**

## Roadmap

- [ ] Basic validation rules:
  - [x] boolean
  - [x] dynamic (any value)
  - [x] enum
  - [x] number
  - [x] null
  - [ ] string **WIP**
- [ ] Advanced validation rules:
  - [x] Multi
  - [ ] List **WIP**
  - [ ] Map **WIP**
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
