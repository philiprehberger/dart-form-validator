import 'field_validator.dart';

/// Built-in composable validation rules.
///
/// Each static method returns a [FieldValidator] that can be used standalone
/// or combined in a [FormSchema].
class Rules {
  Rules._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  static final _urlRegex = RegExp(
    r'^https?://[^\s/$.?#].[^\s]*$',
    caseSensitive: false,
  );

  static final _numericRegex = RegExp(r'^-?\d+(\.\d+)?$');

  /// Requires the value to be non-null and non-empty (for strings).
  static FieldValidator required({String? message}) {
    return FieldValidator(
      message ?? 'This field is required',
      (value) {
        if (value == null) return false;
        if (value is String) return value.trim().isNotEmpty;
        return true;
      },
    );
  }

  /// Validates that the value is a valid email address.
  static FieldValidator email({String? message}) {
    return FieldValidator(
      message ?? 'Invalid email address',
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return _emailRegex.hasMatch(value);
      },
    );
  }

  /// Validates that the value is a valid URL with http or https scheme.
  static FieldValidator url({String? message}) {
    return FieldValidator(
      message ?? 'Invalid URL',
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return _urlRegex.hasMatch(value);
      },
    );
  }

  /// Validates that a string value has at least [min] characters.
  static FieldValidator minLength(int min, {String? message}) {
    return FieldValidator(
      message ?? 'Must be at least $min characters',
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return value.length >= min;
      },
    );
  }

  /// Validates that a string value has at most [max] characters.
  static FieldValidator maxLength(int max, {String? message}) {
    return FieldValidator(
      message ?? 'Must be at most $max characters',
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return value.length <= max;
      },
    );
  }

  /// Validates that a string value matches the given [regex] pattern.
  static FieldValidator pattern(RegExp regex, {String? message}) {
    return FieldValidator(
      message ?? 'Invalid format',
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return regex.hasMatch(value);
      },
    );
  }

  /// Validates that the value is numeric (integer or decimal).
  static FieldValidator numeric({String? message}) {
    return FieldValidator(
      message ?? 'Must be a number',
      (value) {
        if (value == null) return true;
        if (value is num) return true;
        if (value is String && value.isEmpty) return true;
        if (value is String) return _numericRegex.hasMatch(value);
        return false;
      },
    );
  }

  /// Validates that a numeric value is between [min] and [max] (inclusive).
  static FieldValidator between(num min, num max, {String? message}) {
    return FieldValidator(
      message ?? 'Must be between $min and $max',
      (value) {
        if (value == null) return true;
        final n = value is num ? value : num.tryParse(value.toString());
        if (n == null) return false;
        return n >= min && n <= max;
      },
    );
  }

  /// Validates that the value equals the value of another field.
  ///
  /// This validator is designed for cross-field comparison. When used inside
  /// a [FormSchema], the full form data map is passed to resolve the other
  /// field. When used standalone, it compares against the literal
  /// [otherField] string.
  ///
  /// Typically used for password confirmation fields.
  static FieldValidator equals(String otherField, {String? message}) {
    return CrossFieldValidator(
      message ?? 'Must match $otherField',
      otherField,
    );
  }

  /// Validates that the value is one of the [allowed] values.
  static FieldValidator oneOf(List<dynamic> allowed, {String? message}) {
    return FieldValidator(
      message ?? 'Must be one of: ${allowed.join(', ')}',
      (value) {
        if (value == null) return true;
        return allowed.contains(value);
      },
    );
  }

  /// Creates a validator with a custom validation function.
  static FieldValidator custom(
    bool Function(dynamic) test, {
    required String message,
  }) {
    return FieldValidator(message, test);
  }
}

/// A validator that compares a field's value against another field in the
/// form data.
///
/// Used by [Rules.equals] for cross-field validation such as password
/// confirmation. When used inside a [FormSchema], the schema passes the
/// full form data to [validateWithData].
class CrossFieldValidator extends FieldValidator {
  /// The name of the other field to compare against.
  final String otherFieldName;

  /// Creates a cross-field validator that compares against [otherFieldName].
  CrossFieldValidator(String message, this.otherFieldName)
      : super(message, (v) => true);

  /// Validates by comparing [value] against the value of [otherFieldName]
  /// in [formData].
  String? validateWithData(dynamic value, Map<String, dynamic> formData) {
    final otherValue = formData[otherFieldName];
    return value == otherValue ? null : message;
  }
}
