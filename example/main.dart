// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_ecr/otel_aws_ecr.dart';

/// Traces Aws Ecr calls with OpenTelemetry.
///
/// `otel_aws_ecr` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Ecr call in
/// [tracedAwsECR]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-ecr-example');

  // Traces a Aws Ecr call.
  final awsECRId = await tracedAwsECR<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Ecr call here, then report what it returned.
      const id = 'aws_ecr_8f3a2c';
      return const AwsECRCallResult(
          value: id,
          result: AwsECRResult(
              registryId: 'registry_8f3a2c',
              repository: 'example',
              imageDigest: 'example',
              imageTag: 'example',
              imageSize: 512,
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsECR create returned $awsECRId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsECRInstrumentationAsync.
  await runWithoutAwsECRInstrumentationAsync(
    () => tracedAwsECR<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_ecr_8f3a2c';
        return const AwsECRCallResult(
            value: id,
            result: AwsECRResult(
                registryId: 'registry_8f3a2c',
                repository: 'example',
                imageDigest: 'example',
                imageTag: 'example',
                imageSize: 512,
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
