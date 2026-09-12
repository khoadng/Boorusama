import 'log_options.dart';

abstract interface class LogOptionsRepository {
  Future<LogOptions> load();
  Future<void> save(LogOptions options);
}
