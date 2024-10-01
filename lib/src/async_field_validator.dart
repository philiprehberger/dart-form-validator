/// An asynchronous validation rule for a field.
///
/// Use for server-side validation like checking username availability.
class AsyncFieldValidator {
  /// Error message returned when validation fails.
  final String message;

  final Future<bool> Function(dynamic value) _validate;

  /// Create an async validator.
  const AsyncFieldValidator(this.message, this._validate);

  /// Run the validation. Returns error message or null if valid.
  Future<String?> validate(dynamic value) async {
    final isValid = await _validate(value);
    return isValid ? null : message;
  }
}
