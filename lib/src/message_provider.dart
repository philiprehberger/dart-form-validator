/// Provides localizable error messages for validation rules.
///
/// Implement this class to supply custom translations. Use
/// [MessageProvider.setProvider] to install a custom provider globally.
abstract class MessageProvider {
  static MessageProvider? _current;

  /// Returns the active provider, falling back to [DefaultMessageProvider].
  static MessageProvider get current => _current ?? DefaultMessageProvider();

  /// Installs a custom [provider] for all validation messages.
  static void setProvider(MessageProvider provider) {
    _current = provider;
  }

  /// Resets to the built-in [DefaultMessageProvider].
  static void resetProvider() {
    _current = null;
  }

  /// Returns the error message for the given [ruleKey].
  ///
  /// The [params] map contains rule-specific values such as `min`, `max`,
  /// or `allowed` that can be interpolated into the message.
  String message(String ruleKey, Map<String, dynamic> params);
}

/// Default English message provider.
///
/// Supports rule keys: `required`, `email`, `url`, `minLength`, `maxLength`,
/// `pattern`, `numeric`, `between`, `equals`, `oneOf`, `inRange`, `date`,
/// `dateAfter`, `dateBefore`, `minItems`, and `maxItems`.
class DefaultMessageProvider extends MessageProvider {
  @override
  String message(String ruleKey, Map<String, dynamic> params) {
    switch (ruleKey) {
      case 'required':
        return 'This field is required';
      case 'email':
        return 'Invalid email address';
      case 'url':
        return 'Invalid URL';
      case 'minLength':
        return 'Must be at least ${params['min']} characters';
      case 'maxLength':
        return 'Must be at most ${params['max']} characters';
      case 'pattern':
        return 'Invalid format';
      case 'numeric':
        return 'Must be a number';
      case 'between':
        return 'Must be between ${params['min']} and ${params['max']}';
      case 'equals':
        return 'Must match ${params['otherField']}';
      case 'oneOf':
        return 'Must be one of: ${(params['allowed'] as List).join(', ')}';
      case 'inRange':
        return 'Must be between ${params['min']} and ${params['max']}';
      case 'date':
        return 'Must be a valid date';
      case 'dateAfter':
        return 'Must be on or after ${params['min']}';
      case 'dateBefore':
        return 'Must be on or before ${params['max']}';
      case 'minItems':
        return 'Must have at least ${params['min']} items';
      case 'maxItems':
        return 'Must have at most ${params['max']} items';
      default:
        return 'Validation failed';
    }
  }
}
