# otel_playwright

Dartastic OpenTelemetry bridge for Playwright (browser automation).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_playwright/otel_playwright.dart';

await tracedPlaywright<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return PlaywrightCallResult(value: r, result: PlaywrightResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutPlaywrightInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
