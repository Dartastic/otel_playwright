// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_playwright/otel_playwright.dart';

/// Traces Playwright calls with OpenTelemetry.
///
/// `otel_playwright` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Playwright call in
/// [tracedPlaywright]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'playwright-example');

  // Traces a Playwright call.
  final playwrightId = await tracedPlaywright<String>(
    operation: 'create',
    invoke: () async {
      // Make the Playwright call here, then report what it returned.
      const id = 'playwright_8f3a2c';
      return const PlaywrightCallResult(
          value: id,
          result: PlaywrightResult(
              browser: 'example',
              browserVersion: '1',
              contextId: 'context_8f3a2c',
              pageId: 'page_8f3a2c',
              url: 'https://api.example.com/v1/resource',
              selector: 'example',
              testFile: 'example',
              testName: 'example',
              testCaseId: 'testcase_8f3a2c',
              viewportWidth: 443,
              viewportHeight: 443,
              durationMs: 120,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedPlaywright create returned $playwrightId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutPlaywrightInstrumentationAsync.
  await runWithoutPlaywrightInstrumentationAsync(
    () => tracedPlaywright<String>(
      operation: 'create',
      invoke: () async {
        const id = 'playwright_8f3a2c';
        return const PlaywrightCallResult(
            value: id,
            result: PlaywrightResult(
                browser: 'example',
                browserVersion: '1',
                contextId: 'context_8f3a2c',
                pageId: 'page_8f3a2c',
                url: 'https://api.example.com/v1/resource',
                selector: 'example',
                testFile: 'example',
                testName: 'example',
                testCaseId: 'testcase_8f3a2c',
                viewportWidth: 443,
                viewportHeight: 443,
                durationMs: 120,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
