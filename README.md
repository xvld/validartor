# vali*dart*or

An easy to user and extendable input validator library in pure dart

Inspired by [fastest-validator](https://github.com/icebob/fastest-validator) for nodeJs by [icebob](https://github.com/icebob).

**This repository is still a WIP**

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
- [ ] Allow creation of schemas for validation
- [ ] 0.1.0
- [ ] Tests and complete coverage
- [ ] Readme and usage
- [ ] Publish 🎉

## Rules

### Boolean

| Property                 | Default        | Type            | Description                                                                                                            | Sanitizer                          |
| ------------------------ | -------------- | --------------- | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------------- |
| `nullable`               | `false`        | `bool`          | Whether the value can be null                                                                                          | ❌                                 |
| `treatNullAsFalse`       | `false`        | `bool`          | Whether null values will be treated as false                                                                           | ✅                                 |
| `allowTruthyFalsyValues` | `false`        | `bool`          | if `true`, allows for truthy and falsy values according to `truthyValues` and `falsyValues` parameters, or the default | ✅                                 |
| `expected`               | `null`         | `bool`          | The expected value.                                                                                                    | ❌                                 |
| `truthyValues`           | `['true', 1]`  | `List<dynamic>` | The values that are acceptable for `true` checks                                                                       | ✅ (With `allowTruthyFalsyValues`) |
| `falsyValues`            | `['false', 0]` | `List<dynamic>` | The values that are acceptable for `false` checks                                                                      | ✅ (With `allowTruthyFalsyValues`) |
