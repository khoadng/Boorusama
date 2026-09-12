import '../../../../foundation/loggers/logger.dart';
import '../types/log_capture_options.dart';
import '../types/log_data.dart';
import 'log_formatter.dart';
import 'log_redaction.dart';
import 'package:flutter/foundation.dart';

class AppLogger extends ChangeNotifier implements Logger {
  AppLogger({LogLevel initialLevel = LogLevel.info, this.output})
    : _currentLevel = initialLevel;

  final Logger? output;
  final List<LogData> _logs = [];
  LogLevel _currentLevel;
  var _includeSensitiveDetails = false;

  bool get includeSensitiveDetails => _includeSensitiveDetails;

  void applyCaptureOptions(LogCaptureOptions options) {
    final value = options.includeSensitiveDetails;
    if (_includeSensitiveDetails == value) return;
    _includeSensitiveDetails = value;
    if (!value) {
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
    final safe = redactLogMessage(message);
    _logs.add(
      LogData(
        dateTime: DateTime.now(),
        serviceName: redactLogMessage(serviceName),
        safeMessage: safe,
        sensitiveMessage: _includeSensitiveDetails
            ? sensitiveMessage ?? (safe != message ? message : null)
            : null,
        level: level,
      ),
    );
    final entry = _logs.last;
    output?.log(
      entry.serviceName,
      entry.safeMessage,
      level: level,
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
  String dump() => formatLogs(logs);

  void clearLogsAtOrBelow(LogLevel level) {
    _logs.removeWhere((log) => log.level.priority <= level.priority);
    notifyListeners();
  }
}
