// Dart imports:
import 'dart:developer' as developer;

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'console.dart';
import 'logger.dart';

class ConsoleLoggerOptions extends Equatable {
  const ConsoleLoggerOptions({
    required this.decodeUriParameters,
  });

  const ConsoleLoggerOptions.defaults() : decodeUriParameters = false;

  final bool decodeUriParameters;

  @override
  List<Object?> get props => [
    decodeUriParameters,
  ];
}

class ConsoleLogger extends Logger {
  ConsoleLogger({
    required this.options,
  });

  final ConsoleLoggerOptions options;

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd, hh:mm:ss').format(dateTime);
  }

  String _composeMessage(String serviceName, String message, String color) {
    final msg = options.decodeUriParameters
        ? tryDecodeFullUri(message).getOrElse(() => message)
        : message;

    final time = colorize(_formatDateTime(DateTime.now()), yellow);
    final service = colorize(serviceName, magenta);
    final m = colorize(msg, color);

    return '$time -> $service -> $m';
  }

  @override
  String getDebugName() => 'Console Logger';

  @override
  void info(String serviceName, String message) {
    developer.log(_composeMessage(serviceName, message, blue));
  }

  @override
  void warn(String serviceName, String message) {
    developer.log(_composeMessage(serviceName, message, yellow));
  }

  @override
  void error(String serviceName, String message) {
    developer.log(_composeMessage(serviceName, message, red));
  }

  @override
  void verbose(String serviceName, String message) {
    developer.log(_composeMessage(serviceName, message, cyan));
  }

  @override
  void debug(String serviceName, String message) {
    developer.log(_composeMessage(serviceName, message, green));
  }
}
