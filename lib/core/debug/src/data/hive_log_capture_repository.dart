import 'package:hive_ce/hive.dart';

import '../types/log_capture_options.dart';
import '../types/log_capture_repository.dart';

const _includeSensitiveDetailsKey = 'include_sensitive_details';

class HiveLogCaptureRepository implements LogCaptureRepository {
  HiveLogCaptureRepository(this._box);

  final Future<Box<bool>> _box;

  @override
  Future<LogCaptureOptions> load() async {
    final box = await _box;
    return LogCaptureOptions(
      includeSensitiveDetails:
          box.get(
            _includeSensitiveDetailsKey,
            defaultValue: LogCaptureOptions.defaults.includeSensitiveDetails,
          ) ??
          LogCaptureOptions.defaults.includeSensitiveDetails,
    );
  }

  @override
  Future<void> save(LogCaptureOptions options) async {
    final box = await _box;
    await box.put(_includeSensitiveDetailsKey, options.includeSensitiveDetails);
  }
}

LogCaptureRepository createLogCaptureRepository() => HiveLogCaptureRepository(
  Hive.openBox<bool>('log_capture_settings'),
);
