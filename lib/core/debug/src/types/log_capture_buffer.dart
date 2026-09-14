// Project imports:
import '../../../../foundation/loggers/logger.dart';

/// A producer retaining captured entries before publishing them.
/// Registered buffers participate synchronously in log clearing.
abstract interface class LogCaptureBuffer {
  void clearAtOrBelow(LogLevel level);
}
