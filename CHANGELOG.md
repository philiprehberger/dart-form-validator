# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-04-02

### Added
- `MessageProvider` for localizable error messages
- `DefaultMessageProvider` with English defaults
- `Rules.inRange()` for inclusive range validation
- `FormSchema.nested()` for validating nested objects
- `FormSchema.validateNested()` returns dot-path error keys
- `ValidationResult.nested()` extracts errors for a nested prefix

## [0.2.0] - 2026-04-01

### Added
- `AsyncFieldValidator` class for asynchronous validation (e.g. server-side checks)
- `FormSchema.validateAsync` method supporting both sync and async validators
- `Rules.when` for conditional validation based on form data
- `Rules.all` composite validator requiring all rules to pass
- `Rules.any` composite validator requiring any rule to pass

## [0.1.0] - 2026-04-01

### Added
- Initial release
- `FieldValidator` class for single-field validation rules
- `Rules` class with built-in composable validators: required, email, url, minLength, maxLength, pattern, numeric, between, equals, oneOf, custom
- `FormSchema` for defining multi-field validation schemas
- `FormSchema.fromJson` for JSON-based schema definitions
- `ValidationResult` with isValid, hasError, errorsFor, allErrors, errorCount
- Cross-field validation support via `Rules.equals`
- Zero dependencies, pure Dart
