# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-05-30

### Added
- `Rules.uuid()` validator for RFC 4122 UUIDs (v1–v5)
- `Rules.alphanumeric()` validator for letter+digit-only fields
- `Rules.notIn()` validator (inverse of `oneOf`) for denylists and reserved values
- `Rules.minWords()` and `Rules.maxWords()` for word-count bounds on free-text fields
- Matching default messages in `DefaultMessageProvider` for all new rules

### Changed
- Reversed barrel files so `lib/philiprehberger_form_validator.dart` is the primary (per pub.dev validation requirement); `lib/form_validator.dart` now re-exports it

## [0.4.0] - 2026-04-02

### Added
- `Rules.date()` validator for date string validation
- `Rules.dateAfter()` and `Rules.dateBefore()` for date range validation
- `Rules.minItems()` and `Rules.maxItems()` for collection size validation
- `FormSchema.fromJson()` now supports `date`, `dateAfter`, `dateBefore`, `minItems`, and `maxItems` descriptors

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
