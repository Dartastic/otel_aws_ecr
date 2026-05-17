# otel_aws_ecr

Dartastic OpenTelemetry bridge for AWS ECR (container registry).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_ecr/otel_aws_ecr.dart';

await tracedAwsECR<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsECRCallResult(value: r, result: AwsECRResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsECRInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
