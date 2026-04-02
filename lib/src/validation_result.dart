/// The result of validating form data against a schema.
///
/// Contains a map of field names to their error messages. An empty errors
/// map means all validation passed.
class ValidationResult {
  /// Map of field names to their list of error messages.
  final Map<String, List<String>> errors;

  /// Creates a validation result with the given [errors].
  const ValidationResult(this.errors);

  /// Returns `true` if there are no validation errors.
  bool get isValid => errors.isEmpty;

  /// Returns `true` if the given [field] has at least one error.
  bool hasError(String field) => errors.containsKey(field);

  /// Returns the list of error messages for the given [field].
  ///
  /// Returns an empty list if the field has no errors.
  List<String> errorsFor(String field) => errors[field] ?? [];

  /// Returns all error messages across all fields as a flat list.
  List<String> get allErrors => errors.values.expand((e) => e).toList();

  /// Returns the total number of validation errors across all fields.
  int get errorCount => allErrors.length;

  @override
  String toString() {
    if (isValid) return 'ValidationResult(valid)';
    return 'ValidationResult($errors)';
  }
}
