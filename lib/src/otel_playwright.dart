// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_playwright_suppression.dart';

class PlaywrightResult {
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

class PlaywrightCallResult<T> {
  const PlaywrightCallResult({required this.value, this.result});
  final T value;
  final PlaywrightResult? result;
}

Future<T> tracedPlaywright<T>({
  required String operation,
  required Future<PlaywrightCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (playwrightInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_playwright');
  final span = t.startSpan('playwright $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'playwright')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.browser != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('browser.name', res.browser!)]));
      }
      if (res.browserVersion != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('browser.version', res.browserVersion!)]));
      }
      if (res.contextId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('playwright.context.id', res.contextId!)]));
      }
      if (res.pageId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('playwright.page.id', res.pageId!)]));
      }
      if (res.url != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeString('url.full', res.url!)]));
      }
      if (res.selector != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('playwright.selector', res.selector!)]));
      }
      if (res.testFile != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('test.file', res.testFile!)]));
      }
      if (res.testName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('test.name', res.testName!)]));
      }
      if (res.testCaseId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('test.case.id', res.testCaseId!)]));
      }
      if (res.viewportWidth != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeInt('playwright.viewport.width', res.viewportWidth!)
        ]));
      }
      if (res.viewportHeight != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeInt('playwright.viewport.height', res.viewportHeight!)
        ]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('test.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('playwright.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
