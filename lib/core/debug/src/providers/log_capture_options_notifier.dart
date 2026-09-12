import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../types/log_capture_options.dart';
import 'providers.dart';

class LogCaptureOptionsNotifier extends Notifier<LogCaptureOptions> {
  LogCaptureOptionsNotifier(this.initialOptions);

  final LogCaptureOptions initialOptions;

  @override
  LogCaptureOptions build() => initialOptions;

  Future<void> setIncludeSensitiveDetails(bool enabled) async {
    final options = state.copyWith(includeSensitiveDetails: enabled);
    await ref.read(logCaptureRepositoryProvider).save(options);
    ref.read(appLoggerProvider).applyCaptureOptions(options);
    state = options;
  }
}
