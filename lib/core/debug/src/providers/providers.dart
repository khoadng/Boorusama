// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../logging/app_logger.dart';
import '../types/log_capture_options.dart';
import '../types/log_capture_repository.dart';
import '../types/log_data.dart';
import 'log_capture_options_notifier.dart';

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

final logCaptureRepositoryProvider = Provider<LogCaptureRepository>(
  (ref) => throw UnimplementedError(),
  name: 'logCaptureRepositoryProvider',
);

final logCaptureOptionsProvider =
    NotifierProvider<LogCaptureOptionsNotifier, LogCaptureOptions>(
      () => throw UnimplementedError(),
      name: 'logCaptureOptionsProvider',
    );

final includeSensitiveLogsProvider = Provider<bool>(
  (ref) => ref.watch(
    logCaptureOptionsProvider.select(
      (options) => options.includeSensitiveDetails,
    ),
  ),
);
