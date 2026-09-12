import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../types/log_options.dart';
import 'providers.dart';

class LogOptionsNotifier extends Notifier<LogOptions> {
  LogOptionsNotifier(this.initialOptions);

  final LogOptions initialOptions;

  @override
  LogOptions build() => initialOptions;

  Future<void> setRedactSensitiveDetails(bool enabled) async {
    final options = state.copyWith(redactSensitiveDetails: enabled);
    await ref.read(logOptionsRepositoryProvider).save(options);
    ref.read(appLoggerProvider).applyOptions(options);
    state = options;
  }
}
