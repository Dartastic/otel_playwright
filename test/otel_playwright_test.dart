// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_playwright/otel_playwright.dart';
import 'package:test/test.dart';

void main() {
  group('otel_playwright', () {
    test('suppression toggles in zone', () async {
      expect(playwrightInstrumentationSuppressed(), isFalse);
      await runWithoutPlaywrightInstrumentationAsync(() async {
        expect(playwrightInstrumentationSuppressed(), isTrue);
      });
      expect(playwrightInstrumentationSuppressed(), isFalse);
    });

    test('PlaywrightResult fields default null', () {
      const r = PlaywrightResult();
      expect(r.statusCode, isNull);
    });
  });
}
