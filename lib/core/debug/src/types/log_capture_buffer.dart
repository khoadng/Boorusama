import '../../../../foundation/loggers/logger.dart';

/// A producer retaining captured entries before publishing them.
/// Registered buffers participate synchronously in capture revocation and clear.
abstract interface class LogCaptureBuffer {
  void discardSensitiveDetails();
  void clearAtOrBelow(LogLevel level);
}
