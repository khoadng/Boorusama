// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import '../types/log_options.dart';
import '../types/log_options_repository.dart';

const _redactSensitiveDetailsKey = 'redact_sensitive_details';

class HiveLogOptionsRepository implements LogOptionsRepository {
  HiveLogOptionsRepository(this._box);

  final Future<Box<bool>> _box;

  @override
  Future<LogOptions> load() async {
    final box = await _box;
    return LogOptions(
      redactSensitiveDetails:
          box.get(
            _redactSensitiveDetailsKey,
            defaultValue: LogOptions.defaults.redactSensitiveDetails,
          ) ??
          LogOptions.defaults.redactSensitiveDetails,
    );
  }

  @override
  Future<void> save(LogOptions options) async {
    final box = await _box;
    await box.put(_redactSensitiveDetailsKey, options.redactSensitiveDetails);
  }
}

LogOptionsRepository createLogOptionsRepository() => HiveLogOptionsRepository(
  Hive.openBox<bool>('log_capture_settings'),
);
