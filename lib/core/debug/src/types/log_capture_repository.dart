import 'log_capture_options.dart';

abstract interface class LogCaptureRepository {
  Future<LogCaptureOptions> load();
  Future<void> save(LogCaptureOptions options);
}
