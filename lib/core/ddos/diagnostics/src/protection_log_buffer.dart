import '../../solver/types.dart';
import '../../../debug/types.dart';
import 'protection_poll_log_buffer.dart';
import '../../../../foundation/loggers/logger.dart';

/// Keeps pre-detection context out of the visible log. Entries have already
/// passed capture/redaction policy, and retain their original timestamps.
class ProtectionLogBuffer implements LogCaptureBuffer {
  static const _maxAttempts = 64;
  static const _maxEntriesPerAttempt = 16;
  final _polls = ProtectionPollLogBuffer();
  final _attempts = <int, _AttemptLog>{};

  List<LogData> accept(ProtectionRecord record, LogData entry) {
    final event = record.event;
    final id = record.scope.attemptId;
    if (event is RecoveryStopped &&
        event.reason == RecoveryStopReason.noDetector) {
      if (id != null) _attempts.remove(id);
      return const [];
    }
    // Session/check events only exist for an actual solver.
    if (id == null) return _polls.accept(record, entry);
    final attempt = _attempts.remove(id) ?? _AttemptLog();
    _attempts[id] = attempt;
    if (_attempts.length > _maxAttempts) _attempts.remove(_attempts.keys.first);

    final publish =
        record.scope.solverId != null ||
        switch (event) {
          DetectorEvaluated(:final score, :final threshold) =>
            score >= threshold,
          ProtectionOperationFailed() => true,
          RecoveryStopped(:final reason) =>
            reason != RecoveryStopReason.disabled,
          _ => false,
        };
    if (attempt.published) return [entry];
    attempt.entries.add(entry);
    if (attempt.entries.length > _maxEntriesPerAttempt) {
      attempt.entries.removeAt(0);
    }
    if (!publish) return const [];
    attempt.published = true;
    final entries = List<LogData>.of(attempt.entries);
    attempt.entries.clear();
    return entries;
  }

  @override
  void discardSensitiveDetails() {
    _polls.discardSensitiveDetails();
    for (final attempt in _attempts.values) {
      for (var i = 0; i < attempt.entries.length; i++) {
        attempt.entries[i] = attempt.entries[i].withoutSensitiveDetails();
      }
    }
  }

  @override
  void clearAtOrBelow(LogLevel level) {
    if (LogLevel.info.priority <= level.priority) _polls.clear();
    for (final attempt in _attempts.values) {
      attempt.entries.removeWhere(
        (entry) => entry.level.priority <= level.priority,
      );
    }
  }
}

class _AttemptLog {
  final entries = <LogData>[];
  var published = false;
}
