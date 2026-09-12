import '../../../../foundation/loggers/logger.dart';
import '../types/log_options.dart';
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
    'sensitiveDetailsRedacted': '$_redactSensitiveDetails',
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
  var _redactSensitiveDetails = false;

  void applyOptions(LogOptions options) {
    if (_redactSensitiveDetails == options.redactSensitiveDetails) return;
    _redactSensitiveDetails = options.redactSensitiveDetails;
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

  /// Attaches pending capture to log clearing; detach when its owner ends.
  VoidCallback attachCaptureBuffer(LogCaptureBuffer buffer) {
    if (!_captureBuffers.add(buffer)) {
      throw StateError('Capture buffer is already attached');
    }
    return () {
      _captureBuffers.remove(buffer);
      buffer.clearAtOrBelow(LogLevel.error);
    };
  }

  /// Captures details now, preserving the observation's timestamp even
  /// when a producer delays publication. Null means the level is disabled.
  LogData? captureEntry(
    String serviceName,
    String message, {
    LogLevel level = LogLevel.info,
    String? sensitiveMessage,
  }) => level.shouldLog(_currentLevel)
      ? _createEntry(level, serviceName, message, sensitiveMessage)
      : null;

  /// Publishes captured entries without losing their original details.
  void publishEntries(Iterable<LogData> entries) {
    for (final entry in entries) {
      if (!entry.level.shouldLog(_currentLevel)) continue;
      _append(
        LogData(
          dateTime: entry.dateTime,
          serviceName: redactLogMessage(entry.serviceName),
          safeMessage: redactLogMessage(entry.safeMessage),
          sensitiveMessage: entry.sensitiveMessage,
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
      sensitiveMessage: sensitiveMessage ?? (safe != message ? message : null),
      level: level,
    );
  }

  void _append(LogData entry) {
    _logs.add(entry);
    output?.log(
      entry.serviceName,
      entry.safeMessage,
      level: entry.level,
      sensitiveMessage: _redactSensitiveDetails ? null : entry.sensitiveMessage,
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

  List<LogData> get logs => List.unmodifiable(
    _redactSensitiveDetails
        ? _logs.map((entry) => entry.withoutSensitiveDetails())
        : _logs,
  );
  String dump() => formatLogs(logs, context: reportContext);

  void clearLogsAtOrBelow(LogLevel level) {
    for (final buffer in _captureBuffers) {
      buffer.clearAtOrBelow(level);
    }
    _logs.removeWhere((log) => log.level.priority <= level.priority);
    notifyListeners();
  }
}
