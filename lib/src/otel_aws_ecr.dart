// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_ecr_suppression.dart';

class AwsECRResult {
  const AwsECRResult({
    this.registryId,
    this.repository,
    this.imageDigest,
    this.imageTag,
    this.imageSize,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? registryId;
  final String? repository;
  final String? imageDigest;
  final String? imageTag;
  final int? imageSize;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class AwsECRCallResult<T> {
  const AwsECRCallResult({required this.value, this.result});
  final T value;
  final AwsECRResult? result;
}

Future<T> tracedAwsECR<T>({
  required String operation,
  required Future<AwsECRCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsECRInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_ecr');
  final span = t.startSpan('ecr $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'aws-api');
    span.setStringAttribute('rpc.service', 'ECR');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.registryId != null) {
        span.setStringAttribute('aws.ecr.registry.id', res.registryId!);
      }
      if (res.repository != null) {
        span.setStringAttribute('aws.ecr.repository', res.repository!);
      }
      if (res.imageDigest != null) {
        span.setStringAttribute('container.image.id', res.imageDigest!);
      }
      if (res.imageTag != null) {
        span.setStringAttribute('container.image.tag', res.imageTag!);
      }
      if (res.imageSize != null) {
        span.setIntAttribute('container.image.size', res.imageSize!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('ecr.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'ecr.error',
        );
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
