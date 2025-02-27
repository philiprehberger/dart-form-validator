import 'package:philiprehberger_form_validator/form_validator.dart';

void main() {
  // --- Schema with composable rules ---
  final schema = FormSchema({
    'name': [Rules.required(), Rules.minLength(2), Rules.maxLength(50)],
    'email': [Rules.required(), Rules.email()],
    'age': [Rules.required(), Rules.numeric(), Rules.between(18, 120)],
    'website': [Rules.url()],
    'role': [Rules.oneOf(['admin', 'user', 'guest'])],
    'password': [Rules.required(), Rules.minLength(8)],
    'confirm': [Rules.required(), Rules.equals('password')],
  });

  // Valid data
  final validData = {
    'name': 'Alice',
    'email': 'alice@example.com',
    'age': '30',
    'website': 'https://alice.dev',
    'role': 'admin',
    'password': 'secret123',
    'confirm': 'secret123',
  };

  final validResult = schema.validate(validData);
  print('Valid: ${validResult.isValid}'); // true

  // Invalid data
  final invalidData = {
    'name': '',
    'email': 'not-an-email',
    'age': '200',
    'website': 'bad-url',
    'role': 'superadmin',
    'password': 'short',
    'confirm': 'mismatch',
  };

  final invalidResult = schema.validate(invalidData);
  print('Valid: ${invalidResult.isValid}'); // false
  print('Error count: ${invalidResult.errorCount}');

  for (final field in schema.fields) {
    if (invalidResult.hasError(field)) {
      print('$field: ${invalidResult.errorsFor(field)}');
    }
  }

  // --- JSON schema definition ---
  final jsonSchema = FormSchema.fromJson({
    'email': ['required', 'email'],
    'name': ['required', 'minLength:3', 'maxLength:100'],
    'age': ['numeric', 'between:18,120'],
    'code': [r'pattern:^\d{4}$'],
  });

  final jsonResult = jsonSchema.validate({
    'email': 'bob@example.com',
    'name': 'Bob',
    'age': '25',
    'code': '1234',
  });
  print('\nJSON schema valid: ${jsonResult.isValid}'); // true

  // --- Standalone rule usage ---
  final emailRule = Rules.email();
  print('\nEmail check: ${emailRule.validate('test@example.com')}'); // null
  print('Email check: ${emailRule.validate('invalid')}'); // error message

  // --- Custom rule ---
  final noSpaces = Rules.custom(
    (value) => value is String && !value.contains(' '),
    message: 'Must not contain spaces',
  );
  print('\nCustom rule: ${noSpaces.validate('hello')}'); // null
  print('Custom rule: ${noSpaces.validate('hello world')}'); // error

  // --- Nested object validation ---
  final nestedSchema = FormSchema.nested(
    {
      'name': [Rules.required()],
    },
    nestedSchemas: {
      'address': FormSchema({
        'city': [Rules.required()],
        'zip': [Rules.required(), Rules.pattern(RegExp(r'^\d{5}$'))],
      }),
    },
  );

  final nestedResult = nestedSchema.validateNested({
    'name': 'Alice',
    'address': {'city': '', 'zip': 'bad'},
  });
  print('\nNested valid: ${nestedResult.isValid}'); // false
  print('address.city errors: ${nestedResult.errorsFor('address.city')}');
  print('address.zip errors: ${nestedResult.errorsFor('address.zip')}');

  // Extract nested sub-result
  final addressErrors = nestedResult.nested('address');
  print('Address error count: ${addressErrors.errorCount}');
}
