# philiprehberger_form_validator

[![Tests](https://github.com/philiprehberger/dart-form-validator/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/dart-form-validator/actions/workflows/ci.yml)
[![pub package](https://img.shields.io/pub/v/philiprehberger_form_validator.svg)](https://pub.dev/packages/philiprehberger_form_validator)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/dart-form-validator)](https://github.com/philiprehberger/dart-form-validator/commits/main)

Declarative form validation with composable rules and JSON schemas

## Requirements

- Dart >= 3.5

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  philiprehberger_form_validator: ^0.2.0
```

Then run:

```bash
dart pub get
```

## Usage

```dart
import 'package:philiprehberger_form_validator/form_validator.dart';

final schema = FormSchema({
  'name': [Rules.required(), Rules.minLength(2)],
  'email': [Rules.required(), Rules.email()],
});

final result = schema.validate({
  'name': 'Alice',
  'email': 'alice@example.com',
});

print(result.isValid); // true
```

### Built-in Rules

```dart
Rules.required()
Rules.email()
Rules.url()
Rules.minLength(3)
Rules.maxLength(100)
Rules.pattern(RegExp(r'^\d+$'))
Rules.numeric()
Rules.between(1, 100)
Rules.equals('password')    // cross-field comparison
Rules.oneOf(['a', 'b', 'c'])
Rules.custom((v) => v != null, message: 'Required')
```

### JSON Schema Definition

```dart
final schema = FormSchema.fromJson({
  'email': ['required', 'email'],
  'name': ['required', 'minLength:3', 'maxLength:100'],
  'age': ['numeric', 'between:18,120'],
});
```

### Cross-field Validation

```dart
final schema = FormSchema({
  'password': [Rules.required(), Rules.minLength(8)],
  'confirm': [Rules.required(), Rules.equals('password')],
});

final result = schema.validate({
  'password': 'secret123',
  'confirm': 'secret123',
});
print(result.isValid); // true
```

### Conditional Validation

```dart
final schema = FormSchema({
  'country': [Rules.required()],
  'state': [Rules.when((data) => data['country'] == 'US', Rules.required())],
});

final result = schema.validate({'country': 'US'});
print(result.hasError('state')); // true — required only when country is US
```

### Combining Validators

```dart
// All must pass
final strict = Rules.all([Rules.required(), Rules.minLength(8)]);

// Any can pass
final flexible = Rules.any([Rules.email(), Rules.url()]);
```

### Async Validation

```dart
final schema = FormSchema({'username': [Rules.required()]});

final result = await schema.validateAsync(
  {'username': 'taken'},
  asyncValidators: [
    MapEntry('username', AsyncFieldValidator(
      'Username already taken',
      (value) async => value != 'taken', // e.g. check server
    )),
  ],
);
print(result.isValid); // false
```

### Inspecting Errors

```dart
final result = schema.validate(data);

result.isValid;              // true if no errors
result.hasError('email');    // check specific field
result.errorsFor('email');   // list of error messages
result.allErrors;            // flat list of all errors
result.errorCount;           // total error count
```

## API

| Class | Description |
|-------|-------------|
| `FieldValidator` | Single validation rule with message and test function |
| `Rules` | Static factory methods for built-in validators |
| `FormSchema` | Schema defining validators per field, validates form data maps |
| `FormSchema.fromJson()` | Create schema from JSON-like rule descriptor map |
| `ValidationResult` | Result object with errors, field queries, and counts |
| `CrossFieldValidator` | Validator that compares against another field's value |
| `AsyncFieldValidator` | Async validation rule (e.g. server-side checks) |
| `Rules.when()` | Conditional validator based on form data |
| `Rules.all()` | Composite validator requiring all rules to pass |
| `Rules.any()` | Composite validator requiring any rule to pass |

## Development

```bash
dart pub get
dart analyze --fatal-infos
dart test
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/dart-form-validator)

🐛 [Report issues](https://github.com/philiprehberger/dart-form-validator/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/dart-form-validator/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
