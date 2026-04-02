/// A single validation rule for a field.
class FieldValidator {
  /// The error message returned when validation fails.
  final String message;

  final bool Function(dynamic value) _validate;

  /// Creates a validator with the given error [message] and validation
  /// function.
  ///
  /// The validation function should return `true` when the value is valid
  /// and `false` when invalid.
  const FieldValidator(this.message, this._validate);

  /// Runs the validation against [value].
  ///
  /// Returns the error message if validation fails, or `null` if the value
  /// is valid.
  String? validate(dynamic value) => _validate(value) ? null : message;
}
