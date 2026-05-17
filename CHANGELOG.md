# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedPlaywright<T>(...)` — wraps a otel_playwright call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutPlaywrightInstrumentation()` / `Async()`.
