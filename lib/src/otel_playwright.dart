// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_playwright_suppression.dart';

class PlaywrightResult {
  /// Creates a result.
  const PlaywrightResult({
    this.browser,
    this.browserVersion,
    this.contextId,
    this.pageId,
    this.url,
    this.selector,
    this.testFile,
    this.testName,
    this.testCaseId,
    this.viewportWidth,
    this.viewportHeight,
    this.durationMs,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? browser;
  final String? browserVersion;
  final String? contextId;
  final String? pageId;
  final String? url;
  final String? selector;
  final String? testFile;
  final String? testName;
  final String? testCaseId;
  final int? viewportWidth;
  final int? viewportHeight;
  final int? durationMs;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class PlaywrightCallResult<T> {
  /// Creates a call result.
  const PlaywrightCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final PlaywrightResult? result;
}

Future<T> tracedPlaywright<T>({
  required String operation,
  required Future<PlaywrightCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (playwrightInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_playwright');
  final span = t.startSpan('playwright $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'playwright')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.browser != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('browser.name', res.browser!)]));
      }
      if (res.browserVersion != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('browser.version', res.browserVersion!)]));
      }
      if (res.contextId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('playwright.context.id', res.contextId!)
        ]));
      }
      if (res.pageId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('playwright.page.id', res.pageId!)]));
      }
      if (res.url != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('url.full', res.url!)]));
      }
      if (res.selector != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('playwright.selector', res.selector!)]));
      }
      if (res.testFile != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('test.file', res.testFile!)]));
      }
      if (res.testName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('test.name', res.testName!)]));
      }
      if (res.testCaseId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('test.case.id', res.testCaseId!)]));
      }
      if (res.viewportWidth != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('playwright.viewport.width', res.viewportWidth!)
        ]));
      }
      if (res.viewportHeight != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt(
              'playwright.viewport.height', res.viewportHeight!)
        ]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('test.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('playwright.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'playwright.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
