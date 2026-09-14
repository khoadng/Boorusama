// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../logging/app_logger.dart';
import '../types/log_data.dart';
import '../types/log_options.dart';
import '../types/log_options_repository.dart';
import 'log_options_notifier.dart';

final appLoggerProvider = Provider<AppLogger>(
  (ref) => throw UnimplementedError(),
);

final debugLogsProvider = Provider<List<LogData>>((ref) {
  final logger = ref.watch(appLoggerProvider);
  void onChanged() => ref.invalidateSelf();
  logger.addListener(onChanged);
  ref.onDispose(() => logger.removeListener(onChanged));
  return logger.logs;
});

final selectedDebugLogCategoryProvider = StateProvider<String?>((ref) => null);

final logOptionsRepositoryProvider = Provider<LogOptionsRepository>(
  (ref) => throw UnimplementedError(),
  name: 'logOptionsRepositoryProvider',
);

final logOptionsProvider = NotifierProvider<LogOptionsNotifier, LogOptions>(
  () => throw UnimplementedError(),
  name: 'logOptionsProvider',
);

final redactSensitiveLogsProvider = Provider<bool>(
  (ref) => ref.watch(
    logOptionsProvider.select(
      (options) => options.redactSensitiveDetails,
    ),
  ),
);
