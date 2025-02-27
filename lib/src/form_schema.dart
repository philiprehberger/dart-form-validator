import 'async_field_validator.dart';
import 'field_validator.dart';
import 'rules.dart';
import 'validation_result.dart';

/// A schema that defines validation rules for a set of form fields.
///
/// Each field name maps to a list of [FieldValidator] instances that are
/// applied in order. All validators run for each field (no short-circuit),
/// so a single field may produce multiple error messages.
class FormSchema {
  final Map<String, List<FieldValidator>> _fields;
  final Map<String, FormSchema> _nestedSchemas;

  /// Creates a schema from a map of field names to validator lists.
  FormSchema(this._fields) : _nestedSchemas = const {};

  /// Creates a schema that also validates nested objects.
  ///
  /// [nestedSchemas] maps a field name to a [FormSchema] that will be used
  /// to validate the nested map stored under that key.
  FormSchema.nested(
    this._fields, {
    Map<String, FormSchema>? nestedSchemas,
  }) : _nestedSchemas = nestedSchemas ?? const {};

  /// Validates a map of form [data] against the schema.
  ///
  /// Returns a [ValidationResult] containing any errors found. Cross-field
  /// validators (e.g., [Rules.equals]) receive the full form data for
  /// comparison.
  ValidationResult validate(Map<String, dynamic> data) {
    final errors = <String, List<String>>{};

    for (final entry in _fields.entries) {
      final fieldName = entry.key;
      final validators = entry.value;
      final value = data[fieldName];
      final fieldErrors = <String>[];

      for (final validator in validators) {
        if (validator is CrossFieldValidator) {
          final error = validator.validateWithData(value, data);
          if (error != null) fieldErrors.add(error);
        } else if (validator is ConditionalValidator) {
          final error = validator.validateWithCondition(value, data);
          if (error != null) fieldErrors.add(error);
        } else {
          final error = validator.validate(value);
          if (error != null) fieldErrors.add(error);
        }
      }

      if (fieldErrors.isNotEmpty) errors[fieldName] = fieldErrors;
    }

    return ValidationResult(errors);
  }

  /// Validates form [data] including nested objects.
  ///
  /// Top-level fields are validated normally. Each key in [_nestedSchemas]
  /// is looked up in [data] — if the value is a [Map], it is validated
  /// recursively and errors are returned with dot-path keys
  /// (e.g., `address.city`). If the value is `null` or not a [Map], a
  /// single error is added for the nested key.
  ValidationResult validateNested(Map<String, dynamic> data) {
    final errors = <String, List<String>>{};

    // Run top-level validation
    final topResult = validate(data);
    errors.addAll(topResult.errors.map(
      (k, v) => MapEntry(k, List<String>.from(v)),
    ));

    // Run nested validation
    for (final entry in _nestedSchemas.entries) {
      final key = entry.key;
      final nestedSchema = entry.value;
      final nestedData = data[key];

      if (nestedData == null || nestedData is! Map<String, dynamic>) {
        errors[key] = ['Must be a valid object'];
        continue;
      }

      final nestedResult = nestedSchema._nestedSchemas.isEmpty
          ? nestedSchema.validate(nestedData)
          : nestedSchema.validateNested(nestedData);

      for (final nestedEntry in nestedResult.errors.entries) {
        errors['$key.${nestedEntry.key}'] = nestedEntry.value;
      }
    }

    return ValidationResult(errors);
  }

  /// Validate with support for async validators.
  ///
  /// Handles both sync [FieldValidator] and [AsyncFieldValidator] rules.
  Future<ValidationResult> validateAsync(
    Map<String, dynamic> data, {
    List<MapEntry<String, AsyncFieldValidator>>? asyncValidators,
  }) async {
    // First run sync validation
    final syncResult = validate(data);
    final errors = Map<String, List<String>>.from(
      syncResult.errors.map((k, v) => MapEntry(k, List<String>.from(v))),
    );

    // Then run async validators
    if (asyncValidators != null) {
      for (final entry in asyncValidators) {
        final error = await entry.value.validate(data[entry.key]);
        if (error != null) {
          errors.putIfAbsent(entry.key, () => []).add(error);
        }
      }
    }

    return ValidationResult(errors);
  }

  /// Returns all field names defined in the schema.
  List<String> get fields => _fields.keys.toList();

  /// Creates a schema from a JSON-like map where values are lists of rule
  /// descriptor strings.
  ///
  /// Supported descriptors:
  /// - `'required'` - field is required
  /// - `'email'` - must be a valid email
  /// - `'url'` - must be a valid URL
  /// - `'numeric'` - must be numeric
  /// - `'minLength:N'` - minimum N characters
  /// - `'maxLength:N'` - maximum N characters
  /// - `'between:N,M'` - numeric value between N and M
  /// - `'pattern:REGEX'` - must match regex pattern
  /// - `'oneOf:a,b,c'` - must be one of the listed values
  /// - `'equals:fieldName'` - must match another field's value
  ///
  /// Example:
  /// ```dart
  /// final schema = FormSchema.fromJson({
  ///   'email': ['required', 'email'],
  ///   'name': ['required', 'minLength:3'],
  ///   'age': ['numeric', 'between:18,120'],
  /// });
  /// ```
  factory FormSchema.fromJson(Map<String, List<String>> json) {
    final fields = <String, List<FieldValidator>>{};

    for (final entry in json.entries) {
      final validators = <FieldValidator>[];

      for (final descriptor in entry.value) {
        validators.add(_parseDescriptor(descriptor));
      }

      fields[entry.key] = validators;
    }

    return FormSchema(fields);
  }

  static FieldValidator _parseDescriptor(String descriptor) {
    final colonIndex = descriptor.indexOf(':');

    if (colonIndex == -1) {
      switch (descriptor) {
        case 'required':
          return Rules.required();
        case 'email':
          return Rules.email();
        case 'url':
          return Rules.url();
        case 'numeric':
          return Rules.numeric();
        default:
          throw ArgumentError('Unknown rule descriptor: $descriptor');
      }
    }

    final name = descriptor.substring(0, colonIndex);
    final param = descriptor.substring(colonIndex + 1);

    switch (name) {
      case 'minLength':
        return Rules.minLength(int.parse(param));
      case 'maxLength':
        return Rules.maxLength(int.parse(param));
      case 'between':
        final parts = param.split(',');
        return Rules.between(num.parse(parts[0]), num.parse(parts[1]));
      case 'pattern':
        return Rules.pattern(RegExp(param));
      case 'oneOf':
        return Rules.oneOf(param.split(','));
      case 'equals':
        return Rules.equals(param);
      default:
        throw ArgumentError('Unknown rule descriptor: $descriptor');
    }
  }
}
