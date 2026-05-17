// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_aws_ecr/otel_aws_ecr.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_ecr', () {
    test('suppression toggles in zone', () async {
      expect(awsECRInstrumentationSuppressed(), isFalse);
      await runWithoutAwsECRInstrumentationAsync(() async {
        expect(awsECRInstrumentationSuppressed(), isTrue);
      });
      expect(awsECRInstrumentationSuppressed(), isFalse);
    });

    test('AwsECRResult fields default null', () {
      const r = AwsECRResult();
      expect(r.statusCode, isNull);
    });
  });
}
