import '../../../../foundation/loggers/logger.dart';
import '../types/log_capture_options.dart';
import '../types/log_data.dart';
import 'log_formatter.dart';
import '../types/log_capture_buffer.dart';
import 'log_redaction.dart';
import 'package:flutter/foundation.dart';

class AppLogger extends ChangeNotifier implements Logger {
  AppLogger({LogLevel initialLevel = LogLevel.info, this.output})
    : _currentLevel = initialLevel;

  final Logger? output;
  final Map<String, String> _reportContext = {
    'app': 'unknown',
    'platform': defaultTargetPlatform.name,
    'webViewEngineFromUserAgent': 'unknown',
    'networkTransports': 'unknown',
    'vpnRoute': 'unknown',
  };

  Map<String, String> get reportContext => Map.unmodifiable({
    ..._reportContext,
    'sensitiveCapture': '$_includeSensitiveDetails',
  });

  void updateReportContext(Map<String, String> values) {
    for (final entry in values.entries) {
      _reportContext[redactLogMessage(entry.key)] = redactLogMessage(
        entry.value,
      );
    }
  }

  final List<LogData> _logs = [];
  final _captureBuffers = <LogCaptureBuffer>{};
  LogLevel _currentLevel;
  var _includeSensitiveDetails = false;

  bool get includeSensitiveDetails => _includeSensitiveDetails;

  void applyCaptureOptions(LogCaptureOptions options) {
    final value = options.includeSensitiveDetails;
    if (_includeSensitiveDetails == value) return;
    _includeSensitiveDetails = value;
    if (!value) {
      for (final buffer in _captureBuffers) {
        buffer.discardSensitiveDetails();
      }
      for (var i = 0; i < _logs.length; i++) {
        _logs[i] = _logs[i].withoutSensitiveDetails();
      }
    }
    notifyListeners();
  }

  void updateLevel(LogLevel newLevel) => _currentLevel = newLevel;
  LogLevel get currentLevel => _currentLevel;

  @override
  String getDebugName() => 'App Logger';

  void _record(
    LogLevel level,
    String serviceName,
    String message,
    String? sensitiveMessage,
  ) {
    if (!level.shouldLog(_currentLevel)) return;
    _append(_createEntry(level, serviceName, message, sensitiveMessage));
  }

  /// Attaches pending capture to clear/revocation; detach when its owner ends.
  VoidCallback attachCaptureBuffer(LogCaptureBuffer buffer) {
    if (!_captureBuffers.add(buffer)) {
      throw StateError('Capture buffer is already attached');
    }
    if (!_includeSensitiveDetails) buffer.discardSensitiveDetails();
    return () {
      _captureBuffers.remove(buffer);
      buffer.clearAtOrBelow(LogLevel.error);
    };
  }

  /// Applies capture policy now, preserving the observation's timestamp even
  /// when a producer delays publication. Null means the level is disabled.
  LogData? captureEntry(
    String serviceName,
    String message, {
    LogLevel level = LogLevel.info,
    String? sensitiveMessage,
  }) => level.shouldLog(_currentLevel)
      ? _createEntry(level, serviceName, message, sensitiveMessage)
      : null;

  /// Publishes captured entries, enforcing the current policy again.
  void publishEntries(Iterable<LogData> entries) {
    for (final entry in entries) {
      if (!entry.level.shouldLog(_currentLevel)) continue;
      _append(
        LogData(
          dateTime: entry.dateTime,
          serviceName: redactLogMessage(entry.serviceName),
          safeMessage: redactLogMessage(entry.safeMessage),
          sensitiveMessage: _includeSensitiveDetails
              ? entry.sensitiveMessage
              : null,
          level: entry.level,
        ),
      );
    }
  }

  LogData _createEntry(
    LogLevel level,
    String serviceName,
    String message,
    String? sensitiveMessage,
  ) {
    final safe = redactLogMessage(message);
    return LogData(
      dateTime: DateTime.now(),
      serviceName: redactLogMessage(serviceName),
      safeMessage: safe,
      sensitiveMessage: _includeSensitiveDetails
          ? sensitiveMessage ?? (safe != message ? message : null)
          : null,
      level: level,
    );
  }

  void _append(LogData entry) {
    _logs.add(entry);
    output?.log(
      entry.serviceName,
      entry.safeMessage,
      level: entry.level,
      sensitiveMessage: entry.sensitiveMessage,
    );
    notifyListeners();
  }

  @override
  void error(String serviceName, String message, {String? sensitiveMessage}) =>
      _record(LogLevel.error, serviceName, message, sensitiveMessage);

  @override
  void warn(String serviceName, String message, {String? sensitiveMessage}) =>
      _record(LogLevel.warning, serviceName, message, sensitiveMessage);

  @override
  void info(String serviceName, String message, {String? sensitiveMessage}) =>
      _record(LogLevel.info, serviceName, message, sensitiveMessage);

  @override
  void verbose(
    String serviceName,
    String message, {
    String? sensitiveMessage,
  }) => _record(LogLevel.verbose, serviceName, message, sensitiveMessage);

  @override
  void debug(String serviceName, String message, {String? sensitiveMessage}) =>
      _record(LogLevel.debug, serviceName, message, sensitiveMessage);

  List<LogData> get logs => List.unmodifiable(_logs);
  String dump() => formatLogs(logs, context: reportContext);

  void clearLogsAtOrBelow(LogLevel level) {
    for (final buffer in _captureBuffers) {
      buffer.clearAtOrBelow(level);
    }
    _logs.removeWhere((log) => log.level.priority <= level.priority);
    notifyListeners();
  }
}
