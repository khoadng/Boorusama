// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/loggers.dart';

export 'data_io.dart';

final debugLogsProvider = Provider<List<LogData>>((ref) {
  return ref.watch(appLoggerProvider).logs;
});

final selectedDebugLogCategoryProvider = StateProvider<String?>((ref) => null);
