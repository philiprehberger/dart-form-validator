import 'field_validator.dart';
import 'message_provider.dart';

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
      message ??
          MessageProvider.current.message('required', {}),
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
      message ??
          MessageProvider.current.message('email', {}),
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return _emailRegex.hasMatch(value);
      },
    );
  }

  /// Validates that the value is a valid URL with http or https scheme.
  static FieldValidator url({String? message}) {
    return FieldValidator(
      message ??
          MessageProvider.current.message('url', {}),
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return _urlRegex.hasMatch(value);
      },
    );
  }

  /// Validates that a string value has at least [min] characters.
  static FieldValidator minLength(int min, {String? message}) {
    return FieldValidator(
      message ??
          MessageProvider.current.message('minLength', {'min': min}),
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return value.length >= min;
      },
    );
  }

  /// Validates that a string value has at most [max] characters.
  static FieldValidator maxLength(int max, {String? message}) {
    return FieldValidator(
      message ??
          MessageProvider.current.message('maxLength', {'max': max}),
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return value.length <= max;
      },
    );
  }

  /// Validates that a string value matches the given [regex] pattern.
  static FieldValidator pattern(RegExp regex, {String? message}) {
    return FieldValidator(
      message ??
          MessageProvider.current.message('pattern', {}),
      (value) {
        if (value == null || value is! String || value.isEmpty) return true;
        return regex.hasMatch(value);
      },
    );
  }

  /// Validates that the value is numeric (integer or decimal).
  static FieldValidator numeric({String? message}) {
    return FieldValidator(
      message ??
          MessageProvider.current.message('numeric', {}),
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
      message ??
          MessageProvider.current
              .message('between', {'min': min, 'max': max}),
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
      message ??
          MessageProvider.current
              .message('equals', {'otherField': otherField}),
      otherField,
    );
  }

  /// Validates that the value is one of the [allowed] values.
  static FieldValidator oneOf(List<dynamic> allowed, {String? message}) {
    return FieldValidator(
      message ??
          MessageProvider.current
              .message('oneOf', {'allowed': allowed}),
      (value) {
        if (value == null) return true;
        return allowed.contains(value);
      },
    );
  }

  /// Validates that a numeric value is within the inclusive range [min]..[max].
  static FieldValidator inRange(num min, num max, {String? message}) {
    return FieldValidator(
      message ??
          MessageProvider.current
              .message('inRange', {'min': min, 'max': max}),
      (value) {
        if (value == null) return true;
        final n = value is num ? value : num.tryParse(value.toString());
        if (n == null) return false;
        return n >= min && n <= max;
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

  /// Conditional validator — only applies when [condition] returns true.
  ///
  /// The condition receives the full form data map.
  static FieldValidator when(
    bool Function(Map<String, dynamic> data) condition,
    FieldValidator validator,
  ) {
    return ConditionalValidator(condition, validator);
  }

  /// Passes only if ALL validators pass.
  static FieldValidator all(List<FieldValidator> validators) {
    return FieldValidator(
      'Validation failed',
      (value) => validators.every((v) => v.validate(value) == null),
    );
  }

  /// Passes if ANY validator passes.
  static FieldValidator any(List<FieldValidator> validators, {String? message}) {
    return FieldValidator(
      message ?? 'None of the validations passed',
      (value) => validators.any((v) => v.validate(value) == null),
    );
  }
}

/// A conditional validator that only applies when a condition is met.
///
/// Used by [Rules.when] for conditional field validation based on form data.
class ConditionalValidator extends FieldValidator {
  final bool Function(Map<String, dynamic>) condition;
  final FieldValidator _inner;

  ConditionalValidator(this.condition, this._inner)
      : super(_inner.message, (_) => true);

  @override
  String? validate(dynamic value) => _inner.validate(value);

  /// Check condition against form data. Returns inner validate result if condition met, null otherwise.
  String? validateWithCondition(dynamic value, Map<String, dynamic> data) {
    if (!condition(data)) return null;
    return _inner.validate(value);
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
