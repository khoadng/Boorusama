// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/loggers/loggers.dart';

final appLoggerProvider = Provider<AppLogger>((ref) {
  throw UnimplementedError();
});

final debugLogsProvider = Provider<List<LogData>>((ref) {
  return ref.watch(appLoggerProvider).logs;
});
