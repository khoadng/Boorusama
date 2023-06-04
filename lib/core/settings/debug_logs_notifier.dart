// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/loggers/loggers.dart';

final uiLoggerProvider = Provider<UILogger>((ref) {
  throw UnimplementedError();
});

final debugLogsProvider = Provider<List<LogData>>((ref) {
  return ref.watch(uiLoggerProvider).logs;
});
