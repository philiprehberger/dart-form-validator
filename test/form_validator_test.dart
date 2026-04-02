import 'package:philiprehberger_form_validator/form_validator.dart';
import 'package:test/test.dart';

void main() {
  group('Rules.required', () {
    final rule = Rules.required();

    test('fails for null', () {
      expect(rule.validate(null), isNotNull);
    });

    test('fails for empty string', () {
      expect(rule.validate(''), isNotNull);
    });

    test('fails for whitespace-only string', () {
      expect(rule.validate('   '), isNotNull);
    });

    test('passes for non-empty string', () {
      expect(rule.validate('hello'), isNull);
    });

    test('passes for non-null value', () {
      expect(rule.validate(42), isNull);
    });
  });

  group('Rules.email', () {
    final rule = Rules.email();

    test('passes for valid email', () {
      expect(rule.validate('user@example.com'), isNull);
    });

    test('fails for invalid email', () {
      expect(rule.validate('not-an-email'), isNotNull);
    });

    test('passes for empty string (not required)', () {
      expect(rule.validate(''), isNull);
    });

    test('passes for null (not required)', () {
      expect(rule.validate(null), isNull);
    });
  });

  group('Rules.url', () {
    final rule = Rules.url();

    test('passes for valid http URL', () {
      expect(rule.validate('http://example.com'), isNull);
    });

    test('passes for valid https URL', () {
      expect(rule.validate('https://example.com/path'), isNull);
    });

    test('fails for URL without scheme', () {
      expect(rule.validate('example.com'), isNotNull);
    });

    test('passes for null', () {
      expect(rule.validate(null), isNull);
    });
  });

  group('Rules.minLength', () {
    final rule = Rules.minLength(3);

    test('fails for short string', () {
      expect(rule.validate('ab'), isNotNull);
    });

    test('passes for exact length', () {
      expect(rule.validate('abc'), isNull);
    });

    test('passes for longer string', () {
      expect(rule.validate('abcde'), isNull);
    });

    test('passes for null', () {
      expect(rule.validate(null), isNull);
    });
  });

  group('Rules.maxLength', () {
    final rule = Rules.maxLength(5);

    test('passes for short string', () {
      expect(rule.validate('abc'), isNull);
    });

    test('passes for exact length', () {
      expect(rule.validate('abcde'), isNull);
    });

    test('fails for long string', () {
      expect(rule.validate('abcdef'), isNotNull);
    });
  });

  group('Rules.numeric', () {
    final rule = Rules.numeric();

    test('passes for integer string', () {
      expect(rule.validate('42'), isNull);
    });

    test('passes for decimal string', () {
      expect(rule.validate('3.14'), isNull);
    });

    test('passes for negative number string', () {
      expect(rule.validate('-7'), isNull);
    });

    test('fails for non-numeric string', () {
      expect(rule.validate('abc'), isNotNull);
    });

    test('passes for num type', () {
      expect(rule.validate(42), isNull);
    });

    test('passes for null', () {
      expect(rule.validate(null), isNull);
    });
  });

  group('Rules.between', () {
    final rule = Rules.between(1, 10);

    test('passes for value in range', () {
      expect(rule.validate('5'), isNull);
    });

    test('passes for min boundary', () {
      expect(rule.validate('1'), isNull);
    });

    test('passes for max boundary', () {
      expect(rule.validate('10'), isNull);
    });

    test('fails for value below range', () {
      expect(rule.validate('0'), isNotNull);
    });

    test('fails for value above range', () {
      expect(rule.validate('11'), isNotNull);
    });

    test('fails for non-numeric value', () {
      expect(rule.validate('abc'), isNotNull);
    });
  });

  group('Rules.oneOf', () {
    final rule = Rules.oneOf(['red', 'green', 'blue']);

    test('passes for allowed value', () {
      expect(rule.validate('red'), isNull);
    });

    test('fails for disallowed value', () {
      expect(rule.validate('yellow'), isNotNull);
    });

    test('passes for null', () {
      expect(rule.validate(null), isNull);
    });
  });

  group('Rules.pattern', () {
    final rule = Rules.pattern(RegExp(r'^\d{3}-\d{4}$'));

    test('passes for matching pattern', () {
      expect(rule.validate('123-4567'), isNull);
    });

    test('fails for non-matching pattern', () {
      expect(rule.validate('12-34'), isNotNull);
    });
  });

  group('Rules.custom', () {
    final rule = Rules.custom(
      (value) => value is String && value.startsWith('X'),
      message: 'Must start with X',
    );

    test('passes when condition is met', () {
      expect(rule.validate('X-ray'), isNull);
    });

    test('fails when condition is not met', () {
      expect(rule.validate('Alpha'), isNotNull);
    });
  });

  group('Rules.equals', () {
    test('returns CrossFieldValidator', () {
      final rule = Rules.equals('password');
      expect(rule, isA<CrossFieldValidator>());
    });
  });

  group('FieldValidator', () {
    test('returns null when valid', () {
      final v = FieldValidator('error', (value) => value == 'ok');
      expect(v.validate('ok'), isNull);
    });

    test('returns message when invalid', () {
      final v = FieldValidator('bad value', (value) => value == 'ok');
      expect(v.validate('nope'), equals('bad value'));
    });
  });

  group('ValidationResult', () {
    test('isValid is true when no errors', () {
      const result = ValidationResult({});
      expect(result.isValid, isTrue);
    });

    test('isValid is false when errors exist', () {
      const result = ValidationResult({
        'name': ['Required'],
      });
      expect(result.isValid, isFalse);
    });

    test('hasError returns true for field with errors', () {
      const result = ValidationResult({
        'email': ['Invalid email'],
      });
      expect(result.hasError('email'), isTrue);
      expect(result.hasError('name'), isFalse);
    });

    test('errorsFor returns errors for specific field', () {
      const result = ValidationResult({
        'name': ['Required', 'Too short'],
      });
      expect(result.errorsFor('name'), equals(['Required', 'Too short']));
    });

    test('errorsFor returns empty list for valid field', () {
      const result = ValidationResult({});
      expect(result.errorsFor('name'), isEmpty);
    });

    test('allErrors returns flat list of all errors', () {
      const result = ValidationResult({
        'name': ['Required'],
        'email': ['Invalid email', 'Too short'],
      });
      expect(result.allErrors, hasLength(3));
    });

    test('errorCount returns total number of errors', () {
      const result = ValidationResult({
        'name': ['Required'],
        'email': ['Invalid'],
      });
      expect(result.errorCount, equals(2));
    });
  });

  group('FormSchema', () {
    test('validates multiple fields', () {
      final schema = FormSchema({
        'name': [Rules.required(), Rules.minLength(2)],
        'email': [Rules.required(), Rules.email()],
      });

      final result = schema.validate({'name': '', 'email': 'bad'});
      expect(result.isValid, isFalse);
      expect(result.hasError('name'), isTrue);
      expect(result.hasError('email'), isTrue);
    });

    test('returns valid for correct data', () {
      final schema = FormSchema({
        'name': [Rules.required(), Rules.minLength(2)],
        'email': [Rules.required(), Rules.email()],
      });

      final result = schema.validate({
        'name': 'Alice',
        'email': 'alice@example.com',
      });
      expect(result.isValid, isTrue);
    });

    test('handles cross-field equals validation', () {
      final schema = FormSchema({
        'password': [Rules.required()],
        'confirm': [Rules.required(), Rules.equals('password')],
      });

      final fail = schema.validate({
        'password': 'secret',
        'confirm': 'wrong',
      });
      expect(fail.hasError('confirm'), isTrue);

      final pass = schema.validate({
        'password': 'secret',
        'confirm': 'secret',
      });
      expect(pass.isValid, isTrue);
    });

    test('collects multiple errors per field', () {
      final schema = FormSchema({
        'name': [Rules.required(), Rules.minLength(5), Rules.maxLength(3)],
      });

      final result = schema.validate({'name': ''});
      // Required fails, minLength and maxLength skip empty values
      expect(result.errorsFor('name'), hasLength(1));
    });

    test('fields returns all field names', () {
      final schema = FormSchema({
        'name': [Rules.required()],
        'email': [Rules.email()],
      });
      expect(schema.fields, containsAll(['name', 'email']));
    });
  });

  group('FormSchema.fromJson', () {
    test('parses required rule', () {
      final schema = FormSchema.fromJson({
        'name': ['required'],
      });
      final result = schema.validate({'name': null});
      expect(result.hasError('name'), isTrue);
    });

    test('parses email rule', () {
      final schema = FormSchema.fromJson({
        'email': ['email'],
      });
      final result = schema.validate({'email': 'bad'});
      expect(result.hasError('email'), isTrue);
    });

    test('parses minLength rule', () {
      final schema = FormSchema.fromJson({
        'name': ['minLength:3'],
      });
      final result = schema.validate({'name': 'ab'});
      expect(result.hasError('name'), isTrue);
    });

    test('parses maxLength rule', () {
      final schema = FormSchema.fromJson({
        'name': ['maxLength:3'],
      });
      final result = schema.validate({'name': 'abcd'});
      expect(result.hasError('name'), isTrue);
    });

    test('parses between rule', () {
      final schema = FormSchema.fromJson({
        'age': ['between:18,65'],
      });
      final result = schema.validate({'age': '10'});
      expect(result.hasError('age'), isTrue);
    });

    test('parses numeric rule', () {
      final schema = FormSchema.fromJson({
        'count': ['numeric'],
      });
      final result = schema.validate({'count': 'abc'});
      expect(result.hasError('count'), isTrue);
    });

    test('parses url rule', () {
      final schema = FormSchema.fromJson({
        'site': ['url'],
      });
      final result = schema.validate({'site': 'not-a-url'});
      expect(result.hasError('site'), isTrue);
    });

    test('parses equals rule', () {
      final schema = FormSchema.fromJson({
        'password': ['required'],
        'confirm': ['equals:password'],
      });
      final result = schema.validate({
        'password': 'abc',
        'confirm': 'xyz',
      });
      expect(result.hasError('confirm'), isTrue);
    });

    test('parses oneOf rule', () {
      final schema = FormSchema.fromJson({
        'color': ['oneOf:red,green,blue'],
      });
      final result = schema.validate({'color': 'yellow'});
      expect(result.hasError('color'), isTrue);
    });

    test('parses pattern rule', () {
      final schema = FormSchema.fromJson({
        'code': [r'pattern:^\d{3}$'],
      });
      final result = schema.validate({'code': 'ab'});
      expect(result.hasError('code'), isTrue);
    });

    test('throws for unknown descriptor', () {
      expect(
        () => FormSchema.fromJson({
          'x': ['unknown'],
        }),
        throwsArgumentError,
      );
    });

    test('parses multiple rules for a field', () {
      final schema = FormSchema.fromJson({
        'email': ['required', 'email'],
      });
      final result = schema.validate({'email': null});
      expect(result.errorsFor('email'), hasLength(1));
    });
  });

  group('Custom error messages', () {
    test('required accepts custom message', () {
      final rule = Rules.required(message: 'Name is required');
      expect(rule.validate(null), equals('Name is required'));
    });

    test('email accepts custom message', () {
      final rule = Rules.email(message: 'Enter valid email');
      expect(rule.validate('bad'), equals('Enter valid email'));
    });
  });
}
