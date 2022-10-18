// Dart imports:
import 'dart:async';

// Package imports:
import 'package:sentry_flutter/sentry_flutter.dart';

const _dns =
    'https://5aebc96ddd7e45d6af7d4e5092884ce3@o1274685.ingest.sentry.io/6469740';

Future<void> runWithSentry(void Function() run) async {
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = _dns
        ..beforeSend = beforeSend
        ..tracesSampleRate = 0.8;
    },
    appRunner: run,
  );
}

FutureOr<SentryEvent?> beforeSend(SentryEvent event, {dynamic hint}) {
  final a = event.exceptions
      ?.map((e) => e.value)
      .where((e) =>
          e != null &&
          e.contains('PlatformException(VideoError, Video player had error'))
      .toList();

  final shouldSend = a != null && a.isEmpty;

  return shouldSend ? event : null;
}
